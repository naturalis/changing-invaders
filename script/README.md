# the actual scripts

Scroll down for explaination...
The program flow scematic:
![flowchart image](../doc/flowchart/simple_flow.png)
The full flowchart:
![flowchart image](../doc/flowchart/full-flowchart.png)

The flowcharts are structured to all use the same color references. Every subdirectory (one field in the smallest flowchart) contains its own part of the flowchart, to improve usability of this repo. Alongside the directory color codes, bright yellow is used for scripts that are not needed when progress simply works fine.
Next to that the bigger flowchart is structured in the following ways:
* boxes
 - boxes that are circles represent symbolical start- and stop- points of the analysis
 - most boxes represent 1 or no script, some represent 2
 - parallellogram boxes are used to either explain something about a specific part in the flow, or as a very last result of something.
 - white boxes might indicate the script belongs to a directory, but is not uploaded, yet, they might also be white because of represeting "other"
 - boxes that are bold, means this should be executed for every sample
 - boxes that are italic, means this should be executed for every number of *K* (ancestor populations)
 - boxes that contain five lines that do not contain scripts explain a part of the flowchart
* output
 - script names are explained in between \(these characters\)
 - output is explained in between \[these characters\] this is almost always filenames, but occasionally this can be a database table, which is represented by fully use of UPPERCASE.
 - output of \(...\).xyz means the input filename, without the last extension (.something part of the filename) and added .xyz
 - output filename that contains *sample* is symbolical. Then the output file(s) will be the sample name.
 - output containing \<this characters\> means a number
* arrows
 - normal arrows represent flow of data
 - arrows ending in dotted lines represent that values are defined in the script pointed to, because of the outcome of the script pointed from
 - arrows ending in a circle represented that the script is based on the script pointed from.
 - arrows that started with a dotted line means that the script pointed to is depended on multiple runs of the "pointed from" script
 - a fully dotted line inside an arrow means "in exceptional cases"
 - a line starting dotted and in the middle switching line and empty represent developmental only
