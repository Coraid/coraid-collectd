#!/usr/bin/env bash
#
# build script for Coraid CorOS 8 systems
#
# note: this is destructive to /opt/collectd and there is upgrade
# if you need to upgrade, use the manual processes
#
# Copyright 2015 Coraid, Inc.

THISDIR=$(basename $PWD)
[[ ${THISDIR} != "collectd" ]] && echo "error: run from collectd source directory" && exit 1

export CPPFLAGS="-D__EXTENSIONS__ -DHAVE_HTONLL"
./build.sh
./configure --disable-perl --disable-static --disable-network
gmake
rm -rf /opt/collectd
gmake install
cp contrib/Coraid/collectd.xml /opt/collectd
mv /opt/collectd/etc/collectd.conf /opt/collectd/etc/collectd.conf.template
cp contrib/Coraid/collectd.conf /opt/collectd/etc
cd /opt
TARBALL=collectd.coros.$(date +%Y%m%d).tar
if [[ -f ${TARBALL} ]]; then
    SAVEAS=$(mktemp ${TARBALL}.XXXX)
    echo "notice: renaming exiting ${TARBALL} to ${SAVEAS}"
    mv ${TARBALL} ${SAVEAS}
fi
CTARBALL=${TARBALL}.gz
if [[ -f ${CTARBALL} ]]; then
    SAVEAS=$(mktemp ${CTARBALL}.XXXX)
    echo "notice: renaming exiting ${CTARBALL} to ${SAVEAS}"
    mv ${CTARBALL} ${SAVEAS}
fi
tar cf ${TARBALL} collectd
gzip -9 ${TARBALL}
[[ ! -f ${CTARBALL} ]] && echo "error: ${CTARBALL} was not created" && exit 1
echo "finished: tarball is ${CTARBALL}"
