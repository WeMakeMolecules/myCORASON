use lib './';
use Cwd;
#latest version modified by Pablo Cruz-Morales June 2020
#####Reference genome and query
$SPECIAL_ORG="28"; ## Reference organism having a known BGC, will be used as reference for BGC homology
$QUERIES="QUERY.query";

#####homology search parameters
$e="0.000001"; 		#sss1E-15					# E value. Minimal for a gene to be considered a hit.
$BITSCORE="200";  #Revisar el archivo .BLAST.pre para tener idea de este parámetro.
$ClusterRadio="20"; #number of genes in the neighborhood to be analized
$eCluster="0.01"; 		#Evalue for the search of queries (from reference organism) homologies, values above this will be colored
$eCore="0.01"; 		#Evalue for the search of ortholog groups within the collection of BGCs	

#####db management
$RAST_IDs="RAST.IDs";
$BLAST_CALL="";
$FORMAT_DB="1"; #here you put 0 if  the genomes DB is already formatted and 1 if you want to reformat the whole DB


#####working directory.. for most cases do not touch
$currWorkDir = &Cwd::cwd();
$dir=$currWorkDir;		##The path of your directory
$NAME= pop @{[split m|/|, $currWorkDir]};					##Name of the group (Taxa, genera etc)
$BLAST="$NAME.blast";

##Wich genomes would you process in case you might, otherwise left empty for whole DB search  
$LIST="10,11,,28,3,4,5,6,7,9";  
$NUM = `wc -l < $RAST_IDs`;
chomp $NUM;
$NUM=int($NUM);
#Window size
$RESCALE=75000;   ## Adjust horizontal size on arrows (genes) if greater then arrows are smaller and you will see more genes.
