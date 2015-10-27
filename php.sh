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
