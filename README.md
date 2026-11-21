# MNase-seq_nf_pipeline

A simple **Nextflow DSL2 pipeline for paired-end MNase-seq data processing**, integrating read quality assessment, adapter trimming, and reference genome alignment.

## Workflow

The pipeline performs the following steps:

1. **Raw read quality control:** FastQC on input FASTQ files.
2. **Adapter trimming:** Trimmomatic for adapter and low-quality base removal.
3. **Trimmed read quality control:** FastQC on trimmed paired-end reads.
4. **Read alignment:** Bowtie2 alignment against a reference genome.

```text
Raw paired-end FASTQ files
          |
          v
       FastQC
          |
          v
     Trimmomatic
          |
          v
   Trimmed paired reads
          |
          +----------+
          |          |
          v          v
       FastQC     Bowtie2
          |          |
          v          v
    QC reports    SAM files
```

## Requirements

Install the following software before running the pipeline:

| Software | Purpose |
|---|---|
| Nextflow | Workflow management |
| Java (17+) | Nextflow runtime |
| FastQC | Read quality assessment |
| Trimmomatic | Adapter and quality trimming |
| Bowtie2 | Reference genome alignment |
| Conda/Mamba | Software environment management |

### Install Nextflow

```bash
curl -s https://get.nextflow.io | bash
chmod +x nextflow
```

Add Nextflow to your PATH if required.

### Install Conda/Mamba

Install [Miniforge](https://github.com/conda-forge/miniforge), which provides Conda and Mamba.

Ensure that the required bioinformatics tools are available in the Conda environment configured for the pipeline.

## Repository structure

```text
MNase-seq_nf_pipeline/
├── main.nf
├── nextflow.config
├── params.config
├── modules/
│   ├── fastqc.nf
│   ├── trimmomatic.nf
│   └── bowtie2.nf
├── adapters/
│   └── TruSeq3-PE-2-GGGGG.fa
├── data/
│   ├── test1_mnaseseq_R1.fastq.gz
│   └── test1_mnaseseq_R2.fastq.gz
├── reference/
│   └── genome.fa
├── ref_index/
└── results/
```

## Quick start tutorial

### 1. Prepare input data

Place your paired-end MNase-seq FASTQ files in the `data/` directory:

```text
data/
│   ├── test1_mnaseseq_R1.fastq.gz
│   └── test1_mnaseseq_R2.fastq.gz
```

Here, `R1` and `R2` represent forward and reverse reads, respectively.

### 2. Prepare the reference genome

Place your reference genome FASTA file in `reference/`:

```text
reference/genome.fa
```

Build the Bowtie2 index:

```bash
bowtie2-build reference/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz ref_index/Homo_sapiens.GRCh38.dna.primary_assembly
```

### 3. Configure parameters

Update `params.config` with the appropriate paths:

```groovy
params {
	inputR1 = "${projectDir}/data/*R1*.fastq.gz"
	inputR2 = "${projectDir}/data/*R2*.fastq.gz"
	reference = "${projectDir}/reference/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz"
	threads = 20
	output_dir = "${projectDir}/results"
	adapters = "${projectDir}/adapters/TruSeq3-PE-2-GGGGG.fa"
	conda_env = "${projectDir}/environment.yml"
        bowtie2_index = "${projectDir}/ref_index/Homo_sapiens.GRCh38.dna.primary_assembly"
}
```

Ensure that the adapter FASTA file exists at the specified location.

### 4. Run the pipeline

Execute the following command from the repository directory:

```bash
nextflow run main.nf
```

To resume an interrupted or failed execution:

```bash
nextflow run main.nf -resume
```

### 5. Expected output

After successful execution, results will be organized as follows:

```text
results/
├── fastqc/
│   ├── raw/
│   └── trimmed/
├── trimmomatic/
└── bowtie2/
```

| Directory | Description |
|---|---|
| `fastqc/raw/` | FastQC reports for original FASTQ reads |
| `fastqc/trimmed/` | FastQC reports for trimmed paired-end reads |
| `trimmomatic/` | Trimmed paired-end and unpaired FASTQ files |
| `bowtie2/` | Alignment output files |

*Note: Exact output filenames and formats depend on the corresponding process modules.*

## Notes

- Input FASTQ filenames should contain `_R1` and `_R2` to enable automatic pairing.
- Ensure that both FASTQ files belong to the same sample.
- Bowtie2 performs end-to-end or local alignment but is not splice-aware; it is suitable for genomic MNase-seq alignment.
- This pipeline currently performs preprocessing and alignment. Downstream MNase-seq analyses, such as fragment-size distribution, nucleosome occupancy, and nucleosome positioning, can be performed using the resulting alignments.

## License

This project is intended for research and academic use. Please refer to the repository license for usage and distribution terms.
