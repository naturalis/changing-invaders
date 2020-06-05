#!/bin/bash
# changing invaders
# naturalis
# script to add iupac codes to fasta sequences
# this script will only work if the fasta is sorted on chromosome and position
# also it currently assumes that chromosomes are a number so X/Y will gives errors
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
 echo 'eval grep -Pq \"$(build_regex '"$nucleotides"')\" <<< "${listofbases//\//}" && [ -z "$iupac" ] && iupac='$2';'
}
SILENT=${SILENT:-true} # if silent is not defined turn it off
fasta="$(cat data/filtered_snps.fasta)"
sqlite3 data/eight.db 'SELECT CHROMOSOME, POSITION, GENOTYPE_BP, ORGANISM, REFERENCE FROM EXULANS ORDER BY CHROMOSOME, POSITION'| \
 while read line;do
  chromosome_position=$(cut -d'|' -f1,2<<<"$line")
  if test "$chromosome_position_old" != "$chromosome_position" -a -n "$chromosome_position_old";then
   buffer="${buffer:1}" # the first character is always a newline
   number=$(echo "$buffer"|wc -l)
   listofbases=
   # this currently does not make sense since the base is already reference
   if test $number != 8;then
    # add reference
    listofbases="$(head -1 <<< "$buffer" | cut -d'|' -f5)"
   fi
   # listofbases="$(head -1 <<< "$buffer" | cut -d'|' -f5)"
   listofbases="$listofbases$(cut -d'|' -f3 <<< "$buffer"|sed -E 's!(.)/\1!\1!'|tr -d \\n)"
   iupac= #nothing yet
   # all 4
   `iupac code for A, T, C and G is N
   # combinations of 3
   iupac code for T, C and G is B
   iupac code for A, T and G is D
   iupac code for A, T and C is H
   iupac code for A, C and G is V
   # combinations of 2
   iupac code for A and G is R
   iupac code for C and T is Y
   iupac code for G and C is S
   iupac code for A and T is W
   iupac code for G and T is K
   iupac code for A and C is M
   # single nucleotides
   iupac code for A is A
   iupac code for T is T
   iupac code for G is G
   iupac code for C is C`
   # place the code on the right base
   keep_going=true;declare -i record_number=1
   record_max=$(grep '>' <<< "$fasta"|uniq|wc -l)
   while $keep_going;do
    # echo "fasta:$(grep '>' <<< "$fasta"|uniq|wc -l), rn:$record_number"
    record=$(grep '>' <<< "$fasta"|uniq|sed -n "$record_number"s/\>//p)
    # echo -n "$record\___$record_number"
    chromosome_fasta=$(cut -d, -f1 <<< "$record")
    position_fasta=$(cut -d, -f2 <<< "$record"|cut -d- -f1)
    chromosome_variants=$(head -1 <<< "$buffer"|cut -d'|' -f1)
    position_variants=$(head -1 <<< "$buffer"|cut -d'|' -f2)
    # check the current fasta record
    if test $chromosome_fasta -lt $chromosome_variants;then
     # save output (4 rows because single line fasta, two > because append)
     head -4 <<<"$fasta" >> data/filtered_snps_iupac.fasta
     # five because sed is 1 based, ~ because from there 1 because skip 0 between lines, and p for printing
     fasta="$(sed -n 5~1p <<<"$fasta")"
     record_max=$(grep '>' <<< "$fasta"|uniq|wc -l)
     # echo "line$(head -4 <<< "$fasta")eol"
     # minus 1 because of the removal of the first (since they are ordered)
     record_number+=-1
    else
     if test $chromosome_fasta -eq $chromosome_variants;then
      if test $position_variants -lt $((position_fasta + 250)) -a $position_variants -gt $((position_fasta - 250)) -a $position_variants -ne $position_fasta;then
       # if it is the SNP, then it shouldn't be incorporated
       if test $position_fasta -gt $position_variants;then
        # if the fasta position is larger then the position as recorded in variants, then the second sequence should be modified
        $SILENT || echo "variant:$(head -1 <<< "$buffer"), iupac edit:$iupac, fasta record $record"
        fasta="$(sed -E $(((record_number-1)*4+2))"s/.(.{$(($position_fasta-($position_variants-1)))})$/$iupac\1/" <<<"$fasta")"
       else
        # if the fasta position is smaller then the position as recorded in variants, then the first sequence should be modified
        $SILENT || echo "variant:$(head -1 <<< "$buffer"), iupac edit:$iupac, fasta record $record"
        fasta="$(sed -E $(((record_number-1)*4+4))"s/(.{$(($position_variants-($position_fasta-1)))})./$iupac\1/" <<<"$fasta")"
       fi
      fi
     else
      test $chromosome_fasta -gt $chromosome_variants && keep_going=false
     fi
    fi
    record_number+=1
    test $record_number -gt $record_max && keep_going=false
   done
   # use the buffer
   buffer= # make the buffer empty
  fi
  buffer="$buffer"$'\n'"$line"
  chromosome_position_old=$chromosome_position
 done
echo "$fasta" >> data/filtered_snps_iupac.fasta
