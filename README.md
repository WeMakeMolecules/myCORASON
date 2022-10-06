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
    cd ..
    tar -xvf EXAMPLE_DATASET.tar.gz
    mv EXAMPLE_DATASET/GENOMES bin/
    mv EXAMPLE_DATASET/GENOMES.IDs bin/
    mv EXAMPLE_DATASET/Tri28.query .
    rm -r EXAMPLE_DATASET*

# Test run corason3
    perl corason3.pl -q Tri28.query -d full -x FORMATDB -r 3 -e 0.0000000001 -s 250 -f 10
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
    
    The database will be created with full entries
    All arguments were provided
    Running CORASON with query Tri28.query and reference gene context from entry ID:3, Actinopyridazinone_BGC_Streptomyces_sp._MSD090630SC-05
    The e-value cutoff is 0.0000000001 and  the bitscore cut-off is 250
    You are searching in the full database with 6 entries, the search will be done for 10 genes flanking the query hits
    
    
    
    ##########################################################################
    CORASON: CORE ANALYSIS OF SYNTENIC ORTHOLOGOUS NATURAL PRODUCT BGCs
    this is version 2.1 uses iqtree, no trimming, phylo sort with nw_distances
    Smartmatch silenced, order files exist if trees fail, aligning with mafft
    Adapted to run with wrapper corason3.pl
    latest version modified by Pablo Cruz-Morales september 2022
    ##########################################################################
	
	Your working directory is /home/ynp/Desktop/CORASON3/bin
	Program lists have been created
	An organism identifier has been added to each sequence
	Formatting the database...
	the database has been formatted
	
	Searching for homologs of the query...
	Sequences found
	Searching for clusters related to the query...
	Clusters found
	There are 5 organisms with similar clusters
	Aligning the sequences...
	Creating a tree of query homologs (single marker)...
	Calculating the BGC core...
	The core has been calculated
	core line number 2 Core!
	core line number ¡2!
	Best cluster 3_10
	Aligning...
	Sequences were aligned
	Creating matrix...
	renaming...

	Formating matrix for BGC tree..
	constructing the BGC tree using IQTREE with  1000 bootstraps replicates...
	Drawing the genome contexts with the order of the BGC tree...
	BGC_TREE.orderDrawing the BGCs with files 1_44.input,3_10.input,4_29.input,5_2296.input,6_3597.input : 
	BGCs found in the following genome IDs:
	1,3,4,5,6,
	There are 5 organisms with similar clusters
	There is a core composed by 2 orhtolog(s) in this BGC
	The core is annotated in the reference organism as follows:
	fig|2898053.3.peg.10	Methionyl-tRNA synthetase-related protein
	fig|2898053.3.peg.12	PROBABLE L-ORNITHINE 5-MONOOXYGENASE OXIDOREDUCTASE PROTEIN( EC:1.13.12.- )
	corason run finished

	All done
	Have a great day



# Cheking results located in a folder called Tri28_results:
	cd Tri28_results/
	ls
	
	
# Cheking the Tri28.gene_context.svg file ( you can open it in  a web browser)

![Tri28 gene_context](https://user-images.githubusercontent.com/68575424/194334286-0ce6f7bd-76d1-4736-a101-30126e29fd20.svg)

# Cheking the  Tri28.core.contree ( you can open it in  a web browser) made with synthenic orthologs found 
here i opened the file with figtree (http://tree.bio.ed.ac.uk/software/figtree/)

![Tri28 core contree](https://user-images.githubusercontent.com/68575424/194334668-01314e7d-8aea-4e9b-86cf-8f7e993f263c.png)

# Creating a CORASON formatted database:

	1. Upload your genome to the RAST server (you need to get an account):
![image](https://user-images.githubusercontent.com/68575424/194347007-9db18417-5d68-43fb-99e3-31c836a0c8f3.png)

	2. Select the file with your genome sequence:
![image](https://user-images.githubusercontent.com/68575424/194347168-2715e7db-45fb-405e-ad19-43f020df21d5.png)

	3. Fill the form:
![image](https://user-images.githubusercontent.com/68575424/194347273-c234ae64-595f-44ec-8c2f-6bea9820bccf.png)

	4. Submit the job:

![image](https://user-images.githubusercontent.com/68575424/194347633-74c951e8-6dd0-4ffa-94e7-1ede60a2f32b.png)
	
	5. When its done... click on details
![image](https://user-images.githubusercontent.com/68575424/194348108-c0b0e0b7-a3d5-4013-a6fb-e79cf354e306.png)
	
	Download the aminoacids fasta file as .faa and the features spread sheet as .txt
![image](https://user-images.githubusercontent.com/68575424/194348528-88521931-8204-46ed-a29c-a4c207bd364a.png)

	6. Do as many genomes as needed then rename the files with secuencial numbers 1...N and create (or update) the /bin/GENOMES.IDs file like this


	1	6666666.505805	BGC0001764_s56-p1_Streptomyces_sp._SoC090715LN-17	1
	2	6666666.298557	BGC0001295_cremeomycin_Streptomyces_cremeus	2
	3	2898053.3	Actinopyridazinone_BGC_Streptomyces_sp._MSD090630SC-05	3
	4	6666666.505798	BGC0001983_triacsins_Kitasatospora_aureofaciens	4
	5	6666666.501124	Streptomyces_fragilis_NBRC_12862	5
	6	6666666.307463	Glycomyces_harbinensis_CGMCC_4.3516	6


	7. Run corason3.pl with the option -x FORMATDB to update the database


