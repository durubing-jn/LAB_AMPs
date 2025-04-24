def create_pyrodigal_orffinders():
    import pyrodigal
    if hasattr(pyrodigal, 'OrfFinder'):
        GeneFinder = pyrodigal.OrfFinder
    else:
        GeneFinder = pyrodigal.GeneFinder
    gorf = GeneFinder(closed=True, min_gene=33, max_overlap=0)
    morf_finder = GeneFinder(meta=True, closed=True, min_gene=33, max_overlap=0)
    return gorf, morf_finder


def ppyrodigal_out(contig, ind, idx, pred, seq):
    from Bio.Seq import Seq  # 用于处理反向互补序列

    orfid = f'{contig}_{ind}'
    seconid = f'ID={idx}_{ind}'
    part = ''.join([str(int(pred.partial_begin)), str(int(pred.partial_end))])
    part = f'partial={part}'
    st = f'start_type={pred.start_type}'
    motif = f'rbs_motif={pred.rbs_motif}'
    sp = f'rbs_spacer={pred.rbs_spacer}'
    gc = f'gc_cont={pred.gc_cont:.3f}'
    last = ';'.join([seconid, part, st, motif, sp, gc])

    header = f'>{orfid} # {pred.begin} # {pred.end} # {pred.strand} # {last}'

    # 处理核酸序列（兼容旧版 pyrodigal）
    start, end = pred.begin - 1, pred.end  # Python index 从 0 开始
    nuc_seq = seq[start:end]
    if pred.strand == -1:
        nuc_seq = str(Seq(nuc_seq).reverse_complement())
    else:
        nuc_seq = str(nuc_seq)

    # GFF strand
    strand = '+' if pred.strand == 1 else '-'
    gff_fields = [
        contig,
        'pyrodigal',
        'CDS',
        str(pred.begin),
        str(pred.end),
        '.',
        strand,
        '0',
        f'ID={orfid};{last}'
    ]
    gff_line = '\t'.join(gff_fields)

    return (
        f'{header}\n{pred.translate()}\n',
        f'{header}\n{nuc_seq}\n',
        gff_line
    )


def predict_genes(infile, ofile):
    import pandas as pd
    from .fasta import fasta_iter
    from atomicwrites import atomic_write

    base = ofile.rsplit('.', 1)[0]
    nuc_file = base + '.fna'
    gff_file = base + '.gff'

    clen = []
    gorf, morf_finder = create_pyrodigal_orffinders()

    with atomic_write(ofile, overwrite=True) as odb, \
         atomic_write(nuc_file, overwrite=True) as ndb, \
         atomic_write(gff_file, overwrite=True) as gdb:

        for idx, (h, s) in enumerate(fasta_iter(infile)):
            orfs, smorfs = [0, 0]
            if len(s) <= 100_000:
                for i, pred in enumerate(morf_finder.find_genes(s)):
                    aa, nt, gff = ppyrodigal_out(h, i+1, idx+1, pred, s)
                    odb.write(aa)
                    ndb.write(nt)
                    gdb.write(gff + '\n')
                    orfs += 1
                    if len(pred.translate()) <= 100:
                        smorfs += 1
            else:
                gorf.train(s)
                for i, pred in enumerate(gorf.find_genes(s)):
                    aa, nt, gff = ppyrodigal_out(h, i+1, idx+1, pred, s)
                    odb.write(aa)
                    ndb.write(nt)
                    gdb.write(gff + '\n')
                    orfs += 1
                    if len(pred.translate()) <= 100:
                        smorfs += 1

            clen.append([h, len(s), orfs, smorfs])

    return pd.DataFrame(clen, columns=['contig', 'length', 'ORFs', 'smORFs'])

