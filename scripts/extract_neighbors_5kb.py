from collections import defaultdict
from Bio import SeqIO

# Step 1: 读取目标基因ID
with open("mge.amp.id") as f:
    target_ids = set(line.strip() for line in f if line.strip())

# Step 2: 读取GFF文件，构建 contig -> gene 列表
gene_positions_by_contig = defaultdict(list)
id_to_info = {}

with open("lac-lig.macrel.out.orfs.gff") as f:
    for line in f:
        if line.startswith("#") or not line.strip():
            continue
        fields = line.strip().split("\t")
        contig = fields[0]
        start = int(fields[3])
        end = int(fields[4])
        attributes = fields[8]

        gene_id = None
        for attr in attributes.split(";"):
            if attr.startswith("ID="):
                gene_id = attr.split("=")[1]
                break

        if gene_id:
            gene_info = {
                "id": gene_id,
                "start": start,
                "end": end,
                "center": (start + end) // 2
            }
            gene_positions_by_contig[contig].append(gene_info)
            id_to_info[gene_id] = {
                "contig": contig,
                "start": start,
                "end": end
            }

# Step 3: 读取所有蛋白质序列
fasta_dict = SeqIO.to_dict(SeqIO.parse("all.macrel.out.orfs.faa", "fasta"))

# Step 4: 提取目标基因 ±5kb 内的基因 和 其所在 contig 上所有基因
neighbor_ids = set()
all_contig_gene_ids = set()
contig_set = set()

# 保存每个目标基因的邻近基因列表
target_flank_dict = defaultdict(list)

for gene_id in target_ids:
    if gene_id not in id_to_info:
        print(f"Warning: {gene_id} not found in GFF.")
        continue

    contig = id_to_info[gene_id]["contig"]
    contig_set.add(contig)
    target_center = (id_to_info[gene_id]["start"] + id_to_info[gene_id]["end"]) // 2

    for gene in gene_positions_by_contig[contig]:
        all_contig_gene_ids.add(gene["id"])  # 所有 contig 上的 gene
        if abs(gene["center"] - target_center) <= 5000:
            neighbor_ids.add(gene["id"])
            target_flank_dict[gene_id].append(gene)

# Step 5: 输出氨基酸序列
with open("neighbor_genes_aa.faa", "w") as f_neighbor, open("contig_all_genes_aa.faa", "w") as f_all:
    for gene_id in neighbor_ids:
        if gene_id in fasta_dict:
            SeqIO.write(fasta_dict[gene_id], f_neighbor, "fasta")
    for gene_id in all_contig_gene_ids:
        if gene_id in fasta_dict:
            SeqIO.write(fasta_dict[gene_id], f_all, "fasta")

# Step 6: 输出每个目标基因 ±5kb 范围内的统计信息
with open("target_flank_gene_summary.tsv", "w") as f_stat:
    f_stat.write("target_gene_id\tcontig\tflank_gene_count\tstart_min\tend_max\tcovered_bp\n")
    for gene_id, flank_genes in target_flank_dict.items():
        if not flank_genes:
            continue
        contig = id_to_info[gene_id]["contig"]
        start_min = min(g["start"] for g in flank_genes)
        end_max = max(g["end"] for g in flank_genes)
        covered_bp = end_max - start_min + 1
        flank_gene_count = len(flank_genes)
        f_stat.write(f"{gene_id}\t{contig}\t{flank_gene_count}\t{start_min}\t{end_max}\t{covered_bp}\n")


