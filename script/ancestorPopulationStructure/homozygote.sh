#!/bin/nash
# changing invaders
# naturalis
# check the intensity of homozygoziness of the samples
bcftools view ${1:-merge8.bcf} |grep -v '##'|awk -F'\t' 'BEGIN{A[1]=0;A[2]=0;A[3]=0;A[4]=0;A[5]=0;A[6]=0;A[7]=0;A[8]=0}/^[^#]/{
split($10, B, ":");split(B[1], C, "/");if (C[1]==C[2]) {A[1]++};
split($11, B, ":");split(B[1], C, "/");if (C[1]==C[2]) {A[2]++};
split($12, B, ":");split(B[1], C, "/");if (C[1]==C[2]) {A[3]++};
split($13, B, ":");split(B[1], C, "/");if (C[1]==C[2]) {A[4]++};
split($14, B, ":");split(B[1], C, "/");if (C[1]==C[2]) {A[5]++};
split($15, B, ":");split(B[1], C, "/");if (C[1]==C[2]) {A[6]++};
split($16, B, ":");split(B[1], C, "/");if (C[1]==C[2]) {A[7]++};
split($17, B, ":");split(B[1], C, "/");if (C[1]==C[2]) {A[8]++};
}/^#/{print}END{print A[1]"\t"A[2]"\t"A[3]"\t"A[4]"\t"A[5]"\t"A[6]"\t"A[7]"\t"A[8]}'|less
