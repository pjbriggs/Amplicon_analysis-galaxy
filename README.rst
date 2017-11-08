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

The tool is not currently hosted on a Galaxy toolshed both the tool
files and the dependencies must be installed manually. In addition
it is necessary to fetch and install the reference data.

1. Install the dependencies
---------------------------

The ``install_tool_deps.sh`` script can be used to fetch and install the
dependencies locally, for example::

    install_tool_deps.sh /path/to/local_tool_dependencies

This can take some time to complete. When finished it should have
created a set of directories containing the dependencies under the
specified top level directory.

2. Install the tool files
-------------------------

There are two files to install:

 * ``amplicon_analysis_pipeline.xml`` (the Galaxy tool definition)
 * ``amplicon_analysis_pipeline.py`` (the Python wrapper script)

Put these in a directory that is visible to Galaxy (e.g. a
``tools/Amplicon_analysis/`` folder), and modify the ``tools_conf.xml``
file to tell Galaxy to offer the tool by adding the line e.g.::

    <tool file="Amplicon_analysis/amplicon_analysis_pipeline.xml" />

3. Install the reference data
-----------------------------

The script ``References.sh`` from the pipeline package at
https://github.com/MTutino/Amplicon_analysis can be run to install
the reference data, for example::

    cd /path/to/pipeline/data
    wget https://github.com/MTutino/Amplicon_analysis/raw/master/References.sh
    /bin/bash ./References.sh

will install the data in ``/path/to/pipeline/data``.

**NB** The final amount of data downloaded and uncompressed will be
around 6GB.

4. Configure dependencies and reference data in Galaxy
------------------------------------------------------

The final steps are to make your Galaxy installation aware of the
tool dependencies and reference data, so it can locate them both when
the tool is run.

To target the tool dependencies installed previously, add the
following lines to the ``dependency_resolvers_conf.xml`` file in the
Galaxy ``config`` directory::

    <dependency_resolvers>
    ...
      <galaxy_packages base_path="/path/to/local_tool_dependencies" />
      <galaxy_packages base_path="/path/to/local_tool_dependencies" versionless="true" />
      ...
    </dependency_resolvers>

(NB it is recommended to place these *before* the ``<conda ... />``
resolvers)

(If you're not familiar with dependency resolvers in Galaxy then
see the documentation at
https://docs.galaxyproject.org/en/master/admin/dependency_resolvers.html
for more details.)

The tool locates the reference data via an environment variable called
``AMPLICON_ANALYSIS_REF_DATA_PATH``, which needs to set to the parent
directory where the reference data has been installed.

There are various ways to do this, depending on how your Galaxy
installation is configured:

 * **For local instances:** add a line to set it in the
   ``config/local_env.sh`` file of your Galaxy installation, e.g.::

       export AMPLICON_ANALYSIS_REF_DATA_PATH=/path/to/pipeline/data

 * **For production instances:** set the value in the ``job_conf.xml``
   configuration file, e.g.::

       <destination id="amplicon_analysis">
          <env id="AMPLICON_ANALYSIS_REF_DATA_PATH">/path/to/pipeline/data</env>
       </destination>

   and then specify that the pipeline tool uses this destination::

       <tool id="amplicon_analysis_pipeline" destination="amplicon_analysis"/>

   (For more about job destinations see the Galaxy documentation at
   https://galaxyproject.org/admin/config/jobs/#job-destinations)

5. Enable rendering of HTML outputs from pipeline
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

Appendix: availability of tool dependencies
===========================================

The tool takes its dependencies from the underlying pipeline script (see
https://github.com/MTutino/Amplicon_analysis/blob/master/README.md
for details).

As noted above, currently the ``install_tool_deps.sh`` script can be
used to manually install the dependencies for a local tool install.

In principle these should also be available if the tool were installed
from a toolshed. However it would be preferrable in this case to get as
many of the dependencies as possible via the ``conda`` dependency
resolver.

The following are known to be available via conda, with the required
version:

 - cutadapt 1.8.1
 - sickle-trim 1.33
 - bioawk 1.0
 - fastqc 0.11.3
 - R 3.2.0

Some dependencies are available but with the "wrong" versions:

 - spades (need 3.5.0)
 - qiime (need 1.8.0)
 - blast (need 2.2.26)
 - vsearch (need 1.1.3)

The following dependencies are currently unavailable:

 - fasta_number (need 02jun2015)
 - fasta-splitter (need 0.2.4)
 - rdp_classifier (need 2.2)
 - microbiomeutil (need r20110519)

(NB usearch 6.1.544 and 8.0.1623 are special cases which must be
handled outside of Galaxy's dependency management systems.)

History
=======

========== ======================================================================
Version    Changes
---------- ----------------------------------------------------------------------
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
