#populates input files for ABCsampler
#follows example found in ABCtoolbox/example/linux directory when the toolbox is first downloaded

def fill_sampler_input_file(num_sum_stats, num_str, num_dna, num_inds):
	file = '%d_%d_%d_%d.input' % (num_str, num_dna, num_inds, num_sum_stats)
	input_file = open(file, 'a')
	x1 = 'samplerType standard \n'
	x2 = 'estName exampleDNA_and_STR.est  \n'
	x3 = 'obsName dna_%d_%d_sum_stats_%d.obs;str_%d_%d_sum_stats_%d.obs \n' % (num_dna, num_inds, num_sum_stats, num_str, num_inds, num_sum_stats)
	x4 = 'simDataName dna_%d_%d_1_%d.arp;str_%d_%d_1_%darp \n' % (num_dna, num_inds, num_sum_stats, num_str, num_inds, num_sum_stats)
	x5 = 'outName example_output_%d_%d_%d_%d \n' % (num_str, num_dna, num_inds, num_sum_stats)
	x6 = 'separateOutputFiles 1 \nnbSims 10000 \nwriteHeader 1 \nsimulationProgram fsc25 \n'
	x7 = 'simInputName dna_%d_%d.par;str_%d_%d.par \n' % (num_dna, num_inds, num_str, num_inds)
	x8 = 'simParam -i#dna_%d_%d.par#-n#1;-i#str_%d_%d.par#-n#1 \n' % (num_dna, num_inds, num_str, num_inds)
	x9 = 'sumStatProgram arlsumstat \nsumStatParam SIMDATANAME#SSFILENAME#0#1'
	input_file.write(x1)
	input_file.write(x2)
	input_file.write(x3)
	input_file.write(x4)
	input_file.write(x5)
	input_file.write(x6)
	input_file.write(x7)
	input_file.write(x8)
	input_file.write(x9)

if __name__ == '__main__':
	#str_values is an array of all possible number of STRs
	str_values = [0, 25, 50, 100, 500, 1000, 2000, 3000, 4000, 5000, 10000]
	#dna_values is an array of all possible sums of DNA sequences linked and unlinked
	dna_values = [0, 50, 100, 500, 1000, 2000, 3000, 4000, 5000, 25, 75, 125, 525, 1025, 2025, 3025, 4025, 5025, 150, 550, 1050, 2050, 3050, 4050, 5050, 200, 600, 1100, 2100, 3100, 4100, 5100, 1500, 2500, 3500, 4500, 5500, 6000, 7000, 8000, 9000, 10000, 10050, 10100, 10500, 11000, 12000, 13000, 14000, 15000]
	#ind_values is an array of all possible number of individuals
	ind_values = [1, 2, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 200]
	for i in range(1, 1001):
		for j in str_values:
			for k in dna_values:
				for l in ind_values:
					fill_sampler_input_file(i, j, k, l)
