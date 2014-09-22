readme

Scripts to parse output from PSortB bioinformatics package.

Usage: nohup ./main_psortb_shellparse_v2.sh
OR
nohup ./main_psortb_shellparse.sh

PSortB produces 3 output files for each partition. For example, for partition 3496, three files are produced: 
3496_psorta (for archaea), 3496_psortp (for Gram +ve bacteria) and 3496_psortn (for Gram -ve bacteria).
This distribution has shell scripts and python programs to combine output from PSortB and generate an output
file that has a list of partitions and proteins/peptides that are likely to be secreted extra-cellularly. 	

1) main_psortb_shellparse.sh
	Shell script to repeatedly call Python script (psortb_parser_v2.py)
	Pastes together PSortB output files by partition. You will have 3 PSortB files for each partition.
	Say the partition number is 3496. Then you will have 3 files 3496_psorta, 3496_psortn, 3496_psortp
	(corresponding to archaea, Gram -ve and Gram +ve).
	This shell script pastes all the files together (for each partition). 
	It then calls the Python parser to parse that temporary file.
	Finally, it creates a consolidated output file that has data from all partitions.

2) main_psortb_shellparse_v2.sh
	Shell script similar to main_psortb_shellparse.sh
	Only difference is it produces a summary final flag that is Y for Extracellular and N for not.
	It calls the python script psortb_parser_v3.py

3) psortb_parser_v2.py 
	More sophisticated Python script to parse PSortB output files
	Called from shell script main_psortb_shellparse.sh


4) psortb_parser_v3.py
	Similar to psortb_parser_v2.py
	Only difference is it produces a summary final flag that is Y for Extracellular and N for not.
	At least one of n/p/a has Extracellular AND each of n/p/a has only Unknown or Extracellular (but nothing like Cytoplasm etc).

5) psortb_parser_v1.py
	Python script to parse PSortB output (see files 3496_psorta, 3496_psortn, 3496_psortp)
	Usage: 
	python psortb_parser_v1.py '3496_psorta' '3496_psortb_output_parsed.txt'


6) Sample output files from PSortB
	 3496_psorta, 3496_psortn, 3496_psortp,2223_psorta, 2223_psortn, 2223_psortp