###### Este script pone un identificador de organismo a cada rast id
use lib './';
use globals2;
use experimental 'smartmatch';
open(OUT, ">MINI/Concatenados.faa");
open(ALL, "lista.$NUM2");


while(<ALL>){
chomp;
#print "$_\n";
# <STDIN>;
  open(EACH, "MINI/$_.faa");
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
close OUT

