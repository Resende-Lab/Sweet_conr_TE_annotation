# All 9 maize genomes
Genome_list=/1_Data/9genomes_list_update.txt
Genome_FASTA=$(head -n $SLURM_ARRAY_TASK_ID $Genome_list | tail -n 1)
Genome_ID=$(echo $Genome_FASTA | cut -f 7 -d '/')

# Create results directory
mkdir $Genome_ID

# Enter to result's directory
cd $Genome_ID

# Module TARGeT and BLAST
ml target/2.10
ml ncbi_blast/2.2.26

# TARGeT path
TARGeT=/apps/target/2.10/bin

# Module PYTHON and PERL
ml python/2.7.14
ml perl/5.24.1

# Python script path
PYTHON=/SCRIPTS/PYTHON

# Perl script path
PERL=/SCRIPTS/PERL

        ####################
        # LINE Transposons #
        ####################
   
# LINE references list   
REF_LIST=/6_TARGeT/Detect_LINE/line_references/list_line_references.txt

# For loop with all 31 LINE references
NLINES=31
for (( K=1; K<=$NLINES; K++ ))
	do

	# Set up a file name for each individual TE fasta
	FILENAME=$(head -n $K $REF_LIST | tail -n 1)
	echo $FILENAME

	# Run TARGeT to detect LINE
	FILE=$(basename "$FILENAME")
	echo $FILE
	DNATE="${FILE%.*}"
	echo $DNATE

	if [ ! -f ${DNATE}.tir.fa.tab ]
		then

		mkdir -p $DNATE
		# -DB: database generation for the first time to index the genome
		python $TARGeT/target.py -q $FILENAME -t nucl -o $DNATE -i s -P 1 -S PHI -b_a 10000 -b_d 10000 -p_n 10000 -p_f 200 -p_M 0.3 $Genome_FASTA ${DNATE}_target
		python $TARGeT/target.py -q $FILENAME -t nucl -o $DNATE -i s -P 1 -S PHI -DB -b_a 10000 -b_d 10000 -p_n 10000 -p_f 200 -p_M 0.3 $Genome_FASTA ${DNATE}_target
	
				
		# Convert names of flanking fasta file
		if [ ! -f ${DNATE}.flank_adj ]
			then
			python $PYTHON/convert_target_toTIRID.py ${DNATE}/*/${DNATE}.flank > ${DNATE}.flank.fa
		else
			python $PYTHON/convert_target_toTIRID.py ${DNATE}/*/${DNATE}.flank_adj > ${DNATE}.flank.fa
		fi

		# Run mTEA
		perl $PERL/id_TIR_in_FASTA.mcs.pl -o ${DNATE}.line.fa -i ${DNATE}.flank.fa -c NNNNNNNNNNNNNNN -t N -d 1 -s 3
	fi
done
