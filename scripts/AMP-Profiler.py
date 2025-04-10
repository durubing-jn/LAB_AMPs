# -*- coding: utf-8 -*-

from Bio import SeqIO
from Bio.SeqUtils.ProtParam import ProteinAnalysis
import pandas as pd

# Free energy table of amino acids for Boman index
free_energy = {
    'A': 0.6, 'R': -4.5, 'N': -0.6, 'D': -3.5, 'C': 0.7,
    'E': -3.5, 'Q': -0.7, 'G': 1.5, 'H': -3.2, 'I': 4.5,
    'L': 3.8, 'K': -3.9, 'M': 1.9, 'F': 2.8, 'P': -1.6,
    'S': -0.8, 'T': -0.7, 'W': -0.9, 'Y': -1.3, 'V': 4.2
}

# List of amino acids
amino_acids = ['A', 'R', 'N', 'D', 'C', 'E', 'Q', 'G', 'H', 'I',
               'L', 'K', 'M', 'F', 'P', 'S', 'T', 'W', 'Y', 'V']

# Calculate Boman index
def calculate_boman_index(sequence):
    total_energy = 0.0
    for aa in sequence:
        if aa in free_energy:
            total_energy += free_energy[aa]
    return total_energy / len(sequence)

# Calculate isoelectric point
def calculate_isoelectric_point(sequence):
    analysis = ProteinAnalysis(str(sequence))
    return analysis.isoelectric_point()

# Calculate amino acid frequency distribution
def calculate_amino_acid_distribution(sequence):
    analysis = ProteinAnalysis(str(sequence))
    return analysis.get_amino_acids_percent()

# Function to calculate the net charge of each peptide
def calculate_charge(sequence, pH=7.0):
    analysis = ProteinAnalysis(str(sequence))
    return analysis.charge_at_pH(pH)

# Function to calculate the normalized hydrophobicity of each peptide
def calculate_hydrophobicity(sequence):
    analysis = ProteinAnalysis(str(sequence))
    return analysis.gravy()  # Uses Kyte-Doolittle hydropathy index

# Save the computed results to a list
data = []

# Read the FASTA file
fasta_file = "AMP.fa"  # Replace with your FASTA file path
with open(fasta_file) as handle:
    for record in SeqIO.parse(handle, "fasta"):
        sequence = record.seq
        charge = calculate_charge(sequence)
        hydrophobicity = calculate_hydrophobicity(sequence)
        boman_index = calculate_boman_index(sequence)
        pI = calculate_isoelectric_point(sequence)
        amino_acid_distribution = calculate_amino_acid_distribution(sequence)
        
        # Add frequency data for each amino acid to the record
        aa_freqs = [amino_acid_distribution.get(aa, 0) for aa in amino_acids]
        
        # Append ID, net charge, hydrophobicity, Boman index, isoelectric point, and amino acid frequency distribution to the list
        data.append([record.id, charge, hydrophobicity, boman_index, pI] + aa_freqs)

# Define column names
columns = ["ID", "Net Charge", "Normalized Hydrophobicity", "Boman Index", "Isoelectric Point"] + amino_acids

# Save the results to a DataFrame
df = pd.DataFrame(data, columns=columns)

# Output the results to an Excel file
output_file = "AMP.profile.xlsx"
df.to_excel(output_file, index=False)

print(f"Results with Boman Index, Isoelectric Point, and Amino Acid Frequencies have been saved to {output_file}")
