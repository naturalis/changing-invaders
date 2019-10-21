CREATE TABLE EXULANS(
   CHROM       INT  NOT NULL,
   POS         INT  NOT NULL,
   ID          TEXT,
   REF         TEXT NOT NULL,
   ALT         TEXT,
   QUAL        FLOAT,
   FILTER      TEXT,
   INFO        TEXT  NOT NULL,
   EXUL1GT     TEXT,
   EXUL1DP     INT,
   EXUL1GQ     INT,
   EXUL1MIN_DP INT,
   EXUL1PL     TEXT,
   -- voor iedere rat:
   -- GT:DP:GQ:MIN_DP:PL
   --
   -- GT:genotype:
   -- DP:gemiddelde read diepte:
   -- GQ:conditionele genotype kwaliteit:
   -- MIN_DP:laagste read diepte:
   -- PL:phred-geschaalde genotype likelihood, afgerond tot het dichtstbijzijnde getal
   MAXSNPSIZE INT
);
.separator "\t"
.import ctest1.g.ts.vcf EXULANS
