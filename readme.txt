readme

1) psortb_parser_v1.py
	Python script to parse PSortB output (see files 3496_psorta, 3496_psortn, 3496_psortp)
	Usage: 
	python psortb_parser_v1.py '3496_psorta' '3496_psortb_output_parsed.txt'

2) psortb_parser_v2.py 
	More sophisticated Python script to parse PSortB output files
	Called from shell script main_psortb_shellparse.sh
	

3) main_psortb_shellparse.sh
	Shell script to repeatedly call Python script (psortb_parser_v2.py)
	Pastes together PSortB output files by partition. You will have 3 PSortB files for each partition.
	Say the partition number is 3496. Then you will have 3 files 3496_psorta, 3496_psortn, 3496_psortp
	(corresponding to archaea, Gram -ve and Gram +ve).
	This shell script pastes all the files together (for each partition). 
	It then calls the Python parser to parse that temporary file.
	Finally, it creates a consolidated output file that has data from all partitions.

4) Sample output files from PSortB
	 3496_psorta, 3496_psortn, 3496_psortp,2223_psorta, 2223_psortn, 2223_psortp