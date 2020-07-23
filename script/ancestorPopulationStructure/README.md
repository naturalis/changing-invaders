# population structure

To calculate the population structure, and display it, use these scripts.
Bcf files are needed, that will be converted to bed files, then either pruned to correct for linkage equibrilium or directly inputed to **fastSTRUCTURE/ADMIXTURE**, whereafter the data can be shown as a barplot, or as a map. *(The latter does not always displays exact circle diagrams when working with small proportions.)*
Please note that population estimate programs (*almost always*) work by the user inputing the number of ancestor populations it expected. This number is called *K*. If one does not know or suspect the number of ancestor populations, generally the program is runned for all values *K* = from 2 to (number of samples/current populations-1). Afterwards the results contain cross-validation errors(for ADMIXTURE) or Marginal Likelihood which can be used to determine, the best value of *K*, of course in cooperation with personal analysis of the results.
See also the flowchart:
![flowchart](../../doc/flowchart/ancestorPopulationStructure.png?raw=true)

# scripts arguments/input
- thin_marker.sh:
  - the (bed) file (without extension) that should be pruned. (output will be filename.pruned.bed) (defaults __merge3__)
- faststructure.sh:
  1. the sample file (without extension) (defaults to __merge3__)
  2. number of ancestor populations (defaults to __4__)
  3. seed (number to feed the random generator, to obtain reproducable results) (defaults to __469__)
  4. number of threads to use (defaults to __1__)
- combined2FoCaPSNPs:
  - Input is a combined vcf file from stdin, that is filtered and output on stdout
- bcf2bed.sh:
  - the bcf file (without extension) to be converted to a bed file (output will include filename.bed) (defaults __merge3__)
- ancestor_map.R:
  - the arguments are the .Q files that describe the admixture proportions (output filename-map.png) (defaults __all *K* that the latest .Q file refers to__)
- ancestor_barplot.R:
  - like ancestor_map.R (output {admixture/faststructure}{rest of file name}.png) (defaults __like ancestor\_map.R__)
- admixture.sh:
  1. the sample file (without extension) (defaults to __merge3__)
  2. number of ancestor populations (defaults to __4__)
  3. runs (number number of runs of bootstrapping and cross validation) (defaults to __10__)
  4. seed (number to feed the random generator, to obtain reproducable results) (defaults to __469__)
  5. number of threads to use (defaults to __1__)
