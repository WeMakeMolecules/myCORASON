use experimental 'smartmatch';
##########################################################
## Inputs genomes .faa .txt
#############################################################
#perl 1_Context_text.pl queryfile boolMakeblast type
## set boolMakeblast to 1 if no database has been created for each genome
## set boolMakeblast to 0 if there are already databases for each genome
#Gets BestHits de acuerdo acording to the e-value
#Writes gen Id, coordinates and function
# Author nselem84@gmail.com
#latest version modified by Pablo Cruz-Morales June 2020
use lib './';
use globals;
###########################################################################################################
######  	Set variables 
	#the query
my $file= $ARGV[0]; 		## Query File
my $name=$file;			
$name=~s/.query//;
my $ORG=$SPECIAL_ORG; 		## Special organism, proteins will be colored according to its cluster
				print "Your special organism is $ORG\n";
my $MakeDB=$ARGV[1]; 		# set to 0 if there is previous Concatenados Blast Database
my %query=ReadFile($file);
my $type=$ARGV[2]; 		# The database (data type) nuc (nucleotides) prots (Aminoacids)
my $DB="ProtDatabase";		##DataBAse Name
my $list=listas($NUM,$LIST);  	# $list stores in a string the genomes that will be used
	print "program lists have been created\n";
	print "an organism id has been added to each sequence\n";
my @LISTA=split(",",$list);

$eSeq=$e; 			## Evalue principal query
$bitscore=$BITSCORE;		##BitScoreTreshold


###############################################################################################################
######### Searching homologous hits to query
################################################################################################################# 

				print "I will search homologous genes in the organisms\n";
`mkdir MINI`;
print "Parameters\n";

if($MakeDB==1){
	print "I will create a smaller database with the selected genomes\n";
	$DB="temDatabase";
	}
else{	
	print"I will not create a new DB so I will use the full DB ProtDatabase\n";
	}

MakeBlast($MakeDB,$type,$name,$eSeq,$DB,$bitscore,@LISTA); 	
				## Search query by blast in all the other organisms
				## Save blast results on a $name file
my %Hits; 			
my %AllHits;
BestHits($name,\%Hits,\%AllHits);
				## BestHits  ##Read Blast file created by MakeBlast sub whit at least $eSeq as evalue cutoff
				## Stores best hits on Hash Hits  BBBYYYY identity
				#refHits->{$name}{$org}=[$percent,$peg];
print "Checking the hits\n";
		#foreach my $key (keys %Hits){ print "$key -> $Hits{$key}\n"; }
				### Read Organism Names
my $names="RAST.IDs";
my %ORGS=readNames($names);
#my $PEG=$Hits{$name}{$ORG}[1];
my $PEG=$Hits{$name}{$ORG}[1];

print "$name, $ORG $PEG\n";
				print "homologous gene search finished\n";

###########################################################################################################################
######### Get $ORG cluster
##########################################################################################################################
## organism peg
## Grep organism in txt file and get $gen number around
my $ClusterSize=$ClusterRadio; ##Gen number around
my $eClust=$eCluster;
my %CLUSTER;
				print "Searching for homologous gene in clusters \n";
#### 
my %CLUSTERcolor=BlastColor($eClust,$DB,%CLUSTER,@LISTA);
#foreach my $peg (sort keys %CLUSTERcolor){
#	print "Peg $peg orgs $orgs";
#	foreach my $orgs (@{$CLUSTERcolor{$peg}}){
#		foreach my $color_percent(@{$CLUSTERCOLOR{$peg}[$orgs]}){
#			print "$color_percent\t";
#		}
#		print "\n";
#	}
#}
##my $pause=<STDIN>;
				print "I have colored genes according to homology\n";		
## Color if pegi_orgj in Cluster{$peg} for some peg set colorNumber 
########################################################################################################################

print "Now I will produce the *.input file\n";

for my $orgs (sort keys %{$AllHits{$name}}){
		foreach $hit(@{$AllHits{$name}{$orgs}}){
			my @sp = split("\_",$hit);

			my $peg=$sp[0];
			my $percent=$sp[1];
	#	print "Org ¡$org! Hit ¡$pe! percent $percent\n";
		
			ContextArray($orgs,$peg,$ORG,$percent,\%ORGS,\%AllHits);
		}
}

