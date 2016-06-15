#!/bin/bash
set -e
set -x

# Variables
export HOME=/home/mop
export PHP_BREW_DIR=$HOME/.phpbrew
export PHP_INSTALL_DIR=/opt/modulus/php
export TEMP_DIR=$HOME/tmp
export TMP_DIR=$TEMP_DIR
export TMPDIR=$TEMP_DIR

#export TEMP_DIR=/$HOME/tmp
PHP_INSTALL_DIR=/opt/modulus/php

# Allows compiling with all cpus
export MAKEFLAGS="-j $(grep -c ^processor /proc/cpuinfo)"

# Install nginx
echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/nginx-stable.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C
sudo apt-get update -y
sudo apt-get install -y nginx=1.10.1-0+trusty0
rm /etc/nginx/sites-enabled/default
cp /opt/modulus/php-conf/nginx.conf /etc/nginx/nginx.conf
cp /opt/modulus/php-conf/nginx-default /etc/nginx/sites-enabled/default
mkdir /var/lib/nginx/body
mkdir /var/lib/nginx/proxy
mkdir /var/lib/nginx/fastcgi
mkdir /var/lib/nginx/uwsgi
mkdir /var/lib/nginx/scgi
mkdir -p $PHP_INSTALL_DIR
mkdir $HOME
mkdir $TEMP_DIR
chown -R mop:mop $HOME

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

# Install phpbrew
curl -L -O https://github.com/phpbrew/phpbrew/raw/master/phpbrew
chmod +x phpbrew
mv phpbrew /usr/bin/phpbrew

# GMP requires gmp.h to be in /usr/include
if [ ! -f /usr/include/gmp.h ]; then
  if [ -f /usr/include/x86_64-linux-gnu/gmp.h ]; then
    ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h
  else
    echo "gmp.h not found in /usr/include/x86_64-linux-gnu, can't build."
    exit 1
  fi
fi

# Install PHP as mop user
sudo -u mop PHP_VER=$PHP_VER /opt/modulus/install_php.sh
ln -s $PHP_BREW_DIR/php/php-$PHP_VER $PHP_INSTALL_DIR/php-$PHP_VER
