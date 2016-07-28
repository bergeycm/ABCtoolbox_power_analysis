#this script populates a qsub file with all of calls of arlsumstat for numbers of DNA and MICROSAT markers
#arlsumstat will compute summary stats on the input files
#directions on how to run arlsumstat are found at http://cmpg.unibe.ch/software/arlequin35/man/arlsumstat_readme.txt

def arlsumstat_loop(file):
	input_file = open(file, 'a')
	#str_values is an array of all possible number of STRs
	str_values = [0, 25, 50, 100, 500, 1000, 2000, 3000, 4000, 5000, 10000]
	#dna_values is an array of all possible sums of DNA sequences linked and unlinked
	dna_values = [0, 50, 100, 500, 1000, 2000, 3000, 4000, 5000, 25, 75, 125, 525, 1025, 2025, 3025, 4025, 5025, 150, 550, 1050, 2050, 3050, 4050, 5050, 200, 600, 1100, 2100, 3100, 4100, 5100, 1500, 2500, 3500, 4500, 5500, 6000, 7000, 8000, 9000, 10000, 10050, 10100, 10500, 11000, 12000, 13000, 14000, 15000]
	#ind_values is an array of all possible number of individuals
	ind_values = [1, 2, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 200]
	for i in range(1, 1001):
		for j in dna_values:
			for l in ind_values:
				input_file.write('./arlsumstat dna_%d_%d/dna_%d_%d_1_%d.arp dna_%d_%d_sum_stats_%d 0 1 \n' % (j, l, j, l, i, j, l, i))
		for k in str_values:
			input_file.write('./arlsumstat str_%d_%d/str_%d_%d_1_%d.arp str_%d_%d_sum_stats_%d 0 1 \n' % (k, l, k, l, i, k, l, i))

if __name__ == '__main__':
	arlsumstat_loop('qsub.arlsumstatloop')
