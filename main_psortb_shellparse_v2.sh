#!/bin/sh

#################################################################
# Name - main_psortb_shellparse_v2.sh
# Creation Date - 20th September 2014
# Author: Soumya Banerjee
# Website: https://sites.google.com/site/neelsoumya/
#
# Description:
#   Shell script to repeatedly call SignalP parser
#   Parse output from SignalP, but "pasted" for both Gram -ve and +ve
#   Complications: SignalP does not produce tab delimited or comma separated output
#   Repeatedly calls from signalp_parse_v7_generic.py
#
#   PSortB produces 3 output files for each partition. For example, for partition 3496, three files are produced: 
#   3496_psorta (for archaea), 3496_psortp (for Gram +ve bacteria) and 3496_psortn (for Gram -ve bacteria).
#   This distribution has shell scripts and python programs to combine output from PSortB and generate an output
#   file that has a list of partitions and proteins/peptides that are likely to be secreted extra-cellularly. 		
#
#   Assumes that SignalP produces a bunch of files of the form 997_signalp_neg, 997_signalp_pos
#   where neg is for Gram negative bacteria and pos is for Gram positive bacteria.
#   This program combines data from both files to produce a single output variable that is the logical OR
#   i.e. if a peptide is secreted in either the neg or pos files, it will output Yes.
#   This shell script repeatedly iterates over many files of the type
#   997_signalp_neg, 997_signalp_pos and repeatedly call the program signalp_parse_v7_generic.py
#   Finally it cleans up temporary files and produces a consolidated output file
#   Has logic to output FINAL flag (Y for Extracellular protein, N for not). 
#
#   Example input format: 3496_psorta
#	   SeqID					Localization		Score
#	   PROKKA_00001 hypothetical protein		Cytoplasmic		7.50
#	   PROKKA_00002 Conjugal transfer protein TrbE	CytoplasmicMembrane	10.00
#	   PROKKA_00003 hypothetical protein		Cytoplasmic		7.50
#
#
# Output - FINAL_SignalP_parsed_file_secreted
#	Partition_number  Protein_id      Protein_name    Localization_a  Score_a Localization_n  Score_n Localization_p  Score_p FINAL_extracellular_flag
#	1003    	  PROKKA_00001    Succinate dehydrogenase hydrophobic membrane anchor subunit     CytoplasmicMembrane     10.00   CytoplasmicMembrane     10.00   CytoplasmicMembrane     9.99    N
#	1003              PROKKA_00002    hypothetical protein    Unknown 2.50    Unknown 2.00    Unknown 2.50    N
#	1003              PROKKA_00003    hypothetical protein    Cytoplasmic     7.50    Unknown 2.00    Cytoplasmic     7.50    N
#
#
# Example - nohup ./main_psortb_shellparse_v2.sh
#
# License - GNU GPL
#
# Change History - 
#                   20th September 2014  - Creation by Soumya Banerjee
#
#################################################################
#################################################################



iCount=1
for file_name in `ls *psortn *psortp *psorta | sort`
do
	# this will generate files in the following order (sorted by partition)
	# 3496_psorta, 3496_psortn,3496_psortp
	# this implements a 3-way switch, i.e. first it switches to iCount = 1 for 'a' (for archaea)
	# then it switches to iCount = 2 (for 'n' Gram -ve) and then finally 
	# to iCount = 3 (for 'p' Gram +ve) and cycles back again (reset to iCount = 1) 
        if [ $iCount = 1 ]
        then
		# first is 'a' file
                archaea_filename=$file_name
                echo $archaea_filename

                # toggle 3-way switch to next phase (await for 'n') 
                iCount=2
        elif [ $iCount = 2 ]
	then
		# now in 'n' file
                negative_filename=$file_name
                echo $negative_filename

                # toggle 3-way switch to next phase (await for 'p') 
                iCount=3
	elif [ $iCount = 3 ] 
	then
		# you are in 'p' file now
		# finally, paste all 3 files (a,n,p) together
                paste $archaea_filename $negative_filename $file_name > temp_file

                # split name on _ (underscore) to get partition number
                str_partition_array=(${file_name//_/ })
                echo ${str_partition_array[0]}

                # call python parser to parse pasted file
                # syntax is python psortb_parser_v3.py 3496 '3496_psorta' '3496_psortb_output_parsed.txt'
                python psortb_parser_v3.py ${str_partition_array[0]} temp_file ${str_partition_array[0]}_psortb_parsed_output

                #cat temp_file

                # remove temp_file so that it is not read by for loop as list of files
                rm temp_file

                #echo $prev_filename 
                #echo $file_name
                #sleep 10
                #rm temp_file

                # toggle switch back to first position
                iCount=1
        fi

done


# concatenate all parsed output files of type 3496_psortb_output_parsed
# output header line
echo -e 'Partition_number\tProtein_id\tProtein_name\tLocalization_a\tScore_a\tLocalization_n\tScore_n\tLocalization_p\tScore_p\tFINAL_extracellular_flag' > FINAL_PSortB_parsed_file_secreted
cat *_psortb_parsed_output >> FINAL_PSortB_parsed_file_secreted


# remove temporary parsed files
rm *_psortb_parsed_output


