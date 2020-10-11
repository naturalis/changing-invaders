# the actual scripts

## Scripts in this directory:

telegram_message.R provides a possibility to allow telegram messages from bash scripts. Running it as bash, telegram_message.R could have one argument (the message itself that should be sent, else the message will be NA)
as bash script it modifies the files in the repo in a manner that the secret token and chat id are applied to files that require them.
These values are inputed by `read` so no argument is required
SNPextract.R could accept a lot of arguments:
1. number of required SNPs (defaults __100__)
2. database file (defaults __system globbing /d\*/d\*/eight.db__)
3. sample-enum file (defaults __system globbing /d\*/d\*/sample-enum.csv__)
4. blast directory (defaults __current directory__)
5. SNP directory (defaults __SNP-files in HOME directory__)
6. posfix for output names (default to __data__)
ontologicalargumentparser.vb allows one to obtain significance information about a list of genes. The list of genes can be the input by the use of standard input, or a file. If it is by means of a file this should be the first non-parameter argument. The output should be declared as second non-parameter argument, if not it is standard output, or *input filename*.oap if input filename is declared. Parameters are `--amount` for the amount of genes and --organism for the organism the genes are from. This can be the latin name, in most cases, or the number as ShinyGO defines it, or common names for `Human`, `Mouse`, `Rat`, `Cow`, `Zebrafish`, `Pig`, `Chicken`, `Macaque` and `Dog`. The program might work better with symbol names (non-ensemble names) as reported by one user. For using non-numeric organism specifiers, the file `possible.organisms` is required (which is just a table generated from messages recieved from ShinyGO). It should be possible, and even simple to exted the program towards other tables and data. The program is written in Visual Basic.NET and should work with the 2020 compiler on MS Windows. On Linux, the building process involved downloading .NET core, and adding that to the PATH variable, then execute `dotnet new console --language vb` in an (preferably empty directory). Removing the possible created `Program.vb` and inserting the source code of ontologicalargumentparser.vb and then execute `dotnet publish --nologo -c release -r linux-x64 --self-contained=true /p:PublishSingleFile=true /p:PublishTrimmed=true /p:DebugType=None` for linux 64 bit (for other platforms look [here](https://docs.microsoft.com/en-us/dotnet/core/rid-catalog) on what to replace linux-x64). Now there is in the current directory a directory/path/thing that is `bin/release/netcoreapp5.0/linux-x64/publish/` in which there is a file with the same name as the current directory. This file is the excutable.

## General information

Scripts that use a reference genome, will work with the REF environment variable, if available. The shell scripts will search for the path in the files.yml file, if they can find it.

Many scripts take some time to run(especially in scripts/readsToVariants folder). Because of this the slurm system is used.
This is a system that manages jobs on a server. Therefore a lot of (bash)scripts in this repository make use of sbatch and the following structure:
```bash
#!/bin/bash
# what the script does
code to parse arguments of set them on default values
[ $# -gt 0 ]&&variable1=$1||variable1=standard_argument
code that checks whether file arguments are available
if test $(that is the case);then
 sbatch <<< '#!/bin/bash
  # read code
  program_a "'"$variable1"'"
'
fi
```
Please note that sbatch is the program where jobs are made known on the server. The program the job comprend is on the next lines.
Because there is worked with '(single quote) arguments that are given are within "'" (double quote so most variables could contain spaces)

The program flow scematic:

![flowchart image](../doc/flowchart/simple_flow.png)

The flowcharts are structured to all use the same color references. Every subdirectory (one field in the smallest flowchart) contains its own part of the flowchart, to improve usability of this repo. Alongside the directory color codes, bright yellow is used for scripts that are not needed when progress simply works fine.
Next to that the bigger flowchart is structured in the following ways:
* boxes
  - boxes that are circles represent symbolical start- and stop- points of the analysis
  - most boxes represent 1 or no script, some represent 2
  - parallellogram boxes are used as the very last result of something.
  - white boxes might indicate the script belongs to a directory, but is not uploaded, yet, they might also be white because of represeting "other"
  - boxes that are bold, means this should be executed for every sample
  - boxes that are italic, means this should be executed for every number of *K* (ancestor populations)
* textual conventions
  - script names are explained in between \(these characters\)
  - output is explained in between \[these characters\] this is almost always filenames, but occasionally this can be a database table, which is represented by fully use of UPPERCASE, except maybe the word postfix.
  - output of \(...\).xyz means the input filename, without the last extension (.something part of the filename) and added .xyz
  - output filename that contains *sample* is symbolical. Then the output file(s) will be the sample name, the same applies to postfix.
  - output containing \<this characters\> means a number
  - output containing {a/b}c ac and bc
  - output containing \+.ext means the filename and .ext added.
  - {} outside of output brackets means more explained about that box
* arrows
  - normal arrows represent flow of data
  - arrows ending in dotted lines represent that values are defined in the script pointed to, because of the outcome of the script pointed from
  - arrows ending in a circle represented that the script is based on the script pointed from.
  - arrows that started with a dotted line means that the script pointed to is depended on multiple runs of the "pointed from" script
  - a fully dotted line inside an arrow means "in exceptional cases"
  - a line starting dotted and in the middle switching line and empty represent developmental only


The full flowchart (not the latest version):
![flowchart image](../doc/flowchart/full-flowchart.png)

