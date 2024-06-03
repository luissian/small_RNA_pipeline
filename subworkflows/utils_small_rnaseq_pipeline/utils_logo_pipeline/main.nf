
include { logColours } from '../../utils_common/utils_common_pipeline'
include { dashedLine } from '../../utils_common/utils_common_pipeline'

include { getWorkflowVersion } from '../../utils_common/utils_common_pipeline'


import org.yaml.snakeyaml.Yaml
import nextflow.extension.FilesEx
//



//
// pipeline logo
//
def pipelineLogo(monochrome_logs=true) {
    Map colors = logColours(monochrome_logs)
    String.format(
         """\n
        ${dashedLine(monochrome_logs)}
        ${colors.blue}         __
        ${colors.blue}        |__) |\\ |  /\\  ${colors.reset}
        ${colors.blue}  small |  \\ | \\| /--\\ ${colors.reset}

        ${colors.purple}  ${workflow.manifest.name} ${getWorkflowVersion()}${colors.reset}
        ${dashedLine(monochrome_logs)}
        """.stripIndent()
    )
}



