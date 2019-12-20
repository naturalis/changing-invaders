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

   DIST_P      INT, -- afstand tov vorige SNP
   DIST_N      INT, -- afstand tov volgende SNP
   ORGANISM    INT,
   FOREIGN KEY(CHROMOSOME, POSITION) REFERENCES UPOS(CHROMOSOME, POSITION)
);
-- ALTER TABLE EXULANS
-- ADD FOREIGN KEY (CHROMOSOME, POSITION) REFERENCES UPOS(CHROMOSOME, POSITION);