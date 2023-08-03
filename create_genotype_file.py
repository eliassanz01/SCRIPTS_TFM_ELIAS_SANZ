import csv

# Ruta del archivo VCF de entrada
vcf = '/home/eliassanz/Desktop/BARKIBU/SCRIPT/dogs.chip.pos.vcf'

# Ruta del archivo CSV de salida
csv_file = '/home/eliassanz/Desktop/BARKIBU/SCRIPT/output_wwen.csv'

with open(vcf, 'r') as vcf_file:
	for line in vcf_file:
		if line.startswith('#'):
			continue
		else:
			fields = line.strip().split('\t')

			genotypes = []
			
			for sample_data in fields[9:]:
				genotype = sample_data.split(':')[0]
				if ',' in fields[4]:
					alternative = fields[4].strip().split(',')
					if genotype in ['1/1']:
						genotypes.append(alternative[0])
					elif genotype in ['2/2']:
						genotypes.append(alternative[1])	
					elif genotype in ['0/1', '1/0']:
						genotypes.append(fields[3] + "," + alternative[0])
					elif genotype in ['2/1', '1/2']:
						genotypes.append(fields[3] + "," + alternative[1])
					elif genotype in ['0/2', '2/0']:
						genotypes.append(fields[4])
					else:
						genotypes.append(fields[3])
				else:
					if genotype in ['1/1']:
						genotypes.append(fields[4])	
					elif genotype in ['0/1', '1/0']:
						genotypes.append(fields[3] + "," + fields[4])
					else:
						genotypes.append(fields[3])
			
			with open(csv_file, 'a', newline="") as cfile:
				writer = csv.writer(cfile, delimiter="\t")
				writer.writerow(genotypes)
