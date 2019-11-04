CREATE TABLE EXULANS(
   CHROM      INT  NOT NULL,
   POS        INT  NOT NULL,
   ID         TEXT,
   REF        TEXT NOT NULL,
   ALT        TEXT,
   QUAL       FLOAT,
   FILTER     TEXT,
   INFO       TEXT  NOT NULL,
   EXUL1GT    TEXT, -- genotype
   EXUL1AD    TEXT, -- allele depth (totaal)
   EXUL1DP    INT,  -- read diepte op deze positie
   EXUL1GQ    INT,  -- conditionele genotype kwaliteit als phred
   EXUL1PL    TEXT, -- phred-scaled genotype likelihoods afgerond
   EXUL1SB    TEXT, -- strand bias statistiek
   -- voor iedere rat:
   -- GT:AD:DP:GQ:PL:SB
   --
   -- GT:genotype:
   -- AD:allel diepte:
   -- DP:read diepte:
   -- GQ:conditionele genotype kwaliteit:
   -- PL:phred-geschaalde genotype likelihood, afgerond tot het dichtstbijzijnde getal
   -- SB:Strand bias
   MAXSNPSIZE INT,
   DIST_P     INT, -- afstand tov vorige SNP
   DIST_N     INT  -- afstand tov volgende SNP
);
.separator "\t"
UPDATE EXULANS set ID = NULL where ID = '';
UPDATE EXULANS set FILTER = NULL where FILTER = '';
.import /dev/stdin EXULANS
-- de grootste combinatie afstand
-- SELECT * FROM EXULANS ORDER BY DIST_N+DIST_P DESC LIMIT 10;
