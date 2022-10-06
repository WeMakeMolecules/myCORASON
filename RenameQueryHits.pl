#latest version modified by Pablo Cruz-Morales Sept 2022
#renames hits file
use strict;
use lib './';
use experimental 'smartmatch';
open (NAMES,"GENOMES.IDs") or die "Couldn't open NAMES file $!";
open (SEQUENCE,"QUERY_HITS.txt") or die "Couldn't open QUERY_HITS.txt file $!";
open (OUT,">>QUERY_HITS.faa") or die "Couldn't open QUERY_HITS.faa file $!";
my %SEQUENCES;
my %NAMES;
my$name;
#########################################################################
readNames(\%NAMES);
readSequence(\%SEQUENCES,\%NAMES);
close NAMES;
close SEQUENCE;
close OUT;
##########################################################################
sub readNames{
my $refNAMES=shift;
my $count=1;
foreach my $line (<NAMES>){
	chomp $line;
	my @st=split("\t",$line);
	my $org=$count;
	$count++;
	my $name=$st[2];
	$name=~s/\[\)\(\,\.\-\]\=/\_/g;
	$name=~s/\s/\_/g;	
	$name=~s/\_\_/\_/g;
	$refNAMES->{$org}=$name;
	print "$org¡$refNAMES->{$org}!\n";
	}
}
sub readSequence{
	my $refSEQUENCES=shift;
	my $refNAMES=shift;
	my $Org="Empty";
	foreach my $line (<SEQUENCE>){
		chomp $line;
		print "LINE $line\n";
		if ($line=~m/>/){
			$Org=$line;
			my $peg="";
			if($Org=~/peg/){
				$Org=~s/peg_(\d*)//;
				$peg=$1;
				}
			$Org=~s/>_org//;
			print "¡$Org!\n";
			my $name=$refNAMES->{$Org}."_peg_".$peg."_org_"."$Org";
			print OUT ">$name\n";
			}		
		else{#	
			print OUT "$line\n";
			
			}
		}
	}
