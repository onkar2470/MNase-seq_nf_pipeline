nextflow.enable.dsl=2

include { FASTQC as FASTQC_RAW } from './modules/fastqc.nf'
include { FASTQC as FASTQC_TRIMMED } from './modules/fastqc.nf'
include { TRIMMOMATIC } from './modules/trimmomatic.nf'
include { BOWTIE2 } from './modules/bowtie2.nf'

workflow {

    input_R1 = Channel
        .fromPath(params.inputR1, checkIfExists: true)
        .map { file -> tuple(file.name.replaceFirst(/_R1.*$/, ''), file) }

    input_R2 = Channel
        .fromPath(params.inputR2, checkIfExists: true)
        .map { file -> tuple(file.name.replaceFirst(/_R2.*$/, ''), file) }

    input_fastqs = input_R1.join(input_R2)

    // FastQC on raw reads
    raw_fastqc_input = input_fastqs.map { sample_id, R1, R2 ->
        tuple(sample_id, 'raw', R1, R2)
    }

    fastqc_raw_out = FASTQC_RAW(raw_fastqc_input)

    // Trimming
    trimmomatic_out = TRIMMOMATIC(input_fastqs)

    // FastQC on trimmed reads
    trimmed_fastqc_input = trimmomatic_out.trimmed_pairs.map { sample_id, R1, R2 ->
        tuple(sample_id, 'trimmed', R1, R2)
    }

    fastqc_trimmed_out = FASTQC_TRIMMED(trimmed_fastqc_input)

    // Alignment
    bowtie2_out = BOWTIE2(trimmomatic_out.trimmed_pairs)
}