for my $orgs(keys %ORGS){
	if (!(-e "$orgs.input")){
		open FILE, ">$orgs.input" or die "Could not create input file\n";
		print FILE "0\t0\t-\t0\t$ORGS{$orgs}\t0\t0\n";
		close FILE;

		open FILE2, ">MINI/$orgs.faa" or die "Could not create input file\n";
		close FILE2;
		}
}
print "$name, $ORG $PEG\n";
`rm Cluster*.*.*`;
`rm Cluster*.*`;
if($MakeDB==1){`rm temDatabase.*`;}
########################################################################################################################
############################## Subs #######################################################################################
#____________________________________________________________________________________________
#########################################################################################################################
sub readNames{
	my $file=shift;
	open FILE,  "$file" or die "I can not open the input FILE, did you provided a query file?\n";
	my %query;
	my $key="";
	my $count="1";
	while (my $line=<FILE>){
		chomp $line;
		$line=~s/\r//;
		my @sp=split("\t",$line);			
		my $org=$sp[0];
		$org=~s/\.faa//;
		$org=~s/\s*//;
		#print "I will use as query $org\n";
		$query{$count}=$sp[2];
		$count++;
		}
	for my $keys (keys %query){
		#print("¿$keys?:¡$query{$keys}!\n");
		}
	close FILE;
	return %query;
	}

