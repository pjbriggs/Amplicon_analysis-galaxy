microbiome-ppln-galaxy
======================

Development of Galaxy tools to wrap Mauro Tutino's microbiome pipeline
scripts (not publicly avaialble).

Pipeline dependencies
---------------------

The pipeline uses the following packages - for step 1::

    cutadapt
    anaconda/2.2.0
    sickle/1.33
    bioawk/27-08-2013
    pandaseq/2.8
    spades/3.5.0
    fastqc/0.11.3

For steps 2 and 2::

    qiime/1.8.0
    blast/legacy/2.2.26
    fasta_number/02jun2015
    fasta-splitter/0.2.4
    rdp_classifier/2.2
    R/3.2.0

Equivalent Galaxy tools:

 - ``Cutadapt`` (no version specified)
   https://toolshed.g2.bx.psu.edu/view/lparsons/package_cutadapt_1_6/
   https://toolshed.g2.bx.psu.edu/view/iuc/package_cutadapt_1_8/

 - ``Sickle`` (1.33)
   https://toolshed.g2.bx.psu.edu/view/slegras/package_sickle_1_33/

 - ``Bioawk`` (27-08-2013)
   No version found on toolshed - have 1.0 version under development at
   https://github.com/fls-bioinformatics-core/galaxy-tools/tree/package_bioawk_27_08_2013/packages/package_bioawk_1_0

 - ``Pandaseq`` (2.8)
   No version found on toolshed - have 2.8.1 version under development at
   https://github.com/fls-bioinformatics-core/galaxy-tools/

 - ``Spades`` (3.5.0)
   Only 3.6.* found on toolshed, e.g.
   https://toolshed.g2.bx.psu.edu/view/nml/package_spades_3_6_2/

 - ``Fastqc`` (0.11.3)
   Only 0.11.2 and 0.11.4 found on toolshed e.g.
   https://toolshed.g2.bx.psu.edu/view/iuc/package_fastqc_0_11_4/

 - ``Qiime`` (1.8)
   Only 1.9.1 found on toolshed:
   https://toolshed.g2.bx.psu.edu/view/iuc/package_python_2_7_qiime_1_9_1/

 - ``Blast`` (2.2.26)
   https://toolshed.g2.bx.psu.edu/view/iyad/package_blast_2_2_26/

 - ``fasta_number`` (02jun2015)
   Part of ``uparse``? No toolshed version available, possible licensing issues?
   http://drive5.com/python/summary.html
   http://drive5.com/python/
   http://drive5.com/python/python_scripts.tar.gz

 - ``fasta_splitter`` (0.2.4)
   No toolshed version found - have 0.2.4 version under development at
   https://github.com/fls-bioinformatics-core/galaxy-tools/tree/package_fasta_splitter_0_2_4/packages/package_fasta_splitter_0_2_4

 - ``RDP classifier`` (2.2)
   Is this part of ``Qiime``?

 - ``R`` (3.2.0)
   Toolshed has ``R`` 3.2.1:
   https://toolshed.g2.bx.psu.edu/view/iuc/package_r_3_2_1/d0bf97420fb5
