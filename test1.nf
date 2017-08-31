#!/bin/bash nextflow
 
params.reads = "$baseDir/data/ggal/*_{1,2}.fq"
params.annot = "$baseDir/data/ggal/ggal_1_48850000_49020000.bed.gff"
params.genome = "$baseDir/data/ggal/ggal_1_48850000_49020000.Ggal71.500bpflank.fa"
params.outdir = 'results'

params.output="$baseDir/tt.fasta"
params.aa="$baseDir/example/aa1.fasta"
params.speciesTree="$baseDir/example/test_species.ph"
params.nn="$baseDir/example/nn1.fasta"
params.cluster_dir='res_dic/cluster'


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
output_file=file(params.output)

process step1_1cluster {
	 
	input:
	 params.cluster_dir
	 file aa from aa_file
	 file speciesTree from speciesTree_file
	 
	 
	output:
	file 'pairwiseSim.fasta' into SIMILARITY_FILE 

	"""
	step1_1 $params.cluster_dir $aa 
	
	 
	"""






}

process step1_2dif  {



	input:
	 params.cluster_dir
	 file SIMILARITY_FILE
	 file SEQ_fasta from aa_file
	output:
	 
	 file 'cluster.txt' into TEXT_CLUSTER
	 file 'clusterTable.csv' into CSV_CLUSTER
	

	"""
	step1_2 $params.cluster_dir $SIMILARITY_FILE $SEQ_fasta
	"""

}
