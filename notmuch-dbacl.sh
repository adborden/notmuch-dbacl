#!/bin/bash

set -o errexit
set -o pipefail
#set -x

export DBACL_PATH=${DBACL_PATH:-~/.notmuch_dbacl}

DBACL_CLASSIFIER=${DBACL_CLASSIFIER:-email}

# TODO use `notmuch config get new.tags` and parse into query
NOTMUCH_NEW_QUERY="tag:new"


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
  dbacl_classify "$@"
}

function dbacl_classify () {
  local category
  category=$1

  # dbacl returns non-zero exit codes on success. We wrap it so it doesn't
  # cause errexit to trigger, unless there is an actual error (zero exit code).
  #
  # dbacl reads the email from stdin and prints the category.
  #
  # Note: order of categories is important. When categories have an equal
  # score, first category takes precedence. That means if the scores are equal
  # for category and not_category, we should make the determination of
  # not_category.
  ! dbacl -v -T "$DBACL_CLASSIFIER" -c "not_$category" -c "$category"
}

function tag () {
  local category classification id
  category=$1

  for id in $(notmuch search --output=messages -- $NOTMUCH_NEW_QUERY); do
    classification=$(notmuch show --format=raw -- "$id" | dbacl_classify "$category")
    if [[ "$classification" == "$category" ]]; then
      notmuch tag +"$category" -- "$id"
    fi
  done
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

  tag <category>
    Tags new messages based on classification.

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
  tag)
    shift
    tag "$@"
    ;;
  reset)
    reset
    ;;
  *)
    usage
    exit 1
esac
