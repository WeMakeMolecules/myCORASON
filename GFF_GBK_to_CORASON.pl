#creates a unique ID for this run
$rand1=int(rand(1000000));
$rand2=int(rand(1000000));
print "#########################################################\n";
print "## GBK GFF TO CORASON BACTERIAL			        ##\n";
print "## A script to convert PRODIGAL proteome and GFF         ##\n";
print "## and antismash v7 GBK (docker version) in CORASON format##\n";
print "## by Pablo Cruz-Morales at DTU Biosustain 	       ##\n";
print "## pcruzm\@biosustain.dtu.dk                	       ##\n";
print "## Jan 2024				               ##\n";
print "## Inputs: a GGF file with the PRODIGAL gene calling    ##\n";
print "##        a prot_raw file from prodigal (-a flag)       ##\n";
print "##        a GBK file with the  ANTISMASH 6 annotation   ##\n";
print "## usage: perl GFF_GBK_to_CORASON file.prot_raw file.gbk file.gff   ##\n";
print "##run id : = $rand1.$rand2                               ##\n";
print "#########################################################\n";
$cont="0";
#Checking that the inputs are correct and providing instruction#
if ($ARGV[0]=~/.+.prot_raw/){
	print "input prodigal prot_raw file is $ARGV[0]\n";
	}
else {print "Error\: did you entered a prot_raw file?\nusage: perl GFF_GBK_to_FUNGISON prot_raw file.gbk\n ";}

if ($ARGV[1]=~/.+.gbk/){
	print "input Antismash gbk file is $ARGV[1]\n";
	}
else {
	print "Error\: did you entered a gbk file?\nusage: perl GFF_GBK_to_FUNGISON file.gff file.gbk\n ";
	}
#storing the file name for the outputs
open FILE, $ARGV[0] or die "I cant open the raw protein file\n";
$file_name_raw="$ARGV[0]";
$file_name_raw=~/(.+)(.prot_raw)/;
$file_name="$1";
open TABLE,  ">$file_name.txt";
#making a temporary table file for protein sequences and ids RAST style with a random number for genome ID from the gff file

open AMINO,  ">amino_acids_$rand1.$rand2";
while ($line=<FILE>){
	if ($line=~/>/){
	$cont++;
	$label_prot="fig\|$rand1.$rand2.peg.$cont\t";
	print AMINO "\n$label_prot";
	}
	else {
	chomp $line;
	$line=~s/\n//g;
	$line=~s/\*//g;
	print  AMINO "$line";
	}
}
close AMINO;
close FILE;
$cont="0";
#making an amino acids fasta file from the amino_acids table

system "tr <amino_acids_$rand1.$rand2 '\t' '\n'|sed 's/fig|/>fig|/' |grep '^\$' -v >$file_name.faa";


