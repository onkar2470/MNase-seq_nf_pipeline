process TRIMMOMATIC {

    tag "$sample_id"

    publishDir "${params.output_dir}/trimmomatic", mode: 'copy'

    input:
    tuple val(sample_id), path(R1_fastq), path(R2_fastq)

    output:
    tuple val(sample_id),
          path("${sample_id}_trimmed_R1_paired.fastq.gz"),
          path("${sample_id}_trimmed_R2_paired.fastq.gz"),
          emit: trimmed_pairs

    path "${sample_id}_trimmed_R1_unpaired.fastq.gz", emit: R1_unpaired_fastq
    path "${sample_id}_trimmed_R2_unpaired.fastq.gz", emit: R2_unpaired_fastq

    script:
    """
    _JAVA_OPTIONS="-Xmx128G" trimmomatic PE -threads ${params.threads} $R1_fastq $R2_fastq \
    ${sample_id}_trimmed_R1_paired.fastq.gz \
    ${sample_id}_trimmed_R1_unpaired.fastq.gz \
    ${sample_id}_trimmed_R2_paired.fastq.gz \
    ${sample_id}_trimmed_R2_unpaired.fastq.gz \
    ILLUMINACLIP:${params.adapters}:2:30:10:1:true MINLEN:25
    """
}
