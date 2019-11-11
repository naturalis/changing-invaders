#!/bin/bash
function ProgressBar {
# Process data
let _progress=$(((${1}*1000/${2}*1000)/1000))
let _done=$(((${_progress}*16)/100))
let _left=$((160-$_done))
# Build progressbar string lengths
_fill=$(printf "%${_done}s")
_empty=$(printf "%${_left}s")
_progress=$(sed 's/.$/.&/'<<<${_progress})
printf "[${_fill// /\#}${_empty// /-}] ${_progress}%%\n"
}
ls /home/d*n*/gatk*/.queue/scatterGather/haplotypeCaller-1-sg/temp_*_of_16/*.sort.g.vcf.gz.out |xargs -L1 tail -1|sed -E 's/ +/ /g'|cut -d' ' -f11|sed 's/[%\\.]//g'|while read number;do ProgressBar ${number} 1000;done
echo cat\(round\($(bcftools view GMI-4_41656.bcf|tail -1|sed -E 's/[ \t]+/ /g'|cut -d' ' -f2)/2719000000 \* 100, 2\), \"%\",sep=\'\'\)\;cat\(\'\\n\'\)|R --slave
