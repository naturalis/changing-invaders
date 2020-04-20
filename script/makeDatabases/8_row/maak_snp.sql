CREATE TABLE UPOS(
   CHROMOSOME  INT  NOT NULL,
   POSITION    INT  NOT NULL
);
CREATE TABLE EXULANS(
   CHROMOSOME  INT  NOT NULL,
   POSITION    INT  NOT NULL,
   REFERENCE   TEXT NOT NULL,
   ALTERNATIVE TEXT,
   QUALITY     FLOAT,
   COVERAGE    INT NOT NULL,
   GENOTYPE    TEXT, -- genotype
   PL          TEXT, -- phred likelihoods afgerond ref
   GENOTYPE_BP TEXT, -- genotype in bases

   DIST_P      INT, -- distance related to SNP before
   DIST_N      INT, -- distance related to SNP after
   ORGANISM    INT,
   FOREIGN KEY(CHROMOSOME, POSITION) REFERENCES UPOS(CHROMOSOME, POSITION)
);
-- ALTER TABLE EXULANS
-- ADD FOREIGN KEY (CHROMOSOME, POSITION) REFERENCES UPOS(CHROMOSOME, POSITION);
