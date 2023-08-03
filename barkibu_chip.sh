#!/bin/bash

### to download and compress the large dog vcf file
aws s3 cp \
	--no-sign-request \
	s3://sra-pub-src-1/SRZ189891/722g.990.SNP.INDEL.chrAll.vcf.1 - |\
	bgzip -@ 8 \
	> dogs.vcf.gz

### to index the file
tabix dogs.vcf.gz


### to extract the SNPs in the barkibu chip
bcftools view \
	 -Oz \
	 -R chip.positions.list \
	 dogs.vcf.gz \
	 -o dogs.chip.pos.vcf.gz
	
## to compress and index the filtered file
tabix dogs.chip.pos.vcf.gz
