#!/usr/bin/env bash

# Add options required for a 'real' installation.
# Note that the main directory of nginx will be set to the default - /usr/local/nginx.
INSTALLATION_OPTIONS="--sbin-path=/usr/local/sbin/nginx
                      --conf-path=/etc/nginx/nginx.conf
                      --pid-path=/var/run/nginx.pid
                      --error-log-path=/var/log/nginx/error.log
                      --http-log-path=/var/log/nginx/access.log"

MODULES="
         --with-ipv6
         --with-http_realip_module
         --with-http_ssl_module
         --add-module=../modules/ngx_devel_kit-0.3.0rc1
         --add-module=../modules/set-misc-nginx-module-0.30
         --without-mail_pop3_module
         --without-mail_imap_module
         --with-http_image_filter_module
         --without-mail_smtp_module
         --without-http_upstream_ip_hash_module
         --without-http_memcached_module
         --with-http_auth_request_module
         --without-http_userid_module
         --add-module=../modules/echo-nginx-module-0.59rc1
         --add-module=../modules/memc-nginx-module-0.16
         --add-module=../modules/srcache-nginx-module-0.30
         --add-module=../modules/lua-nginx-module
         --add-module=../modules/lua-upstream-nginx-module-0.05
         --add-module=../modules/headers-more-nginx-module-0.30rc1
         --add-module=../modules/drizzle-nginx-module-0.1.9
         --add-module=../modules/rds-json-nginx-module-0.14
         --add-module=../modules/ngx_coolkit-0.2rc3
         --add-module=../modules/redis2-nginx-module-0.12
         --add-module=../modules/lua-nginx-module/t/data/fake-module
         --with-http_gunzip_module
         --with-http_dav_module
         --with-select_module
         --with-poll_module
         --with-pcre-jit
         --with-debug
        "

# Add Lua options for the Lua Module (see http://wiki.nginx.org/HttpLuaModule#Installation ).
# Note that we use the recommended LuaJIT, and not Lua 5.1/2.
export LUAJIT_LIB=/usr/lib/libluajit-5.1.so.2
export LUAJIT_INC=/usr/include/luajit-2.0/
export PCRE_CONF_OPT="--enable-utf"

# Use the parameter -f to force re-configuration even if the Makefile exists.
# Conversly, you can run make clean.
if [ ! -e Makefile ] || [ "$1" == -f ] ; 
then
    # The following line is with Adallom, the other one without... Notice that we're last.
    ./configure $MODULES --with-cc=gcc $INSTALLATION_OPTIONS
fi

if [ $? -eq 0 ] ; then
    make && make install
fi
