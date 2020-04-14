# poulation structure

To calculate the population structure, and display it, use these scripts.
Bcf files are needed, that will be converted to bed files, then either pruned to correct for linkage equibrilium or directly inputed to **fastSTRUCTURE/ADMIXTURE**, whereafter the data can be shown as a barplot, or as a map. *(The latter does not always displays exact circle diagrams when working with small proportions.)*
Please note that population estimate programs (*almost always*) work by the user inputing the number of ancestor populations it expected. This number is called *K*. If one does not know or suspect the number of ancestor populations, generally the program is runned for all values *K* = from 2 to (number of samples/current populations-1). Afterwards the results contain cross-validation errors(for ADMIXTURE) or Marginal Likelihood which can be used to determine, the best value of *K*, of course in cooperation with personal analysis of the results.
See also the flowchart:
https://raw.githubusercontent.com/naturalis/changing-invaders/master/anchestorPopulationStructure/flowchart.png
