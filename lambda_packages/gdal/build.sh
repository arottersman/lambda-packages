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
yum -y install wget python27-devel python27-pip gcc gcc-c++

pip install virtualenv

BASE_DIR="/usr/lambda-home"
TMP_DIR="python27_gdal_213"

mkdir -p ${BASE_DIR}
mkdir -p ${TMP_DIR}
cd  ${TMP_DIR}

echo "downloading geos source"
wget http://download.osgeo.org/geos/geos-3.4.2.tar.bz2
echo "unzipping geos"
tar xjf geos-3.4.2.tar.bz2
echo "build geos"
cd geos-3.4.2
./configure
make
make install
cd ..

echo "downloading proj4 source"
wget http://download.osgeo.org/proj/proj-4.9.1.tar.gz
wget http://download.osgeo.org/proj/proj-datumgrid-1.5.tar.gz
echo "unzipping proj4"
tar xzf proj-4.9.1.tar.gz
cd proj-4.9.1/nad
tar xzf ../../proj-datumgrid-1.5.tar.gz
cd ..
echo "building proj4"
./configure
make
make install
cd ..

echo "downloading gdal"
wget http://download.osgeo.org/gdal/2.1.3/gdal-2.1.3.tar.gz
echo "unzipping gdal"
tar xzf gdal-2.1.3.tar.gz
cd gdal-2.1.3
echo "building gdal"
./configure
make 
make install
cd ..

cd ${BASE_DIR}

echo "setting up virtualenv"
virtualenv env
source env/bin/activate
export GDAL_CONFIG=/var/task/bin/gdal-config
export GEOS_LIBRARY_PATH=/var/task/lib/libgdal.so
pip install --upgrade pip

echo "pip install GDAL"
pip install GDAL

echo "zipping"
cd ${BASE_DIR}/env/lib64/python2.7/site-packages
tar -zcvf ${BASE_DIR}/python2.7-gdal-2.1.3.tar.gz *
deactivate
