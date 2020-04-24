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
   -- for every rat:
   -- GT:PL
   --
   -- GT:genotype:
   -- PL:phred-geschaalde genotype likelihood, rounded to the nearest number
   -- MAXSNPSIZE INT, not really relevant
   DIST_P     INT, -- distance related to SNP before
   DIST_N     INT  -- distance related to SNP after
);
-- the largest combination distance
-- SELECT * FROM EXULANS ORDER BY DIST_N+DIST_P DESC LIMIT 10;
.separator "\t"
.import /dev/stdin EXULANS
