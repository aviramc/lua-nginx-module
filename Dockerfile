FROM ubuntu:14.04

# Install dependencies
# Change the sources.list to use Israel
RUN sed -i 's/archive/il\.archive/g' /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                         apt-transport-https \
                         build-essential \
                         gdb \
                         zlib1g \
                         libssl-dev \
                         libffi-dev \
                         perl-modules \
                         wget \
                         ca-certificates \
                         libluajit-5.1-2 \
                         libluajit-5.1-common \
                         libluajit-5.1-dev \
                         lua-cjson \
                         libyaml-perl \
                         memcached \
                         redis-server \
                         libdrizzle4 \
                         libdrizzle-dev \
                         libgd-dev \
                         git \
                         curl \
                         libpcre3 \
                         libpcre3-dev \
                         valgrind \
                         vim

# libdrizzle in Ubuntu 14.04 has all the include files directly in /usr/include/libdrizzle-1.0/
# which makes compatibility with the drizzle module difficult without changing its code.
# Instead, we use a link to correct the libdrizzle include path.
RUN ln -s /usr/include/libdrizzle-1.0/ /usr/include/libdrizzle

# Install mysql server with 'root' as default password
RUN echo mysql-server mysql-server/root_password password root | debconf-set-selections && \
    echo mysql-server mysql-server/root_password_again password root | debconf-set-selections && \
    apt-get install -y --no-install-recommends mysql-server

RUN service mysql start && \
    mysql --user=root --password=root -e "CREATE USER 'ngx_test'@'localhost' IDENTIFIED BY 'ngx_test'; \
    GRANT ALL PRIVILEGES ON *.* TO 'ngx_test'@'localhost' WITH GRANT OPTION; \
    CREATE DATABASE ngx_test; "

# Configure cpan (requires the user to press Enter twice)
RUN echo -e "\n\n" | cpan
RUN cpan App::cpanminus
# Install the Test::Nginx Perl package
RUN cpanm Test::Nginx

RUN mkdir /nginx/
RUN mkdir /nginx/modules

# Download Nginx - replace link and version if needed
RUN cd /nginx && \
    wget http://nginx.org/download/nginx-1.9.7.tar.gz -O nginx.tar.gz && \
    tar -zxf nginx.tar.gz && \
    rm nginx.tar.gz && \
    mv nginx-1.9.7 nginx

COPY util/container_build.sh /nginx/nginx/test_build.sh
COPY util/run_test_dependencies.sh /usr/local/bin

# Install 3rd party modules - replace links with new ones if needed.
# ngx_devel_kit
RUN cd /nginx/modules && \
    wget https://github.com/simpl/ngx_devel_kit/archive/v0.3.0rc1.tar.gz -O module.tar.gz && \
    tar -xzf module.tar.gz && \
    rm module.tar.gz

# set-misc-nginx-module
RUN cd /nginx/modules && \
    wget https://github.com/openresty/set-misc-nginx-module/archive/v0.30.tar.gz -O module.tar.gz && \
    tar -xzf module.tar.gz && \
    rm module.tar.gz

# echo-nginx-module
RUN cd /nginx/modules && \
    wget https://github.com/openresty/echo-nginx-module/archive/v0.59rc1.tar.gz -O module.tar.gz && \
    tar -xzf module.tar.gz && \
    rm module.tar.gz

# memc-nginx-module
RUN cd /nginx/modules && \
    wget https://github.com/openresty/memc-nginx-module/archive/v0.16.tar.gz -O module.tar.gz && \
    tar -xzf module.tar.gz && \
    rm module.tar.gz

# srcache-nginx-module
RUN cd /nginx/modules && \
    wget https://github.com/openresty/srcache-nginx-module/archive/v0.30.tar.gz -O module.tar.gz && \
    tar -xzf module.tar.gz && \
    rm module.tar.gz

# lua-upstream-nginx-module
RUN cd /nginx/modules && \
    wget https://github.com/openresty/lua-upstream-nginx-module/archive/v0.05.tar.gz -O module.tar.gz && \
    tar -xzf module.tar.gz && \
    rm module.tar.gz

# headers-more-nginx-module
RUN cd /nginx/modules && \
    wget https://github.com/openresty/headers-more-nginx-module/archive/v0.30rc1.tar.gz -O module.tar.gz && \
    tar -xzf module.tar.gz && \
    rm module.tar.gz

# drizzle-nginx-module
RUN cd /nginx/modules && \
    wget https://github.com/openresty/drizzle-nginx-module/archive/v0.1.9.tar.gz -O module.tar.gz && \
    tar -xzf module.tar.gz && \
    rm module.tar.gz

# rds-json-nginx-module
RUN cd /nginx/modules && \
    wget https://github.com/openresty/rds-json-nginx-module/archive/v0.14.tar.gz -O module.tar.gz && \
    tar -xzf module.tar.gz && \
    rm module.tar.gz

# ngx_coolkit
RUN cd /nginx/modules && \
    wget https://github.com/FRiCKLE/ngx_coolkit/archive/0.2rc3.tar.gz -O module.tar.gz && \
    tar -xzf module.tar.gz && \
    rm module.tar.gz

# redis2-nginx-module
RUN cd /nginx/modules && \
    wget https://github.com/openresty/redis2-nginx-module/archive/v0.12.tar.gz -O module.tar.gz && \
    tar -xzf module.tar.gz && \
    rm module.tar.gz

# Install the mockeagain module
RUN cd /nginx && \
    git clone https://github.com/openresty/mockeagain.git && \
    cd mockeagain && \
    make && \
    cp mockeagain.so /usr/lib
