CREATE TABLE EXULANS(
   CHROM      INT  NOT NULL,
   POS        INT  NOT NULL,
   REF        TEXT NOT NULL,
   ALT        TEXT,
   QUAL       FLOAT,
   INFO       TEXT  NOT NULL,
   EXUL1GT    TEXT, -- genotype
   EXUL1PL    TEXT, -- phred-scaled genotype likelihoods afgerond
   EXUL2GT    TEXT, -- etc
   EXUL2PL    TEXT,
   EXUL3GT    TEXT,
   EXUL3PL    TEXT,
   -- voor iedere rat:
   -- GT:PL
   --
   -- GT:genotype:
   -- PL:phred-geschaalde genotype likelihood, afgerond tot het dichtstbijzijnde getal
   -- MAXSNPSIZE INT, niet echt meer relevant
   DIST_P     INT, -- afstand tov vorige SNP
   DIST_N     INT  -- afstand tov volgende SNP
);
-- de grootste combinatie afstand
-- SELECT * FROM EXULANS ORDER BY DIST_N+DIST_P DESC LIMIT 10;
.separator "\t"
.import /dev/stdin EXULANS
