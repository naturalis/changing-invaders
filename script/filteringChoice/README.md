# filteringChoice

These scripts are for choosing right filering criterion. This is done both for quality (quality_distribution.R) and coverage (coverage_distribution.R). The script limits.R is used to click on the plot and allow the user to see what value is on that position to use that value as threshold.

flowchart:
![flowchart](../../doc/flowchart/filteringChoice.png?raw=true)


# scripts arguments/input
- coverage_distribution.R:
  - the input is always the globbing of /d\*/d\*/eight.db (sqlite) database file. (output will be coverage.png and coverage.csv)
- limits.R:
  - this requires 3 input files (all in current directory):
    1. "quality log10" quality distribution but then with log10
    2. quality.csv above, but not log-transformed
    3. depth1.csv coverage depth distribution
- quality_distribution.R:
  - the input is always the globbing of /d\*/d\*/eight.db (sqlite) database file. (output will be quality.png and quality.csv)
