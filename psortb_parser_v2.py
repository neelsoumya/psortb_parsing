import csv

#################################################################
#################################################################
# Name - psortb_parser_v2.py
# Creation Date - 20th September 2014
# Author: Soumya Banerjee
# Website: https://sites.google.com/site/neelsoumya/
#
# Description:
#   Parse output from PSortB bioinformatics package
#   Called from main_psortb_shellparse.sh
#   Example input format (pasted files from archaea, Gram -ve and Gram +ve:
#	 SeqID   Localization    Score   SeqID   Localization    Score   SeqID   Localization    Score
# 	PROKKA_00001 hypothetical protein       Cytoplasmic     7.50    PROKKA_00001 hypothetical protein       Unknown 2.00    PROKKA_00001 hypothetical protein       Unknown 2.50
# 	PROKKA_00002 Conjugal transfer protein TrbE     CytoplasmicMembrane     10.00   PROKKA_00002 Conjugal transfer protein TrbE     CytoplasmicMembrane     10.00   PROKKA_00002 Conjugal transfer protein TrbE     CytoplasmicMembrane     9.99
#
#   We are interested in the PROKKA ids, protein names, Localization and Score for archaea, Gram -ve and Gram +ve.
#   The columns SeqID, Localization and Score are tab delimited	
#   However the PROKKA ids and protein names (part of SeqID) are space delimited
#
#
# Input - 3496_all_anp_pasted
# 	SeqID   Localization    Score   SeqID   Localization    Score   SeqID   Localization    Score
# 	PROKKA_00001 hypothetical protein       Cytoplasmic     7.50    PROKKA_00001 hypothetical protein       Unknown 2.00    PROKKA_00001 hypothetical protein       Unknown 2.50
# 	PROKKA_00002 Conjugal transfer protein TrbE     CytoplasmicMembrane     10.00   PROKKA_00002 Conjugal transfer protein TrbE     CytoplasmicMembrane     10.00   PROKKA_00002 Conjugal transfer protein TrbE     CytoplasmicMembrane     9.99
#
#
# Output - 3496_psortb_output_parsed.txt
#	PROKKA_00001    hypothetical protein    Cytoplasmic     7.50
#	PROKKA_00002    Conjugal transfer protein TrbE  CytoplasmicMembrane     10.00
#	PROKKA_00003    hypothetical protein    Cytoplasmic     7.50
#
#
# Example - python psortb_parser_v2.py 3496 '3496_all_anp_pasted' '3496_psortb_output_parsed.txt'
#
# License - GNU GPL
#
# Change History - 
#                   20th September 2014  - Creation by Soumya Banerjee
#
#################################################################
#################################################################

def func_column_parser(i_partition_id,input_file_prism,output_file):


    ##########################
    # open output file
    ##########################

    output_file_ptr  = open(output_file, 'w')

    ###################################################################################
    # read input file
    ###################################################################################

    iLine_number = 1
    with open(input_file_prism, 'r') as input_file_ptr_prism:
        
        for line in input_file_ptr_prism:

	    # if not header line, then parse else skip header line	
	    if iLine_number > 1:
	    	# extract columns (tab delimited)	
            	str_temp = str(line)
            	str_split_line = str_temp.split('\t')

		localization_a = str_split_line[1] 
		score_a = str_split_line[2]
		localization_n = str_split_line[4]
		score_n = str_split_line[5]
		localization_p = str_split_line[7]
		score_p = str_split_line[8]

	    	# extract PROKKA id and protein name from 1st column (separated by spaces)
	    	str_id_name = str_split_line[0].split(' ')
		str_protein_id = str_id_name[0]
	    	str_protein_name = ' '.join(str_id_name[1:])	    
         	
            	# format is 
		# 3496	PROKKA_00001    hypothetical protein    Cytoplasmic     7.50 Cytoplasmic     7.00 Cytoplasmic     8.50 
            	output_file_ptr.write('\t'.join([ str(i_partition_id), str_protein_id, str_protein_name, localization_a, score_a, localization_n, score_n, localization_p, score_p ]))
                  
	    # else if iLine_number = 1  
	    else:
		pass	

	    # Increment line number
	    iLine_number = iLine_number + 1		


    # close file pointer	
    output_file_ptr.close()

    print('done')


if __name__ == "__main__":
    import sys
    func_column_parser(int(sys.argv[1]),str(sys.argv[2]),str(sys.argv[3]))