#____________________________________________________________________________________________
sub ContextArray{
	my $orgs=shift;
	my $peg=shift;
	my $ORG=shift;
	my $percent0=shift;
	my $refORGS=shift;
	my $refHits=shift;

	print "org $orgs peg $peg \n";
	open(FILE,">$orgs\_$peg.input")or die "could not open $orgs.input file $!";
	open(FILE3,">$orgs\_$peg.input2")or die "could not open $orgs.input2 file $!";

	open(FILE2,">MINI/$orgs\_$peg.faa")or die "could not open $orgs.mini file $!";

	my @CONTEXT;
#	print "Enter to continue\n";
#	my $pause=<STDIN>;
	my ($hit0,$start0,$stop0,$dir0,$func0,$contig0,$amin0)=getInfo($peg,$orgs);
	$CONTEXT[0]=[$hit0,$start0,$stop0,$dir0,$func0];

	#print "hit $CONTEXT[0][0] start $CONTEXT[0][1] stop $CONTEXT[0][2] dir $CONTEXT[0][3] func $CONTEXT[0][4]\n\n";		
	print FILE "$CONTEXT[0][1]\t$CONTEXT[0][2]\t$CONTEXT[0][3]\t1\t$refORGS->{$orgs}\t$CONTEXT[0][4]\t$CONTEXT[0][0]\t$percent0\n";

	#my $PreOrgNam=$refORGS->{$orgs};
	#my @PreNames=split(" ",$PreOrgNam);
	#my $orgNam=$PreNames[0]."_".$PreNames[1];
	#my $orgNam=$PreOrgNam;
	#$orgNam=~s/ /_/g;
	my $genId=$hit0;
	$genId=~s/fig\|/_/g;
	my @spt=split(/\./,$genId);

	my $FinalName="peg_".$spt[$#spt]."_org".$orgs;
	$FinalName=~s/\./_/g;	$FinalName=~s/__/_/g;
	print FILE2 ">$hit0\n$amin0\n";

	print FILE3 ">$FinalName\n$amin0\n";
	close FILE3;

	my $count=1;	

	my $iniciar=0;
	if($peg-$ClusterSize>0){$iniciar=$peg-$ClusterSize;}	
	for ($i=$iniciar;$i<$peg+$ClusterSize;$i++){
		if($i!=$peg){

			my ($hit,$start,$stop,$dir,$func,$contig,$amin)=getInfo($i,$orgs);
			if(!($hit eq "")){
				if($contig0 eq $contig){
					$CONTEXT[$count]=[$hit,$start,$stop,$dir,$func];
					}
			#setColor
		        my($color,$percent)=setColor($i,$orgs);			
	#		print "$peg, $org, $color \n";
			#print "$percent  $orgs  \n";
			print FILE "$CONTEXT[$count][1]\t$CONTEXT[$count][2]\t$CONTEXT[$count][3]\t$color\t$refORGS->{$orgs}\t$CONTEXT[$count][4]\t$CONTEXT[$count][0]\t$percent\n";
				}
			if($hit eq ""){
				}
			else {
				print FILE2 ">$hit\n$amin\n";
			      }
			$count++;
		}
	}
close FILE;
}
#__________________________________________________________________________________________________________________________
sub getInfo{		## Read the txt
	my $peg=shift;
	my $orgs=shift;
	my $Grep=`grep 'peg.$peg\t' GENOMES/$orgs.txt`;
	my @sp=split(/\t|\n/,$Grep);
	my $contig=$sp[0];	
	my $hit=$sp[1];
	if ($hit=~/gb/){$hit=~s/gi\|\d*\|gb\|\w*.\w*\|//;}
	my $start=$sp[4];
	my $stop=$sp[5];
	my $dir=$sp[6];
	my $func=$sp[7];
	my $amin=$sp[12];
	print "org �$orgs! peg ¡$peg! hit $hit start $start stop $stop dir $dir func $func\n\n";	
	print "Grep $Grep\n";
	return ($hit,$start,$stop,$dir,$func,$contig,$amin);
}

## Hash of arrays {Hit}->[GenClose:start,stop,direction,function]
## Second Color Search a context, Repeat the script for each sequence in the cluster
sub getSeq{
	my $peg=shift;
	my $orgs=shift;
	my $Grep=`grep 'peg.$peg\t' GENOMES/$orgs.txt`;
	my @sp=split("\t",$Grep);	
	my $hit=$sp[1];
	my $seq=$sp[12];
#	print "hit $hit start $start stop $stop dir $dir func $func\n\n";	
	return ($hit,$seq);
}
## Hash of arrays {Hit}->[GenClose:start,stop,direction,function]
#____________________________________________________________________________________

sub getGenesContigReference{
         my $pegRef=shift;
         my $org=shift;
         my $clusterSize=shift;
         my $Grep=`grep 'peg.$pegRef\t' GENOMES/$org.txt`;
         my @sp=split("\t",$Grep);
         my $contigRef = $sp[0];
         my $peg;
         my %seqSameContig; 

        (($pegRef - $ClusterSize) >= 0) ? ($peg=$pegRef-$clusterSize):($peg=0);
	
         while($peg<=$pegRef+$clusterSize){
                 #$peg++;
                 $Grep=`grep 'peg.$peg\t' GENOMES/$org.txt`;
                 @sp=split("\t",$Grep);
                 $contig= $sp[0];
		#print "contig: $contig \n";
                 if($contig and $contigRef eq $contig){
                         #print "$sp[1] \n";
                         $seqSameContig{$sp[1]}=$sp[12];
			# print "$seqSameContig{$sp[1]} \n";
                 }
                 $peg++;
         }
         #print "$sp[12] \n";
         #for my $seq (keys %seqSameContig){
         #       print "$seq  $seqSameContig{$seq}\n";
         #}
         return %seqSameContig;
 }


#_____________________________________________________________________________________
sub listas{
	my $NUM=shift;
	my $LIST=shift;
	my $lista="";

	if ($LIST){ 
		print "Lista de genomas deseados $LIST";
		$lista=$LIST;
		}
	else {
		for( my $COUNT=1;$COUNT <= $NUM ;$COUNT++){
			$lista.=$COUNT;
			if($COUNT<$NUM){
				$lista.=",";
				}
			}
		}

	return $lista;
		
	}

#_____________________________________________________________________________________
sub header{
	my @LISTA=@_;
	open(OUT, ">Concatenados.fna");

	foreach $num (@LISTA){
		#print "NUM $num\n";
	  	open(EACH, "$num.fna") or die "Could not open file $num.fna $!";
  		while($line=<EACH>){
		   	chomp($line);
    			if($line =~ />/){
			      print OUT "$line|$num\n";	
		    		}
    			else{
      				print OUT "$line\n";
    				} 
    			}#end while EACH
  		close EACH;
		#print "Acane el archivo $num\n";

		}#end 

	close OUT
	}

#_____________________________________________________________________________________
sub makeDB{
              
                open(OUT, ">TempConcatenados.faa");
                open(ALL, "lista.$NUM");

                while(<ALL>){
                                chomp;
                                print "Archivo numero $_\n";
                                # <STDIN>;
                                  open(EACH, "GENOMES/$_.faa");
                                  while($line=<EACH>){
                                                   chomp($line);
                                                    if($line =~ />/){
                                                                      print OUT "$line|$_\n";
                                                                      #<STDIN>;  
                                                                    }
                                                    else{
                                                                      print OUT "$line\n";
                                                    }     
                                  }#end while EACH
                                close EACH;
                                }#end while ALL
                close ALL;
                close OUT;

	$type=shift;
	if ($type eq 'nuc'){
		`makeblastdb -in TempConcatenados.fna -dbtype nucl -out $DB.db`;
			print "a nucleotide DB has been created \n";

		}
	elsif($type eq 'prots'){
                `makeblastdb -in TempConcatenados.faa -dbtype prot -out $DB.db`;
                print "a protein db has been created \n";
	}
}
sub MakeBlast{
	my $MakeDB=shift;
	my $type=shift;
	my $file=shift;
	my $evalueL=shift;
	my $DBname=shift;
	my $bitscore=shift;
	my @LISTA=@_;
	my $listfile='lista.'.$NUM;

	open FILE, ">$listfile" or die "Could not open file $NUM.lista" ;
        
        if ($MakeDB==1){foreach my $num (@LISTA){print FILE "$num\n";}}
        else{for (my $i=1;$i<=$NUM;$i++){	print FILE "$i\n";}		}
	
	close FILE;

	if ($MakeDB==1){
	## Make Database from concatenados.faa (PRODUCE CONCATENADOS.faa)
		if ($type eq 'nuc'){
			print"$type type\n";
			print"executing blast on a nucleotide database\n";
			header(@LISTA);
			makeDB($type);
			blastnSeq($evalueL,$file);	
			}
	
		elsif($type eq 'prots'){
			print"$type type\n";
			print "Hello Aminos\n";
			`perl -I . header.pl`;
			makeDB($type);
			blastpSeq($evalueL,$file,$DBname,$bitscore);	
			}
		else {
			print"$type is not an accepted database type\n";
			}

		}
	else{ ##Si no existe BAse de datos Concatenados.faa poner un warning
		if ($type eq 'nuc'){
			blastnSeq($evalueL,$file);	
				
			}

		elsif($type eq 'prots'){
			blastpSeq($evalueL,$file,$DBname,$bitscore);	
			}
		else {
			print"$type is not an accepted database type\n";
			}	
		}
	}
#_________________________________________________________________________________________
##Subs___________________________________________________________________________________
sub blastnSeq{
	my $e=shift;
	if (-e 	"$key.parser"){unlink ("$key.parser");}	if (-e 	"$key.BLAST"){unlink ("$key.BLAST");}
	`blastn -db $DB.db -query $key -outfmt 6 -evalue $eSeq -num_threads 4 -out $key.BLAST`;
	`blastn -db $DB.db -query $key -evalue $e -num_threads 4 -out $key.parser` ;
	open (PARSER,"$key.parser") or die "Could not open $key.parser $!";
	my %SEQ;
	my $name;
	foreach my $line (<PARSER>){
		chomp $line;
		$line=~s/\r//;
		if ($line=~m/>/){
			$name=$line;
			$SEQ{$name}="";
			#print "LINE $name\n";
			}
		if ($line=~/Sbjct/){
			#print "BEFORE $line\n";
			$line=~s/[^ACGT]//g;

			#print "AFTER $line\n";
			$SEQ{$name}.=$line;
			
			}
		}
	close PARSER;
	unlink ("$key.parser");

	open (PARSER,">$key.parser") or die "Could not open $key.parser $!";

	foreach my $KEY (keys %SEQ){
		print PARSER "$KEY\n$SEQ{$KEY}\n";
		}
	close PARSER;
	#if (-e BLAST ){system (rm -r BLAST);}
	#system(mkdir BLAST);
	#print "Se corrió el blast\n";
	#print "\nLista $list#\n";
	#print "Inicia búsqueda de listas de ortologos \n";
	}
#_____________________________________________________________________________________
sub blastpSeq{
	my $e=shift;
	my $name=shift;
	my $DBname=shift;
	my $bitscore=shift;
	
	print"Now we will start the blast \n";
	if (-e 	"$name.parser"){unlink ("$name.parser");}	if (-e 	"$name.BLAST"){unlink ("$name.BLAST");}
	`blastp -db $DBname.db -query $name.query -outfmt 6 -evalue $e -num_threads 12 -out $name.BLAST.pre`;
	open (PREBLAST,"$name.BLAST.pre") or die "Could not open $name.BLAST.pre $!";
	open (BLAST,">$name.BLAST") or die "Could not open $name.BLAST $!";
#	open (PARSER,">$name.PARSER") or die "Could not open $name.BLAST $!";  #Salva el fasta
        
	my @HITS;
	
	foreach my $line (<PREBLAST>){
                chomp $line;
			#print "$line\n";
		my @columns=split("\t",$line);
		my $score=$columns[11];
			
		if ($score>=$bitscore){
			#print "$columns[1],: Score $score\n";
                        print BLAST "$line\n";
			push(@HITS,$columns[1]);
                        }
		}

	foreach my $hit(@HITS){
	#print "This is a hit ¡$hit!\n";
	}

	`blastp -db $DBname.db -query $name.query -evalue $e -num_threads 4 -out $name.parser.pre` ;
	open (PREPARSER,"$name.parser.pre") or die "Could not open $name.parser.pre $!";
	open (PARSER,">$name.parser") or die "Could not open $name.parser $!";
	my %SEQ;
	my $key;
	foreach my $line (<PREPARSER>){
		chomp $line;
		$line=~s/\r//;
		if ($line=~m/>/){
			$key=$line;
			$key=~s/>\s*//;
			#print "Linea del parser $key \n";
			if ($key~~@HITS){
				$SEQ{$key}="";
				}
			}
		if ($line=~/Sbjct/){
			#print "BEFORE $line\n";
			$line=~s/[0-9]*//g;
			$line=~s/\s//g;
			$line=~s/-//g;
			$line=~s/Sbjct//;
			#print "AFTER $line\n";
			if (-exists $SEQ{$key}){
				#print "AFTER $line\n";
				$SEQ{$key}.=$line;
				}
			}
		}
	foreach my $hit (keys %SEQ){
		print PARSER ">$hit\n$SEQ{$hit}\n";
		#print ">$hit\n$SEQ{$hit}\n";
			}
	close PARSER;
	close PREPARSER;
	close PREBLAST;
	close BLAST;
#	`rm *.pre`;
	print "Archivos BLAST y PARSER creados\n";
	}
#____________________________________________________________
#_____________________________________________________________________________________
sub BestHits{ ##For a given query
	my $name=shift;
	my $refHits=shift;
	my $refAllHits=shift;
#/	open FILETEST, ">>aver" or die "Couldn run test";

	open FILE,  "$name.BLAST" or die "I can not open the input FILE $name.BLAST\n";
	print "Creando HAsh BestHits\n";
	$refHits->{$name}=();
	$refAllHits->{$name}=();

	while (my $line=<FILE>){
		chomp $line;
	#	print "$line\n";
		my @sp=split("\t",$line);
		my @sp1=split('\|',$sp[1]);
		my @sp2=split('\.',$sp1[1]);
		my $peg=$sp2[3]; my $org=$sp1[2];my $percent=$sp[2];
#		print("Peg $peg\tOrg $org\t Percent $percent\n");

		if (!exists $refHits->{$name}{$org}){
			$refHits->{$name}{$org}=[0]; # setting $refHits->{$name}{$org}[0]=0;
			$refAllHits->{$name}{$org}=[]; # setting $refHits->{$name}{$org}[0]=0;
#			print "Hit found for organism $org\n";
			}

		if($refHits->{$name}{$org}[0]<$percent){
#			print "Second Hit found for organism $org\n";
			$refHits->{$name}{$org}=[$percent,$peg];
			####### GRAN DUDA POR PARSEAR  aaaah ya 
			}

		push(@{$refAllHits->{$name}{$org}},"$peg\_$percent");
#		print FILETEST "$name-> $org-> $peg\_$percent\n ";
#		print("Peg $refHits->{$name}{$org}[1]\tOrg $org\tPercent $refHits->{$name}{$org}[0] \n");

		}
	close FILE;
#	close FILETEST;
}
#________________________________________________________________________________________________


## READ QUERY
sub ReadFile{
my $file=shift;
	open FILE,  "$file" or die "\nI can not open the input FILE, did you provided a query file?\n\n";


	my %query;
	my $key="";
	while (my $line=<FILE>){
		chomp $line;
		$line=~s/\r//;
		if($line=~m/>/){
			$key=">".$file;
			$key=~s/.query//;
			my @sp=split(" ",$line);			
			$sp[0]=~s/\>//;
			$key.="_".$sp[0];
			$query{$key}="";		
			}
		else{
			$query{$key}.=$line;		
			}
		}
	print "I will use as query\n";
	for my $keys (keys %query){
		print("$keys\n$query{$keys}\n");
		}
	return %query;
}

#________________________________________________________________________________
sub BlastColor{
	my $eClust=shift;
	my $DBname=shift;
	my $refCLUSTER=shift;
	my @LISTA=@_;

	my %CLUSTERcolor;
	my $count=2;
	my %clusterGenes = getGenesContigReference($PEG,$ORG,$ClusterSize);

	my $totalGenes = keys %clusterGenes;
	my $genesUser = 1+$ClusterSize*2;
	#print "total: $totalGenes users: $genesUser \n";
	#<STDIN>;
	if($totalGenes <  $genesUser){
		print "Warning: Only $totalGenes were found. \n ";
	}

        for my $seq (keys %clusterGenes){
                my $hit = $seq;
                my $sequence = $clusterGenes{$seq};
                $hit=~m{\.peg\.(\d+)};  
                my $i = $1;             
                print(">$hit\n$sequence");

                ## print filesnamed Cluster_peg.query with sequence of the neighbour
                if($sequence ne ""){
                        open(QUERY,">Cluster$i.query") or die"Could not open cluster file $i ";
                        print QUERY ">$hit\n$sequence";         
                        #print ">$hit\n$sequence";
                        close QUERY;
                        }
		## Do blast for each one
                my $nameClust="Cluster$i";
                MakeBlast(0,$type,$nameClust,$eClust,$DBname,0,@LISTA);
		                ## Save BEst Hits in a hash
                my %HitsClust; my %AllHitsClust; BestHits($nameClust,\%HitsClust,\%AllHitsClust);

                ## %CLUSTER{$peg}={peg1_org1,peg2_org2,...}
                $refCLUSTER->{$i}=[];
                my $color=$count;

                #print "## Hits for $i on the cluster of $ORG\n";
                for my $HIT(keys %AllHitsClust){
                        for my $orgs (sort keys %{$AllHitsClust{$HIT}}){
                                my @pegsClust=@{$AllHitsClust{$HIT}{$orgs}};
                                #my $peg=$AllHitsClust{$HIT}{$orgs}[1];
                                foreach my $peg_percent (@pegsClust){
                                        my @sp=split("_",$peg_percent);
                                        my $peg=$sp[0]; my $percent=$sp[1];
                                        if(!exists $CLUSTERcolor{$peg}){
                                                $CLUSTERcolor{$peg}=[];
                                                }
                                        #print "org $orgs PEg:$peg\n";
                                        my $save=$peg."_".$orgs;
                                        push(@{$refCLUSTER->{$i}},$save);
                                        #push(@{$refCLUSTER->{$i}},$save);
                                        if (!exists $CLUSTERcolor{$peg}[$orgs]){
                                                $CLUSTERcolor{$peg}[$orgs]=[];
                                                }
                                        push(@{$CLUSTERcolor{$peg}[$orgs]},"$color\_$percent");
                                        #print "$color $percent -> ClusterColor ¡@{$CLUSTERcolor{$peg}[$orgs]}!\n";
                                        #print("count #$count# color #$color#, peg #$peg#, orgs #$orgs# yo #$CLUSTERcolor{$peg}[$orgs]#\n");
                                        }
                                }
                        }
                $count++;      

	}
	
	return %CLUSTERcolor;
}
#__________________________________________________________________________________________________
sub setColor{
	my $peg=shift;
	my $orgs=shift;

	my $colorF=0;
	my $percentF=0;
	
	#print "Peg $peg, Org $orgs \n ";
	if (exists $CLUSTERcolor{$peg}[$orgs]){ ## Cualquier peg en cualquier organismo
		print "Arreglo @{$CLUSTERcolor{$peg}[$orgs]}\n";
		foreach $color_percent (@{$CLUSTERcolor{$peg}[$orgs]}){ ## Puede parecerse a distintos miembros del cluster indicados por los colores, el numero de color es el numero de gen en el cluster
			my @sp=split("_",$color_percent); ## viene acompañado de su porcentaje
			my $colorInHash=$sp[0]; 
			my $percentInHash=$sp[1];
			#print "$color_percent Color en hash $colorInHash PErcent in Hash $percentInHash\n";
			if($percentInHash>$percentF and $colorInHash ne ""){ #Escogemos el de mejor porcentaje
				#print "$percentInHash > $percentF\n then";
				$colorF=$colorInHash; ##Selects the Hit y dejamos ese color
				$percentF=$percentInHash;
				#print "color = $colorInHash:$colorF\n ";
				}

			}
		}
	print "Color $colorF Percent $percentF\n\n";
	return $colorF,$percentF;
	}