#Creating a functions table using a GBK file from antismash with fullhmmer option on 
$id=0;
open GEBEKA,  ">functions_table_$rand1.$rand2";
system  "grep \-E \'/ID\=".+"\|\/description\' $ARGV[1]\| tr \'\\n\' \' \'\|sed \'s/\\/ID\/\\n/g\'\|sed \'s\/  \/\/g\' \> raw_grepped_$rand1.$rand2";
open FILEGREP, "raw_grepped_$rand1.$rand2";
while($line=<FILEGREP>){
	if ($line=~/\s+\n/){$dummy="1";next;}

	if ($line=~/="\d+\_\d+"\/description\=\".+/){
$id++;
	$line=~/(="\d+\_)(\d+)("\/description\=\")(.+)/;
#	$id="$2";
	$annotation="$4";
	$annotation=~s/\/description\=\"//g;
	$annotation=~s/Condensation domain"/C-/g;
	$annotation=~s/Phosphopantetheine attachment site"/xCP-/g;
	$annotation=~s/AMP-binding enzyme C-terminal domain"AMP-binding enzyme"/A-/g;
	$annotation=~s/AMP-binding enzyme"/A-/g;
	$annotation=~s/KR domain"/KR-/g;
	$annotation=~s/Zinc-binding dehydrogenase"Alcohol dehydrogenase GroES-like domain"/ER-/g;
	$annotation=~s/Methyltransferase domain"/MT-/g;
	$annotation=~s/Polyketide synthase dehydratase"/DH-/;
	$annotation=~s/Acyl transferase domain"/AT-/g;
	$annotation=~s/Ketoacyl-synthetase C-terminal extension"Beta-ketoacyl synthase, C-terminal domain"Beta-ketoacyl synthase, N-terminal domain"/KS-/g;
	$annotation=~s/Beta-ketoacyl synthase, N-terminal domain"Beta-ketoacyl synthase, C-terminal domain"/KS-/g;
        $annotation=~s/N-terminal domain"Beta-ketoacyl synthase, C-terminal domain"Beta-ketoacyl synthase, N-terminal domain"/KS-/g;
	$annotation=~s/KS-Ketoacyl-synthetase C-terminal extension"/KS-/g;
	$annotation=~s/Zinc-binding dehydrogenase"/ER-/g;
	$annotation=~s/Male sterility protein"/Acyl-loading-/g;
	$annotation=~s/Alcohol dehydrogenase GroES-like domain"ER/ER-/g;
	$annotation=~s/Beta-ketoacyl synthase, C-terminal domain"Beta-ketoacyl synthase, N-terminal domain"/KS-/g;		
	$annotation=~s/Beta-ketoacyl synthase, N-terminal domain"/KS-/g;
	$annotation=~s/Starter unit:ACP transacylase in aflatoxin/Start_AT-/g;
	$annotation=~s/Thioesterase domain"/TE-/g;
	$annotation=~s/(.*)\1/$1/g;
	$annotation=~s/"/ /g;
	$annotation_line="$id\t$annotation\n";
	$annotation_line=~s/ \n/\n/g;
	$annotation_line=~s/\(RNA-dependent/RNA-dependent/g; 
	$annotation_line=~s/\(a.k.a. RRM, RBD, or/RRM/g;
	$annotation_line=~s/\// /g;
	$annotation_line=~s/\// /g;	
	$annotation_line=~s/\,/ /g;	
	print GEBEKA "$annotation_line";
	}
	else {
	$line=~/(="\d+\_)(\d+)/;	
	$id++;
	$annotation="unknown function";
	$id=~s/\=\"//;
	$id=~s/"//;
	$id=~s/.t1.cds//;
	print GEBEKA "$id\t$annotation\n"; 
	}
}
close FILEGREP;
close GEBEKA;
#getting a list of coordinates gene numbers and strand
open COORDINATES, "$ARGV[2]" or die "I cant open the prodigal GFF3 file\n";

#making the table (txt) file
print TABLE "contig_id	feature_id	type	location	start	stop	strand	function	locus_tag	figfam	species	nucleotide_sequence	amino_acid	sequence_accession\n";
while ($line=<COORDINATES>){
	if ($line=~/CDS/){
	
        $line=~/(.+)\t(Prodigal_v2.6.3)\t(CDS)\t(\d+)\t(\d+)\t(\d+\.\d+)\t(.)\t/;
	$contador++;
	$contig="$1";
	$up="$4";
	$down="$5";
	$strand="$7";
	
        $gene="fig\|$rand1.$rand2.peg.$contador";
	$type="transcript";
	$location="chromosome";
	$locustag="$contig";
	$figfam="figfam";
	$species="$ARGV[0]";
	$nucleotide="ATCG";
	$accession="$locustag";



	#finding  the amino acid sequences fron the amino_acids file	
	open AMINOSEQ, "amino_acids_$rand1.$rand2" or die "i cant see the aminoacids table \n";
	while ($seq=<AMINOSEQ>){
		$seq=~/(.+)\t(.+)/;
		$label="$1";
		$aminoacid="$2";
		if ($label eq $gene){
	#finding  the annotations fron the functions_table file
	open FUNCTIONS, "functions_table_$rand1.$rand2" or die "i cant see the FUNCTIONS file \n";
		while ($func=<FUNCTIONS>){
			$func=~/(.+)\t(.+)/;
			$funcid="$1";
			$function="$2";
			$match="fig\|$rand1.$rand2.peg.$funcid";

			if ($match eq $gene){
	#checking the orientation of the gene, if negative then flipping the numbers, this makes arrrows go in the right direction
			if ($strand=~/\+/){
			$start="$up"; 
			$end="$down"; 
			}
			if ($strand=~/\-/){
			#else{
			$start="$down"; 
			$end="$up";
			}
			print  TABLE "$contig\t$gene\t$type\t$location\t$start\t$end\t$strand\t$function\t$locustag\t$figfam\t$species\t$nucleotide\t$aminoacid\t$accession\n";
			}
			else{
			$cont++;
			}
		}
		}
		else{
		$cont++;
		}
	}
	}
	else {
	$cont++;
	}
}
#print TABLE "$contig\t$gene\t$type\t$location\t$start\t$end\t$strand\t$function\t$locustag\t$figfam\t$species\t$nucleotide\t$aminoacid\t$accession\n";
close COORDINATES;
close AMINOSEQ;
close COORDINATES;
close TABLE;
system "rm  raw_grepped_$rand1.$rand2 amino_acids_$rand1.$rand2 functions_table_$rand1.$rand2";
;;
