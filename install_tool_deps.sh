#!/bin/bash -e
#
# Install the tool dependencies for Amplicon_analysis_pipeline.sh for
# testing from command line
#
function install_python_package() {
    echo Installing $2 $3 from $4 under $1
    local install_dir=$1
    local install_dirs="$install_dir $install_dir/bin $install_dir/lib/python2.7/site-packages"
    for d in $install_dirs ; do
	if [ ! -d $d ] ; then
	    mkdir -p $d
	fi
    done
    wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q $4
    if [ ! -f "$(basename $4)" ] ; then
	echo "No archive $(basename $4)"
	exit 1
    fi
    tar xzf $(basename $4)
    if [ ! -d "$5" ] ; then
	echo "No directory $5"
	exit 1
    fi
    cd $5
    /bin/bash <<EOF
export PYTHONPATH=$install_dir:$PYTHONPATH && \
export PYTHONPATH=$install_dir/lib/python2.7/site-packages:$PYTHONPATH && \
python setup.py install --prefix=$install_dir --install-scripts=$install_dir/bin --install-lib=$install_dir/lib/python2.7/site-packages >>$INSTALL_DIR/INSTALLATION.log 2>&1
EOF
    popd
    rm -rf $wd/*
    rmdir $wd
}
function install_cutadapt_1_11() {
    echo Installing cutadapt 1.11
    INSTALL_DIR=$1/cutadapt/1.11
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR
    install_python_package $INSTALL_DIR cutadapt 1.11 \
	https://pypi.python.org/packages/47/bf/9045e90dac084a90aa2bb72c7d5aadefaea96a5776f445f5b5d9a7a2c78b/cutadapt-1.11.tar.gz \
	cutadapt-1.11
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup cutadapt/1.11
echo Setting up cutadapt 1.11
#if [ -f $1/python/2.7.10/env.sh ] ; then
#   . $1/python/2.7.10/env.sh
#fi
export PATH=$INSTALL_DIR/bin:\$PATH
export PYTHONPATH=$INSTALL_DIR:\$PYTHONPATH
export PYTHONPATH=$INSTALL_DIR/lib:\$PYTHONPATH
export PYTHONPATH=$INSTALL_DIR/lib/python2.7:\$PYTHONPATH
export PYTHONPATH=$INSTALL_DIR/lib/python2.7/site-packages:\$PYTHONPATH
#
EOF
}
function install_sickle_1_33() {
    echo Installing sickle 1.33
    INSTALL_DIR=$1/sickle/1.33
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR
    mkdir -p $INSTALL_DIR/bin
    wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q https://github.com/najoshi/sickle/archive/v1.33.tar.gz
    tar zxf v1.33.tar.gz
    cd sickle-1.33
    make >$INSTALL_DIR/INSTALLATION.log 2>&1
    mv sickle $INSTALL_DIR/bin
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup sickle/1.33
echo Setting up sickle 1.33
export PATH=$INSTALL_DIR/bin:\$PATH
#
EOF
}
function install_bioawk_27_08_2013() {
    echo Installing bioawk 27-08-2013
    INSTALL_DIR=$1/bioawk/27-08-2013
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR
    mkdir -p $INSTALL_DIR/bin
    wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q https://github.com/lh3/bioawk/archive/v1.0.tar.gz
    tar zxf v1.0.tar.gz
    cd bioawk-1.0
    make >$INSTALL_DIR/INSTALLATION.log 2>&1
    mv bioawk $INSTALL_DIR/bin
    mv maketab $INSTALL_DIR/bin
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup bioawk/2013-07-13
echo Setting up bioawk 2013-07-13
export PATH=$INSTALL_DIR/bin:\$PATH
#
EOF
}
function install_pandaseq_2_8_1() {
    # Taken from https://github.com/fls-bioinformatics-core/galaxy-tools/blob/master/local_dependency_installers/pandaseq.sh
    echo Installing pandaseq 2.8.1
    local install_dir=$1/pandaseq/2.8.1
    if [ -f $install_dir/env.sh ] ; then
	return
    fi
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q https://github.com/neufeld/pandaseq/archive/v2.8.1.tar.gz
    tar xzf v2.8.1.tar.gz
    cd pandaseq-2.8.1
    ./autogen.sh >$install_dir/INSTALLATION.log 2>&1
    ./configure --prefix=$install_dir >>$install_dir/INSTALLATION.log 2>&1
    make; make install >>$install_dir/INSTALLATION.log 2>&1
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $1/pandaseq/2.8.1/env.sh <<EOF
#!/bin/sh
# Source this to setup pandaseq/2.8.1
echo Setting up pandaseq 2.8.1
export PATH=$install_dir/bin:\$PATH
export LD_LIBRARY_PATH=$install_dir/lib:\$LD_LIBRARY_PATH
#
EOF
}
function install_spades_3_5_0() {
    # See http://spades.bioinf.spbau.ru/release3.5.0/manual.html
    echo Installing spades 3.5.0
    local install_dir=$1/spades/3.5.0
    if [ -f $install_dir/env.sh ] ; then
	return
    fi
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q http://spades.bioinf.spbau.ru/release3.5.0/SPAdes-3.5.0-Linux.tar.gz
    tar zxf SPAdes-3.5.0-Linux.tar.gz
    cd SPAdes-3.5.0-Linux
    mv bin $install_dir
    mv share $install_dir
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $1/spades/3.5.0/env.sh <<EOF
#!/bin/sh
# Source this to setup spades/3.5.0
echo Setting up spades 3.5.0
export PATH=$install_dir/bin:\$PATH
#
EOF
}
function install_fastqc_0_11_3() {
    echo Installing fastqc 0.11.3
    local install_dir=$1/fastqc/0.11.3
    if [ -f $install_dir/env.sh ] ; then
	return
    fi
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.3.zip
    unzip -qq fastqc_v0.11.3.zip
    cd FastQC
    chmod 0755 fastqc
    mv * $install_dir
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $1/fastqc/0.11.3/env.sh <<EOF
#!/bin/sh
# Source this to setup fastqc/0.11.3
echo Setting up fastqc 0.11.3
export PATH=$install_dir:\$PATH
#
EOF
}
function install_qiime_1_8_0() {
    # See http://qiime.org/1.8.0/install/install.html
    echo Installing qiime 1.8.0
    INSTALL_DIR=$1/qiime/1.8.0
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR
    # Python packages
    install_python_package $INSTALL_DIR numpy 1.7.1 \
	https://pypi.python.org/packages/84/fb/5e9dfeeb5d8909d659e6892c97c9aa66d3798fad50e1d3d66b3c614a9c35/numpy-1.7.1.tar.gz \
	numpy-1.7.1
    install_python_package $INSTALL_DIR matplotlib 1.3.1 \
	https://pypi.python.org/packages/d4/d0/17f17792a4d50994397052220dbe3ac9850ecbde0297b7572933fa4a5c98/matplotlib-1.3.1.tar.gz \
	matplotlib-1.3.1
    install_python_package $INSTALL_DIR qiime 1.8.0 \
	https://github.com/biocore/qiime/archive/1.8.0.tar.gz \
	qiime-1.8.0
    install_python_package $INSTALL_DIR pycogent 1.5.3 \
	https://pypi.python.org/packages/1f/9f/c6f6afe09a3d62a6e809c7745413ffff0f1e8e04d88ab7b56faedf31fe28/cogent-1.5.3.tgz \
	cogent-1.5.3
    install_python_package $INSTALL_DIR pyqi 0.3.1 \
	https://pypi.python.org/packages/60/f0/a7392f5f5caf59a50ccaddbb35a458514953512b7dd6053567cb02849c6e/pyqi-0.3.1.tar.gz \
	pyqi-0.3.1
    install_python_package $INSTALL_DIR biom-format 1.3.1 \
	https://pypi.python.org/packages/98/3b/4e80a9a5c4a3c6764aa8c0c994973e7df71eee02fc6b8cc6e1d06a64ab7e/biom-format-1.3.1.tar.gz \
	biom-format-1.3.1
    install_python_package $INSTALL_DIR qcli 0.1.0 \
	https://pypi.python.org/packages/9a/9a/9c634aed339a5f063e0c954ae439d03b33a7159aa50c6f21034fe2d48fe8/qcli-0.1.0.tar.gz \
	qcli-0.1.0
    install_python_package $INSTALL_DIR pynast 1.2.2 \
	https://pypi.python.org/packages/a0/82/f381ff91afd7a2d92e74c7790823e256d87d5cd0a98c12eaac3d3ec64b8f/pynast-1.2.2.tar.gz \
	pynast-1.2.2
    install_python_package $INSTALL_DIR emperor 0.9.3 \
	https://pypi.python.org/packages/cd/f1/5d502a16a348efe1af7a8d4f41b639c9a165bca0b2f9db36bce89ad1ab40/emperor-0.9.3.tar.gz \
	emperor-0.9.3
    # Update the acceptable Python version
    sed -i 's/acceptable_version = (2,7,3)/acceptable_version = (2,7,6)/g' $INSTALL_DIR/bin/print_qiime_config.py
    # Non-Python dependencies
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q http://www.microbesonline.org/fasttree/FastTree
    chmod 0755 FastTree
    mv FastTree $INSTALL_DIR/bin
    # Config file
    sed -i 's,qiime_scripts_dir,qiime_scripts_dir\t'"$INSTALL_DIR\/bin"',g' $INSTALL_DIR/lib/python2.7/site-packages/qiime/support_files/qiime_config
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup qiime/1.8.0
echo Setting up qiime 1.8.0
#if [ -f $1/python/2.7.10/env.sh ] ; then
#   . $1/python/2.7.10/env.sh
#fi
export QIIME_CONFIG_FP=$INSTALL_DIR/lib/python2.7/site-packages/qiime/support_files/qiime_config
export PATH=$INSTALL_DIR/bin:\$PATH
export PYTHONPATH=$INSTALL_DIR:\$PYTHONPATH
export PYTHONPATH=$INSTALL_DIR/lib:\$PYTHONPATH
export PYTHONPATH=$INSTALL_DIR/lib/python2.7:\$PYTHONPATH
export PYTHONPATH=$INSTALL_DIR/lib/python2.7/site-packages:\$PYTHONPATH
#
EOF
}
function install_vsearch_1_1_3() {
    echo Installing vsearch 1.1.3
    local install_dir=$1/vsearch/1.1.3
    if [ -f $install_dir/env.sh ] ; then
	return
    fi
    mkdir -p $install_dir/bin
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q https://github.com/torognes/vsearch/releases/download/v1.1.3/vsearch-1.1.3-linux-x86_64
    chmod 0755 vsearch-1.1.3-linux-x86_64
    mv vsearch-1.1.3-linux-x86_64 $install_dir/bin/vsearch
    ln -s $install_dir/bin/vsearch $install_dir/bin/vsearch113
    popd
    # Clean up
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
cat > $install_dir/env.sh <<EOF
#!/bin/sh
# Source this to setup vsearch/1.1.3
echo Setting up vsearch 1.1.3
export PATH=$install_dir/bin:\$PATH
#
EOF
}
function install_microbiomeutil_2010_04_29() {
    # Provides ChimeraSlayer
    echo Installing microbiomeutil 2010-04-29
    local install_dir=$1/microbiomeutil/2010-04-29
    if [ -f $install_dir/env.sh ] ; then
	return
    fi
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q https://sourceforge.net/projects/microbiomeutil/files/__OLD_VERSIONS/microbiomeutil_2010-04-29.tar.gz
    tar zxf microbiomeutil_2010-04-29.tar.gz
    cd microbiomeutil_2010-04-29
    make >$install_dir/INSTALLATION.log 2>&1
    mv * $install_dir
    popd
    # Clean up
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
cat > $install_dir/env.sh <<EOF
#!/bin/sh
# Source this to setup microbiomeutil/2010-04-29
echo Setting up microbiomeutil 2010-04-29
export PATH=$install_dir/ChimeraSlayer:\$PATH
#
EOF
}
function install_blast_2_2_26() {
    echo Installing blast 2.2.26
    local install_dir=$1/blast/2.2.26
    if [ -f $install_dir/env.sh ] ; then
	return
    fi
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q ftp://ftp.ncbi.nlm.nih.gov/blast/executables/legacy/2.2.26/blast-2.2.26-x64-linux.tar.gz
    tar zxf blast-2.2.26-x64-linux.tar.gz
    cd blast-2.2.26
    mv * $install_dir
    popd
    # Clean up
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
cat > $install_dir/env.sh <<EOF
#!/bin/sh
# Source this to setup blast/2.2.26
echo Setting up blast 2.2.26
export PATH=$install_dir/bin:\$PATH
#
EOF
}
function install_fasta_number() {
    # See http://drive5.com/python/fasta_number_py.html
    echo Installing fasta_number
    # Install to "default" version i.e. essentially a versionless
    # installation (see Galaxy dependency resolver docs)
    local install_dir=$1/fasta_number/default
    if [ -f $install_dir/env.sh ] ; then
	return
    fi
    mkdir -p $install_dir/bin
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q http://drive5.com/python/python_scripts.tar.gz
    tar zxf python_scripts.tar.gz
    mv fasta_number.py $install_dir/bin
    popd
    # Clean up
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
cat > $install_dir/env.sh <<EOF
#!/bin/sh
# Source this to setup fasta_number/default
echo Setting up fasta_number \(default\)
export PATH=$install_dir/bin:\$PATH
#
EOF
}
function install_fasta_splitter_0_2_4() {
    echo Installing fasta-splitter 0.2.4
    local install_dir=$1/fasta-splitter/0.2.4
    if [ -f $install_dir/env.sh ] ; then
	return
    fi
    mkdir -p $install_dir/bin
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q http://kirill-kryukov.com/study/tools/fasta-splitter/files/fasta-splitter-0.2.4.zip
    unzip -qq fasta-splitter-0.2.4.zip
    chmod 0755 fasta-splitter.pl
    mv fasta-splitter.pl $install_dir/bin
    popd
    # Clean up
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
cat > $install_dir/env.sh <<EOF
#!/bin/sh
# Source this to setup fasta-splitter/0.2.4
echo Setting up fasta-splitter 0.2.4
export PATH=$install_dir/bin:\$PATH
#
EOF
}
function install_rdp_classifier_2_2() {
    echo Installing rdp-classifier 2.2R
    local install_dir=$1/rdp-classifier/2.2
    if [ -f $install_dir/env.sh ] ; then
	return
    fi
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q https://sourceforge.net/projects/rdp-classifier/files/rdp-classifier/rdp_classifier_2.2.zip
    unzip -qq rdp_classifier_2.2.zip
    cd rdp_classifier_2.2
    mv * $install_dir
    popd
    # Clean up
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
cat > $install_dir/env.sh <<EOF
#!/bin/sh
# Source this to setup rdp-classifier/2.2
echo Setting up RDP classifier 2.2
export RDP_JAR_PATH=$install_dir/rdp_classifier-2.2.jar
#
EOF
}
function install_R_3_2_0() {
    # Adapted from https://github.com/fls-bioinformatics-core/galaxy-tools/blob/master/local_dependency_installers/R.sh
    echo Installing R 3.2.0
    local install_dir=$1/R/3.2.0
    if [ -f $install_dir/env.sh ] ; then
	return
    fi
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q http://cran.r-project.org/src/base/R-3/R-3.2.0.tar.gz
    tar xzf R-3.2.0.tar.gz
    cd R-3.2.0
    ./configure --prefix=$install_dir
    make
    make install
    popd
    # Clean up
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
cat > $install_dir/env.sh <<EOF
#!/bin/sh
# Source this to setup R/3.2.0
echo Setting up R 3.2.0
export PATH=$install_dir/bin:\$PATH
export TCL_LIBRARY=$install_dir/lib/libtcl8.4.so
export TK_LIBRARY=$install_dir/lib/libtk8.4.so
#
EOF
}
function install_uc2otutab() {
    # See http://drive5.com/python/uc2otutab_py.html
    echo Installing uc2otutab
    # Install to "default" version i.e. essentially a versionless
    # installation (see Galaxy dependency resolver docs)
    local install_dir=$1/uc2otutab/default
    if [ -f $install_dir/env.sh ] ; then
	return
    fi
    mkdir -p $install_dir/bin
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q http://drive5.com/python/python_scripts.tar.gz
    tar zxf python_scripts.tar.gz
    mv uc2otutab.py die.py fasta.py progress.py uc.py $install_dir/bin
    popd
    # Clean up
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
cat > $install_dir/env.sh <<EOF
#!/bin/sh
# Source this to setup uc2otutab/default
echo Setting up uc2otutab \(default\)
export PATH=$install_dir/bin:\$PATH
#
EOF
}
##########################################################
# Main script starts here
##########################################################
# Fetch top-level installation directory from command line
TOP_DIR=$1
if [ -z "$TOP_DIR" ] ; then
    echo Usage: $(basename $0) DIR
    exit
fi
if [ -z "$(echo $TOP_DIR | grep ^/)" ] ; then
    TOP_DIR=$(pwd)/$TOP_DIR
fi
if [ ! -d "$TOP_DIR" ] ; then
    mkdir -p $TOP_DIR
fi
# Install dependencies
install_cutadapt_1_11 $TOP_DIR
install_sickle_1_33 $TOP_DIR
install_bioawk_27_08_2013 $TOP_DIR
install_pandaseq_2_8_1 $TOP_DIR
install_spades_3_5_0 $TOP_DIR
install_fastqc_0_11_3 $TOP_DIR
install_qiime_1_8_0 $TOP_DIR
install_vsearch_1_1_3 $TOP_DIR
install_microbiomeutil_2010_04_29 $TOP_DIR
install_blast_2_2_26 $TOP_DIR
install_fasta_number $TOP_DIR
install_fasta_splitter_0_2_4 $TOP_DIR
install_rdp_classifier_2_2 $TOP_DIR
install_R_3_2_0 $TOP_DIR
install_uc2otutab $TOP_DIR
##
#
