Amplicon_analysis-galaxy
========================

A Galaxy tool wrapper to Mauro Tutino's ``Amplicon_analysis`` pipeline
script at https://github.com/MTutino/Amplicon_analysis

The pipeline can analyse paired-end 16S rRNA data from Illumina Miseq
(Casava >= 1.8) and performs the following operations:

 * QC and clean up of input data
 * Removal of singletons and chimeras and building of OTU table
   and phylogenetic tree
 * Beta and alpha diversity of analysis

Usage documentation
===================

Usage of the tool (including required inputs) is documented within
the ``help`` section of the tool XML.

Installing the tool in a Galaxy instance
========================================

The following sections describe how to install the tool files,
dependencies and reference data, and how to configure the Galaxy
instance to detect the dependencies and reference data correctly
at run time.

1. Install the tool from the toolshed
-------------------------------------

The core tool is hosted on the Galaxy toolshed, so it can be installed
directly from there (this is the recommended route):

 * https://toolshed.g2.bx.psu.edu/view/pjbriggs/amplicon_analysis_pipeline/

Alternatively it can be installed manually; in this case there are two
files to install:

 * ``amplicon_analysis_pipeline.xml`` (the Galaxy tool definition)
 * ``amplicon_analysis_pipeline.py`` (the Python wrapper script)

Put these in a directory that is visible to Galaxy (e.g. a
``tools/Amplicon_analysis/`` folder), and modify the ``tools_conf.xml``
file to tell Galaxy to offer the tool by adding the line e.g.::

    <tool file="Amplicon_analysis/amplicon_analysis_pipeline.xml" />

2. Install the reference data
-----------------------------

The script ``References.sh`` from the pipeline package at
https://github.com/MTutino/Amplicon_analysis can be run to install
the reference data, for example::

    cd /path/to/pipeline/data
    wget https://github.com/MTutino/Amplicon_analysis/raw/master/References.sh
    /bin/bash ./References.sh

will install the data in ``/path/to/pipeline/data``.

**NB** The final amount of data downloaded and uncompressed will be
around 9GB.

3. Configure reference data location in Galaxy
----------------------------------------------

The final step is to make your Galaxy installation aware of the
location of the reference data, so it can locate them both when the
tool is run.

The tool locates the reference data via an environment variable called
``AMPLICON_ANALYSIS_REF_DATA_PATH``, which needs to set to the parent
directory where the reference data has been installed.

