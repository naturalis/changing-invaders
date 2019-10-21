#!/usr/bin/python3
# script om 'sql' queries te doen op de SNP database
# door David
import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy import Table, Column, Integer, Float, Text, MetaData
from sqlalchemy.sql import select
engine = create_engine('sqlite:///onenucleotide.db', echo=True)
metadata = MetaData()
EXULANS = Table('EXULANS', metadata,
	Column('CHROM', Integer, nullable = False),
	Column('POS', Integer, nullable = False),
	Column('ID', Text),
	Column('REF', Integer),
	Column('ALT', Text),
	Column('QUAL', Float),
	Column('FILTER', Text),
	Column('INFO', Text, nullable = False),
	Column('EXUL1GT', Text),
	Column('EXUL1AD', Text),
	Column('EXUL1DP', Integer),
	Column('EXUL1GQ', Integer),
	Column('EXUL1PL', Text),
)

result = engine.execute(select([EXULANS.c.REF]))
for row in result:
	print(row)
result.close()
