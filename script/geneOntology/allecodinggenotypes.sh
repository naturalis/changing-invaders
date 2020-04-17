#!/bin/bash
# changing invaders
# a script to save all genotypes of all coding (CNS)SNPs in coding.gt
# this is possibly usefull for a MCA
#
# het from the annotated file with only the CNSSNPs, the bases and the sample genotypes (other sample information will
# be removed later) format the bases to a comma seperated list. Remove the header lines (except for the sample header)
# show the header from the second field (the fisrt field is not a samplename, but REF,ALT) and display the genotypes
# in bases where homozygote genotypes (A/A) are simplified to a single base (A)
# replace now from the samplenames the last pat so only the short, first part remains
# and save that in coding.gt
cut -d$'\t' -f4,5,10- merge8.ann.vcf|sed -e 's/:[^\t]*//g' -e 's/\t/,/'|egrep -v '^#'|awk '{if (NR==1){$1="";print substr($0, 2)}else{a=$1;split(a,b,",");for(i=2;i<=NF;i++) { split($i, c, "/");if (b[c[1]+1]==b[c[2]+1])printf b[c[2]+1]"\t"; else printf b[c[1]+1]"/"b[c[2]+1]"\t" }print ""}}'|sed '1s/_[^\t ]*./\t/g' > coding.gt
