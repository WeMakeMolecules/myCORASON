echo "################################################################################################################################"
echo "# This BASH script contains a set of instructions to download translated proteomes from genomes in the NCBI FTP site           #"
echo "# pcruzmorales september 2023                                                                                                  #"
echo "# Type download_protemomes.sh and a keyword the script will download the genomes with the keyword                       #"
echo "# usage: download_proteomes.sh  'Genus specie strain'   use the quotation marks '                                       #"
echo "# or: download_proteomes.sh  'KEYWORD' single word no spaces                                                            #"
echo "# WARNING: Depending on the keyword you can download THE ENTIRE DATABASE!, you may try grep with your keyword first            #"
echo "# dependencies: curl pigz                                                                                                      #"
echo "################################################################################################################################"
echo " "
echo " "
echo " "
set -u # or set -o nounset


#this line Downloads the complete list of bacterial assemblies in the refseq 
echo "GETTING THE DATABASE..."
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/genbank/bacteria/assembly_summary.txt
#add a '#' symbol after the first time so you don’t have to repeat this download every time, but leave it to get the latest database


#this line is to filter only the entries with the keyword 
echo "FINDING THE RIGHT ENTRIES..."
grep "$1" assembly_summary.txt > list.txt


#this line is to use the $1.list.txt file (entries with only the keyword) and create file with a list of downloads
echo "MAKING A LIST OF DOWNLOADS..."
cut -f 20 list.txt |perl -ne '/(https.+)(GCA_.+)/; print "$1$2/$2_protein.faa.gz\n"' > downloads.txt
echo "DOWNLOADING THE FILES..."


#this line is to download the files in the list of downloads
wget --input-file=downloads.txt -q 
#wget --input-file=downloads_stat.txt


#this line is to decompress the files which are in gzip format
pigz -d *.gz


echo "RENAMING FILES..."
#this line is to create a little script with the orders to rename the files with the species + strain name
awk 'BEGIN {FS="\t"}; {print "mv,"$1"*protein.faa,"$8$9$1".faa"}' list.txt | sed s'/ /_/g'|sed s'/=/-/g'|sed s'/strain//'|sed s'/(//'|sed s'/)//'|sed 's/-/_/g'|sed 's/,/ /g' > rename.sh
#now I have to clean the weird symbol using tr, i write a new file with the clean names 
tr '/' '_' < rename.sh > rename_clean.sh 

#now i run the new script that i just saved to get clean names
#this line is to run the script that renames the files
# I added this to the execution of the rename_clean.sh file in the next line > /dev/null 2>&1, this sends the output errors to the garbage so the run does not shows the errors
sh rename_clean.sh >/dev/null 2>&1


#this line is to eliminate all the intermediate files that we created 
echo "CLEANING UP..."
rm rename.sh rename_clean.sh downloads.txt list.txt assembly_summary.txt
echo "ALL DONE :) ..."