There are various ways to do this, depending on how your Galaxy
installation is configured:

 * **For local instances:** add a line to set it in the
   ``config/local_env.sh`` file of your Galaxy installation (you
   may need to create a new empty file first), e.g.::

       export AMPLICON_ANALYSIS_REF_DATA_PATH=/path/to/pipeline/data

 * **For production instances:** set the value in the ``job_conf.xml``
   configuration file, e.g.::

       <destination id="amplicon_analysis">
          <env id="AMPLICON_ANALYSIS_REF_DATA_PATH">/path/to/pipeline/data</env>
       </destination>

   and then specify that the pipeline tool uses this destination::

       <tool id="amplicon_analysis_pipeline" destination="amplicon_analysis"/>

   (For more about job destinations see the Galaxy documentation at
   https://docs.galaxyproject.org/en/master/admin/jobs.html#job-destinations)

4. Enable rendering of HTML outputs from pipeline
-------------------------------------------------

To ensure that HTML outputs are displayed correctly in Galaxy
(for example the Vsearch OTU table heatmaps), Galaxy needs to be
configured not to sanitize the outputs from the ``Amplicon_analysis``
tool.

Either:

 * **For local instances:** set ``sanitize_all_html = False`` in
   ``config/galaxy.ini`` (nb don't do this on production servers or
   public instances!); or

 * **For production instances:** add the ``Amplicon_analysis`` tool
   to the display whitelist in the Galaxy instance:

   - Set ``sanitize_whitelist_file = config/whitelist.txt`` in
     ``config/galaxy.ini`` and restart Galaxy;
   - Go to ``Admin>Manage Display Whitelist``, check the box for
     ``Amplicon_analysis`` (hint: use your browser's 'find-in-page'
     search function to help locate it) and click on
     ``Submit new whitelist`` to update the settings.

Additional details
==================

Some other things to be aware of:

 * Note that using the Silva database requires a minimum of 18Gb RAM

Known problems
==============

 * Only the ``VSEARCH`` pipeline in Mauro's script is currently
   available via the Galaxy tool; the ``USEARCH`` and ``QIIME``
   pipelines have yet to be implemented.
 * The images in the tool help section are not visible if the
   tool has been installed locally, or if it has been installed in
   a Galaxy instance which is served from a subdirectory.

   These are both problems with Galaxy and not the tool, see
   https://github.com/galaxyproject/galaxy/issues/4490 and
   https://github.com/galaxyproject/galaxy/issues/1676

Appendix: installing the dependencies manually
==============================================

If the tool is installed from the Galaxy toolshed (recommended) then
the dependencies should be installed automatically and this step can
be skipped.

Otherwise the ``install_amplicon_analysis_deps.sh`` script can be used
to fetch and install the dependencies locally, for example::

    install_amplicon_analysis.sh /path/to/local_tool_dependencies

(This is the same script as is used to install dependencies from the
toolshed.) This can take some time to complete, and when completed will
have created a directory called ``Amplicon_analysis-1.2.3`` containing
the dependencies under the specified top level directory.

**NB** The installed dependencies will occupy around 2.6G of disk
space.

You will need to make sure that the ``bin`` subdirectory of this
directory is on Galaxy's ``PATH`` at runtime, for the tool to be able
to access the dependencies - for example by adding a line to the
``local_env.sh`` file like::

    export PATH=/path/to/local_tool_dependencies/Amplicon_analysis-1.2.3/bin:$PATH

History
=======

========== ======================================================================
Version    Changes
---------- ----------------------------------------------------------------------
1.3.5.0    Updated to Amplicon_Analysis_Pipeline version 1.3.5.
1.2.3.0    Updated to Amplicon_Analysis_Pipeline version 1.2.3; install
           dependencies via tool_dependencies.xml.
1.2.2.0    Updated to Amplicon_Analysis_Pipeline version 1.2.2 (removes
           jackknifed analysis which is not captured by Galaxy tool)
1.2.1.0    Updated to Amplicon_Analysis_Pipeline version 1.2.1 (adds
           option to use the Human Oral Microbiome Database v15.1, and
           updates SILVA database to v123)
1.1.0      First official version on Galaxy toolshed.
1.0.6      Expand inline documentation to provide detailed usage guidance.
1.0.5      Updates including:

           - Capture read counts from quality control as new output dataset
           - Capture FastQC per-base quality boxplots for each sample as
             new output dataset
           - Add support for -l option (sliding window length for trimming)
           - Default for -L set to "200"
1.0.4      Various updates:

	   - Additional outputs are captured when a "Categories" file is
	     supplied (alpha diversity rarefaction curves and boxplots)
	   - Sample names derived from Fastqs in a collection of pairs
	     are trimmed to SAMPLE_S* (for Illumina-style Fastq filenames)
           - Input Fastqs can now be of more general ``fastq`` type
	   - Log file outputs are captured in new output dataset
	   - User can specify a "title" for the job which is copied into
	     the dataset names (to distinguish outputs from different runs)
	   - Improved detection and reporting of problems with input
	     Metatable
1.0.3      Take the sample names from the collection dataset names when
           using collection as input (this is now the default input mode);
           collect additional output dataset; disable ``usearch``-based
           pipelines (i.e. ``UPARSE`` and ``QIIME``).
1.0.2      Enable support for FASTQs supplied via dataset collections and
           fix some broken output datasets.
1.0.1      Initial version
========== ======================================================================
