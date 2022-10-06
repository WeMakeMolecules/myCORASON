#Created by Pablo Cruz-Morales, sept 2022
#This is a wrapper script to run corason.pl via a command line
#It writes the globals.pm file using user defined parameters
#It delivers the results in a directory named after the -q option
#this script should be placed at /corason
#the rest should be under /corason/bin
#the genomes database must be in /corason/bin/genomes
#the GENOMES.Ids file must be in /coraon/bin/

use strict;
#use warnings;
use Getopt::Long qw(GetOptions);


print "USAGE: perl corason3.pl <OPTIONS>\n\n";
print "OPTIONS:\n\n";
print "-q FILE.query   	|QUERY FILE, [a file with .query extension}\n";
print "-r 1234			|REFERENCE GENOME ID FROM GENOMES.IDs, WHEN NOT USING -d full MAKE SURE THE ENTRY IS LISTED IN -d [a number]\n";
print "-e 0.0000001		|E-VALUE CUTOFF, [a number]\n";
print "-s 200	        	|BIT-SCORE CUTOFF [a number]\n";
print "-f 10			|NUMBER OF FLAKING GENES INCLUDED IN THE ANALYSIS, [a number]\n";
print "-d full  OR -db 1,2,3	|IDs OF THE GENOMES INCLUDED IN THE ANALYSIS, ][full= entire database OR selected genomes separated by ',' ]\n";
print "-x n or -F FORMATDB	|FORMAT THE DATABASE SELECTED WITH THE -d OPTION, ['no' is the recommeded option or 'FORMATDB']\n\n";

my $query;
my $reference;
my $evalue;
my $score;
my $database;
my $flanks;
my $refname;
my $databasesize;
my $dbstatement;
my $filenames;
my $formatoption;

GetOptions(

'q=s' => \$query,
'r=s' => \$reference,
'e=s' => \$evalue,
's=s' => \$score,
'd=s' => \$database,
'f=s' => \$flanks,
'x=s' => \$formatoption,

) or die "missing parameters\n";

#printing the globals.pm file	
open OUT, ">./bin/globals.pm";
#printign defaults
print OUT "use lib \'\.\/\'\;\n";
print OUT "use Cwd\;\n";
print OUT "\$eCluster=\"0.01\"\;\n"; 		
print OUT "\$eCore=\"0.01\"\;\n"; 		
print OUT "\$GENOMES_IDs=\"GENOMES.IDs\"\;\n";
print OUT "\$BLAST_CALL=\"\"\;\n";
print OUT "\$currWorkDir = &Cwd::cwd();\n";
print OUT "\$dir=\$currWorkDir\;\n";		
print OUT "\$NAME= pop \@\{\[split m|/|, \$currWorkDir]}\;\n";					
print OUT "\$BLAST=\"\$NAME.blast\";\n";
print OUT "\$NUM = `wc -l < \$GENOMES_IDs`;\n";
print OUT "chomp \$NUM;\n";
print OUT "\$NUM=int(\$NUM);\n";
#edit this to zoom in or out inthe SVG canvas
print OUT "\$RESCALE=90000;\n";	

	#printing user input parameters
	
		#database selection options
	if ($database=~/full/) {
	$databasesize=`grep "." ./bin/GENOMES.IDs  -c`;
	chomp $databasesize;
	$dbstatement="You are searching in the full database with $databasesize entries";
	print OUT "\$LIST=\"\";\n";
	}
	elsif ($database=~/,/) {
	print OUT "\$LIST=\"$database\";\n";
	$dbstatement="You are searching in entries $database";
	}
	else {
	die "missing argument -d full  OR -db 1,2,3 [IDs OF THE GENOMES INCLUDED IN THE ANALYSIS, full= ENTIRE DATABASE, selected genomes separated by ',']\n\n";
	}
	#database formating options
	if ($formatoption=~/FORMATDB/) {
	print OUT "\$FORMAT_DB=\"1\"\;\n"; 
	print "The database will be created with $database entries\n";
	}
	elsif ($formatoption=~/no/) {
	print OUT "\$FORMAT_DB=\"0\"\;\n"; 
	print "\nYou selected the current database, no DB formatting is requiered\n";
	print "\nWARNING: MAKE SURE THE CURRENT DATABASE INCLUDES YOUR ENTRIES\n";
	print "E.G. USE OF options '-d 1,2,3,4 -x FORMATDB' CREATES A DATABASE WITH ONLY ENTRIES 1,2,3,4\n";
	print "TRY -db full and  -x FORMATDB TO CREATE A DATABASE WITH ALL THE ENTRIES\n";
	
	}
	else {
	die "missing argument -x n or -x FORMATDB [FORMAT THE DATABASE SELECTED WITH THE -d OPTION, 'no' or 'FORMATDB]\n\n";
	}


	
	if ($query=~/.+query/) {
	print OUT "\$QUERIES=\"$query\"\;\n";
	system "cp $query ./bin/$query";
	}
	else {
	die "missing argument -q FILE.query [QUERY FILE, a file with .query extension]\n\n"; 
	}
	if ($reference) {
	$refname=`awk  '(\$4==$reference){print \$3}' ./bin/GENOMES.IDs`;
	chomp $refname;
	print OUT "\$SPECIAL_ORG=\"$reference\";\n";
	}
	else {
	die "missing argument -r 1234 [REFERENCE GENOME ID FROM GENOMES.IDs INDEX, a number]\n\n"; 
	}
	if ($evalue) {
	print OUT "\$e=\"$evalue\"\;\n";
	}
	else {
	die "missing argument -e 0.0000001 [E-VALUE CUTOFF, a number]\n\n"; 
	}
	if ($score) {
	print OUT "\$BITSCORE=\"$score\"\;\n";
	}
	else {
	die "missing argument -s 200 [BIT-SCORE CUTOFF a number]\n\n";
	}
	if ($flanks) {
	print OUT "\$ClusterRadio=\"$flanks\"\;\n"; 
	}
	else {
	die "missing argument -f 10 [NUMBER OF FLANKING GENES INCLUDED IN THE ANALYSIS, a number]\n\n";
	}





close OUT;
print "All arguments were provided\n";
print "Running CORASON with query $query and reference gene context from entry ID:$reference, $refname\n";
print "The e-value cutoff is $evalue and  the bitscore cut-off is $score\n";
print "$dbstatement, the search will be done for $flanks genes flanking the query hits\n\n";
#running corason2.pl
system "cd bin; perl corason.pl";
#labelling and organizing the outputs
system "mv ./bin/*.contree ./bin/Report.report ./bin/concatenated_matrix.aln ./bin/GENE_CONTEXT.svg ./bin/QUERY_HITS.aln ./bin/*.BLAST .";
$query=~/(.+).(query)/;
$filenames="$1";
system "mkdir $filenames\_results";
system "mv concatenated_matrix.aln ./$filenames\_results/$filenames.core.aln";
system "mv GENE_CONTEXT.svg ./$filenames\_results/$filenames.gene_context.svg";
system "mv QUERY_HITS.aln ./$filenames\_results/$filenames.hits.aln";
system "mv QUERY_HITS.aln.contree ./$filenames\_results/$filenames.hits.contree";
system "mv concatenated_matrix.aln.contree ./$filenames\_results/$filenames.core.contree";
system "mv Report.report ./$filenames\_results/$filenames.report";
system "mv *.BLAST ./$filenames\_results/";
system "rm ./bin/$query";
print "All done\n";
print "Have a great day\n\n";
