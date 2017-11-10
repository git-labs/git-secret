#!/usr/bin/env bash

# shellcheck disable=2016
AWK_ADD_TO_GITIGNORE='
BEGIN { cnt=0; }
{
  print $0
  if ( $0 == pattern ) cnt++;
}
ENDFILE { if ( cnt == 0) print pattern; }
'

function gitignore_add_pattern {
  local pattern
  local gitignore_file_path

  pattern="$1"
  gitignore_file_path=$(_append_root_path '.gitignore')

  _maybe_create_gitignore
  gawk -i inplace -v pattern="$pattern" "$AWK_ADD_TO_GITIGNORE" "$gitignore_file_path"
}

function init {
  OPTIND=1

  while getopts 'h' opt; do
    case "$opt" in
      h) _show_manual_for 'init';;
    esac
  done

  shift $((OPTIND-1))
  [ "$1" = '--' ] && shift

  # Check if '.gitsecret/' already exists:
  local git_secret_dir
  git_secret_dir=$(_get_secrets_dir)

  if [[ -d "$git_secret_dir" ]]; then
    _abort 'already inited.'
  fi

  # Check if it is ignored:
  _secrets_dir_is_not_ignored

  # Create internal files:

  mkdir "$git_secret_dir" "$(_get_secrets_dir_keys)" "$(_get_secrets_dir_path)"
  touch "$(_get_secrets_dir_keys_mapping)" "$(_get_secrets_dir_paths_mapping)"

  echo "'$git_secret_dir/' created."

  local random_seed_file
  random_seed_file=".gitsecret/keys/random_seed"
  gitignore_add_pattern "$random_seed_file"

  # TODO: git attributes to view diffs
}