#!/bin/bash
# maak een tabel met enkel de gevalideerde SNPs
# changing invaders
# by David
[ $# -gt 0 ] && db=$1 || db=zeven_of_meer.db
sbatch -D $PWD <<< $'#!/bin/bash
sqlite3 zeven_of_meer.db < $HOME/maak_valid.sql
$HOME/telegramhowto.R "tabel aangemaakt"'
