# All 9 maize genomes
Genome_list=/1_Data/9genomes_list_HelitronScanner.txt
Genome_FASTA=$(head -n $SLURM_ARRAY_TASK_ID $Genome_list | tail -n 1)
Genome_ID=$(echo $Genome_FASTA | cut -f 7 -d '/')

# Create results directory
mkdir $Genome_ID

# Enter to result's directory
cd $Genome_ID

# Genome directory 
Genome_DIR=/share_sweetcorn/reference/$Genome_ID

# SINEfinder directory
SINE_DIR=/7_SINEfinder/$Genome_ID


        ###########################################
        # Edit outputs and remove TSD information #
        ###########################################

# Transfer SINE output files
mv $Genome_DIR/*-matches.fasta $SINE_DIR
mv $Genome_DIR/*-matches.csv $SINE_DIR

# Rename SINE output files
rename *-matches.fasta ${Genome_ID}-matches.fasta *-matches.fasta
rename *-matches.csv ${Genome_ID}-matches.csv *-matches.csv

# SINEfinder outputs the fasta with the TSD included. I remove these here, so they aren't considered when clustering into families
python remove_tsd_sinefinder.py ${Genome_ID}-matches.fasta ${Genome_ID}-matches.noTSD.fa
