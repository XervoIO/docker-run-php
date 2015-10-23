#!/bin/bash
set -e
set -x

# PHP Version to build.  We build 5.3, 5.4, 5.5, and 5.6.
PHP_5_3="5.3.29"
PHP_5_4="5.4.45"
PHP_5_5="5.5.30"
PHP_5_6="5.6.14"
# Array with php version to compile
PHP_VERS=($PHP_5_3 $PHP_5_4 $PHP_5_5 $PHP_5_6)

# Variables
PHP_BREW_DIR=/mnt/home/.phpbrew
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

# Install phpbrew
curl -L -O https://github.com/phpbrew/phpbrew/raw/master/phpbrew
chmod +x phpbrew
mv phpbrew /usr/bin/phpbrew

# phpbrew must be initialized to work.  Will create the folder
# /mnt/home/.phpbrew
phpbrew init
source ~/.phpbrew/bashrc

# GMP requires gmp.h to be in /usr/include
if [ ! -f /usr/include/gmp.h ]; then
  if [ -f /usr/include/x86_64-linux-gnu/gmp.h ]; then
    ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h
  else
    echo "gmp.h not found in /usr/include/x86_64-linux-gnu, can't build."
    exit 1
  fi
fi

# Install PHP
for PHP_VER in "${PHP_VERS[@]}"
do
  if phpbrew install php-$PHP_VER $PHP_BREW_FLAGS ; then
    echo "clear_env = no" >> $PHP_BREW_DIR/php/php-$PHP_VER/etc/php-fpm.conf
  else
    if [ -f $PHP_BREW_DIR/build/php-$PHP_VER/build.log ]; then
      tail -200 $PHP_BREW_DIR/build/php-$PHP_VER/build.log
    else
      echo "Build failed, no log file created."
      exit 1
    fi
  fi
done

# Install MONGO support
# NOTE:  We run this out of the other loop because if we run this in the other
# loop, the installation of PHP 5.4 will almost always fail because reasons.
# (I really don't know why it fails, phpbrew just fails to install it)
for PHP_VER in "${PHP_VERS[@]}"
do
  phpbrew use $PHP_VER
  if phpbrew ext install mongo ; then
    mv $PHP_BREW_DIR/php/php-$PHP_VER $PHP_INSTALL_DIR/php-$PHP_VER
  else
    echo "Installing mongo failed for $PHP_VER"
    if [ -f $PHP_BREW_DIR/build/php-$PHP_VER/ext/mongo/build.log ]; then
      tail -200 $PHP_BREW_DIR/build/php-$PHP_VER/ext/mongo/build.log
    else
      echo "Mongo build log missing"
      exit 1
    fi
  fi
done

# Clean up
rm -rf $PHP_BREW_DIR
