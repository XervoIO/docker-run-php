#!/bin/bash
set -e
set -x

# PHP Version to build.
PHP_VER="5.6.6"

# Variables
export HOME=/mnt/home
export TEMP_DIR=/$HOME/tmp
PHP_BREW_DIR=$HOME/.phpbrew
PHP_INSTALL_DIR=/opt/modulus/php
PHP_BREW_FLAGS="+default +mysql +pgsql +fpm +soap +gmp -- \
  --with-libdir=lib/x86_64-linux-gnu --with-gd=shared --enable-gd-natf \
  --with-jpeg-dir=/usr --with-png-dir=/usr"

# Allows compiling with all cpus
export MAKEFLAGS="-j $(grep -c ^processor /proc/cpuinfo)"

# phpbrew must be initialized to work.  Will create the folder
# ~/.phpbrew
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

# Install MONGO support
# NOTE:  We run this out of the other loop because if we run this in the other
# loop, the installation of PHP 5.4 will almost always fail because reasons.
# (I really don't know why it fails, phpbrew just fails to install it)
phpbrew use $PHP_VER
if phpbrew ext install mongo ; then
  ln -s $PHP_BREW_DIR/php/php-$PHP_VER $PHP_INSTALL_DIR/php-$PHP_VER
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

# Clean up
rm -rf $PHP_BREW_DIR/build
