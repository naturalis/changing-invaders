.separator "	"
.output "EXULANS.filter.vcf"
SELECT EXULANS.CHROMOSOME, EXULANS.POSITION, ".", REFERENCE, ALTERNATIVE, QUALITY, ".", "DP=" || COVERAGE, "GT:PL", GENOTYPE || ":" || PL, ORGANISM FROM EXULANS INNER JOIN FILTERED ON EXULANS.POSITION = FILTERED.position AND EXULANS.CHROMOSOME = FILTERED.chromosome;
