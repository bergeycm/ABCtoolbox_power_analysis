#converts summary stastics files that have statistics for both genetic markers into a format that ABCestimator can interpret 

def combine(file):
	lines = open(file).readlines()
	#print(lines)
	one = lines[0].rstrip()
	one = one + '\t'
	two = lines[1].rstrip()
	two = two + '\t'
	three = lines[2]
	four = lines[3]
	f = open(file, 'w')
	f.write('Obs0_H_1\tObs0_S_1\tObs0_D_1\tObs0_FS_1\tObs0_Pi_1\tObs1_Ksd_1\tObs1_Hsd_1\tObs1_GW_1\tObs1_R_1\tObs1_Rsd_1\n')
	f.write(two+four)

if __name__ == '__main__':
	#str_values is an array of all possible number of STRs
	str_values = [0, 25, 50, 100, 500, 1000, 2000, 3000, 4000, 5000, 10000]
	#dna_values is an array of all possible sums of DNA sequences linked and unlinked
	dna_values = [0, 50, 100, 500, 1000, 2000, 3000, 4000, 5000, 25, 75, 125, 525, 1025, 2025, 3025, 4025, 5025, 150, 550, 1050, 2050, 3050, 4050, 5050, 200, 600, 1100, 2100, 3100, 4100, 5100, 1500, 2500, 3500, 4500, 5500, 6000, 7000, 8000, 9000, 10000, 10050, 10100, 10500, 11000, 12000, 13000, 14000, 15000]
	#ind_values is an array of all possible number of individuals
	ind_values = [1, 2, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 200]
	for i in range(1,1001):
		for j in str_values:
			for k in dna_values:
				for l in ind_values
				combine('both_sum_stats_%d_%d_%d_%d.obs' % (j, k, l, i))	
