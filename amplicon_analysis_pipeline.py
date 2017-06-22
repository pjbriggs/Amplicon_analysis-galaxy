#!/usr/bin/env python
#
# Wrapper script to run Amplicon_analysis_pipeline.sh
# from Galaxy tool

import sys
import os
import argparse
import subprocess

class PipelineCmd(object):
    def __init__(self,cmd):
        self.cmd = [str(cmd)]
    def add_args(self,*args):
        for arg in args:
            self.cmd.append(str(arg))

if __name__ == "__main__":
    # Command line
    p = argparse.ArgumentParser()
    p.add_argument("metatable",
                   metavar="METATABLE_FILE",
                   help="Metatable.txt file")
    p.add_argument("fastq_pairs",
                   metavar="SAMPLE_NAME FQ_R1 FQ_R2",
                   nargs="+",
                   default=list(),
                   help="Triplets of SAMPLE_NAME followed by "
                   "a R1/R2 FASTQ file pair")
    p.add_argument("-g",dest="forward_pcr_primer")
    p.add_argument("-G",dest="reverse_pcr_primer")
    p.add_argument("-q",dest="trimming_threshold")
    p.add_argument("-O",dest="minimum_overlap")
    p.add_argument("-L",dest="minimum_length")
    p.add_argument("-P",dest="pipeline",
                   choices=["vsearch","uparse","qiime"],
                   type=str.lower,
                   default="vsearch")
    p.add_argument("-S",dest="use_silva",action="store_true")
    p.add_argument("-r",dest="reference_data_path")
    p.add_argument("-c",dest="categories_file")
    args = p.parse_args()

    # Build the environment for running the pipeline
    metatable_file = os.path.abspath(args.metatable)
    os.symlink(metatable_file,"Metatable.txt")

    # Link to Categories.txt file (if provided)
    if args.categories_file is not None:
        categories_file = os.path.abspath(args.categories_file)
        os.symlink(categories_file,"Categories.txt")

    # Link to FASTQs and construct Final_name.txt file
    with open("Final_name.txt",'w') as final_name:
        fastqs = iter(args.fastq_pairs)
        for sample_name,fqr1,fqr2 in zip(fastqs,fastqs,fastqs):
            r1 = "%s_R1_.fastq" % sample_name
            r2 = "%s_R2_.fastq" % sample_name
            os.symlink(fqr1,r1)
            os.symlink(fqr2,r2)
            final_name.write("%s\n" % '\t'.join((r1,sample_name)))
            final_name.write("%s\n" % '\t'.join((r2,sample_name)))

    # Construct the pipeline command
    pipeline = PipelineCmd("Amplicon_analysis_pipeline.sh")
    if args.forward_pcr_primer:
        pipeline.add_args("-g",args.forward_pcr_primer)
    if args.reverse_pcr_primer:
        pipeline.add_args("-G",args.reverse_pcr_primer)
    if args.trimming_threshold:
        pipeline.add_args("-q",args.trimming_threshold)
    if args.minimum_overlap:
        pipeline.add_args("-O",args.minimum_overlap)
    if args.minimum_length:
        pipeline.add_args("-L",args.minimum_length)
    if args.reference_data_path:
        pipeline.add_args("-r",args.reference_data_path)
    pipeline.add_args("-P",args.pipeline)
    if args.use_silva:
        pipeline.add_args("-S")

    # Echo the pipeline command to stdout
    sys.stdout.write("Running %s\n" % pipeline.cmd)

    # Run the pipeline
    try:
        subprocess.check_call(pipeline.cmd,
                              stdout=sys.stdout,
                              stderr=sys.stderr)
        exit_code = 0
    except subprocess.CalledProcessError as ex:
        # Non-zero exit status
        sys.stderr.write(str(ex))
        exit_code = ex.returncode

    # Echo log file contents to stdout
    log_file = "Amplicon_analysis_pipeline.log"
    if os.path.exists(log_file):
        sys.stdout.write("\nOutput from %s:\n\n" % log_file)
        with open(log_file,'rb') as log:
            sys.stdout.write(log.read())
    else:
        sys.stderr.write("ERROR missing log file \"%s\"\n" %
                         log_file)

    # List the output directory contents
    sys.stdout.write("\nOutput files:\n")
    results_dir = os.path.abspath("RESULTS")
    for d,dirs,files in os.walk(results_dir):
        sys.stdout.write("-- %s\n" % os.path.relpath(d,results_dir))
        for f in files:
            sys.stdout.write("---- %s\n" % os.path.relpath(f,results_dir))

    # Finish
    sys.exit(exit_code)
