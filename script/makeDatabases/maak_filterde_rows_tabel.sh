#!/bin/bash
# changing invaders
# by david
# create a table with only the validated SNPs
[ $# -gt 0 ] && db=$1 || db=seven_or_more.db
sbatch -D $PWD <<< $'#!/bin/bash
sqlite3 "'"$db"'" < $HOME/maak_valid.sql
$HOME/telegramhowto.R "generated table"'