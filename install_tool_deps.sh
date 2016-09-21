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
    install_python_package $INSTALL_DIR numpy 1.9 \
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
    ./autogen.sh >/dev/null 2>&1
    ./configure --prefix=$install_dir >/dev/null 2>&1
    make; make install >/dev/null 2>&1
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
##
#
