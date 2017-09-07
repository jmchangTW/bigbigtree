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

params.py_diff = "$baseDir/scripts/fasta_compare.py"
diff = file(params.py_diff)


params.msa_met="fmcoffee"
params.aa_dir = "$baseDir/res_dic/aa_fasta"
params.nn_dir = "$baseDir/res_dic/nn_fasta"
params.aln_dir = "$baseDir/res_dic/alns"
params.config_cluster = "CRG"

params.step3_1aln = "$baseDir/tmp_scripts/step3_1.py"
step3_1 = file(params.step3_1aln)

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


TCOFFEE_PAREMETER=['-multi_core', 'no', '+keep_name', '-output', 'fasta_aln']

if(params.msa_met == "mcoffee"){
	TCOFFEE_PAREMETER += ['-mode', 'mcoffee']
}
else if(params.msa_met == "fmcoffee"){
	TCOFFEE_PAREMETER += ['-mode', 'fmcoffee']
}
else if(params.msa_met != "tcoffee"){
	println "[ERROR] unknow method for MSA" + params.msa_met
}

aln_Dir = file(params.aln_dir)
result = aln_Dir.mkdir()
println result ? "create aln folder" : "aln folder exist"



process step3_1performAln {

	output:
	stdout r

	"""
	python $step3_1 params.aa_dir params.nn_dir params.aln_dir params.msa_met params.config_cluster
	"""

}

r.subscribe { println it }
