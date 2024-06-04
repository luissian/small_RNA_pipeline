#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

params.str = 'Hello world!'

include { SMALL_RNA_PIPELINE         } from './workflows/small_rna_workflow'
include { INITIALIZATION_PIPELINE } from './subworkflows/utils_common/initialization_pipeline'


process splitLetters {
    output:
    path 'chunk_*'

    """
    printf '${params.str}' | split -b 6 - chunk_
    """
}

process convertToUpper {
    input:
    path x

    output:
    stdout

    """
    cat $x | tr '[a-z]' '[A-Z]'
    """
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
workflow {

    main:
    ch_versions = Channel.empty()
    //
    // SUBWORKFLOW: Run initialisation tasks
    //
    INITIALIZATION_PIPELINE (
        params.version,
        params.help,
        params.validate_params,
        params.monochrome_logs,
        args,
        params.outdir,
        params.input
    )


    splitLetters | flatten | convertToUpper | view { it.trim() }
    //
    // WORKFLOW: Run small RNA workflow
    //
    SMALL_RNA_PIPELINE (
        Channel.of(file(params.input, checkIfExists: true)),
        INITIALIZATION_PIPELINE.out.samplesheet,
        ch_versions
    )
}
