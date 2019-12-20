// veranderd van gatk forums
// david noteborn
// changing invaders
package org.broadinstitute.gatk.queue.qscripts

import org.broadinstitute.gatk.queue.QScript
import org.broadinstitute.gatk.queue.extensions.gatk._

import org.broadinstitute.gatk.tools.walkers.haplotypecaller.ReferenceConfidenceMode
import org.broadinstitute.gatk.utils.commandline.ClassType

class VariantCaller extends QScript {
	// Required arguments. All initialized to empty values.
	@Input(doc="The reference file for the bam files.", shortName="R", required=true)
	var referenceFile: File = _

	@Input(doc="One or more bam files.", shortName="I", required=true)
	var bamFiles: List[File] = Nil

	@Input(doc="Output core filename.", shortName="O", required=true)
	var outputFilename: File = _

	//@Argument(doc="Maxmem.", shortName="mem", required=true)
	//var maxMem: Int = _

	//@Argument(doc="Number of cpu threads per data thread", shortName="nct", required=true)
	//var numCPUThreads: Int = _

	@Argument(doc="Number of scatters", shortName="nsc", required=true)
	var numScatters: Int = _

	@Argument(doc="Minimum phred-scaled confidence to call variants", shortName="stand_call_conf", required=false)
	var standCallConf: Int = 10 //default: best-practices value

	@Input(doc="An optional file with targets intervals.", shortName="L", required=false)
	var targetFile: File = _

	@Argument(doc="Amount of padding (in bp) to add to each interval", shortName="ip", required=false)
	var intervalPadding: Int = 0

	@Argument(doc="Exclusive upper bounds for reference confidence GQ bands", shortName="gqb", required=false)
	@ClassType(classOf[Int])
	var GVCFGQBands: Seq[Int] = Nil

    def script() {
        // Define common settings for original HC, gvcf HC.
		trait HC_Arguments extends HaplotypeCaller {
			this.reference_sequence = referenceFile

			this.scatterCount = numScatters
			//this.memoryLimit = maxMem
			//this.num_cpu_threads_per_data_thread = numCPUThreads

		}
	    var gvcfFiles : List[File] = Nil

	    // Make gvcf per bam file
	    for (bamFile <- bamFiles) {
		val haplotypeCaller = new HaplotypeCaller with HC_Arguments

		// All required input
		haplotypeCaller.input_file :+= bamFile
		haplotypeCaller.out = swapExt(bamFile, "bam", "g.vcf")

		// gVCF settings
		haplotypeCaller.emitRefConfidence = ReferenceConfidenceMode.GVCF
		haplotypeCaller.GVCFGQBands = GVCFGQBands

		// Optional input
		if (targetFile != null) {
		    haplotypeCaller.L :+= targetFile
		    haplotypeCaller.ip = intervalPadding
		}

		//add function to queue
		gvcfFiles :+= haplotypeCaller.out
		add(haplotypeCaller)
	    }
    }
}
