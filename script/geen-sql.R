# selecteer queries dmv rsql
# geen sql-sql
# by david
library(RSQLite)
library(rsql)

onenucleotide <- dbConnect(RSQLite::SQLite(), "~/Documenten/Naturalis/onenucleotide.db")
EXULANS = rsql_table('EXULANS', dbListFields(onenucleotide, "EXULANS"))
cat(to_sql(EXULANS$select()))

head(dbGetQuery(onenucleotide, to_sql(EXULANS$select(.(referentie = REF, mutatie = ALT))$where(from("",.(MAXSNPSIZE < 3 && LENGTH(REF) < 3))))))
dbDisconnect(onenucleotide)
