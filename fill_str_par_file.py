#!/usr/bin/env python

# ----------------------------------------------------------------------------------------
# --- Write par files for all counts of DNA sequences and individuals
# ----------------------------------------------------------------------------------------

import os

# Create folder to hold par files if it doesn't exist
par_dir = "results/par_files/"
if not os.path.exists(os.path.dirname(par_dir)):
    os.makedirs(os.path.dirname(par_dir))

# par files were created following the example files found in the
# ABCtoolbox/example/linux directory

def fill_str_par_file(num_str, num_inds):

    file = par_dir + 'str_%d_%d.par' % (num_str, num_inds)
    input_file = open(file, 'w')

    x1 = '//Per chromosome: Number of linkage blocks \n'
    x2 = '1 \n'
    x3 = ('//per Block: data type, num loci, rec. rate and mut rate + '
    	  'optional parameters \n')
    x4 = 'MICROSAT 1 0.0000 0.0005 0 0 \n'

    input_file.write('//Number of population samples (demes) \n')
    input_file.write('1 \n')
    input_file.write('//Population effective sizes (number of genes) \n')
    input_file.write('15000 \n')
    input_file.write('//Sample sizes: 2*N \n')
    sample_size = 2*num_inds
    input_file.write('%d \n' % sample_size)
    input_file.write('//Growth rates  : negative growth implies population expansion \n') 
    input_file.write('0 \n')
    input_file.write('//Number of migration matrices : \n')
    input_file.write('0 \n')
    input_file.write(('//historical event: time, source, sink, migrants, new size, '
    	              'new growth rate, migration matrix \n'))
    input_file.write('2 historical events \n')
    input_file.write('970 0 0 0 1 0.25 0 \n')
    input_file.write('870 0 0 0 1 -0.1 0 \n')
    input_file.write('//Number of independent loci [chromosome] \n')
    input_file.write('%d 1 \n' % num_str)

    for i in range(num_str):
        input_file.write(x1)
        input_file.write(x2)
        input_file.write(x3)
        input_file.write(x4)

    input_file.close()

if __name__ == '__main__':

    # str_values is an array of all possible numbers of STRs
    str_values = [0, 25, 50, 100, 500, 1000, 2000, 3000, 4000, 5000, 10000]
    # ind_values is an array of all possible number of individuals
    ind_values = [1, 2, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 200]

    for j in str_values:
        for k in ind_values:
            fill_str_par_file(j, k)
