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
    def __repr__(self):
        return ' '.join([str(arg) for arg in self.cmd])

def ahref(target,name=None,type=None):
    if name is None:
        name = os.path.basename(target)
    ahref = "<a href='%s'" % target
    if type is not None:
        ahref += " type='%s'" % type
    ahref += ">%s</a>" % name
    return ahref

def check_errors():
    # Errors in Amplicon_analysis_pipeline.log
    with open('Amplicon_analysis_pipeline.log','r') as pipeline_log:
        log = pipeline_log.read()
        if "Names in the first column of Metatable.txt and in the second column of Final_name.txt do not match" in log:
            print_error("""*** Sample IDs don't match dataset names ***

The sample IDs (first column of the Metatable file) don't match the
supplied sample names for the input Fastq pairs.
""")
    # Errors in pipeline output
    with open('pipeline.log','r') as pipeline_log:
        log = pipeline_log.read()
        if "Errors and/or warnings detected in mapping file" in log:
            with open("Metatable_log/Metatable.log","r") as metatable_log:
                # Echo the Metatable log file to the tool log
                print_error("""*** Error in Metatable mapping file ***

%s""" % metatable_log.read())
        elif "No header line was found in mapping file" in log:
            # Report error to the tool log
            print_error("""*** No header in Metatable mapping file ***

Check you've specified the correct file as the input Metatable""")

def print_error(message):
    width = max([len(line) for line in message.split('\n')]) + 4
    sys.stderr.write("\n%s\n" % ('*'*width))
    for line in message.split('\n'):
        sys.stderr.write("* %s%s *\n" % (line,' '*(width-len(line)-4)))
    sys.stderr.write("%s\n\n" % ('*'*width))

if __name__ == "__main__":
    # Command line
    print "Amplicon analysis: starting"
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
    print "Amplicon analysis: building the environment"
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
    print "Amplicon analysis: constructing pipeline command"
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
    print "Running %s" % pipeline

    # Run the pipeline
    with open("pipeline.log","w") as pipeline_out:
        try:
            subprocess.check_call(pipeline.cmd,
                                  stdout=pipeline_out,
                                  stderr=subprocess.STDOUT)
            exit_code = 0
            print "Pipeline completed ok"
        except subprocess.CalledProcessError as ex:
            # Non-zero exit status
            sys.stderr.write("Pipeline failed: exit code %s\n" %
                             ex.returncode)
            exit_code = ex.returncode
        except Exception as ex:
            # Some other problem
            sys.stderr.write("Unexpected error: %s\n" % str(ex))

    # Check for log file
    log_file = "Amplicon_analysis_pipeline.log"
    if os.path.exists(log_file):
        print "Found log file: %s" % log_file
        if exit_code == 0:
            # Create an HTML file to link to log files etc
            # NB the paths to the files should be correct once
            # copied by Galaxy on job completion
            with open("pipeline_outputs.html","w") as html_out:
                html_out.write("""<html>
<head>
<title>Amplicon analysis pipeline: log files</title>
<head>
<body>
<h1>Amplicon analysis pipeline: log files</h1>
<ul>
""")
                html_out.write(
                    "<li>%s</li>\n" %
                    ahref("Amplicon_analysis_pipeline.log",
                          type="text/plain"))
                html_out.write(
                    "<li>%s</li>\n" %
                    ahref("pipeline.log",type="text/plain"))
                html_out.write(
                    "<li>%s</li>\n" %
                    ahref("Metatable.html"))
                html_out.write("""<ul>
</body>
</html>
""")
        else:
            # Check for known error messages
            check_errors()
            # Write pipeline stdout to tool stderr
            sys.stderr.write("\nOutput from pipeline:\n")
            with open("pipeline.log",'r') as log:
                sys.stderr.write("%s" % log.read())
            # Write log file contents to tool log
            print "\nAmplicon_analysis_pipeline.log:"
            with open(log_file,'r') as log:
                print "%s" % log.read()
    else:
        sys.stderr.write("ERROR missing log file \"%s\"\n" %
                         log_file)

    # List the output directory contents
    results_dir = os.path.abspath("RESULTS")
    print "Listing contents of output dir %s:" % results_dir
    for d,dirs,files in os.walk(results_dir):
        print "-- %s" % os.path.relpath(d,results_dir)
        for f in files:
            print "---- %s" % os.path.relpath(f,results_dir)

    # Finish
    print "Amplicon analysis: finishing, exit code: %s" % exit_code
    sys.exit(exit_code)
