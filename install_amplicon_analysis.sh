#!/bin/sh -e
#
# Prototype script to setup a conda environment with the
# dependencies needed for the Amplicon_analysis_pipeline
# script
#
# Handle command line
usage()
{
    echo "Usage: $(basename $0) [DIR]"
    echo ""
    echo "Installs the Amplicon_analysis_pipeline package plus"
    echo "dependencies in directory DIR (or current directory "
    echo "if DIR not supplied)"
}
if [ ! -z "$1" ] ; then
    # Check if help was requested
    case "$1" in
	--help|-h)
	    usage
	    exit 0
	    ;;
    esac
    # Assume it's the installation directory
    cd $1
fi
# Versions
PIPELINE_VERSION=1.3.2
CONDA_REQUIRED_VERSION=4.6.14
RDP_CLASSIFIER_VERSION=2.2
# Directories
TOP_DIR=$(pwd)/Amplicon_analysis-${PIPELINE_VERSION}
BIN_DIR=${TOP_DIR}/bin
CONDA_DIR=${TOP_DIR}/conda
CONDA_BIN=${CONDA_DIR}/bin
CONDA_LIB=${CONDA_DIR}/lib
CONDA=${CONDA_BIN}/conda
ENV_NAME="amplicon_analysis_pipeline@${PIPELINE_VERSION}"
ENV_DIR=${CONDA_DIR}/envs/$ENV_NAME
#
# Functions
#
# Report failure and terminate script
fail()
{
    echo ""
    echo ERROR $@ >&2
    echo ""
    echo "$(basename $0): installation failed"
    exit 1
}
#
# Rewrite the shebangs in the installed conda scripts
# to remove the full path to conda 'bin' directory
rewrite_conda_shebangs()
{
    pattern="s,^#!${CONDA_BIN}/,#!/usr/bin/env ,g"
    find ${CONDA_BIN} -type f -exec sed -i "$pattern" {} \;
}
#
# Reset conda version if required
reset_conda_version()
{
    CONDA_VERSION="$(${CONDA_BIN}/conda -V 2>&1 | head -n 1 | cut -d' ' -f2)"
    echo conda version: ${CONDA_VERSION}
    if [ "${CONDA_VERSION}" != "${CONDA_REQUIRED_VERSION}" ] ; then
	echo "Resetting conda to last known working version $CONDA_REQUIRED_VERSION"
	${CONDA_BIN}/conda config --set allow_conda_downgrades true
	${CONDA_BIN}/conda install -y conda=${CONDA_REQUIRED_VERSION}
    else
	echo "conda version ok"
    fi
}
#
# Install conda
install_conda()
{
    echo "++++++++++++++++"
    echo "Installing conda"
    echo "++++++++++++++++"
    if [ -e ${CONDA_DIR} ] ; then
	echo "*** $CONDA_DIR already exists ***" >&2
	return
    fi
    local cwd=$(pwd)
    local wd=$(mktemp -d)
    cd $wd
    wget -q https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh
    bash ./Miniconda2-latest-Linux-x86_64.sh -b -p ${CONDA_DIR}
    echo Installed conda in ${CONDA_DIR}
    # Reset the conda version to a known working version
    # (to avoid problems observed with e.g. conda 4.7.10)
    echo ""
    reset_conda_version
    # Update the installation files
    # This is to avoid problems when the length the installation
    # directory path exceeds the limit for the shebang statement
    # in the conda files
    echo ""
    echo -n "Rewriting conda shebangs..."
    rewrite_conda_shebangs
    echo "ok"
    echo -n "Adding conda bin to PATH..."
    PATH=${CONDA_BIN}:$PATH
    echo "ok"
    cd $cwd
    rm -rf $wd/*
    rmdir $wd
}
#
# Create conda environment
install_conda_packages()
{
    echo "+++++++++++++++++++++++++"
    echo "Installing conda packages"
    echo "+++++++++++++++++++++++++"
    local cwd=$(pwd)
    local wd=$(mktemp -d)
    cd $wd
    cat >environment.yml <<EOF
name: ${ENV_NAME}
channels:
  - defaults
  - conda-forge
  - bioconda
dependencies:
  - python=2.7
  - cutadapt=1.8
  - sickle-trim=1.33
  - bioawk=1.0
  - pandaseq=2.8.1
  - spades=3.10.1
  - fastqc=0.11.3
  - qiime=1.9.1
  - blast-legacy=2.2.26
  - fasta-splitter=0.2.6
  - rdp_classifier=$RDP_CLASSIFIER_VERSION
  - vsearch=2.10.4
  - r=3.5.1
  - r-tidyverse=1.2.1
  - bioconductor-dada2=1.10
  - bioconductor-biomformat=1.10.1
  - bioconductor-shortread=1.40.0
EOF
    ${CONDA} env create --name "${ENV_NAME}" -f environment.yml
    echo Created conda environment in ${ENV_DIR}
    cd $cwd
    rm -rf $wd/*
    rmdir $wd
    #
    # Patch qiime 1.9.1 tools to switch deprecated 'axisbg'
    # matplotlib property to 'facecolor':
    # https://matplotlib.org/api/prev_api_changes/api_changes_2.0.0.html
    echo ""
    for exe in make_2d_plots.py plot_taxa_summary.py ; do
	echo -n "Patching ${exe}..."
	find ${CONDA_DIR} -type f -name "$exe" -exec sed -i 's/axisbg=/facecolor=/g' {} \;
	echo "done"
    done
    #
    # Patch qiime 1.9.1 tools to switch deprecated 'set_axis_bgcolor'
    # method call to 'set_facecolor':
    # https://matplotlib.org/api/_as_gen/matplotlib.axes.Axes.set_axis_bgcolor.html
    for exe in make_rarefaction_plots.py ; do
	echo -n "Patching ${exe}..."
	find ${CONDA_DIR} -type f -name "$exe" -exec sed -i 's/set_axis_bgcolor/set_facecolor/g' {} \;
	echo "done"
    done
}
#
# Install all the non-conda dependencies in a single
# function (invokes separate functions for each package)
install_non_conda_packages()
{
    echo "+++++++++++++++++++++++++++++"
    echo "Installing non-conda packages"
    echo "+++++++++++++++++++++++++++++"
    # Temporary working directory
    local wd=$(mktemp -d)
    local cwd=$(pwd)
    local wd=$(mktemp -d)
    cd $wd
    # Amplicon analysis pipeline
    echo -n "Installing Amplicon_analysis_pipeline..."
    if [ -e ${BIN_DIR}/Amplicon_analysis_pipeline.sh ] ; then
	echo "already installed"
    else
	install_amplicon_analysis_pipeline
	echo "ok"
    fi
    # ChimeraSlayer
    echo -n "Installing ChimeraSlayer..."
    if [ -e ${BIN_DIR}/ChimeraSlayer.pl ] ; then
	echo "already installed"
    else
	install_chimeraslayer
	echo "ok"
    fi
    # Uclust
    echo -n "Installing uclust for QIIME/pyNAST..."
    if [ -e ${BIN_DIR}/uclust ] ; then
	echo "already installed"
    else
	install_uclust
	echo "ok"
    fi
}
#
# Amplicon analyis pipeline
install_amplicon_analysis_pipeline()
{
    local wd=$(mktemp -d)
    local cwd=$(pwd)
    local wd=$(mktemp -d)
    cd $wd
    wget -q https://github.com/MTutino/Amplicon_analysis/archive/${PIPELINE_VERSION}.tar.gz
    tar zxf ${PIPELINE_VERSION}.tar.gz
    cd Amplicon_analysis-${PIPELINE_VERSION}
    INSTALL_DIR=${TOP_DIR}/share/amplicon_analysis_pipeline-${PIPELINE_VERSION}
    mkdir -p $INSTALL_DIR
    ln -s $INSTALL_DIR ${TOP_DIR}/share/amplicon_analysis_pipeline
    for f in *.sh *.R ; do
	/bin/cp $f $INSTALL_DIR
    done
    /bin/cp -r uc2otutab $INSTALL_DIR
    mkdir -p ${BIN_DIR}
    cat >${BIN_DIR}/Amplicon_analysis_pipeline.sh <<EOF
#!/usr/bin/env bash
#
# Point to Qiime config
export QIIME_CONFIG_FP=${TOP_DIR}/qiime/qiime_config
# Set up the RDP jar file
export RDP_JAR_PATH=${TOP_DIR}/share/rdp_classifier/rdp_classifier-${RDP_CLASSIFIER_VERSION}.jar
# Set the Matplotlib backend
export MPLBACKEND="agg"
# Put the scripts onto the PATH
export PATH=${BIN_DIR}:${INSTALL_DIR}:\$PATH
# Activate the conda environment
export PATH=${CONDA_BIN}:\$PATH
source ${CONDA_BIN}/activate ${ENV_NAME}
# Execute the driver script with the supplied arguments
$INSTALL_DIR/Amplicon_analysis_pipeline.sh \$@
exit \$?
EOF
    chmod 0755 ${BIN_DIR}/Amplicon_analysis_pipeline.sh
    cat >${BIN_DIR}/install_reference_data.sh <<EOF
#!/usr/bin/env bash -e
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
    cd $cwd
    rm -rf $wd/*
    rmdir $wd
}
#
# ChimeraSlayer
install_chimeraslayer()
{
    local cwd=$(pwd)
    local wd=$(mktemp -d)
    cd $wd
    wget -q https://sourceforge.net/projects/microbiomeutil/files/__OLD_VERSIONS/microbiomeutil_2010-04-29.tar.gz
    tar zxf microbiomeutil_2010-04-29.tar.gz
    cd microbiomeutil_2010-04-29
    INSTALL_DIR=${TOP_DIR}/share/microbiome_chimeraslayer-2010-04-29
    mkdir -p $INSTALL_DIR
    ln -s $INSTALL_DIR ${TOP_DIR}/share/microbiome_chimeraslayer
    /bin/cp -r ChimeraSlayer $INSTALL_DIR
    cat >${BIN_DIR}/ChimeraSlayer.pl <<EOF
#!/usr/bin/env bash
export PATH=$INSTALL_DIR:\$PATH
$INSTALL_DIR/ChimeraSlayer/ChimeraSlayer.pl $@
EOF
    chmod 0755 ${INSTALL_DIR}/ChimeraSlayer/ChimeraSlayer.pl
    chmod 0755 ${BIN_DIR}/ChimeraSlayer.pl
    cd $cwd
    rm -rf $wd/*
    rmdir $wd
}
#
# uclust required for QIIME/pyNAST
# License only allows this version to be used with those two packages
# See: http://drive5.com/uclust/downloads1_2_22q.html
install_uclust()
{
    local wd=$(mktemp -d)
    local cwd=$(pwd)
    local wd=$(mktemp -d)
    cd $wd
    wget -q http://drive5.com/uclust/uclustq1.2.22_i86linux64
    INSTALL_DIR=${TOP_DIR}/share/uclust-1.2.22
    mkdir -p $INSTALL_DIR
    ln -s $INSTALL_DIR ${TOP_DIR}/share/uclust
    /bin/mv uclustq1.2.22_i86linux64 ${INSTALL_DIR}/uclust
    chmod 0755 ${INSTALL_DIR}/uclust
    ln -s  ${INSTALL_DIR}/uclust ${BIN_DIR}
    cd $cwd
    rm -rf $wd/*
    rmdir $wd
}
setup_pipeline_environment()
{
    echo "+++++++++++++++++++++++++++++++"
    echo "Setting up pipeline environment"
    echo "+++++++++++++++++++++++++++++++"
    # fasta_splitter.pl
    echo -n "Setting up fasta_splitter.pl..."
    if [ -e ${BIN_DIR}/fasta-splitter.pl ] ; then
	echo "already exists"
    elif [ ! -e ${ENV_DIR}/share/fasta-splitter/fasta-splitter.pl ] ; then
	echo "failed"
	fail "fasta-splitter.pl not found"
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
	fail "rdp_classifier.jar not found"
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
#
# Top level script does the installation
echo "======================================="
echo "Amplicon_analysis_pipeline installation"
echo "======================================="
echo "Installing into ${TOP_DIR}"
if [ -e ${TOP_DIR} ] ; then
    fail "Directory already exists"
fi
mkdir -p ${TOP_DIR}
install_conda
install_conda_packages
install_non_conda_packages
setup_pipeline_environment
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
