# notmuch-dbacl

Scripts to classify notmuch mail using the dbacl Bayesian text classifier.

## Usage

### Prerequisites

- [notmuch](https://notmuchmail.org/)
- [dbacl](http://dbacl.sourceforge.net/)


### Basics

First, tag some messages for a new category. For example, let's tag some
messages as "important".

Next, learn a new "important" category and specify the query for these messages.

    $ ./notmuch-dbacl.sh learn important tag:important

This creates two dbacl category files in `DBACL_PATH` (`~/.notmuch_dbacl`).

Now you can test it by piping in a single message.

    $ notmuch show --format=raw -- $(notmuch search --limit 1 --output=messages -- tag:inbox) | ./notmuch-dbacl.sh classify important

This should print "important" or "not_important".


### Tagging script

An example tagging script for notmuch new. This should be called after you sync
your email e.g. as an offlineimap hook.

```bash
#!/bin/bash

set -o errexit
set -o pipefail

# Add new messages to the notmuch database
notmuch new

# Tag new messages based on dbacl classification
notmuch-dbacl.sh tag important

# Remove the new tag and add your defaults.
notmuch tag +unread +inbox -new -- tag:new
```


### Commands

#### learn

Learn a category. This should be run regularly (weekly).

These options are passed to `dbacl`.

`-h size`

`-H gsize`


#### classify

Reads a message from stdin and classifies the message.


#### tag

Should be called as part of `notmuch new` script. Tags new messages based on
classification.


## How it works

Each category is binary, a message is either part of the category or not. When
learning a category, we create two dbacl categories, "category" and
"not_category". Then when classifying messages, dbacl classifies against these
two categories. This is based on the dbacl [spam
tutorial](http://dbacl.sourceforge.net/spamtut-1.html) which does the same.


## Troubleshooting

```
$ notmuch-dbacl.sh learn important tag:important
Learning category important ... ok
Learning negative category important ... dbacl:warning: table full, some tokens
ignored - try with option -h 16
ok
```

This is normal. Specify `-h` and `-H` for dbacl to allocate additional memory.
`-h` is the size to start and `-H` is the maximum size to which it will grow.

_TODO: allow -x passthru to dbacl for really really large mailboxes to allow
random sampling._
