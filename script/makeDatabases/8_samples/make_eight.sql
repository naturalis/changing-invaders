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
   EXUL4GT    TEXT,
   EXUL4PL    TEXT,
   EXUL5GT    TEXT,
   EXUL5PL    TEXT,
   EXUL6GT    TEXT,
   EXUL6PL    TEXT,
   EXUL7GT    TEXT,
   EXUL7PL    TEXT,
   EXUL8GT    TEXT,
   EXUL8PL    TEXT,
   -- for every rat:
   -- GT:PL
   --
   -- GT:genotype:
   -- PL:phred-scaled genotype likelihood, rounded to the nearest integer
   -- MAXSNPSIZE INT, not really relevant
   DIST_P     INT, -- distance to previous SNP
   DIST_N     INT  -- distance to previous SNP
);
-- the biggest combination distance
-- SELECT * FROM EXULANS ORDER BY DIST_N+DIST_P DESC LIMIT 10;
.separator "\t"
.import /dev/stdin EXULANS
