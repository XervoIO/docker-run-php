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

# Install phpbrew
curl -L -O https://github.com/phpbrew/phpbrew/raw/master/phpbrew
chmod +x phpbrew
mv phpbrew /usr/bin/phpbrew

# phpbrew must be initialized to work.  Will create the folder
# ~/.phpbrew
phpbrew init
