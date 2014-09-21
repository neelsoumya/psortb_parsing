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
#   Assumes that SignalP produces a bunch of files of the form 997_signalp_neg, 997_signalp_pos
#   where neg is for Gram negative bacteria and pos is for Gram positive bacteria.
#   This program combines data from both files to produce a single output variable that is the logical OR
#   i.e. if a peptide is secreted in either the neg or pos files, it will output Yes.
#   This shell script repeatedly iterates over many files of the type
#   997_signalp_neg, 997_signalp_pos and repeatedly call the program signalp_parse_v7_generic.py
#   Finally it cleans up temporary files and produces a consolidated output file
#   Has logic to output FINAL flag (Y for Extracellular protein, N for not). 
#
#   Example input format: 997_signalp_neg
#
#   name                     Cmax  pos  Ymax  pos  Smax  pos  Smean   D     ?  Dmaxcut    Networks-used     
#   PROKKA_00001               0.104  26  0.123  11  0.186   3  0.159   0.136 N  0.510      SignalP-TM       
#   PROKKA_00002               0.111  28  0.197  12  0.459   9  0.391   0.288 N  0.570      SignalP-noTM     
#
#
# Output - FINAL_SignalP_parsed_file_secreted
#	Partition_number        Protein_id      Dthreshold_neg  Signalp_neg     Dthreshold_pos  Signalp_pos     Signalp_output_FINAL
#	1003    PROKKA_00001    0.136   N       N       0.122   N
#	1003    PROKKA_00002    0.288   N       N       0.270   N
#	1003    PROKKA_00003    0.159   N       N       0.141   N
#	1003    PROKKA_00004    0.096   N       N       0.108   N
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


