


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
}
