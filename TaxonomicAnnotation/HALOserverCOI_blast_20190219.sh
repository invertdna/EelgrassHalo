#!/bin/bash

PATH=$PATH:/mnt/nfs/home/rpkelly/ncbi-blast-2.8.1+/bin

BLAST_DB='/mnt/nfs/home/rpkelly/blastdb/nt'
# BLAST PARAMETERS
PERCENT_IDENTITY="80"
WORD_SIZE="30"
EVALUE="1e-30"
# number of matches recorded in the alignment:
MAXIMUM_MATCHES="100"
CULLING="10"

	################################################################################
	# BLAST CLUSTERS
	################################################################################
	echo $(date +%H:%M) "BLASTing..."
	blast_output="/mnt/nfs/home/rpkelly/processed/BLASTed_COI_HALO_20190213.txt" 
	blastn \
		-query "/mnt/nfs/home/rpkelly/raw/Halo_Allreps_20190215.fasta" \
		-db "${BLAST_DB}" \
		-num_threads 4 \
		-perc_identity "${PERCENT_IDENTITY}" \
		-word_size "${WORD_SIZE}" \
		-evalue "${EVALUE}" \
		-max_target_seqs "${MAXIMUM_MATCHES}" \
		-culling_limit="${CULLING}" \
		-outfmt "5" \
		-out "${blast_output}"

