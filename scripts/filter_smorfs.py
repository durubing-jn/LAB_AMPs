from .fasta import fasta_iter
from .utils import open_output

def filter_smorfs(ifile, ofile, uniq, full_headers=False):
    '''Remove larger ORFs, leaving only smORFs behind. Also outputs matching nucleotide sequences.'''
    seen = set()
    smorf_ids = []
    
    # 输出蛋白质序列
    with open_output(ofile, mode='wt') as output:
        for h, seq in fasta_iter(ifile, full_headers):
            if len(seq) > 100:
                continue
            if uniq:
                if seq in seen:
                    continue
                seen.add(seq)
                new_id = 'smORF_{}'.format(len(seen))
                output.write(">{}\n{}\n".format(new_id, seq))
                smorf_ids.append(new_id)
            else:
                output.write(">{}\n{}\n".format(h, seq))
                smorf_ids.append(h.split()[0])  # 保留第一个词作为 ID

    # 输出对应核酸序列（.fna）
    fna_infile = ifile.replace('.faa', '.fna')
    fna_outfile = ofile.replace('.faa', '.fna')
    
    try:
        with open_output(fna_outfile, mode='wt') as outn:
            for h, seq in fasta_iter(fna_infile, full_headers):
                header_id = h.split()[0]
                if header_id in smorf_ids:
                    outn.write(f'>{h}\n{seq}\n')
    except FileNotFoundError:
        import sys
        sys.stderr.write(f"[WARNING] Corresponding nucleotide file not found: {fna_infile}\n")
