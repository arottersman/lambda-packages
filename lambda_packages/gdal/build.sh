#!/bin/bash
#
# Script to build gdal with its related python
# packages for lambda.
#
# Use it to build inside a docker container with
# an Amazon Linux image
#
#

set -e

echo "installing dependencies"
yum -y update
yum -y install wget
yum -y install python27-devel python27-pip gcc gcc-c++

pip install virtualenv

BASE_DIR=/var/task
TMP_DIR=${BASE_DIR}/python27_gdal_213

mkdir -p ${BASE_DIR}
mkdir -p ${TMP_DIR}
cd  ${TMP_DIR}

echo "downloading source"
wget http://download.osgeo.org/gdal/2.1.3/gdal-2.1.3.tar.gz

echo "unzipping gdal source"
tar xzf gdal-2.1.3.tar.gz
cd gdal-2.1.3

echo "running configuring gdal make"
./configure --prefix=${BASE_DIR} \
            --without-python

echo "running make"
make

echo "install"
make install

cd ${BASE_DIR}

echo "setting up virtualenv"
virtualenv env
source env/bin/activate

echo "making and installing python gdal"
cd ${TMP_DIR}/gdal-2.1.3/swig
make
cd python
python setup.py install

echo "zipping"
cd ${BASE_DIR}/env/lib64/python2.7/site-packages
tar -zcvf ${BASE_DIR}/python2.7-gdal-2.1.3.tar.gz *

echo "cleaning up"
deactivate
rm -rf ${TMP_DIR}
