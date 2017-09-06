import sys
input1 = sys.argv[1]
input2 = sys.argv[2]

file_aa = open(input1,"r")
file_nn = open(input2,"r")

f = open('fasta_diff.txt', "w")

def readFa(file_fasta):
#	print(file_fasta.read())
	dic, k , v = {}, '', []
	for i in file_fasta:
		if i.startswith('>'):
			dic[k] = v
			k = i[1:-1]
			v = []
		else:
			v.append(i)
	dic[k] = v
	dic.pop('')

#	print "%s sequences in total" % len(dic)
#	for (k, v) in dic.items():
#   		print("SEQUENCE: %s\nLENGTH:%s" % (k, sum(map(len, v))))
	return dic

dic_aa = readFa(file_aa)
dic_nn = readFa(file_nn)

for (seq_aa_name, v_aa) in dic_aa.items():
	for (seq_nn_name, v_nn) in dic_nn.items():
		if seq_aa_name == seq_nn_name :	
			aa_count = sum(map(len,v_aa))
			nn_count = sum(map(len,v_nn))	
			if aa_count*3 != nn_count:
				print("length different")
				print("%s" % seq_aa_name)
				print("aa_length: %d" % (aa_count))
				print("nn_length: %d" % (nn_count))
				print("------------------\n")
				f.write("length different\n")
                                f.write("%s\n" % seq_aa_name)
                                f.write("aa_length: %d\n" % (aa_count))
                                f.write("nn_length: %d\n" % (nn_count))
                                f.write("------------------\n")


