/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { UTILS_NEXTFLOW_PIPELINE   } from '../../utils_common/utils_nextflow_pipeline'
include { UTILS_NFVALIDATION_PLUGIN   } from '../../utils_common/utils_nfvalidation_plugin'
include { pipelineLogo              } from '../../utils_small_rnaseq_pipeline/utils_logo_pipeline'
include { dashedLine                } from '../../utils_common/utils_common_pipeline'


workflow INITIALIZATION_PIPELINE {

    take:
    version           // boolean: Display version and exit
    help              // boolean: Display help text
    validate_params   // boolean: Boolean whether to validate parameters against the schema at runtime
    monochrome_logs   // boolean: Do not use coloured log outputs
    nextflow_cli_args //   array: List of positional nextflow CLI args
    outdir            //  string: The output directory where the results will be saved
    input             //  string: Path to input samplesheet

    main:

    ch_versions = Channel.empty()
    
     //
    // Print version and exit if required and dump pipeline parameters to JSON file
    //
    UTILS_NEXTFLOW_PIPELINE (
        version,
        true,
        outdir,
        workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1
    )
    //Detect Protocol setting, set this early before help so help shows proper adapters etc pp
    formatProtocol(params,log)
    //
    // Validate parameters and generate parameter summary to stdout
    //
    pre_help_text = pipelineLogo(monochrome_logs)
    post_help_text = '\n' +  dashedLine(monochrome_logs)
    def String workflow_command = "nextflow run ${workflow.manifest.name} -profile singularity --input samplesheet.csv --outdir <OUTDIR>"
    UTILS_NFVALIDATION_PLUGIN (
        help,
        workflow_command,
        pre_help_text,
        post_help_text,
        validate_params,
        "nextflow_schema.json"
    )

}



/*
* Format the protocol
* Given the protocol parameter (params.protocol),
* this function formats the protocol such that it is fit for the respective
* subworkflow
*/
def formatProtocol(params,log) {

    switch(params.protocol){
        case 'illumina':
            params.putIfAbsent("clip_r1", 0);
            params.putIfAbsent("three_prime_clip_r1",0);
            params.putIfAbsent("three_prime_adapter", "TGGAATTCTCGGGTGCCAAGG");
            break
        default:
            log.warn "Please make sure to specify all required clipping and trimming parameters, otherwise only adapter detection will be performed."
        }

        log.warn "Running with Protocol ${params.protocol}"
        log.warn "Therefore using Adapter: ${params.three_prime_adapter}"
        log.warn "Clipping ${params.clip_r1} bases from R1"
        log.warn "And clipping ${params.three_prime_clip_r1} bases from 3' end"
    }
