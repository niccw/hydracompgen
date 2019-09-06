#!/usr/bin/env python3

import sys
#path
#/Users/niccw/Desktop/vlogin3/hydra/greenBrown/May2019/LINE_expansion/all_CR1_a2ablastn
# Default 12 columns (Query Seq-id, Subject Seq-id, Percentage of identical matches, 
# Alignment length, Number of mismatches, Number of gap openings, Start of alignment in query, 
# End of alignment in query, Start of alignment in subject, End of alignment in subject, Expect value, Bit score)

# E-value col 11 (lower better)
# bit score col 12 (higher better)
# use float("string") to handle scientific notation

def parse_blast_output(path:str):
    d = {}
    with open(path,"r") as f:
        for line in f:
            [query,subject,_,_,_,_,_,_,_,_,evalue,bs] = line.strip().split("\t")
            # concat query and subject (defined order)
            if query < subject:
                key = query + ";" + subject
            else:
                key = subject + ";" + query
            # add/update dict
            if key not in d:
                d[key] = bs
            else:
                # compare bit score
                if bs > d[key]:
                    d[key] = bs
    
    # print
    for k,v in d.items():
        ids = k.split(";")
        print(f"{ids[0]}\t{ids[1]}\t{v}")          


if __name__ == "__main__":
    parse_blast_output(sys.argv[1])
