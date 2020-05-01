# reads to variants

This folder contains all the scripts that are used to the moment that usefull variant files are generated.

As a first step there is trimmed on the DNA reads(and bad quality ones are removed) (fastp.pl), then the reads are mapped to *R. norvegicus*(minimap2.pl), whereafter reads are combined to files that contain all the mapped reads of one organism(bam_merge.sh). Then the samplenames are equalized a single file(equal_sample_name.sh). Then the reads in the files are sorted on chromosome (and (first)position within) (bam_sort.sh) and indexed (bam_index.sh). Then the files are used to call SNP variants (bcf_call.sh). And eventually the different samples are combined to one(bcf_merge.sh).

Most scripts in this folder work by the slurm system and do not themself run what they say they do, but execute a job that does so, and then exit. Also most scripts in this folder do need as argument the samplename without filename extension. Notice that this does not nessisarily is the case for ALL scripts here, just a general rule.
![flowchart](../../doc/flowchart/readsToVariants.png?raw=true)
