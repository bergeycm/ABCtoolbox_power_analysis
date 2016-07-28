#creates a qsub file with all of the calls to fastsimcoal2 that are needed to generate 1000 simulated data sets for all numbers of MICROSAT and DNA markers

#writes all calls of fastsimcoal2 to simulate 1000 data files for every number of STRs
def create_str_data_sets(num_str, num_inds):
	file = 'qsub.create_str_data_sets' 
	input_file = open(file, 'a')
	x1 = './fsc25 -i str_%d_%d.par -n1000 \n' % (num_str, num_inds)
	input_file.write(x1)

#writes all calls of fastsimcoal2 to similate 1000 data files for every number of DNA sequences
def create_dna_data_sets(num_dna, num_inds):
        file = 'qsub.create_dna_data_sets' 
        input_file = open(file, 'a')
        x2 = './fsc25 -i dna_%d_%d.par -n1000 \n' % (num_dna, num_inds)
        input_file.write(x2)

if __name__ == '__main__':
	#str_values is an array of all possible number of STRs
	str_values = [0, 25, 50, 100, 500, 1000, 2000, 3000, 4000, 5000, 10000]
	#dna_values is an array of all possible sums of DNA sequences linked and unlinked
	dna_values = [0, 50, 100, 500, 1000, 2000, 3000, 4000, 5000, 25, 75, 125, 525, 1025, 2025, 3025, 4025, 5025, 150, 550, 1050, 2050, 3050, 4050, 5050, 200, 600, 1100, 2100, 3100, 4100, 5100, 1500, 2500, 3500, 4500, 5500, 6000, 7000, 8000, 9000, 10000, 10050, 10100, 10500, 11000, 12000, 13000, 14000, 15000]
	#ind_values is an array of all possible number of individuals
	ind_values = [1, 2, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 200]
	for i in ind_values:
		for j in str_values:
			create_str_data_sets(j, i)
		for k in dna_values:
			create_dna_data_sets(k, i)
