#!/bin/bash
set -e
set -x

# Variables
HOME=/home/mop
PHP_BREW_DIR=$HOME/.phpbrew
PHP_INSTALL_DIR=/opt/modulus/php
TEMP_DIR=$HOME/tmp
TMP_DIR=$TEMP_DIR
TMPDIR=$TEMP_DIR
PHP_BREW_FLAGS="+default +mysql +pgsql +fpm +soap +gmp +gd +opcache -- \
  --with-libdir=lib/x86_64-linux-gnu --with-gd=shared --enable-gd-natf \
  --with-jpeg-dir=/usr --with-png-dir=/usr"

# Allows compiling with all cpus
export MAKEFLAGS="-j $(grep -c ^processor /proc/cpuinfo)"

# phpbrew must be initialized to work.  Will create the folder
# ~/.phpbrew
phpbrew init
source ~/.phpbrew/bashrc

# Install PHP
if ! phpbrew install php-$PHP_VER $PHP_BREW_FLAGS ; then
  if [ -f $PHP_BREW_DIR/build/php-$PHP_VER/build.log ]; then
    tail -200 $PHP_BREW_DIR/build/php-$PHP_VER/build.log
    exit 1
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
if ! phpbrew ext install mongo ; then
  echo "Installing mongo failed for $PHP_VER"
  if [ -f $PHP_BREW_DIR/build/php-$PHP_VER/ext/mongo/build.log ]; then
    tail -200 $PHP_BREW_DIR/build/php-$PHP_VER/ext/mongo/build.log
    exit 1
  else
    echo "Mongo build log missing"
    exit 1
  fi
fi
