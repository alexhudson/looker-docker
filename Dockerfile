FROM ubuntu:latest

# Which version of PhantomJS to install. This is a "known good" compatible one.
ARG PJS_VER=phantomjs-2.1.1

# Looker needs its own user and group
RUN adduser --disabled-password --gecos '' --shell /bin/bash looker

# Bring in Oracle Java JDK 8
# http://www.webupd8.org/2014/03/how-to-install-oracle-java-8-in-debian.html
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
RUN apt-get update
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

# git and tzdata are needed at runtime by Looker
# curl & bzip2 are needed during the build (in principle, we could extract this)
# libfontconfig1 is a requirement for PhantomJS
RUN apt-get install -y oracle-java8-installer curl git tzdata bzip2 libfontconfig1 && apt-get clean

# dumb-init lives separately on github
RUN curl -Lo /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64

# Run a locale generatation and set the same environment variables for runtime
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Install PhantomJS
RUN cd /tmp && \
    wget https://bitbucket.org/ariya/phantomjs/downloads/$PJS_VER-linux-x86_64.tar.bz2 && \
    tar -jxf $PJS_VER-linux-x86_64.tar.bz2 && \
    cp $PJS_VER-linux-x86_64/bin/phantomjs /usr/local/bin && \
    rm -rf $PJS_VER-linux-x86_64*

COPY run-looker /usr/local/bin
RUN chmod a+x /usr/local/bin/*

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["su", "looker", "-c", "/usr/local/bin/run-looker"]

# Default web UI
EXPOSE 9999

# API
EXPOSE 19999
