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


#### tag

Should be called as part of `notmuch new` script. Tags new messages based on
classification.


## How it works

Each category is binary, a message is either part of the category or not. When
learning a category, we create two dbacl categories, "category" and
"not_category". Then when classifying messages, dbacl classifies against these
two categories. This is based on the dbacl [spam
tutorial](http://dbacl.sourceforge.net/spamtut-1.html) which does the same.
