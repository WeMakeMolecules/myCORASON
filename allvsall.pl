use experimental 'smartmatch';
use lib './';
use warnings;
use strict;
use Getopt::Long;

####################################################################################################
# This program produces lists of orthogroups
# Needs:
# Req: Numerical list of desired genomes to explore in order to look for orthogroups
# input: An input file with an all vs all blast that includes at least the numbers in Req
# Optional:
# verbose mode 
# Output file name of the outputfile
#
## Example (Find the core of the genomes 1,2,3)
# $perl allvsall.pl -R 1,2,3 -v 0 -i file.blast
# Where file.blast is the blast of allvsall genomes (obtained with the script 1_Makeblast.pl 
# Written by Nelly Selem # nselem84@gmail.com
# latest version modified by Pablo Cruz-Morales June 2020
##################################################################################################################

#############################################
## Subs
sub Options;
sub bestHit(); #Lines on a file, Arguments hash of hashes reference
sub ListBidirectionalBestHits; #Hash of hashes reference (empty), Hash of hashes full with best hits
sub IsEverybody();
sub SelecGroup(); 

############################################
#Variables
my $verbose;
my $inputblast;
my $output;
 
my %BH = (); #Hash de hashes
my %BiBestHits;
my @Required=Options(\$verbose,\$inputblast,\$output);
#################################################################################################
########################################################
## Main
## 1 Find Best Hits
&bestHit(\%BH,$inputblast);

foreach my $peg (keys %BH){
print " Peg: $peg\n";
	foreach my $org (keys %{$BH{$peg}}){
		if (-exists $BH{$peg}{$org}[0] and exists $BH{$peg}{$org}[1]){
			print "Org $org, Percentage $BH{$peg}{$org}[0], Peg2 $BH{$peg}{$org}[1]\n\n";
			}		
		}
	}

## 2 Find Bidirectional Best Hits

print "Now finding Best Bidirectional Hits List\n";
&ListBidirectionalBestHits(\%BiBestHits,\%BH);

## 3 Find ortho groups of selected Genomes
print ("Selecting List that contains orthologs from all desired genomes\n");
&SelecGroup(\%BiBestHits,@Required);

##############################################################################
##################### Subs implementation

sub Options{ 
	my $Req; ## Genomes list to look for otrho groups

	GetOptions ("In=s" => \$inputblast,"Out=s" => \$output,"Req=s" => \$Req,"verbose" => \$verbose) or die("Error in command line arguments\n");
	if(!$inputblast) {
		die("Please provide an all vs all blast file");
		} 
	if (!$output){
		$output="Out.Ortho";
		}
	if(!$Req){
		die ("You must specify from which organisms you desire an ortho-group");
		}	
	else{
		my @Required=split(",",$Req);
		if ($verbose){
			print("You want ortho groups of the following genomes\n");
			for my $req(@Required){
				print "$req \t";
				}
				print("\n");
			}
		return @Required;
		}
	}

#__________________________________________________________________________________________________
#__________________________________________________________________________________________________
sub bestHit(){
	my $BH=shift;
	my $input=shift;
	open(FILE, $input);

	foreach my $line(<FILE>) {
		my @sp = split(/\t/, $line);
		my $o1 = ''; ## Get organism from column A (The query)
		if($sp[0] =~ m/\|(\d+\_\d+)$/) { $o1 = $1; }

		my $o2 = '';
		if($sp[1] =~ m/\|(\d+\_\d+)$/) {  
			$o2 = $1; ## Get Organism from Column B (The hit)
		} 

	##sp[0] query gen from column A
	#If there are not previous hits for the query
		if(!exists $BH->{$sp[0]}) { $BH->{$sp[0]} = (); }## Then I start a list
		if(!exists $BH->{$sp[0]}{$o2}) { $BH->{$sp[0]}{$o2} = [0]; } ## If it does not exist a hit for genColumnA and orgColumnB 
									     ## Start in 0.

		if($sp[2] > $BH->{$sp[0]}{$o2}[0]) { ## If for the organism the new line has a better match
			$BH->{$sp[0]}{$o2} = [$sp[2], $sp[1]]; ## I change it ## If the score is the same
							       ## I will lost paralogs (same score and choose arbitrary one)
							       ## It would be a good idea to improve this part
		} elsif($sp[2] > $BH->{$sp[0]}{$o2}[0]) {
			push(@{$BH->{$sp[0]}{$o2}}, $sp[1]);
		}
		
	}
	close(FILE);
	} #### Data Structure BEst Hit (BH) has been fullfilled with the best hit of each gene

#__________________________________________________________________________________________________

sub ListBidirectionalBestHits(){
## Arguments HAsh Best Hits
## Return a hash of hashes with bidirectional best hits for each gen
	my $RefBiBestHits=shift;
	my $RefBH=shift;
	my $count=0;
	for my $gen (keys %$RefBH) {
		for my $org (keys %{$RefBH->{$gen}}) {#Organismos kk
			
			my $hit=$RefBH->{$gen}{$org}[1];
			if($hit and( exists $RefBH->{$hit})) {
				my $oo1 = '';
				if($gen =~ m/\|(\d+\_\d+)$/) { 
					$oo1 = $1; 
					}
				if(exists $RefBH->{$hit}{$oo1}[1] and $gen eq $RefBH->{$hit}{$oo1}[1]) {
					$RefBiBestHits->{$gen}{$org}=$hit;
					$count++;
					}
				}
			}
		}
	}
#__________________________________________________________________________________________________

sub SelecGroup(){
use experimental 'smartmatch';
	my $refBBH=shift;
	open (OUT,">./OUTSTAR/$output");
	
	for my $gen (keys %$refBBH){
		my $oo1 = '';
		if($gen =~ m/\|(\d+\_\d+)$/) { $oo1 = $1; }
		my @ORGS=sort (keys %{$refBBH->{$gen}});
		if ($oo1~~@Required){	
			if(&IsEverybody(\@Required,\@ORGS) ){
				############### Print ortologous list of the subgroup ######################
 				print OUT "$oo1\t";
				for(my $i=0;$i<scalar  @ORGS;$i++){			
					my $ortoi;
					if ($ORGS[$i] eq $oo1){
						$ortoi=$gen; ## If it does not has ortologous then it is itself
						}
					else{   if($ORGS[$i]~~@Required){
							 $ortoi=$refBBH->{$gen}{$ORGS[$i]};
							}
						}
					if($ortoi){
						print OUT "$ortoi\t";
						}
					}		
				print OUT "\n";
				}
			}
		}
	close OUT;
	}

#_________________________________________________________________________________
sub IsEverybody(){
use experimental 'smartmatch';
	my ($Required,$query)=@_;
	my $flag=1;
	for my $element(@$Required){
		if($element~~@$query){
		$flag=$flag*1;	
			}
		else{
		      return 0;
			}
		}
	return $flag;
}

