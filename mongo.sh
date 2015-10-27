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

source ~/.phpbrew/bashrc

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
      exit 1
    else
      echo "Mongo build log missing"
      exit 1
    fi
  fi
done
