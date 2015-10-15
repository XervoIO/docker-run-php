#!/bin/bash
set -e
set -x

export HOME=/root
export TEMP_DIR=/root/tmp

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

# Install php-brew
export MAKEFLAGS="-j $(grep -c ^processor /proc/cpuinfo)"
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

# tar -C /opt/modulus -xvzf /opt/modulus/php-4212015.tar.gz
# rm -rf /opt/modulus/php-4212015.tar.gz
