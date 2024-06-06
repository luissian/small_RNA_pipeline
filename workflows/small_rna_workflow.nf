/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { CAT_FASTQ                        } from '../modules/cat/fastq/main'
include { FASTQ_FASTQC_UMITOOLS_FASTP      } from '../subworkflows/utils_common/fastq_fastqc_umitools_fastp'


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow SMALL_RNA_PIPELINE {

    take:
    ch_input            // channel: samplesheet file as specified to --input
    ch_samplesheet      // channel: sample fastqs parsed from --input
    ch_versions         // channel: [ path(versions.yml) ]

    main:
    //Config checks
    // Check optional parameters
    if (!params.mirtrace_species) {
            exit 1, "Reference species for miRTrace is not defined via the --mirtrace_species parameter."
        }




    //
    // Create separate channels for samples that have single/multiple FastQ files to merge
    //
    ch_samplesheet
        .branch {
            meta, fastqs ->
                single  : fastqs.size() == 1
                    return [ meta, fastqs.flatten() ]
                multiple: fastqs.size() > 1
                    return [ meta, fastqs.flatten() ]
        }
        .set { ch_fastq }

    // MODULE: Concatenate FastQ files from same sample if required
    //
    CAT_FASTQ (
        ch_fastq.multiple
    )
    .reads
    .mix(ch_fastq.single)
    .set { ch_cat_fastq }

    ch_versions = ch_versions.mix(CAT_FASTQ.out.versions.first())
    
    
    mirna_adapters = params.with_umi ? [] : params.fastp_known_mirna_adapters
    
    //
    // SUBWORKFLOW: Read QC, extract UMI and trim adapters & dedup UMIs if necessary / desired by the user
    //
    FASTQ_FASTQC_UMITOOLS_FASTP (
        ch_cat_fastq,
        params.skip_fastqc,
        params.with_umi,
        params.skip_umi_extract_before_dedup,
        params.umi_discard_read,
        params.skip_fastp,
        mirna_adapters,
        params.save_trimmed_fail,
        params.save_merged,
        params.min_trimmed_reads
    )
    ch_versions = ch_versions.mix(FASTQ_FASTQC_UMITOOLS_FASTP.out.versions)
    




}
