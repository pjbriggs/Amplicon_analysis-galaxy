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

Pipeline dependencies
=====================

The pipeline script has the following dependencies

 - cutadapt (version not specified):

   * Using 1.11
   * Toolshed has `1.6 <https://toolshed.g2.bx.psu.edu/view/lparsons/package_cutadapt_1_6/>`_, `1.8 <https://toolshed.g2.bx.psu.edu/view/iuc/package_cutadapt_1_8/>`_

 - sickle 1.33:

   * Using 1.33
   * Toolshed has `1.33 <https://toolshed.g2.bx.psu.edu/view/slegras/package_sickle_1_33/>`_

 - bioawk 27-08-2013

   * Using 27-08-2013
   * Toolshed doesn't have a version but there is a `WIP <https://github.com/fls-bioinformatics-core/galaxy-tools/tree/package_bioawk_27_08_2013/packages/package_bioawk_1_0>`_

 - pandaseq 2.8

   * Using 2.8.1
   * Toolshed doesn't have a version but there is a `WIP <https://github.com/fls-bioinformatics-core/galaxy-tools/tree/master/packages/package_pandaseq_2_8_1>`_

 - spades 3.5.0

   * Using 3.5.0
   * Toolshed has `3.6.2 <https://toolshed.g2.bx.psu.edu/view/nml/package_spades_3_6_2/>`_

 - fastqc 0.11.3

   * Using 0.11.3
   * Toolshed has `0.11.4 <https://toolshed.g2.bx.psu.edu/view/iuc/package_fastqc_0_11_4/>`_

 - qiime 1.8.0

   * Using 1.8.0
   * Toolshed has `1.9.1 <https://toolshed.g2.bx.psu.edu/view/iuc/package_python_2_7_qiime_1_9_1/>`_

 - blast 2.2.26

   * Using 2.2.26
   * Toolshed has broken `2.2.26 <https://toolshed.g2.bx.psu.edu/view/iyad/package_blast_2_2_26/>`_

 - fasta_number 02jun2015

   * Unspecified verion (latest from `uparse <http://drive5.com/python/summary.html>`_)
   * Toolshed doesn't have a version

 - fasta-splitter 0.2.4

   * Using 0.2.4
   * Toolshed doesn't have a version but there is a `WIP <https://github.com/fls-bioinformatics-core/galaxy-tools/tree/package_fasta_splitter_0_2_4/packages/package_fasta_splitter_0_2_4>`_

 - rdp_classifier 2.2

   * Using 2.2
   * Toolshed doesn't have a version?

 - R 3.2.0

   * Using 3.2.0
   * Toolshed has `3.2.1 <https://toolshed.g2.bx.psu.edu/view/iuc/package_r_3_2_1/>`_

 - microbiomeutil r20110519

   * Using 2010-04-29

 - vsearch 1.1.3/1.1.3

   * Using 1.1.3

 - usearch 6.1.544 and 8.0.1623

   * ?

There is an installer script which attempts to install the dependencies
locally (``install_tool_deps.sh``).

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
1.0.0      Initial version
========== ======================================================================
