process FASTQC {

    tag "${sample_id} (${qc_type})"

    publishDir "${params.output_dir}/fastqc", mode: 'copy'

    input:
    tuple val(sample_id), val(qc_type), path(R1_fastq), path(R2_fastq)

    output:
    tuple val(sample_id), val(qc_type),
          path("fastqc_out/*"),
          emit: fastqc_out

    script:
    """
    mkdir fastqc_out

    fastqc --memory 4096 -t 2 \
        --outdir fastqc_out \
        $R1_fastq $R2_fastq

    # Add sample ID and QC type to filenames
    for f in fastqc_out/*; do
        mv "\$f" "fastqc_out/${sample_id}_${qc_type}_\$(basename "\$f")"
    done
    """
}
