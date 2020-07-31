#latest version modified by Pablo Cruz-Morales June 2020
use experimental 'smartmatch';
use lib './';
use globals2;
$infile="$NAME2";
$lista="lista.$NUM2";
$Working_dir="$dir2/$infile";
system "mkdir $dir2/$infile/ALIGNMENTS/";
###############################################################################################
##############################################
$TOTAL=`grep \$ $dir2/$infile/lista.ORTHOall  -c`;
$NumOrg=$NUM2;

open (LS, "$lista") or die $!;
while (<LS>){
 chomp;
 print "$_\n";
  push(@lista0, $_);
}
my @sorted_orgs = sort { $a <=> $b } @lista0;
print ("@lista0\n");

#line parsing through the contents of folder .lista.orthoall
until ($counter==$TOTAL){
	$counter++;	
	print "I am at $counter\n";
	&align($counter);	
}





`mkdir $dir2/$infile/CONCATENADOS`;
######## 
sub align{
system "muscle -in $Working_dir/FASTAINTER/$_[0].interFastatodos -out $Working_dir/ALIGNMENTS/$_[0].muscle.aln -quiet";
	$nombre="$Working_dir/ALIGNMENTS/$_[0].muscle.aln";
	open(FILE2,$nombre)or die $!;
	print("Se abrio el archivo $nombre\n");
	@content=<FILE2>;
	foreach $line (@content){
		if($line =~ />/){
                                chomp;
                                $headerFasta=$line;
                                $org=$line;
				chomp $org;
                        	$org=~s/>fig\|*.*.peg.*\|//g; #Obtengo el indicador de organismo
                                $hashFastaH{$org}=$headerFasta;
                        }
                        else{
                               $hashFastaH{$org}=$hashFastaH{$org}.$line;
                        }


	}
	
	open ORDEN,">$Working_dir/ALIGNMENTS/$_[0].orden.muscle" or die $!;

	 for ($i=0;$i<=$NumOrg;$i++){
		if ($sorted_orgs[$i]~~@lista0){
		print ORDEN "$hashFastaH{$sorted_orgs[$i]}";
		}
	}
	close ORDEN;
	close(FILE2);
}
############################################
	
print "finished aligning  with muscle\n";
