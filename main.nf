#!/bin/bash nextflow
 

params.aa="$baseDir/example/aa1.fasta"
params.speciesTree="$baseDir/example/test_species.ph"
params.nn="$baseDir/example/nn1.fasta"
params.cluster_dir='res_dic/cluster'
params.msa_mode='fmcoffee'
params.species_Number='9'
params.py_diff="$baseDir/scripts/fasta_dif.py"
params.logfile="$baseDir/nextflow.log"
params.tree_mode="treebest"
params.file_path=".file_path"

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
log_file=file(params.logfile)
path_file=file(params.file_path)

process step0_check_fasta_diff{
        input:
                file SEQ_aa from aa_file
                file SEQ_nn from nn_file
        output:
        stdout result


        """
        python $diff $SEQ_aa $SEQ_nn
        
        """


}

result.subscribe {println it}


process step1_1cluster {
	 
	input:
	
	 file SEQ_fasta_aa from aa_file
	
	 
	 
	output:
	file 'pairwiseSim.fasta' into SIMILARITY_FILE 
	stdout result1_1
	"""
	step1_1  $SEQ_fasta_aa 
	
	 
	"""

}

result1_1.subscribe {log_file.append("$it") }

process step1_2dif  {



	input:
	 
	 file SIMILARITY_FILE
	 file SEQ_fasta_aa from aa_file

	output:
	 
	 file 'cluster.txt' into TEXT_CLUSTER
	 file 'clusterTable.csv' into CSV_CLUSTER
	 stdout result1_2
	
	"""
	step1_2  $SIMILARITY_FILE $SEQ_fasta_aa ${params.species_Number}
	"""

}
result1_2.subscribe {log_file.append("$it") }

process step2_cluster_to_fasta_aa  {
	


	input:
	 file SEQ_fasta_aa from aa_file
 	 file TEXT_CLUSTER 
	 
	output:
	 
	 file '*.fasta' into cluster_fasta_aa
	 stdout result2_1	 

	"""
	step2_cluster-2-fasta-4-seqFasta.pl $SEQ_fasta_aa $TEXT_CLUSTER
	"""

}
result2_1.subscribe {log_file.append("$it") }


process step2_cluster_to_fasta_nn  {
	


	input:
	 file SEQ_fasta_nn from nn_file
 	 file TEXT_CLUSTER 
	output:
	 
	 file '*.fasta' into cluster_fasta_nn
	 stdout result2_2	

	"""
	step2_cluster-2-fasta-4-seqFasta.pl $SEQ_fasta_nn $TEXT_CLUSTER
	"""

}
result2_2.subscribe {log_file.append("$it") }

process step3_1_alignment_aa {
	 
	
	
	input:
	file aa_fasta_channel from cluster_fasta_aa.flatten()
	
	output:
	 file '*.fasta_aln_aa' into aln_fasta_aa,aln_fasta_aa_3_2
	
	 stdout result3_1a
	script:
	"""
	
		t_coffee ${aa_fasta_channel} -multi_core no +keep_name -output fasta_aln  -mode ${params.msa_mode}  -outfile  "${aa_fasta_channel}_aln_aa"
	
		
		
	"""	 




}
result3_1a.subscribe {log_file.append("$it") }

process step3_1_alignment_nn {
	
	input:
		file alnaa from aln_fasta_aa.collect()
		file nnf from cluster_fasta_nn.flatten()
	output:
	 file '*.fasta_aln_nn' into aln_fasta_nn,aln_fasta_nn_4_1
	 
	 stdout result3_1n
	 
	script:
	"""
	
		t_coffee -other_pg seq_reformat -in $nnf   -in2 $nnf"_aln_aa"  -action +thread_dna_on_prot_aln -output fasta >   $nnf"_aln_nn"
			
		
	"""	 

}

result3_1n.subscribe {log_file.append("$it") }

process step3_2_deal_filename{
	input:
	 file aa from aln_fasta_aa_3_2.collect()
	 file p from path_file


	output:
	 file '*.aln_aa' into alnfa
	 stdout result3_2
	"""
	deal_filename.pl $aa
	
	
	"""
}

result3_2.subscribe {log_file.append("$it") }
process step3_2_deal_duplicate{
	input:
	 file nn from aln_fasta_nn.collect()
	 file aa from alnfa.flatten()
	 file p from path_file
	output:
	 file "*.fasta_ali_nn" into aln_nn_tocon
	 stdout result3_3
	script:
		
		
	"""
	deal-duplicateID.pl $aa


	"""

}


