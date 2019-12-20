CREATE TABLE EXULANS(
   CHROM      INT  NOT NULL,
   POS        INT  NOT NULL,
   ID         TEXT,
   REF        TEXT NOT NULL,
   ALT        TEXT,
   QUAL       FLOAT,
   FILTER     TEXT,
   INFO       TEXT  NOT NULL,
   EXUL1GT    TEXT,
   EXUL1AD    TEXT,
   EXUL1DP    INT,
   EXUL1GQ    INT,
   EXUL1PL    TEXT,
   -- voor iedere rat:
   -- GT:AD:DP:GQ:PL
   --
   -- GT:genotype:
   -- AD:allel diepte:
   -- DP:read diepte:
   -- GQ:conditionele genotype kwaliteit:
   -- PL:phred-geschaalde genotype likelihood, afgerond tot het dichtstbijzijnde getal
   MAXSNPSIZE INT,
   DIST_P     INT, -- afstand tov vorige SNP
   DIST_N     INT  -- afstand tov volgende SNP
);
.separator "\t"
.import ctest1.g.ts.vcf EXULANS