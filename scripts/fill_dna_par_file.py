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

def fill_dna_par_file(num_dna, num_inds):

    file = par_dir + 'dna_%d_%d.par' % (num_dna, num_inds)
    input_file = open(file, 'w')

    x1 = '//Per chromosome: Number of linkage blocks \n'
    x2 = '1 \n'
    x3 = ('//per Block: data type, num loci, rec. rate and mut rate + '
          'optional parameters \n')
    x4 = 'DNA 500 0.00000 0.00000002 0.33 \n'

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
    input_file.write('%d 1 \n' % num_dna)

    for i in range(num_dna):
        input_file.write(x1)
        input_file.write(x2)
        input_file.write(x3)
        input_file.write(x4)

    input_file.close()

if __name__ == '__main__':

    # dna_values is an array of all counts of DNA sequences, linked and unlinked
    dna_values = [500, 1000, 2000, 5000, 10000, 15000]
    # ind_values is an array of all possible number of individuals
    ind_values = [1, 2, 5, 10, 25, 50, 100]

    for j in dna_values:
        for k in ind_values:
            fill_dna_par_file(j, k)
