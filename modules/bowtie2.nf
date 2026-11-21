process BOWTIE2 {

    tag "$sample_id"

    publishDir "${params.output_dir}/bowtie2", mode: 'copy'

    input:
    tuple val(sample_id), path(R1_fastq), path(R2_fastq)

    output:
    path "${sample_id}_sorted.bam", emit: aligned_sorted_bam
    path "${sample_id}_sorted.bam.bai", emit: aligned_sorted_bam_index
    path "${sample_id}_bowtie2.log", emit: bowtie2_log
    script:
    """
    bowtie2 -p ${params.threads} \
    -x ${params.bowtie2_index} \
    -1 $R1_fastq \
    -2 $R2_fastq --very-sensitive --no-mixed --no-discordant -I 20 -X 500 2> ${sample_id}_bowtie2.log \
     | samtools view -@ ${params.threads} -b -F 4 - \
     | samtools sort -@ ${params.threads} - -o ${sample_id}_sorted.bam

     samtools index ${sample_id}_sorted.bam
    """
}
