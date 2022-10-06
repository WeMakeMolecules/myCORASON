use lib './';
use globals;

$RAST_IDs2=$RAST_IDs;

$GENOME_DB2="";

$LIST2 = ""; 					##Wich genomes would you process 
						##Can be left blank if you want consecutive genomes starting from 1
$NUM2 = "";

$NAME2=$NAME;					##Name of the group (Taxa, gender etc)
$BLAST2="Core$NAME.blast";
$dir2=$dir;		##The path of your directory
$e2=$eCore; 							# E value. Minimal for a gene to be considered a hit.

