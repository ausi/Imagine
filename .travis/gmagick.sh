#!/bin/bash

set -xe

GRAPHICSMAGIC_VERSION='1.3.30'
if [ ${TRAVIS_PHP_VERSION:0:1} = '5' ]; then
  GMAGICK_VERSION='1.1.7RC2'
else
  GMAGICK_VERSION='2.0.4RC1'
fi

PHP_VERSION=`php -r 'echo PHP_VERSION_ID;'`
CUSTOM_CFLAGS='-Wno-misleading-indentation -Wno-unused-const-variable -Wno-pointer-compare -Wno-tautological-compare'

mkdir -p cache
cd cache

sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get -q update
sudo apt-get -y install graphicsmagick graphicsmagick-dbg libgraphicsmagick1-dev

if [ ! -e ./gmagick-$GMAGICK_VERSION-$PHP_VERSION-$GRAPHICSMAGIC_VERSION ]; then
    rm -rf ./gmagick-* || true
    wget https://pecl.php.net/get/gmagick-$GMAGICK_VERSION.tgz
    tar -xzf gmagick-$GMAGICK_VERSION.tgz
    rm gmagick-$GMAGICK_VERSION.tgz
    mv gmagick-$GMAGICK_VERSION gmagick-$GMAGICK_VERSION-$PHP_VERSION-$GRAPHICSMAGIC_VERSION
    cd gmagick-$GMAGICK_VERSION-$PHP_VERSION-$GRAPHICSMAGIC_VERSION
    phpize
    CFLAGS="${CFLAGS:-} ${CUSTOM_CFLAGS:-}" ./configure --with-gmagick=/opt/gmagick
    make -j V=0
else
    cd gmagick-$GMAGICK_VERSION-$PHP_VERSION-$GRAPHICSMAGIC_VERSION
fi

sudo make install
echo 'extension=gmagick.so' >> `php --ini | grep 'Loaded Configuration' | sed -e 's|.*:\s*||'`
php --ri gmagick
