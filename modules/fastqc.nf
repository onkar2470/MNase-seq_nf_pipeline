process FASTQC {

    tag "$sample_id"

    publishDir "${params.output_dir}/fastqc/${qc_type}", mode: 'copy'

    input:
    tuple val(sample_id), val(qc_type), path(R1_fastq), path(R2_fastq)

    output:
    tuple val(sample_id), val(qc_type),
          path("fastqc_out"),
          emit: fastqc_out

    script:
    """
    mkdir fastqc_out
    fastqc -t 2 --outdir fastqc_out $R1_fastq $R2_fastq
    """
}
