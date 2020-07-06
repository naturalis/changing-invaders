# reads to variants

This folder contains all the scripts that are used to the moment that useful variant files are generated.

As a first step there is trimmed on the DNA reads(and bad quality ones are removed) (fastp.pl), then the reads are mapped to *R. norvegicus*(minimap2.pl), whereafter reads are combined to files that contain all the mapped reads of one organism(bam_merge.sh). Then the samplenames are equalized a single file(equal_sample_name.sh). Then the reads in the files are sorted on chromosome (and (first)position within) (bam_sort.sh) and indexed (bam_index.sh). Then the files are used to call SNP variants (bcf_call.sh). And eventually the different samples are combined to one(bcf_merge.sh).

Most scripts in this folder work by the slurm system and do not themself run what they say they do, but execute a job that does so, and then exit. Also most scripts in this folder do need as argument the samplename without filename extension. Notice that this does not nessisarily is the case for ALL scripts here, just a general rule.
![flowchart](../../doc/flowchart/readsToVariants.png?raw=true)

# scripts arguments/input
- bam_index.sh:
  - the input argument is the sample(without extension) as a bam file, that will be indexed (by default **GMI-4_41656**)
- bam_merge.sh:
  - the input is always the files in the /home/rutger.vos/fileserver/projects/B1900*/Samples/ directory
- bam_sort.sh:
  - the input argument is the sample(without extension) as a bam file, that will be indexed (by default **GMI-4_41656**) the output is *sample*.sort.bam
- bcf_call.sh:
  - the reference genome is used if the location is available:
    1. in the REF environment variable
    2. in the file files.yml in the directory the script is located (defaults __110__)
    3. in the file data/files.yml in the directory the script is located, but moving two folders up (where it is in github)
    4. at last in the directory REF as file Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa in the home directory of the current user
  - the arguments given are:
    1. the sample(without extension) as a bam file, that will be used for calling (by default **GMI-4_41656**)
    2. the number of threads (by default **8**)
  - the output is *sample*.bcf
- bcf_merge.sh:
  - the input is, if two arguments are given, the first argument is used as the directory where these samples are. If only one argument is given it is a filter over the bcf files in the working directory that should be matched. (defaults to __all but merge bcf samples__)
  - the output is a file called merge*number*.bcf where *number* is the sum of merge*number* numbers and the number of other samples.
- equal_sample_name.sh:
  - the input is always the bam samples in ../r\*.v\*/fileserver/projects/B19005-525/Samples/\* the output files are same as input files, but with the equal sample names.
- fasta_index.sh:
  - the input argument is the sample(without extension) as a fasta file, that will be indexed (by default **GMI-4_41656**)
- fastp.pl:
  - the argument is the YAML configuration as --files
  - the output is in files *sample*.html,  *sample*.json,  *sample*.log, where *sample* is the samplename without lanes and runs and *sample.fastp.fastq.gz* where the samplename only lacks the extension. This for every sample described in the YAML file.
- minimap2.pl:
  - the imput parameters are not positional but named:
    - reference, for the reference genome (defaults __the Rnor_6.0-filtered entry of the YAML configuration__)
    - threads, for the number of threads used (defaults __4__)
    - yaml, for the YAML configuration file (no default)
    - verbose, for the leven of verbosity (defaults __warnings__)
    - outdir, directory where to write the bam files (no default)
    - index, whether to index the reference genome (no default)
    - workdir, directory to do the analysis (defaults to __the tmp directory in the home directory__)
  - the output are the merged sample files as bam (*sample*.bam + *sample*.rg)
