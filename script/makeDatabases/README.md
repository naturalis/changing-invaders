# Make Databases

The SNPs are templorarily saved inside a database, here are different scripts written for.
On the current moment the scripts from `maak_snp_db.sh` are the used model.
`maak_*.sql` does contain the table definitions.
`voeg_bcf_toe.sql` adds a table (from stdin) (seperated on tab) (row-based)
`vulupos.sql` is a script that fills all unique chromosoom/positie correlations in the UPOS table of the database (row based)
`bewerk_*.py` edits the vcf/bcf file so it fits in the database
`maak_*_database.sh` does combine everything to one working script.
`maak_filterde_rows_tabel.sh` create a table based on filtered criterion, using `maak_valid.sql`.
Note: 8row should be renamed to raw based possibly
flowchart (check individual folders for more zoomed in version):
![flowchart](flowchart.png?raw=true)