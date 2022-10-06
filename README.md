# Corason3
This is a clean version of CORASON that works with genomes annotated in RAST and with genomes annotated with the tools in the FUNGIT repository.
It wont drop large jobs on thousands of PKSs and NRPSs in fungal and bacterial genomes and in general for long sequences
It uses mafft to make alignments, iqtree to make phylogenies and it wont stop if there is no core
# viva la perl!

# Download the precompiled package
	wget https://github.com/WeMakeMolecules/myCORASON/raw/master/CORASON3.tar.gz
# Decompress the file
    tar -xvf CORASON3.tar.gz
# make the nw_distance file executable
	cd CORASON3/bin
	chmod +x nw_distance
    
# Install the dependencies
    sudo apt install blast+
    sudo apt install iqtree
    sudo apt install mafft


# Install the SVG module for perl, Method 1 this method is most likely to work
	sudo apt install cpanminus
        cpanm SVG
# Install the SVG module for perl, Method 2 
        perl -MCPAN -e shell
        install SVG

# Loading the example dataset
    cd CORASON3/
    tar -xvf EXAMPLE_DATASET.tar.gz
    mv EXAMPLE_DATASET/GENOMES bin/
    mv EXAMPLE_DATASET/GENOMES.IDs bin/
    mv EXAMPLE_DATASET/Tri28.query .
    rm -r EXAMPLE_DATASET*

# Test run corason3
    perl corason3.pl -q Tri28.query -d full -x FORMATDB -r 1 -e 0.0000000001 -s 250 -f 10 

# expected output in STDIN:
	USAGE: perl corason3.pl <OPTIONS>
	
	OPTIONS:
	
	-q FILE.query   	|QUERY FILE, [a file with .query extension}
	-r 1234			|REFERENCE GENOME ID FROM GENOMES.IDs, WHEN NOT USING -d full MAKE SURE THE ENTRY IS LISTED IN -d [a number]
	-e 0.0000001		|E-VALUE CUTOFF, [a number]
	-s 200	        	|BIT-SCORE CUTOFF [a number]
	-f 10			|NUMBER OF FLAKING GENES INCLUDED IN THE ANALYSIS, [a number]
	-d full  OR -db 1,2,3	|IDs OF THE GENOMES INCLUDED IN THE ANALYSIS, ][full= entire database OR selected genomes separated by ',' ]
	-x n or -F FORMATDB	|FORMAT THE DATABASE SELECTED WITH THE -d OPTION, ['no' is the recommeded option or 'FORMATDB']
	
	
	


# Cheking results located in a folder called Tri28_results:
	cd Tri28_results/
	ls
	
	
# Cheking the Tri28.gene_context.svg file ( you can open it in  a web browser)


# Cheking the  Tri28.core.contree ( you can open it in  a web browser) made with synthenic orthologs found 
here i opened the file with figtree (http://tree.bio.ed.ac.uk/software/figtree/)





