# Pipeline for Hydra comparative genomics analysis

## Before start

Install programmes used in the pipeline:

- [Trinity](https://github.com/trinityrnaseq/trinityrnaseq/wiki)

- [cd-hit](http://cd-hit.org/)

- [TransDecoder](https://github.com/TransDecoder/TransDecoder/wiki)

- [blast+](https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download)

- [MUSCLE](https://www.drive5.com/muscle/)

- [gblocks](http://molevol.cmima.csic.es/castresana/Gblocks.html)

- [RaXML](https://cme.h-its.org/exelixis/web/software/raxml/index.html)

- [FastTree](http://www.microbesonline.org/fasttree/) : (optinal) much faster than RaXML and produce similar result in these dataset

- [r8s](http://ceiba.biosci.arizona.edu/r8s/index.html)

- [OrthoFinder](https://github.com/davidemms/OrthoFinder)

- [DIAMOND](https://ab.inf.uni-tuebingen.de/software/diamond/) : protein aligner used OrthoFInder

- [dnaPipeTE](https://github.com/clemgoub/dnaPipeTE)

- [Gephi](https://gephi.org/) : network visualisation

Files:

[hydra2.0_genemodels.aa](https://research.nhgri.nih.gov/hydra/download/?dl=aa) : protein model from hydra genome 2.0 project



## Protein sequence from raw reads

### Assembly transcriptome using Trinity

Optimise the memory and cpu usage base on your working condition.

`Trinity --seqType fq --max_memory 120G --CPU 18 --output <species>_trinity_out_dir --left <species>_reads_1.fq.gz  --right <species>_reads_2.fq.gz`

Rename the `Trinity.fasta` after Trinity finished

```bash
cd <species>_trinity_out_dir
mv Trinity.fa <species>_Trinity.fa
```

### Using CDhit to cluster highly similar sequences and remove redudants

`cd-hit-est -o <species>_Trinity_cdhit.fasta -c 0.98 -i <species>_Trinity.fasta -p 1 -d 0 -b 3 -T 10`

### Petides prediction with Transcoder

```bash
# prepare a directory for species peptide sequences
mkdir all_pep

# run transdecoder on each species
cd <path>/<species>_trinity_out_dir>
TransDecoder.LongOrfs -t <species>_Trinity_cdhit.fasta
TransDecoder.Predict -t <species>_Trinity_cdhit.fasta

# rename the peptide files and gather them to one place
mv longest_orfs.pep <species>.pep
mv <species>.pep all_pep
```

## RaXML tree construction and divergence estimation using r8s

```bash
cd all_pep

# blast the species pep against reference amino acid seq
blastp -query <species>.pep -db /proj/Simakov/HYDRA/hydra2.0_genemodels.aa -outfmt 6 -evalue 1e-6 -num_threads 10  -out <species>.blastp

# generate mbh for each species
perl /proj/Simakov/scripts/CLUSTERING/mahMbh.pl <species>.blastp > <species>.mbh

# combine all mbh into one file
perl /proj/Simakov/scripts/CLUSTERING/combMbh.pl <species1>.mbh <species2>.mbh <species3>.mbh <...> > all.mbh.clus

# align using MUSCLE and curate alignment using gblocks (using perl wrapper scripts)
perl /proj/Simakov/scripts/runMuscleFT.pl
perl /proj/Simakov/scripts/concatAlignments.pl aln-gb > concat.aln

# build tree using RaXML
raxmlHPC -m GTRGAMMA -s concat.aln -n concat.aln.tree -# 1000
# (or) build tree using FastTree
FastTree concat.aln > concat.aln.tree

# estimate Divergence Time by r8s
# convert .newick to .nexus from RaXML/FastTree (we use figtree: Save Trees > 'Nexus')
# add r8s block to nexus arccording to http://oldsaf.bio.caltech.edu/saf_manuals/r8s.manual.pdf
# divtime method=lf; fixage taxon=bil age=550;
r8s -f hydra.nexus
```

## Orthofinder analysis

```bash
mkdir <path>/hydra_orthofinder
mv <hvir>.fa hydra2.0_genemodels.aa <path>/hydra_orthofinder
orthofinder -a 8 -f <path>/hydra_orthofinder -S diamond
```

## TE annotation using DNApipeTE

```bash
# run DNApipeTE using either left/right read.fa.gz or combined read.fa.gz
python3 dnaPipeTE.py -input <species>_reads_combine.fq.gz -output <species>_dnapipete_output -sample_size 1000000 -sample_number 2 -cpu 20

# parse the output file from DNApipeTE (for class and family count)
cd <species>_dnapipete_output
perl dnaPipeTESum.pl reads_per_component_and_annotation > <species>_families.sum  >& <species>_classes.sum
```

## LINE element analysis

```bash
# after DNApipeTE, rename line.fa for each species
cd <species>_dnapipete_output/Annotation
# add species name to fasta header
awk -v species=<species> '$1~/^>/ {n=gsub(/>/,">"species,$1);print n}{print}' LINE_annoted.fasta > <species>.line.fa

# also parse the name in reads_per_component_and_annotation
cd ../
awk -v species=<species> 'BEGIN{FS=" "}{gsub(/^/,species"_",$3);print}' > <species>_reads_per_component_and_annotation
cd ../
find . -name *reads_per_component_and_annotation -exec 'cat {} > all_reads_per_component_and_annotation' \;

# merge all line from all species
find . -name '*line.fa' -exec 'cat {} > hydra_line.fa' \;

# all-to-all blastn
blastn -subject hydra_line.fa -query hydra_line.fa -out hydra_a2a -outfmt 6

# parse blast output (outfmt=6) to edge.csv
python3 parse_blast_output.py hydra_a2a > line_edge_weight.tsv
awk 'BEGIN{FS="\t";OFS=",";print "Source,Target,Mutation,Type,Weight"} {m=1/$3;print $1,$2,m,"unidirected",$3}' line_edge_weight.tsv > line_edges.csv

# parse reads_per_component_and_annotation to node.csv
awk 'BEGIN{FS=" ";OFS=",";print "ID,N"} print{$3,$1}' all_reads_per_component_and_annotation > all_node.csv
# extract LINE id
awk 'NR==FNR{a[$1];next} $1 in a{print}' line_edge_weight.tsv all_node.csv > line_node.csv

# import line_node.csv and line_edge.csv to gephi for network visualisation
```

## CR1/L2 element analysis

```bash
# continues from TE annotation using DNApipeTE

# extract CR1 and L2 id
awk '$6~/CR1|L2/ {print $3}' reads_per_component_and_annotation > <species>_CR1L2.id
# extract sequence
cd Annotation
seqkit grep -f <species>_CR1L2.id LINE_annoted.fasta > <species>_CR1L2.fa

# apply LINE element analysis on CR1/L2 subset
```

## Plots

```bash
# TE bar plot, continue from TE annotation using DNApipeTE
cp <species>_classes.sum r_plots
# plot using line_expansion_bar_flip.R

# TE familes plot, continue from TE annotation using DNApipeTE
cp <species>_families.sum r_plots
# plot using families_plot.R

# ortholog plot, continue from Orthofinder analysis
cp <path>/hydra_orthofinder/Statistics_PerSpecies_perc.csv r_plots
# plot using orthofinder_plot.R
```

