![flowchart](../../../doc/flowchart/makeDatabases_8samples.png?raw=true)

# scripts arguments/input
- make_eight.sql:
  - stdin is used for the table import
- edit_eight.py:
  - input is a vcf file, output is STDOUT, table for the database
- make_eight_db.sh:
  - argument is the name of the sample (defaults to **merge8**) (without extension from the bcf file)
  - output is the database onenucleotide_eight.db
