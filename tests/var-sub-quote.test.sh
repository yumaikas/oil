#!/bin/bash
# 
# Tests for the args in:
#
# ${foo:-}
#
# I think the weird single quote behavior is a bug, but everyone agrees.  It's
# a consequence of quote removal.
#
# WEIRD: single quoted default, inside double quotes.  Oh I guess this is
# because double quotes don't treat single quotes as special?
#
# OK here is the issue.  If we have ${} bare, then the default is parsed as
# LexState.OUTER.  If we have "${}", then it's parsed as LexState.DQ.  That
# makes sense I guess.  Vim's syntax highlighting is throwing me off.

### :-
empty=''
argv.py ${empty:-a} ${Unset:-b}
# stdout: ['a', 'b']

### -
empty=''
argv.py ${empty-a} ${Unset-b}
# empty one is still elided!
# stdout: ['b']

### Inner single quotes
argv.py ${Unset:-'b'}
# stdout: ['b']

### Inner single quotes, outer double quotes
# This is the WEIRD ONE.  Single quotes appear outside.  But all shells agree!
argv.py "${Unset:-'b'}"
# stdout: ["'b'"]

### Inner double quotes
argv.py ${Unset:-"b"}
# stdout: ['b']

### Inner double quotes, outer double quotes
argv.py "${Unset-"b"}"
# stdout: ['b']

### Multiple words: no quotes
argv.py ${Unset:-a b c}
# stdout: ['a', 'b', 'c']

### Multiple words: no outer quotes, inner single quotes
argv.py ${Unset:-'a b c'}
# stdout: ['a b c']

### Multiple words: no outer quotes, inner double quotes
argv.py ${Unset:-"a b c"}
# stdout: ['a b c']

### Multiple words: outer double quotes, no inner quotes
argv.py "${Unset:-a b c}"
# stdout: ['a b c']

### Multiple words: outer double quotes, inner double quotes
argv.py "${Unset:-"a b c"}"
# stdout: ['a b c']

### Multiple words: outer double quotes, inner single quotes
argv.py "${Unset:-'a b c'}"
# WEIRD ONE.
# stdout: ["'a b c'"]


### Var with multiple words: no quotes
var='a b c'
argv.py ${Unset:-$var}
# stdout: ['a', 'b', 'c']

### Multiple words: no outer quotes, inner single quotes
var='a b c'
argv.py ${Unset:-'$var'}
# stdout: ['$var']

### Multiple words: no outer quotes, inner double quotes
var='a b c'
argv.py ${Unset:-"$var"}
# stdout: ['a b c']

### Multiple words: outer double quotes, no inner quotes
var='a b c'
argv.py "${Unset:-$var}"
# stdout: ['a b c']

### Multiple words: outer double quotes, inner double quotes
var='a b c'
argv.py "${Unset:-"$var"}"
# stdout: ['a b c']

### Multiple words: outer double quotes, inner single quotes
# WEIRD ONE.
#
# I think I should just disallow any word with single quotes inside double
# quotes.
var='a b c'
argv.py "${Unset:-'$var'}"
# stdout: ["'a b c'"]



### No outer quotes, Multiple internal quotes
# It's like a single command word.  Parts are joined directly.
var='a b c'
argv.py ${Unset:-A$var " $var"D E F}
# stdout: ['Aa', 'b', 'c', ' a b cD', 'E', 'F']



### Strip a string with single quotes, unquoted
foo="'a b c d'"
argv.py ${foo%d\'}
# stdout: ["'a", 'b', 'c']

### Strip a string with single quotes, double quoted
foo="'a b c d'"
argv.py "${foo%d\'}"
# stdout: ["'a b c "]

### Strip a string with single quotes, double quoted, with unescaped '
# We're in a double quoted context, so we should be able to use a regular
# single quote.  This is very much the case with :-.
foo="'a b c d'"
argv.py "${foo%d'}"
# stdout: ["'a b c "]
# BUG bash/mksh stdout-json: ""

### The string to strip is space sensitive
foo='a b c d'
argv.py "${foo%c d}" "${foo%c  d}"
# stdout: ['a b ', 'a b c d']

### The string to strip can be single quoted, outer is double quoted
foo='a b c d'
argv.py "${foo%'c d'}" "${foo%'c  d'}"
# stdout: ['a b ', 'a b c d']
# BUG dash stdout: ['a b c d', 'a b c d']

### The string to strip can be single quoted, outer is unquoted
foo='a b c d'
argv.py ${foo%'c d'} ${foo%'c  d'}
# stdout: ['a', 'b', 'a', 'b', 'c', 'd']
