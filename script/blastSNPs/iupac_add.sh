#!/bin/bash
# changing invaders
# naturalis
# script to add iupac codes to fasta sequences
build_regex() {
# this function builds a regex
# every argument is a nucleotide, and every nucleotide should at least once occur in the searched string
# the searched string could not contain other characters than the nucleotide
# the regex is a Perl compatible regex that could be used in grep (so grep -P)
 for nucleotide in "$@";do
  regex="$regex(?=(.*$nucleotide))"
 done
 echo "^$regex[$(echo $*|tr -d ' ')]+$"
}

iupac() {
 # this function makes the code look nicer
 # the idea is that one writes something like:
 # `iupac code for T, C and G is B` # $(iupac ...) might work as well
 # so the nucleotides are combined with ,'s
 # and the word and is added
 # so this code removes both
 # and only starts reading from the 3rd argument
 # (since first probably are 'code for')
 # the code prints a command that will set the variable iupac if the variable
 # listofbases comply to the iupac constrains
 # this is not directly executed because in that case, the iupac variable is not accessible
 # outside this function, eval is used to make sure that the string will be evaluated as bash and not
 # see it as raw arguments
 shift 2;nucleotides=
 while test $# -gt 2;do
  test "and" != $1 && nucleotides="$nucleotides ${1/,/}";shift
 done
 echo 'eval grep -Pq "$(build_regex '"$nucleotides"')" <<< "${listofbases//\//}" && [ -z "$iupac" ] && iupac='$2
}
sqlite3 data/eight.db 'SELECT CHROMOSOME, POSITION, GENOTYPE_BP, ORGANISM, REFERENCE FROM EXULANS ORDER BY CHROMOSOME, POSITION'| \
 while read line;do
  echo "$line"
  chromosome_position=$(cut -d'|' -f1,2<<<"$line")
  if test "$chromosome_position_old" != "$chromosome_position";then
  buffer="${buffer:1}" # the first character is always a newline
   # echo "BUFF:$buffer:BUFF"
   number=$(echo "$buffer"|wc -l)
   listofbases=
   # this currently does not make sense since the base is already reference
   if test $number != 8;then
    # add reference
    listofbases="$(head -1 <<< "$buffer" | cut -d'|' -f5)"
   fi
   listofbases="$(head -1 <<< "$buffer" | cut -d'|' -f5)"
   listofbases="$listofbases$(cut -d'|' -f3 <<< "$buffer"|sed -E 's!(.)/\1!\1!'|tr -d \\n)"
   iupac=
   # all 4
   `iupac code for A, T, C and G is N`
   # combinations of 3
   `iupac code for T, C and G is B`
   `iupac code for A, T and G is D`
   `iupac code for A, T and C is H`
   `iupac code for A, C and G is V`
   # combinations of 2
   `iupac code for A and G is R`
   `iupac code for C and T is Y`
   `iupac code for G and C is S`
   `iupac code for A and T is W`
   `iupac code for G and T is K`
   `iupac code for A and C is M`
#    # single nucleotides
   `iupac code for A is A`
   `iupac code for T is T`
   `iupac code for G is G`
   `iupac code for C is C`
   # place the code on the right base
   echo iupac: $iupac
   # use the buffer
   buffer= # make the buffer empty
  fi
  buffer="$buffer"$'\n'"$line"
  chromosome_position_old=$chromosome_position
 done
echo "$buffer"
echo "$buffer"|wc -l
