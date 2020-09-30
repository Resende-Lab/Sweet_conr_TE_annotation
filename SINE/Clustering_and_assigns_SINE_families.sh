# All 9 maize genomes
Genome_list=/1_Data/9genomes_list_HelitronScanner.txt
Genome_FASTA=$(head -n $SLURM_ARRAY_TASK_ID $Genome_list | tail -n 1)
Genome_ID=$(echo $Genome_FASTA | cut -f 7 -d '/')

# Enter to result's directory
cd $Genome_ID

# Module SiLiX and VSEARCH
ml silix/1.2.11
ml vsearch/20161209-2.3.4

# MTEC fasta file path
MTEC=/1_Data/

        ########################################
        # Clustering and assigns SINE families #
        ########################################

# VSEARCH to identify homology, SILIX to cluster
vsearch --allpairs_global ${Genome_ID}-matches.noTSD.fa --blast6out ${Genome_ID}-matches.noTSD.allvall.8080.out --id 0.8 --query_cov 0.8 --target_cov 0.8 --threads 16 --minseqlength 1

# Single linkage cluster those that are 80% identical to each other.
silix ${Genome_ID}-matches.noTSD.fa ${Genome_ID}-matches.noTSD.allvall.8080.out -f SINE -i 0.8 -r 0.8 > ${Genome_ID}-matches.noTSD.8080.fnodes

# Cluster my families into MTEC TE families
vsearch --usearch_global $MTEC/TE_12-Feb-2015_15-35.fa -db ${Genome_ID}-matches.noTSD.fa --id 0.8 --query_cov 0.8 --target_cov 0.8 --blast6out ${Genome_ID}-matches.noTSD.TEDB8080.out --strand both --top_hits_only --threads 16
