###### This script adds a genome identifier to each RAST id 
#latest version modified by Pablo Cruz-Morales June 2020
use lib './';
use globals;
use experimental 'smartmatch';
open(OUT, ">Concatenados.faa");
open(ALL, "lista.$NUM");
while(<ALL>){
chomp;
  open EACH, "GENOMES/$_.faa";
  while($line=<EACH>){
   chomp($line);
    if($line =~ />/){
      print OUT "$line|$_\n";
    }
    else{
      print OUT "$line\n";
    }     
  }#end while EACH
  close EACH;
}#end while ALL
close ALL;
close OUT

