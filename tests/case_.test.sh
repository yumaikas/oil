#!/bin/bash
#
# Test the case statement

### Case statement
case a in
  a) echo A ;;
  *) echo star ;;
esac
# stdout: A

### Case statement with ;;&
# ;;& keeps testing conditions
# NOTE: ;& and ;;& are bash 4 only, no on Mac
case a in
  a) echo A ;;&
  *) echo star ;;&
  *) echo star2 ;;
esac
# stdout-json: "A\nstar\nstar2\n"
# N-I dash stdout-json: ""

### Case statement with ;&
# ;& ignores the next condition.  Why would that be useful?
case a in
  a) echo A ;&
  XX) echo two ;&
  YY) echo three ;;
esac
# stdout-json: "A\ntwo\nthree\n"
# N-I dash stdout-json: ""

### Case with empty condition
case $empty in
  ''|foo) echo match ;;
  *) echo no ;;
esac
# stdout: match
