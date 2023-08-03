import csv

vcf = '/home/eliassanz/Desktop/BARKIBU/SCRIPT/diseases.vcf'
csv_file = '/home/eliassanz/Desktop/BARKIBU/SCRIPT/output_diseases.csv'

# Leer el archivo VCF y almacenar las genotipos en una lista de listas
genotypes_list = []
with open(vcf, 'r') as vcf_file:
    for line in vcf_file:
        if line.startswith('#'):
            continue
        else:
            fields = line.strip().split('\t')
            genotypes = []
            for sample_data in fields[9:]:
                genotype = sample_data.split(':')[0]
                if genotype in ['1/1', '2/2']:
                    genotypes.append('1')
                else:
                    genotypes.append('0')
            genotypes_list.append(genotypes)

# Transponer la lista de listas para invertir filas y columnas
transposed_genotypes = list(map(list, zip(*genotypes_list)))

# Escribir el archivo CSV con los genotipos invertidos
with open(csv_file, 'w', newline='') as cfile:
    writer = csv.writer(cfile, delimiter='\t')
    writer.writerows(transposed_genotypes)

