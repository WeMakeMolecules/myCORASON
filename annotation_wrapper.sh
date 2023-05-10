#wrapper for prodigal gff/raw_prot and antismash gbk to CORASON
LABEL=$(echo "$1" | sed 's/.fna//')
prodigal -i $LABEL -a $LABEL.prot_raw -f gff -o $LABEL.gff
run_antismash $LABEL.fna $LABEL --genefinding-gff3 /input/$LABEL.gff --taxon bacteria --fullhmmer --cc-mibig --cb-knownclusters
perl GFF_GBK_to_CORASON.pl $LABEL.prot_raw $LABEL.gbk $LABEL.gff