result3_3.subscribe {log_file.append("$it") }


process step3_2_concatenate{
	input:
	 file nn_tocon from aln_nn_tocon.collect()
	 file p from path_file
	output:
	 file 'concatenation.fasta_aln' into concatenate_aln_best,concatenate_aln_phy
	 stdout result3_4
	
	"""
	step3-2_concateAlign  "concatenation.fasta_aln"
	"""

}

result3_4.subscribe {log_file.append("$it") }
process step4_1_produce_treebest {

        input:
		file con_fasta_aln from concatenate_aln_best
		file p from path_file
        output:
		file 'concatenation.ph' into con_ph_best
		stdout result4_1
	when:
		params.tree_mode == 'treebest'

	script:
        """
        treebest best -o concatenation.ph concatenation.fasta_aln
        """

}
result4_1.subscribe {log_file.append("$it") }
process step4_1_produce_tree_phyml {

        input:
		file con_fasta_aln from concatenate_aln_phy
		file p from path_file
        output:
		file 'concatenation.ph' into con_ph_phy
		stdout result4_2
	when:
		params.tree_mode == 'phyml'

	script:
        """
	touch tempp.code
	touch tempp
	t_coffee -other_pg seq_reformat -in concatenation.fasta_aln -output code_name>  tempp.code
	t_coffee -other_pg seq_reformat -code  tempp.code -in  concatenation.fasta_aln -output phylip > tempp
	phyml -i tempp -b 0
	postprocess-4-phyml.pl tempp concatenation.ph
        """

}

result4_2.subscribe {log_file.append("$it") }
process step4_2_deal_cluster{
	

	input:
	 file  nnn from aln_fasta_nn_4_1.collect()
	 file p from path_file
	output:
	 file 'cluster*.aln_nn' into aln_4_2,aln_4_2_phy
	 stdout result4_3
	"""
	deal_clustername.pl $nnn
	"""
}



result4_3.subscribe {log_file.append("$it") }



process step4_2_produce_tree {
	 errorStrategy 'ignore'
	input:
		file aln_nn from aln_4_2.flatten()
		file con from con_ph_best
		file speciesTree from speciesTree_file
		file p from path_file
	output:
		file '*.ph' into clu_ph
		stdout result4_4
        when:
                params.tree_mode == 'treebest'

        script:
	"""
	treebest best -o ${aln_nn.getBaseName()}".ph" $aln_nn -f $speciesTree

	"""

}


result4_4.subscribe {log_file.append("$it") }
process step4_2_produce_tree_phyml {
	 errorStrategy 'ignore'
	input:
		file aln_nn from aln_4_2_phy.flatten()
		file con from con_ph_phy
		file speciesTree from speciesTree_file
		file p from path_file
	output:
		file '*.ph' into clu_ph_phy
		stdout result4_5
        when:
                params.tree_mode == 'phyml'

        script:
	"""
	touch tempp.code
	touch tempp
	t_coffee -other_pg seq_reformat -in $aln_nn -output code_name>  tempp.code
	t_coffee -other_pg seq_reformat -code  tempp.code -in  $aln_nn -output phylip > tempp
	phyml -i tempp -b 0
	postprocess-4-phyml.pl tempp ${aln_nn.getBaseName()}.ph

	"""

}
result4_5.subscribe {log_file.append("$it") }
process step4_3_produce_tree {

	input:
		file cluster_ph from clu_ph.collect()
		file con from con_ph_best
		file p from path_file

	output:
		file 'final.ph' into final_result
		stdout result4_6
	 when:
                params.tree_mode == 'treebest'
	 script:	
	"""
	mergeGroup2bigTree concatenation.ph final.ph 
	"""

}
result4_6.subscribe {log_file.append("$it") }

process step4_3_produce_tree_phyml {

	input:
		file cluster_ph from clu_ph_phy.collect()
		file con from con_ph_phy
		file p from path_file

	output:
		file 'final.ph' into final_result_phyml
		stdout result4_7
	 when:
                params.tree_mode == 'phyml'
	 script:
	"""
	mergeGroup2bigTree concatenation.ph final.ph 
	"""

}
result4_7.subscribe {log_file.append("$it") }
