#!/bin/bash

set -o errexit
set -o pipefail
#set -x

export DBACL_PATH=${DBACL_PATH:-~/.notmuch_dbacl}

DBACL_CLASSIFIER=${DBACL_CLASSIFIER:-email}

function learn () {
  local category query
  category=$1
  shift
  query="$@"

  # Ensure category directory exists
  mkdir -p "$DBACL_PATH"

  flags=
  if [[ -n "$gsize" ]]; then
    flags="$flags -H $gsize"
  fi

  if [[ -n "$size" ]]; then
    flags="$flags -h $size"
  fi

  # Learn the category
  echo -n "Learning category $category ... "
  notmuch show --format=mbox -- "$query" | dbacl -T "$DBACL_CLASSIFIER" $flags -l "$category"
  echo ok

  # Learn the negative category
  echo -n "Learning negative category $category ... "
  notmuch show --format=mbox -- not "($query)" | dbacl -T "$DBACL_CLASSIFIER" $flags -l "not_$category"
  echo ok
}

function classify () {
  local category flags
  category=$1

  # Reads stdin
  dbacl -T "$DBACL_CLASSIFIER" $flags -c "$category" -c "not_$category" -v
}

function reset () {
  :
}

function usage () {
  cat <<EOF >&2
Usage: $(basename $0) [-h <size>] <command> <args>

Commands:
  learn <category> <query>...
    Learns the category using the notmuch query.

  classify <category>
    Reads an email from stdin and classifies it against the category.

EOF
}

# Parse flags
while getopts H:h: flag; do
  case "$flag" in
    H)
      gsize=$OPTARG
      ;;
    h)
      size=$OPTARG
      ;;
    ?)
      usage
      exit 1
      ;;
  esac
done

# Remove flags from arguments
shift $(($OPTIND - 1))

case "$1" in
  learn)
    shift
    learn "$@"
    ;;
  classify)
    shift
    classify "$@"
    ;;
  reset)
    reset
    ;;
  *)
    usage
    exit 1
esac
