FROM ubuntu:23.10

MAINTAINER Darrell Ricke <Darrell.Ricke@ll.mit.edu>

###############################################################################
# ** Large Language Models (LLM) user interface**
# 
# **Author:**  Darrell O. Ricke, Ph.D.  (mailto: Darrell.Ricke@ll.mit.edu)
#  Copyright:  Copyright (c) 2024 Massachusetts Institute of Technology 
#  License:    GNU GPL license (http://www.gnu.org/licenses/gpl.html)  
# 
# **RAMS request ID 1026697**
# 
# **Overview:**
# Large Language Models (LLM) user interface.
# 
# **Citation:** None
# 
# **Disclaimer:**
# DISTRIBUTION STATEMENT A. Approved for public release. Distribution is unlimited.
#
# This material is based upon work supported by the Department of the Air Force 
# under Air Force Contract No. FA8702-15-D-0001. Any opinions, findings, 
# conclusions or recommendations expressed in this material are those of the 
# author(s) and do not necessarily reflect the views of the Department of the Air Force. 
# 
# © 2024 Massachusetts Institute of Technology
# 
# The software/firmware is provided to you on an As-Is basis
# 
# Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
# Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
# U.S. Government rights in this work are defined by DFARS 252.227-7013 or
# DFARS 252.227-7014 as detailed above. Use of this work other than as specifically
# authorized by the U.S. Government may violate any copyrights that exist in this work.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
###############################################################################

ENV HTTP_PROXY="http://llproxy.llan.ll.mit.edu:8080" 
ENV HTTPS_PROXY="http://llproxy.llan.ll.mit.edu:8080"
ENV FTP_PROXY="http://llproxy.llan.ll.mit.edu:8080"

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# libcurl4-openssl-dev \
RUN apt-get update && apt-get install -y build-essential coreutils \
    wget bzip2 git g++ gfortran libreadline6-dev libncurses5-dev xorg-dev libpng-dev libbz2-dev \
    liblzma-dev libpcre3-dev make libcairo2-dev libgtk2.0-dev \
    locales libcurl4-nss-dev \
    language-pack-en language-pack-en-base \
    git curl unzip bc tabix \
    libssl-dev libgit2-dev libssh2-1-dev \
    gcc zip \
    python3.11 gcc zip python3-dev \
    zlib1g-dev libbz2-dev liblzma-dev pigz libncurses5-dev \
    libreadline-dev \
    openssl \
    gnupg2 \
    libmysqlclient-dev \
    nodejs \
    sqlite3 \
    ruby-full rubygems libyaml-dev

ENV CRAN_URL "http://cran.rstudio.com"

RUN mkdir /usr/local/S
COPY entrypoint.sh /usr/bin

RUN gem install bundler \
    && gem install mysql2 \
    && apt-get -y install libsqlite3-dev \
    && gem install sqlite3 \ 
    && gem install rake \
    && gem install tzinfo-data \
    && gem install rails 

WORKDIR /usr/local/S
RUN curl https://bootstrap.pypa.io/pip/3.6/get-pip.py -o get-pip.py \
    && python3 get-pip.py

WORKDIR /usr/local/S
COPY crystal_llm.tar /usr/local/S
RUN tar -xf crystal_llm.tar 

WORKDIR /usr/local/S/crystal_llm
RUN bundle update

RUN bundle exec rake assets:precompile RAILS_ENV=production \
    && bundle exec rake assets:precompile RAILS_ENV=development

RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000
CMD cd /usr/local/S/crystal_llm \
    && rails server -b 0.0.0.0
