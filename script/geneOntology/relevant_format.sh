#!/bin/bash
# changing invaders
# catchy format
# by david
input="${1:-complete_ng.tsv}"
output="${2:-${input/%.tsv/_ontology.tsv}}"
if [ ! -e "$input" ] && echo "The input file ($input) does not exist. Please modify the filename." && exit
while read line;do
 # for every SNP line in the file do the following
 chrpos="$(cut -d$'\t' -f1<<<"$line"|sed -e 's/...//' -e 's/_/\t/')"
 # extract gene annotation information (if it exist)
 both="$(grep "$chrpos" ../gen*-o*/merge8.ann.vcf|cut -d$'\t' -f8|tr ';' '\n'|grep ANN)"
 gene_name="$(cut -d'|' -f5 <<< "$both")"
 # the potential impact of the mutation (if available)
 priority="$(cut -d'|' -f3 <<< "$both")"
 # if the gene_name is not "", fill in the information for the output, else give default values
 if test "$gene_name" = "";then
  GO_term_name=
  GO_term_id=
 else
  GO_term_name="$(grep "$gene_name" ../gen*-o*/GO_BIO*S_ALL.csv|cut -d, -f2|tr \\n \||xargs echo|tr \| \\n|sed 's/.$//'|tr \\n \||sed 's/|*$//')"
  GO_term_id="$(egrep -i "\"($GO_term_name)\"" ../gen*-o*/go-term*.csv|cut -d, -f1|xargs echo|tr ' ' \|)"
 fi
 # output the line with more information
 echo "$line" | sed 's/\t/\t'$chrpos'\t'"$gene_name"'\t'"$priority"'\t'"$GO_term_name"'\t'"$GO_term_id"'\t/'
done < "$input" > "$output"
