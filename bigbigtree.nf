#!/bin/bash nextflow
 


params.aa="$baseDir/example/aa1.fasta"
params.speciesTree="$baseDir/example/test_species.ph"
params.nn="$baseDir/example/nn1.fasta"
params.cluster_dir='res_dic/cluster'
params.py_diff="$baseDir/scripts/fasta_dif.py"

log.info """\
         R N A T O Y   P I P E L I N E    
         =============================
         aa: ${params.aa}
         speciesTree : ${params.speciesTree}
         nn : ${params.nn}
         cluster_dir: ${params.cluster_dir}
         """
         .stripIndent()


aa_file=file(params.aa)
speciesTree_file=file(params.speciesTree)
nn_file=file(params.nn)
diff= file(params.py_diff)

process step0_check_fasta_diff{
	output:
	stdout result


	"""
	python $diff $aa_file $nn_file 
 	
	"""


}

result.subscribe {println it}
process step1_1cluster {
	 
	input:
	 params.cluster_dir
	 file SEQ_fasta_aa from aa_file
	 file speciesTree from speciesTree_file
	 
	 
	output:
	file 'pairwiseSim.fasta' into SIMILARITY_FILE 

	"""
	step1_1 $params.cluster_dir $SEQ_fasta_aa 
	
	 
	"""






}

process step1_2dif  {



	input:
	 params.cluster_dir
	 file SIMILARITY_FILE
	 file SEQ_fasta_aa from aa_file
	output:
	 
	 file 'cluster.txt' into TEXT_CLUSTER
	 file 'clusterTable.csv' into CSV_CLUSTER
	

	"""
	step1_2 $params.cluster_dir $SIMILARITY_FILE $SEQ_fasta_aa
	"""

}


process step2_cluster_to_fasta_aa  {



	input:
	 file SEQ_fasta_aa from aa_file
 	 file TEXT_CLUSTER 
	output:
	 
	 file 'cluster*.fasta' into cluster_fasta_aa
	

	"""
	step2_cluster-2-fasta-4-seqFasta.pl $SEQ_fasta_aa $TEXT_CLUSTER
	"""

}



process step2_cluster_to_fasta_nn  {



	input:
	 file SEQ_fasta_nn from nn_file
 	 file TEXT_CLUSTER 
	output:
	 
	 file '*.fasta' into cluster_fasta_nn
	 

	"""
	step2_cluster-2-fasta-4-seqFasta.pl $SEQ_fasta_nn $TEXT_CLUSTER
	"""

}
