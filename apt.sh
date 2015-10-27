#!/bin/bash
set -e
set -x

# PHP Version to build.  We build 5.3, 5.4, 5.5, and 5.6.
PHP_5_3="5.3.29"
PHP_5_4="5.4.38"
PHP_5_5="5.5.22"
PHP_5_6="5.6.6"
# Array with php version to compile
PHP_VERS=($PHP_5_3 $PHP_5_4 $PHP_5_5 $PHP_5_6)

# Variables
export HOME=/root
export TEMP_DIR=/root/tmp
PHP_BREW_DIR=$HOME/.phpbrew
PHP_INSTALL_DIR=/opt/modulus/php
PHP_BREW_FLAGS="+default +mysql +pgsql +fpm +soap +gmp -- \
  --with-libdir=lib/x86_64-linux-gnu --with-gd=shared --enable-gd-natf \
  --with-jpeg-dir=/usr --with-png-dir=/usr"

# Allows compiling with all cpus
export MAKEFLAGS="-j $(grep -c ^processor /proc/cpuinfo)"

# Install nginx
echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/nginx-stable.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C
sudo apt-get update -y
sudo apt-get install -y nginx=1.8.0-1+trusty1
rm /etc/nginx/sites-enabled/default
cp /opt/modulus/php-conf/nginx.conf /etc/nginx/nginx.conf
cp /opt/modulus/php-conf/nginx-default /etc/nginx/sites-enabled/default
mkdir /var/lib/nginx/body
mkdir /var/lib/nginx/proxy
mkdir /var/lib/nginx/fastcgi
mkdir /var/lib/nginx/uwsgi
mkdir /var/lib/nginx/scgi
mkdir -p $PHP_INSTALL_DIR

# Install php 5 to run phpbrew
mkdir /mnt/tmp
apt-get build-dep -y php5
apt-get install -y php5 php5-dev php-pear autoconf automake php5-gd curl \
  build-essential libxslt1-dev re2c libxml2 libxml2-dev php5-cli bison \
  libbz2-dev libreadline-dev libfreetype6 libfreetype6-dev libpng12-0 \
  libpng12-dev libjpeg-dev libjpeg8-dev libjpeg8  libgd-dev libgd3 libxpm4 \
  libltdl7 libltdl-dev libssl-dev openssl gettext libgettextpo-dev \
  libgettextpo0 libicu-dev libmhash-dev libmhash2 libmcrypt-dev libmcrypt4 \
  postgresql-client postgresql-contrib libmysqlclient-dev libmysqld-dev bc
