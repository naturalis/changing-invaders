![flowchart](../../doc/flowchart/makeDatabases_rowbased.png?raw=true)

# scripts arguments/input
- make_snp.sql:
  - contains the table definition
- fill_upos.sql:
  - contains upos creation SQL command
- add_bcf.sql:
  - contains organism insertion SQL command (using stdin)
- edit_snp.py:
  - argument is the organism number
  - rest of input is the vcf file by stdin
  - stdout is the table for the datbase
- make_snp_db.sh:
  1. the directory where to find the samples (defaults to globbing od /home/r\*.v\*/f\*/projects/B1900\*/Samples/)
  2. pattern to match for used samples (default samples are the expansion __{/data/d\*.n\*/L0235_41658,/home/d\*.n\*/sample-files/{C0910_41662,GMI-4_41656,L0234_41660,R14018_41657,R7129_41659,R6750_41661,P0041_41663}}.bcf__)
  3. number of first organism (defaults to __1__)
