## ruby-base 
FROM t10471/base:latest

MAINTAINER t10471 <t104711202@gmail.com>

ENV OPTS_APT -y --force-yes --no-install-recommends

RUN apt-get update\
 && apt-get install ${OPTS_APT}\
      ctags \
      ca-certificates \
      libcurl4-openssl-dev \
      libffi-dev \
      libgdbm-dev \
      libpq-dev \
      libreadline6-dev \
      libssl-dev \
      libtool \
      libxml2-dev \
      libxslt-dev \
      libyaml-dev \
      postgresql-client-9.3 \
      software-properties-common \
      zlib1g-dev


RUN apt-get remove ${OPTS_APT}\
      libruby1.9.1 \
      ruby \
      ruby-dev \
      ruby1.9.1 \
      ruby1.9.1-dev

WORKDIR /root

# set $PATH so that non-login shells will see the Ruby binaries
# ENV PATH $PATH:/opt/rubies/ruby-2.1.4/bin

# Add PostgreSQL Global Development Group apt source
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" \
    > /etc/apt/sources.list.d/pgdg.list

# Add PGDG repository key
RUN wget -qO - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc \
    | apt-key add -

# Install MRI Ruby 2.1.4
RUN curl -O http://ftp.ruby-lang.org/pub/ruby/2.1/ruby-2.1.4.tar.gz && \
    tar -zxvf ruby-2.1.4.tar.gz && \
    cd ruby-2.1.4 && \
    ./configure --disable-install-doc --enable-shared && \
    make
WORKDIR /root/ruby-2.1.4 
RUN checkinstall \
            --type=debian \
            --install=yes \
            --pkgname="ruby" \
            --maintainer="ubuntu-devel-discuss@lists.ubuntu.com" \
            --nodoc \
            --default
WORKDIR /root 
RUN rm -r ruby-2.1.4 ruby-2.1.4.tar.gz && \
    echo 'gem: --no-document' > /usr/local/etc/gemrc
# ==============================================================================
# Rubygems, Bundler and Foreman
# ==============================================================================

# Install rubygems and bundler
ADD http://production.cf.rubygems.org/rubygems/rubygems-2.4.2.tgz /tmp/
RUN cd /tmp && \
    tar -zxf /tmp/rubygems-2.4.2.tgz && \
    cd /tmp/rubygems-2.4.2 && \
    ruby setup.rb && \
    /bin/bash -l -c 'gem install bundler --no-rdoc --no-ri' && \
    echo "gem: --no-ri --no-rdoc" > ~/.gemrc

# Clean up APT and temporary files when done
RUN apt-get clean -qq && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN ln -s  /usr/local/bin/ruby /usr/bin/ruby
WORKDIR /root/tmp/vim
RUN ./configure --with-features=huge \
            --disable-darwin \
            --disable-selinux \
            --enable-luainterp \
            --enable-pythoninterp \
            --enable-python3interp \
            --enable-rubyinterp \
            --enable-multibyte \
            --enable-xim \
            --enable-fontset\
            --enable-gui=no
RUN make
RUN checkinstall \
            --type=debian \
            --install=yes \
            --pkgname="vim" \
            --maintainer="ubuntu-devel-discuss@lists.ubuntu.com" \
            --nodoc \
            --default
WORKDIR /root 

ADD init.sh /root/
