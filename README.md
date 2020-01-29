# notmuch-dbacl

Scripts to classify notmuch mail using the dbacl Bayesian text classifier.

## Usage

### Prerequisites

- [notmuch](https://notmuchmail.org/)
- [dbacl](http://dbacl.sourceforge.net/)
- getopt (util-linux)

### Commands

#### learn

Learn a category. This should be run regularly (weekly).

These options are passed to `dbacl`.

`-h size`

`-H gsize`


#### classify

Reads a message from stdin and classifies the message.
