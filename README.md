# bigbigtree

bigbigtree is a  divide and concatenate strategy for the phylogenetic reconstruction of large orthologous datasets




Compile/Installation 
--------------------

Clone the git repository on your computer with the following command: 

    git clone https://github.com/jmchanglab/bigbigtree.git
    
or

	nextflow clone jmchanglab/bigbigtree

Make sure you have installed nextflow, python and perl:bio. 




Usage 
--------------------

	
	
	compulsory:  
        	--aa	 input of Proteins sequences in FASTA format,the each sequence ID must end with a suffix specifying the Species information separated by a underscore char.For Example:    >XXX_SPECIES there 'XXX' is the sequence ID and 'SPECIES' is the species code.
		
        	--nn 	 input of Nucleotides sequences in FASTA format,the each sequence ID must end with a suffix specifying the Species information separated by a underscore char.For Example:    >XXX_SPECIES there 'XXX' is the sequence ID and 'SPECIES' is the species code.
		
		
		
	optional:	
		--speciesTree		input of species Tree
		--msa_mode		can choose fmcoffee,mcoffee,tcoffee(default:fmcoffee)
		--tree_mode		can chhose treebest,phyml(default:treebest)
		--logfile 		
	
        	
For instance:
>nextflow run main.nf --aa 'example/Or_aa.fasta' --nn 'example/Or_nn_v2.fasta' --speciesTree 'example/speciesTree.ph' --msa_mode 'tcoffee' --tree_mode 'phyml' --logfile '$baseDir/nextflow.log'


Docker 
--------------------
If you have installed Docker, you can execute nextflow code with my docker container.Using the command below to get the docker image: 

	docker pull tsaihanlung/mybiocontainer-python-bioperl

Execute nextflow with docker:

	nextflow run main.nf -with-docker 1a265f5fe961
