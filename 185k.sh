#!/bin/bash

# The bim, fam, and bed files with markers used below in the supplemental data of this article:

# Manuscript entitled "Imputation of canine genotype array data using 365 whole-genome sequences improves power of genome-wide association studies"
#Authors are Jessica J. Hayward, Michelle E. White, Michael Boyle, Margret L. Casal, Marta G. Castelhano, Sharon A. Center, Vicki N. Meyers-Wallen, Kenneth W. Simpson, 
# Nathan B. Sutter, Rory J. Todhunter, Adam R. Boyko

tar -xvzf bim.tar.gz
tar -xvzf fam.tar.gz
tar -xvzf bed.tar.gz

mkdir all
mv ./bim/* all
mv ./fam/* all
mv ./bed/* all

cd all

gzip -d *.bed.gz

for i in {1..39}
 do 
  ./plink \
  --bfile 'chr'$i'_prephased' \
  --dog \
  --recode vcf \
  --out chr$i 
  
  bcftools sort \
  chr$i.vcf \
  -Oz \
  -o chr$i.sorted.vcf.gz
  
  tabix chr$i.sorted.vcf.gz
  
  echo "chr$i.sorted.vcf.gz" >> chr.list
done

bcftools concat \
  -f chr.list \
  --Oz \
  -o 185k.vcf.gz

zcat 185k.vcf.gz |\
  grep -v "#" | \
  cut -f 1,2 \
  > 185k.pos.list
  
perl -pi -e 's/^/chr/g' 185k.pos.list


bcftools view \
	 -Oz \
	 -R 185k.pos.list \
	 dogs.vcf.gz \
	 -o dogs.185k.pos.vcf.gz
	
## to compress and index the filtered file
tabix dogs.185k.pos.vcf.gz

