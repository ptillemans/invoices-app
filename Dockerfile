FROM ubuntu:latest

RUN apt-get update && apt-get -y --force-yes install apt-transport-https gnupg

COPY elex.* /etc/apt/sources.list.d/
RUN apt-key adv --import /etc/apt/sources.list.d/elex.pgp

# install dependencies
RUN apt-get update && apt-get -y --force-yes install \
  ruby \
  ruby-dev \
  rails \
  rake \
  git \
  libc6-dev \
  libxml2-dev \
  libxslt1-dev \
  zlib1g-dev \
  libsasl2-dev \
  libldap2-dev \
  libssl-dev \
  libaio-dev \
  libsqlite3-dev \
  oracle-instantclient12.1-basic \
  oracle-instantclient12.1-devel \
  gcc g++\
  nodejs \
  make \
  && gem install bundler -v "<2.0"


# set the environment for the container
ENV SECRET_KEY_BASE=0c0d429f6cd3839bb1fc2241f0c8de100cc3d0fdfe268ed5e459079c23bf1fb83cdfda418928a75f2edc9dc43557fb80209c324ceb728d1dcb13b2ddfdb364461
ENV LD_LIBRARY_PATH=/usr/lib/oracle/12.1/client64/lib/
ENV RAILS_ENV=fremach

# expose rails port
EXPOSE 3000

# data volumes
VOLUME ["/var/lib/invoices"]

COPY scripts/startRails /invoices/bin/startRails
COPY invoices-app /invoices
WORKDIR /invoices
RUN bundle install

# create ssh config and precompile rails assets
RUN mkdir ~/.ssh \
    && chmod 700 ~/.ssh \
    && (echo "Host *\n StrictHostKeyChecking no\n UserKnownHostsFile /dev/null" >> ~/.ssh/config) \
    && rake assets:precompile

CMD ["/invoices/bin/startRails"]
