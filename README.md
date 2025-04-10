# Antimicrobial peptides in Lactobacillaceae

## 1. Genome download

```sh
## prepare the conda environment
https://github.com/Carrion-lab/bacLIFE/archive/refs/heads/main.zip
unzip bacLIFE-main.zip
cd bacLIFE-main
conda env create -f bacLIFE_download.yml

## get the NCBI accession number
conda activate bacLIFE_download
esearch -db assembly -query '("Lactobacillaceae"[Organism] OR Lactobacillaceae[All Fields]) AND ("latest refseq"[filter] AND all[filter] NOT anomalous[filter])' | esummary | xtract -pattern DocumentSummary -element AssemblyAccession > NCBI_accs.txt

## download genmome based on NCBI accession number
# the quality information were downloaded from https://www.ncbi.nlm.nih.gov/datasets/genome/
mkdir genomes/
cd genomes/
bit-dl-ncbi-assemblies -w ../NCBI_accs.txt -f fasta -j 10
gzip -d ./*.gz

```

## 2. AMPs prediction

```SH
## prepare the conda environment
conda create --name env_macrel -c bioconda macrel
conda install macrel

## AMP prediction
conda activate env_macrel
macrel contigs -t 80 --fasta genome.fna --output macrel.out_contigs
```

## 3. Clustering analysis of AMPs

```sh
conda install cd-hit
cd-hit -i AMP_lab.fna -o nonredu_AMP_lab.fasta -c 1 -T 24 -n 5 -d 0 -aS 1 -g 1 -sc 1 -sf 1
```

## 4. Physicochemical properties of AMPs

```sh
## a custom python script was used to determine physicochemical properties of AMPs
python script/AMP-Profiler.py

```

## 5. Prediction of AMP MICs using APEX v2

```sh
## we utilized a pre-trained deep learning model (https://gitlab.com/machine-biology-group-public/apex) to predict the MICs of AMP
conda create -n apex python==3.9
conda activate apex
pip install torch==1.11.0+cu113 torchvision==0.12.0+cu113 torchaudio==0.11.0 --extra-index-url https://download.pytorch.org/whl/cu113

python script/apex-main/predict.py nonredu_AMP_lab.fasta

```

## 6. Novelty assessment of AMPs

```sh
# Novelty assessment
conda install diamond
for i in AEP Human AMPSphere public.databases; do
diamond makedb --in ${i}.fasta --db ${i}_blastp_database
done

for i in AEP Human AMPSphere public.databases; do
diamond blastp --db ${i}_blastp_database.dmnd --query nonredu_AMP_lab.fasta -o LAB_AMP.vs.${i}_fmt6.txt --threads 15 -c1 -b6 --id 100 --query-cover 100 --max-target-seqs 1
done

# the link of each AMP database
AEP:https://www.nature.com/articles/s41551-024-01201-x#Sec47
Human:https://www.nature.com/articles/s41551-021-00801-1#Sec16
AMPSphere:https://ampsphere.big-data-biology.org/home
public.databases:https://dbaasp.org/home (DBAASP), http://dramp.cpu-bioinfor.org/ (DRAMP), https://aps.unmc.edu/AP/ (APD3)
```

## 7.R Script

```
The R code utilized in this study is saved in the directory named R/
```

