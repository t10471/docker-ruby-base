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
      software-properties-common \
      zlib1g-dev


RUN apt-get remove ${OPTS_APT}\
      libruby1.9.1 \
      ruby \
      ruby-dev \
      ruby1.9.1 \
      ruby1.9.1-dev

WORKDIR /root

ENV RUBY_VERSION 2.2.2
RUN curl -O http://cache.ruby-lang.org/pub/ruby/2.2/ruby-${RUBY_VERSION}.tar.gz && \
    tar -zxvf ruby-${RUBY_VERSION}.tar.gz && \
    cd ruby-${RUBY_VERSION} && \
    ./configure --disable-install-doc --enable-shared && \
    make
WORKDIR /root/ruby-${RUBY_VERSION} 
RUN checkinstall \
            --type=debian \
            --install=yes \
            --pkgname="ruby" \
            --maintainer="ubuntu-devel-discuss@lists.ubuntu.com" \
            --nodoc \
            --default
WORKDIR /root 
RUN rm -r ruby-${RUBY_VERSION} ruby-${RUBY_VERSION}.tar.gz && \
    echo 'gem: --no-document' > /usr/local/etc/gemrc
# ==============================================================================
# Rubygems, Bundler and Foreman
# ==============================================================================

# Install rubygems and bundler
ENV GEM_VERSION 2.4.7
ADD http://production.cf.rubygems.org/rubygems/rubygems-${GEM_VERSION}.tgz /tmp/
RUN cd /tmp && \
    tar -zxf /tmp/rubygems-${GEM_VERSION}.tgz && \
    cd /tmp/rubygems-${GEM_VERSION} && \
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
