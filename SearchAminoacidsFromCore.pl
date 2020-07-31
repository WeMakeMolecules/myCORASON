use lib './';
use Getopt::Long;
use globals2;
use experimental 'smartmatch';
#####################################
#requirements:
#-genomes list
#-pairedB LAST  e.g. 1vs2  2vs3  3vs 4 .../
#- fasta aminocids for each genome
#AUTOR: Christian Eduardo Martinez G.
#cmartinez@langebio.cinvestav.mx
#latest version modified by Pablo Cruz-Morales June 2020
#####################################
#!/usr/bin/perl
# $dir Global variable from globals
my $infile="$NAME2";  ##will make a folder
my $outdir="$dir2/$infile";
my $lista="lista.$NUM2";
my $listaname="$NUM2.lista";
my $DesiredGenes="Core";
#-----------------------------------------
system "mkdir $outdir";
system "mkdir $outdir/FASTAINTERporORG/";
system "mkdir $outdir/FASTAINTER/";
### read all mini BGC candidates
my %MINIS=ReadFasta($dir2,$listaname);#INPUT the .bbh OUTPUT= intersection of all at  inter.todos
foreach my $PegId(keys %MINIS){	
	}
## makes a hash with the id of each ortholog
## print a fasta with the IDs sorted by orthology
## pront list otho all
byOrthologues($DesiredGenes,\%MINIS,$outdir);
## makes a hash with the id of each gene in the core of each genome
## prints a fasta wih the ids sorted by genome
byOrganism($DesiredGenes,\%MINIS,$outdir);
print "Done!\n";
####################################
##makes a fasta of the intersections (CORES)
####################################
sub ReadFasta{
	my $dir=shift;
	my $listaname=shift;
	my %hashFastaH;
	open (FAA, "$dir/$listaname") or die $!;
	my $headerFasta="";
	while(my $linea=<FAA>){
		chomp($linea);
		######### Get file number
		my $fnumber=$linea;
		$fnumber=~s/\.faa//;
		####### fills hash with a header-sequence#####
		open (CU, "$dir/MINI/$linea") or die $linea;
  		while(<CU>){
    			 if($_ =~ />/){
       				chomp;
      				$headerFasta=$_."|$fnumber";
    			}
     			else{
       				$_ =~ s/\*//g;
       				$hashFastaH{$headerFasta}= $hashFastaH{$headerFasta}.$_;
     			}
		 }#end while CU
	}#end while FAA ############# finishes filling hash with a header-sequence
	close CU;
	close FAA;
	return %hashFastaH;
}
#_______________________________________________________________________
sub byOrthologues{
	my $DesiredGenes=shift;
	my $refMINIS=shift;
	my $outdir=shift;
	open (ALL, "$dir/$DesiredGenes") or die $!;
	my $count=1;
 	foreach my $linea(<ALL>){
		open (FASTAINTER, ">$outdir/FASTAINTER/$count.interFastatodos") or die "Couldnt open file $count interFastatodos $!";
		open (LISTA, ">>$outdir/lista.ORTHOall") or die "Lista ortho all $!";
		print LISTA "$count.interFastatodos \n";
		chomp $linea;
		my @sp=split (/\t/,$linea);
		foreach my $gen (@sp){
			$gen=">$gen";
			if(exists $refMINIS->{$gen}){
				print FASTAINTER "$gen\n$refMINIS->{$gen}";
     				}
     			else{
     				}
			}
		close FASTAINTER;
		close LISTA;
		$count++;
		}
	close ALL;
}
#_______________________________________________________________________
sub byOrganism{
	my $DesiredGenes=shift;
	my $refMINIS=shift;
	my $outdir=shift;
	open (ALL, "$dir/$DesiredGenes") or die $!;
	my %Orgs;
	my $count=1;
 	foreach my $linea(<ALL>){ ##for each line in the core 
		chomp $linea;
		my @sp=split (/\t/,$linea);
		$count ++;		
		foreach my $gen (@sp){		## grabs the gene in order
			$gen=">$gen";
			if ($gen=~/\>fig\|\d*.\d*\.peg\.\d*\|(\d*\_\d*)$/){
				if (!exists $Orgs{$1}){
					$Orgs{$1}=[];
					}
			
				push(@{$Orgs{$1}},$gen);
				}
		}	
	}
	close ALL;
	foreach my $orgNumber(keys %Orgs){
    		open (FASTAINTERORG, ">$outdir/FASTAINTERporORG/$orgNumber.interFastatodos") or die "Couldn't open orthologues file $orgNumber $!"; 
     		if(exists $Orgs{$orgNumber}){
			foreach my $gen (@{$Orgs{$orgNumber}}){
     				if(exists $MINIS{$gen}){
 	      				print FASTAINTERORG "$gen\n$MINIS{$gen}";
					}
				else{
					}
				}
     			}
		else{
			}
  		close FASTAINTERORG;
 	}#end while foreach
}
