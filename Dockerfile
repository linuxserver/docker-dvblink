FROM lsiobase/xenial
MAINTAINER sparklyballs

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# environment variables
ARG DEBIAN_FRONTEND="noninteractive"

# package versions
ARG PYTHON_VERSION="2.6.9"

# build packages as variable
ARG BUILD_PACKAGES="\
	file \
	g++ \
	gcc \
	libtool \
	tcl-dev \
	tk-dev"

# install build packages
RUN \
 apt-get update && \
 apt-get install -y \
	${BUILD_PACKAGES} && \

# install runtime packages
 apt-get install -y \
	dbus \
	libxml2 && \

# compile gnu libiconv
 mkdir -p \
	/tmp/libiconv-src && \
 curl -o \
 /tmp/libiconv.tar.gz -L \
	https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz && \
 tar xf \
 /tmp/libiconv.tar.gz -C \
	/tmp/libiconv-src --strip-components=1 && \
 cd /tmp/libiconv-src && \
 ./configure \
	--prefix=/usr/local && \
 make && \
 make install && \

# compile python 2.6
 mkdir -p \
	/tmp/python-src && \
 curl -o \
 /tmp/python.tar.xz -L \
	"https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" && \
 tar xf \
 /tmp/python.tar.xz -C \
	/tmp/python-src --strip-components=1 && \
 cd /tmp/python-src && \
 ./configure \
	--enable-shared \
	--enable-unicode=ucs4 && \
 make -j$(nproc) && \
 make install && \

# uninstall build packages
 apt-get purge -y --auto-remove \
	${BUILD_PACKAGES} && \

# install dvblink server
 mkdir -p \
	/usr/share/applications && \
 curl -o \
 /tmp/dvblink.deb -L \
	http://download.dvblogic.com/9283649d35acc98ccf4d0c2287cdee62/ && \
 dpkg -i /tmp/dvblink.deb && \

# cleanup
 find /usr/local -depth \
	\( \
	\( -type d -a -name test -o -name tests \) \
	-o \
	\( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
	\) -exec rm -rf '{}' + && \

 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*
