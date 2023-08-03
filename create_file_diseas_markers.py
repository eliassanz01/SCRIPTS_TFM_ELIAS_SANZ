#!/usr/bin/env python3

import sys
import glob
import os
import csv

input_folder = sys.argv[1]
output_file = sys.argv[2]

files = glob.glob(f"{input_folder}/*table.final.tsv")
sorted_files = sorted(files, key=lambda x: int(x.split("/")[-1].split("-")[0]))

for x in sorted_files:
	with open(x, 'r') as file:
		tsv_reader = csv.reader(file, delimiter="\t")
		output=[]
		for row in tsv_reader:
			if row[3].startswith("DMpar"):
			
				if row[8]=="1/1":
					value = 1
				else:
					value = 0
					
				output.append(value)		
	
	
	with open(output_file, "a", newline="") as tsv_file:
		tsv_writer = csv.writer(tsv_file, delimiter="\t")
		tsv_writer.writerow(output)
