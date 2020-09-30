# All 9 maize genomes
Genome_list=/1_Data/9genomes_list_HelitronScanner.txt
Genome_FASTA=$(head -n $SLURM_ARRAY_TASK_ID $Genome_list | tail -n 1)
Genome_ID=$(echo $Genome_FASTA | cut -f 7 -d '/')

        ##########################
        # SINEfinder Transposons #
        ##########################

# Run SINEfinder (-f both : outputs csv and fasta)
python sine_finder.py -T chunkwise -V1 -f both ${Genome_FASTA}
