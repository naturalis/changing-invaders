CREATE TABLE EXULANS(
   CHROM  INT  NOT NULL,
   POS    INT  NOT NULL,
   ID     TEXT,
   REF    TEXT NOT NULL,
   ALT    TEXT,
   QUAL   FLOAT,
   FILTER TEXT,
   INFO   TEXT  NOT NULL,
   FORMAT TEXT,
   EXUL1  TEXT -- voor iedere rat:
                -- GT:AD:DP:GQ:PL
                -- genotype:
                -- allel diepte:
                -- read diepte:
                -- conditionele genotype kwaliteit:
                -- phred-geschaalde genotype likelihood, afgerond tot het dichtstbijzijnde getal
);
.separator "\t"
.import testdb.vcf EXULANS
