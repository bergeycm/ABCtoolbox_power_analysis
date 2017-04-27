#populates input files for ABCestimator following the example in the ABCtoolbox/example/linux directory 

def fill_estimator_input_file(num_sum_stats, num_str, num_dna, num_inds):
	file = 'ABCestimator_%d_%d_%d_%d.input' % (num_str, num_dna, num_inds, num_sum_stats)
	input_file = open(file, 'a')
	x1 = '//inputfile for the program ABCestimator \nestimationType standard \n//file with the simulations. Consists of first the parameters and then the stats. A header line is required! \n'
	x2 = 'simName example_output_%d_%d_%d_%d_sampling1.txt \n' % (num_str, num_dna, num_inds, num_sum_stats)
	x3 = '//file with obnserved statistics. A Header is required with names corresponding to the stats in the simfile! \nobsName	both_sum_stats_%d_%d_%d_%d.obs \n' % (num_str, num_dna, num_inds, num_sum_stats)
	x4 = '//columns containg parameters for which estimates will be produced \nparams	2-7 \n//number of simulations to estimate the GLM on \nnumRetained	1000 \nmaxReadSims	10000 \n//the width of the diracpeaks, affecting the smoothing.. \ndiracPeakWidth 0.02 \n//number of points at which to estimate posterior density \nposteriorDensityPoints 200 \n//should the statistics be standardized? values: 1 / 0 (default) \nstadardizeStats 1 \n//should the prior be written in a file? values: 0 (default) / 1 \nwriteRetained 1 \nobsPValue	1'
	x5 = 'outputPrefix ABC_GLM_%d_%d_%d_%d' % (num_str, num_dna, num_inds, num_sum_stats) 
	input_file.write(x1)
	input_file.write(x2)
	input_file.write(x3)
	input_file.write(x4)

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
					fill_estimator_input_file(i, j, k, l)
