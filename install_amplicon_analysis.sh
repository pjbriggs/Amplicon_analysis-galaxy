#!/bin/bash -e
#
# Prototype script to setup a conda environment with the
# dependencies needed for the Amplicon_analysis_pipeline
# script
#
# Handle command line
function usage() {
    echo "Usage: $(basename $0) [DIR]"
    echo ""
    echo "Installs the Amplicon_analysis_pipeline package plus"
    echo "dependencies in directory DIR (or current directory "
    echo "if DIR not supplied)"
}
if [ ! -z "$1" ] ; then
    # Check if help was requested
    if [ "$1" == "--help" ] || [ "$1" == "-h" ] ; then
	usage
	exit 0
    fi
    # Assume it's the installation directory
    cd $1
fi
# Versions
PIPELINE_VERSION=1.2.3
RDP_CLASSIFIER_VERSION=2.2
# Directories
TOP_DIR=$(pwd)/Amplicon_analysis-${PIPELINE_VERSION}
BIN_DIR=${TOP_DIR}/bin
MINICONDA_DIR=${TOP_DIR}/miniconda2
CONDA_BIN=${MINICONDA_DIR}/bin
CONDA_LIB=${MINICONDA_DIR}/lib
CONDA=${CONDA_BIN}/conda
ENV_NAME="amplicon_analysis_pipeline@${PIPELINE_VERSION}"
ENV_DIR=${MINICONDA_DIR}/envs/$ENV_NAME
#
# Install conda
function install_conda_deps() {
    echo "++++++++++++++++++++++++++"
    echo "Creating conda environment"
    echo "++++++++++++++++++++++++++"
    if [ -e ${MINICONDA_DIR} ] ; then
	echo "*** $MINICONDA_DIR already exists ***"
	return
    fi
    local wd=$(mktemp -d)
    pushd $wd
    wget -q https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh
    /bin/bash ./Miniconda2-latest-Linux-x86_64.sh -b -p ${MINICONDA_DIR}
    echo Installed conda in ${MINICONDA_DIR}
    #
    # Create the conda environment
    cat >environment.yml <<EOF
name: ${ENV_NAME}
channels:
  - defaults
  - conda-forge
  - bioconda
dependencies:
  - python=2.7
  - cutadapt=1.11
  - sickle-trim=1.33
  - bioawk=1.0
  - pandaseq=2.8.1
  - spades=3.5.0
  - fastqc=0.11.3
  - qiime=1.8.0
  - blast-legacy=2.2.26
  - fasta-splitter=0.2.4
  - rdp_classifier=$RDP_CLASSIFIER_VERSION
  - vsearch=1.1.3
  # Need to explicitly specify libgfortran
  # version (otherwise get version incompatible
  # with numpy=1.7.1)
  - libgfortran=1.0
  # Compilers needed to build R
  - gcc_linux-64
  - gxx_linux-64
  - gfortran_linux-64
EOF
    ${CONDA} env create --name "${ENV_NAME}" -f environment.yml
    echo Created conda environment in ${ENV_DIR}
    popd
    rm -rf $wd/*
    rmdir $wd
}
#
# Amplicon analyis pipeline
function install_amplicon_analysis_pipeline() {
    echo "+++++++++++++++++++++++++++++++++++++"
    echo "Installing Amplicon_analysis_pipeline"
    echo "+++++++++++++++++++++++++++++++++++++"
    if [ -e ${BIN_DIR}/Amplicon_analysis_pipeline.sh ] ; then
	echo "*** Amplicon_analysis_pipeline.sh already installed ***"
	return
    fi
    local wd=$(mktemp -d)
    pushd $wd
    wget -q https://github.com/MTutino/Amplicon_analysis/archive/v${PIPELINE_VERSION}.tar.gz
    tar zxf v${PIPELINE_VERSION}.tar.gz
    cd Amplicon_analysis-${PIPELINE_VERSION}
    INSTALL_DIR=${TOP_DIR}/share/amplicon_analysis_pipeline-${PIPELINE_VERSION}
    mkdir -p $INSTALL_DIR
    ln -s $INSTALL_DIR ${TOP_DIR}/share/amplicon_analysis_pipeline
    for f in *.sh ; do
	/bin/cp $f $INSTALL_DIR
    done
    /bin/cp -r uc2otutab $INSTALL_DIR
    mkdir -p ${BIN_DIR}
    cat >${BIN_DIR}/Amplicon_analysis_pipeline.sh <<EOF
#!/bin/bash
#
# Point to Qiime config
export QIIME_CONFIG_FP=${TOP_DIR}/qiime/qiime_config
# Set up the RDP jar file
export RDP_JAR_PATH=${TOP_DIR}/share/rdp_classifier/rdp_classifier-${RDP_CLASSIFIER_VERSION}.jar
# Put the scripts onto the PATH
export PATH=${BIN_DIR}:${INSTALL_DIR}:\$PATH
# Activate the conda environment
source ${CONDA_BIN}/activate ${ENV_NAME}
# Execute the driver script with the supplied arguments
$INSTALL_DIR/Amplicon_analysis_pipeline.sh \$@
exit \$?
EOF
    chmod 0755 ${BIN_DIR}/Amplicon_analysis_pipeline.sh
    cat >${BIN_DIR}/install_reference_data.sh <<EOF
#!/bin/bash -e
#
function usage() {
  echo "Usage: \$(basename \$0) DIR"
}
if [ -z "\$1" ] ; then
  usage
  exit 0
elif [ "\$1" == "--help" ] || [ "\$1" == "-h" ] ; then
  usage
  echo ""
  echo "Install reference data into DIR"
  exit 0
fi
echo "=========================================="
echo "Installing Amplicon analysis pipeline data"
echo "=========================================="
if [ ! -e "\$1" ] ; then
    echo "Making directory \$1"
    mkdir -p \$1
fi
cd \$1
DATA_DIR=\$(pwd)
echo "Installing reference data under \$DATA_DIR"
$INSTALL_DIR/References.sh
echo ""
echo "Use '-r \$DATA_DIR' when running Amplicon_analysis_pipeline.sh"
echo "to use the reference data from this directory"
echo ""
echo "\$(basename \$0): finished"
EOF
    chmod 0755 ${BIN_DIR}/install_reference_data.sh
    popd
    rm -rf $wd/*
    rmdir $wd
}
#
# ChimeraSlayer
function install_chimeraslayer() {
    echo "++++++++++++++++++++++++"
    echo "Installing ChimeraSlayer"
    echo "++++++++++++++++++++++++"
    if [ -e ${BIN_DIR}/ChimeraSlayer.pl ] ; then
	echo "*** ChimeraSlayer.pl already installed ***"
	return
    fi
    local wd=$(mktemp -d)
    pushd $wd
    wget -q https://sourceforge.net/projects/microbiomeutil/files/__OLD_VERSIONS/microbiomeutil_2010-04-29.tar.gz
    tar zxf microbiomeutil_2010-04-29.tar.gz
    cd microbiomeutil_2010-04-29
    INSTALL_DIR=${TOP_DIR}/share/microbiome_chimeraslayer-2010-04-29
    mkdir -p $INSTALL_DIR
    ln -s $INSTALL_DIR ${TOP_DIR}/share/microbiome_chimeraslayer
    /bin/cp -r ChimeraSlayer $INSTALL_DIR
    cat >${BIN_DIR}/ChimeraSlayer.pl <<EOF
#!/bin/bash
export PATH=$INSTALL_DIR:\$PATH
$INSTALL_DIR/ChimeraSlayer/ChimeraSlayer.pl $@
EOF
    chmod 0755 ${INSTALL_DIR}/ChimeraSlayer/ChimeraSlayer.pl
    chmod 0755 ${BIN_DIR}/ChimeraSlayer.pl
    popd
    rm -rf $wd/*
    rmdir $wd
}
#
# uclust required for QIIME/pyNAST
# License only allows this version to be used with those two packages
# See: http://drive5.com/uclust/downloads1_2_22q.html
function install_uclust() {
    echo "++++++++++++++++++++++++++++++++++"
    echo "Installing uclust for QIIME/pyNAST"
    echo "++++++++++++++++++++++++++++++++++"
    if [ -e ${BIN_DIR}/uclust ] ; then
	echo "*** uclust already installed ***"
	return
    fi
    local wd=$(mktemp -d)
    pushd $wd
    wget -q http://drive5.com/uclust/uclustq1.2.22_i86linux64
    INSTALL_DIR=${TOP_DIR}/share/uclust-1.2.22
    mkdir -p $INSTALL_DIR
    ln -s $INSTALL_DIR ${TOP_DIR}/share/uclust
    /bin/mv uclustq1.2.22_i86linux64 ${INSTALL_DIR}/uclust
    chmod 0755 ${INSTALL_DIR}/uclust
    ln -s  ${INSTALL_DIR}/uclust ${BIN_DIR}
    popd
    rm -rf $wd/*
    rmdir $wd
}
#
# R 3.2.1
# Can't use version from conda due to dependency conflicts
function install_R_3_2_1() {
    echo "++++++++++++++++++"
    echo "Installing R 3.2.1"
    echo "++++++++++++++++++"
    if [ -e ${BIN_DIR}/R ] ; then
	echo "*** R already installed ***"
	return
    fi
    source ${CONDA_BIN}/activate ${ENV_NAME}
    local wd=$(mktemp -d)
    pushd $wd
    echo -n "Fetching R 3.2.1 source code..."
    wget -q http://cran.r-project.org/src/base/R-3/R-3.2.1.tar.gz
    echo "ok"
    INSTALL_DIR=${TOP_DIR}
    mkdir -p $INSTALL_DIR
    echo -n "Unpacking source code..."
    tar xzf R-3.2.1.tar.gz >INSTALL.log 2>&1
    echo "ok"
    cd R-3.2.1
    echo -n "Running configure..."
    ./configure --prefix=$INSTALL_DIR --with-x=no --with-readline=no >>INSTALL.log 2>&1
    echo "ok"
    echo -n "Running make..."
    make >>INSTALL.log 2>&1
    echo "ok"
    echo -n "Running make install..."
    make install >>INSTALL.log 2>&1
    echo "ok"
    popd
    rm -rf $wd/*
    rmdir $wd
    source ${CONDA_BIN}/deactivate
}
function setup_pipeline_environment() {
    echo "+++++++++++++++++++++++++++++++"
    echo "Setting up pipeline environment"
    echo "+++++++++++++++++++++++++++++++"
    # vsearch113
    echo -n "Setting up vsearch113..."
    if [ -e ${BIN_DIR}/vsearch113 ] ; then
	echo "already exists"
    elif [ ! -e ${ENV_DIR}/bin/vsearch ] ; then
	echo "failed"
	echo "ERROR vsearch not found" >&2
	exit 1
    else
	ln -s ${ENV_DIR}/bin/vsearch ${BIN_DIR}/vsearch113
	echo "ok"
    fi
    # fasta_splitter.pl
    echo -n "Setting up fasta_splitter.pl..."
    if [ -e ${BIN_DIR}/fasta-splitter.pl ] ; then
	echo "already exists"
    elif [ ! -e ${ENV_DIR}/share/fasta-splitter/fasta-splitter.pl ] ; then
	echo "failed"
	echo "ERROR fasta-splitter.pl not found" >&2
	exit 1
    else
	ln -s ${ENV_DIR}/share/fasta-splitter/fasta-splitter.pl ${BIN_DIR}/fasta-splitter.pl
	echo "ok"
    fi
    # rdp_classifier.jar
    local rdp_classifier_jar=rdp_classifier-${RDP_CLASSIFIER_VERSION}.jar
    echo -n "Setting up rdp_classifier.jar..."
    if [ -e ${TOP_DIR}/share/rdp_classifier/${rdp_classifier_jar} ] ; then
	echo "already exists"
    elif [ ! -e ${ENV_DIR}/share/rdp_classifier/rdp_classifier.jar ] ; then
	echo "failed"
	echo "ERROR rdp_classifier.jar not found" >&2
	exit 1
    else
	mkdir -p ${TOP_DIR}/share/rdp_classifier
	ln -s ${ENV_DIR}/share/rdp_classifier/rdp_classifier.jar ${TOP_DIR}/share/rdp_classifier/${rdp_classifier_jar}
	echo "ok"	
    fi
    # qiime_config
    echo -n "Setting up qiime_config..."
    if [ -e ${TOP_DIR}/qiime/qiime_config ] ; then
	echo "already exists"
    else
	mkdir -p ${TOP_DIR}/qiime
	cat >${TOP_DIR}/qiime/qiime_config <<EOF-qiime-config
qiime_scripts_dir	${ENV_DIR}/bin
EOF-qiime-config
	echo "ok"
    fi
}
function remove_conda_compilers() {
    echo "+++++++++++++++++++++++++++++++++++++++++"
    echo "Removing compilers from conda environment"
    echo "+++++++++++++++++++++++++++++++++++++++++"
    ${CONDA} remove -y -n ${ENV_NAME} gcc_linux-64 gxx_linux-64 gfortran_linux-64
}
#
# Top level script does the installation
echo "======================================="
echo "Amplicon_analysis_pipeline installation"
echo "======================================="
echo "Installing into ${TOP_DIR}"
if [ -e ${TOP_DIR} ] ; then
    echo "*** Directory already exists ***" >&2
    exit 1
fi
mkdir -p ${TOP_DIR}
install_conda_deps
install_amplicon_analysis_pipeline
install_chimeraslayer
install_uclust
install_R_3_2_1
setup_pipeline_environment
remove_conda_compilers
echo "===================================="
echo "Amplicon_analysis_pipeline installed"
echo "===================================="
echo ""
echo "Install reference data using:"
echo ""
echo "\$ ${BIN_DIR}/install_reference_data.sh DIR"
echo ""
echo "Run pipeline scripts using:"
echo ""
echo "\$ ${BIN_DIR}/Amplicon_analysis_pipeline.sh ..."
echo ""
echo "(or add ${BIN_DIR} to your PATH)"
echo ""
echo "$(basename $0): finished"
##
#
