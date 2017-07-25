Amplicon_analysis-galaxy
========================

Development of Galaxy tools to wrap the Amplicon_analysis pipeline:
https://github.com/MTutino/Amplicon_analysis

Pipeline options to interface
=============================

 - Input files:

   * List of Fastq R1/R2 pairs
   * ``Categories.txt`` file
   * ``Final_name.txt`` file
   * ``Metatable.txt`` file

 - Step one (quality control):

   * Cutadapt: forward and reverse PCR primers, without any
     barcode/adapter (-g and -G options). Must be supplied.
   * Sickle: threshold below which read will be trimmed (-q) (default 20)
   * Pandaseq: minimum overlap (in bp) between forward and reverse reads
     (-O) (default 10)
   * Pandaseq: minimum length (in bp) for a sequence to be kept after
     overlapping (-L) (default 380)

 - Step two (pipeline):

   * Pipeline: one of 'uparse', 'vsearch' or 'QIIME' (e.g. -P vsearch)
   * Reference database: by default the reference database is GreenGenes,
     use -S to use Silva instead

 - Step three (reporting):

   * no options required at present

Setup and configuration
=======================

To ensure that HTML outputs are displayed correctly in Galaxy (for example
the Vsearch OTU table heatmaps), Galaxy needs to be configured not to
sanitize the outputs from the ``Amplicon_analysis`` tool.

Either:

 - Set ``sanitize_all_html = False`` in ``config/galaxy.ini`` (nb don't do
   this on production servers or public instances!); or
 - Add the ``Amplicon_analysis`` tool to the display whitelist in the
   Galaxy instance:

   * Set ``sanitize_whitelist_file = config/whitelist.txt`` in
     ``config/galaxy.ini`` and restart Galaxy;
   * Go to ``Admin>Manage Display Whitelist``, check the box for
     ``Amplicon_analysis`` (hint: use your browser's 'find-in-page'
     search function to help locate it) and click on
     ``Submit new whitelist`` to update the settings.

Outputs to collect
==================

 - <PIPELINE>_OTU_tables/*_tax_OTU_table.biom
 - <PIPELINE>_OTU_tables/otus.tre
 - Metatable_log/Metatable_corrected.txt (final metatable file)
 - RESULTS/<PIPELINE>_<reference>/phylum_genus_dist/bar_charts.html
 - RESULTS/<PIPELINE>_<reference>/OTUS_count.txt
 - RESULTS/<PIPELINE>_<reference>/table_summary.txt
 - RESULTS/<PIPELINE>_<reference>/Heatmap/otu_table.html
 - RESULTS/<PIPELINE>_<reference>/beta_div_even/weighted_2d_plot/...html
 - RESULTS/<PIPELINE>_<reference>/beta_div_even/unweighted_2d_plot/...html

Dependencies
============

The tool takes its dependencies from the underlying pipeline script (see
https://github.com/MTutino/Amplicon_analysis/blob/master/README.md
for details).

The ``install_tool_deps.sh`` script can be used to install the
dependencies locally, for example::

    install_tool_deps.sh /path/to/local_tool_dependencies

This can then be targeted in a Galaxy installation by adding the
following lines to the ``dependency_resolvers_conf.xml`` file::

    <galaxy_packages base_path="/path/to/local_tool_dependencies" />
    <galaxy_packages base_path="/path/to/local_tool_dependencies" versionless="true" />

ideally before the ``<conda ... />`` resolvers; see
https://docs.galaxyproject.org/en/latest/admin/dependency_resolvers.html#galaxy-packages-dependency-resolver.

Alternatively (or in addition), a number of dependencies are also
available via (Bio)conda:

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

Other notes
===========

 * The pipeline takes as input multiple pairs of Fastq files, which is
   potentially a challenge for implementing a Galaxy wrapper. One possible
   approach could be to use Galaxy collections, along the lines of:
   - _Processing many samples at once (Galaxy wiki):https://github.com/nekrut/galaxy/wiki/Processing-many-samples-at-once

 * Silva database requires minimum 18Gb RAM

History
=======

========== ======================================================================
Version    Changes
---------- ----------------------------------------------------------------------
1.05       Updates including:

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
