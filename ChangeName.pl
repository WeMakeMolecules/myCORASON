use lib './';
use experimental 'smartmatch';
#!/usr/local/bin/perl -w
use Getopt::Long;
use globals;
#latest version modified by Pablo Cruz-Morales June 2020
###################################################################################################
### Description

$description="Help:\n
######### Author Nelly Selem   nselem84\@gmail.com Nov 2013\nlatest version modified by Pablo Cruz-Morales June 2020\n
######### This script will copy all files in a given directory with a number in their name
## and create new files named just with the reference number on the dir when this script is executed. \n
### This script will keep the original files in order to prevent loose of information.\n\n
## Also the scrip will rename the fasta names in the files the new names will be\n
## org1, org2, org3, ... \n
## Each file should contain the same number of sequences previously oredered by organisms.\n
#########################################################################\n
### You can ask for verbose mode -v \n
### You can specify a prefix for the prefix -o prefix \n
### You can also specify the input dir -d directory \n\n

#########################################################################\n
###      Algorithm \n
#### 
###  3. Once the files were opened a Hash is constructed by the sequences\n
###     concatenation HASH{organism}=gen1.gen2.gen3....\n
###  4. This HASH is printed in an output file.\n
#########################################################################################\n
";


#####################################################################################################
####### User Input 
my $help=""; my $verbose=""; my $prefix=""; my $dire="";
GetOptions('help|?' => \$help,'verbose' => \$verbose,'prefix=s' => \$prefix,'dir=s' => \$dire);
#####################################################################################################




###############################################################################################
####### Global Variables
my @files;
###############################################################################################

$infile="$NAME"; 
my $directory = "$dir/$infile/ALIGNMENTS"; 
print "directory $directory will be open\n";
my $out_directory = "$dir/$infile/CONCATENADOS"; 


############################################################################################## S
################### Leyendo variables proporcionadas por el usuario en la consola 
if ($help){print "$description\n";}
if ($verbose){print "Verbose Mode\n";}
if ($prefix){print "Prefix Archivo de salida: $prefix\n";}
if ($dire){ $directory=$dire;
           print "Directorio de entrada: $dire\n";}
################################################################################################



#####################################################################################################################
########################    #Main Program
####################################################################################################################
        &GetFileNames; ## Saves the dir file names in @files

	if($verbose){
		print "###################The Files that will be modified:###########\n";
		print join("\n ", @files);
		print "\n#############################################################\n";
		}	

        foreach $archivo (@files){ ## Para cada archivo
	   	@Contenido=&GetContent($archivo);##  Obtengo su contenido
		&EscribiendoSalida($archivo, @Contenido); # Cambio los nombres del fasta a org1, org2...
							 ## Creo un archivo cuyo nombre solo contiene el numero contenido en el original
		### En ese archivo se guardan las secuencias del original, pero con los identificadores cambiados a org1, org 2, etc
		}
######################################################################################################################
#######################################################################################################################






###############################################################################################
#################Subroutines

sub GetFileNames{ ##Pondra en @files los nombres de los archivos que abriremos
#### Voy a abrir todos los archivos del directorio para llenar el arreglo files

     opendir (DIR, $directory) or die $!;  ### Abriendo el directorio
                 while (my $file = readdir(DIR)) { ####leyendo todos los archivos
                         if (($file=~m/^\d/)&&($file=~m/aln/)){
                                push(@files,$file);     ####Guarda el nombre del archivo en el arreglo @files
                                if($verbose ){  print "The File $file will be open\n";}
                        }
                    }
   print "Se abrio el directorio $directory con los archivos numericos\n\n";
   closedir DIR;
}
######################################################################################
########################################################################

sub GetContent{ ######## solo necesita un archivo fasta que abrir 
####### Abro un archivo del Directorio cambiar los nombres de las secuencias
###### Estoy suponiendo yA todos tienen exactamente los mismos 30 genes ordenados.
###### Si no, habría que hacer un paso previo.

        my ($filename)= @_;
        $filename="$directory"."/"."$filename";
	open(FILE1,$filename);###########Abrir el archivo 
	@file=<FILE1>; #Saving the information in an array
	close FILE1; # Closing file
	return @file;
}



#########################################################################################
sub EscribiendoSalida{  #######Necesita a @file lleno
########## finalmente imprimo archivo de salida

###### Creo un archivo salida
	
	my $nombre=shift;
	my (@Content)=@_;

	#print"\n#########Nombre del archivo a modificar:##########\n";
	print "$nombre\n";

	#print"\n#########Contenido:##########\n";
	#print join(", ", @Content);

 	$nombre=~s/([^0-9]*)//g;  ### En la cadena nombre elimino todo lo que no sea numero.
				  ### Así pues en $nombre se guarda solamente el numero incluido en el nombre del archivo

	if ($verbose) {print "Nuevo nombre $nombre\n";}

	open(OUTFILE,">$out_directory/$nombre");

	my $cont=1;################## Aqui cambiare los identificadores del fasta
	foreach $line (@Content){ ## Para cada clave de organismo
		if ($line=~m/>/) {#Reconozco las lineas que tienen el caracter >
		#$line=">"."org"."$cont"; ########## y las cambio por >org#		
		#$cont=$cont+1;
		my $oo1 = '';
                if($line =~ m/\|(\d*\_\d+)$/) { $oo1 = $1; }
		$line=">org".$oo1;

		}
		if($verbose){print "$line\n";}     ###imprimo en pantalla su secuencia concatenada 
		print OUTFILE "$line\n";###imprimo en archivo salida la secuencia concatenada
		}## todo en formato fasta
	close OUTFILE; ## Y cierro el archivo de salida
	print"\n Se escribio archivo de salida $nombre\n";
}
################################################################################################
exit;

#########################################################################################################
