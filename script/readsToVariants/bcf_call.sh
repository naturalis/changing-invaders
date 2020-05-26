#!/bin/bash
# changing invaders
# by david
# bcf calling by the use of slurm (default 8+1 cores)
# callwith `./bcf_call.sh [possible sample name] [number of threads(-1)]`
[ $# -gt 0 ] && sample=$1 || sample=GMI-4_41656
[ $# -gt 1 ] && threads=$2 || threads=8
# obtain the reference genome, if it is exported using 'export REF' in bash, use that file
# if not, check if it can find a file called files.yml, this is looked up in the directory of this
# script and two directories higher in data/files.yml (as it is structured in github)
# if one of these locations has the file, use the path in that file, else use a hard coded path
[ "$REF" = "" ] && {
 [ -e "$(dirname "$0")/files.yml" ] && yaml="$(dirname "$0")/files.yml"
 [ -e "$(dirname "$0")/../../data/files.yml" ] && yaml="$(dirname "$0")/../../data/files.yml"
 [ "" != "$yaml" ] && REF="$(grep -Po '(?<=filtered: ).*' "$yaml")" || REF="$HOME/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa"
}
if [ "$sample*.bam" = "$(echo "$sample"*.bam)" ];then
 sbatch -D $PWD -c $((threads+1))<<< '#!/bin/bash
#SBATCH --job-name=bcf-"'"$sample"'"
# --max-depth default is used, if not working reducing to something lower
#SBATCH --output="'"$sample"'".bcf.out
bcftools mpileup -I -Ou -f "'"$REF"'" "'"$sample"'"*.bam | bcftools call --threads '$threads' --skip-variants indels -mv -Ob  -P 1.1e-4 -o "'"$sample"'".bcf
$HOME/telegramhowto.R "Variants of '"$sample"' are called (using bcf)."'
else
 echo "$sample*.bam" does not exist.
fi
