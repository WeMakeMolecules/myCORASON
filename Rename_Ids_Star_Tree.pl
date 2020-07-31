#latest version modified by Pablo Cruz-Morales June 2020
use strict;
use lib './';
use experimental 'smartmatch';
open (NAMES,"RAST.IDs") or die "Couldn't open NAMES file $!";
open (SEQUENCE,"concatenated_matrix.txt") or die "Couldn't open Concatenados file $!";
open (MATRIX,">>concatenated_matrix.aln") or die "Couldn't open RightNames file $!";

my %SEQUENCES;
my %NAMES;
my $name;

#########################################################################

readNames(\%NAMES);
readSequence(\%SEQUENCES,\%NAMES);
close NAMES;
close SEQUENCE;
close MATRIX;
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
	$name=~s/\s/_/g;	
	$name=~s/\_\_/\_/g;
	$refNAMES->{$org}=$name;
	print "$org -> $refNAMES->{$org}!\n";
	}
}

sub readSequence{
	my $refSEQUENCES=shift;
	my $refNAMES=shift;

	my $Org="Empty";
	foreach my $line (<SEQUENCE>){
		chomp $line;
		 if ($line=~m/>/){
                        $Org=$line;
			my $peg="";
			if ($Org=~/org(\d*)\_(\d*)$/){
				$Org=$1;
				$peg=$2;
                        	print "Org #$Org#\n";
				}
                        my $name=$refNAMES->{$Org}."_peg_"."$peg"."_org_"."$Org";
                        print MATRIX ">$name\n";
                        }
                else{#  
                        print MATRIX "$line\n";

                        }
chomp $line;
		}
	}
