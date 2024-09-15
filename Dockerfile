ARG ubuntu_ver
FROM ubuntu:$ubuntu_ver

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NOWARNINGS yes

# Package versionup
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y update
RUN apt-get -y dist-upgrade

# Japanese
RUN apt-get install -y language-pack-ja-base language-pack-ja locales
RUN locale-gen ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
RUN DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y tzdata

# Dev package get
RUN apt-get -y install sudo git \
  vim \
  man \
  curl \
  wget \
  unzip \
  jq

# Node Install
ARG nvm_ver
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$nvm_ver/install.sh | bash
RUN . $HOME/.nvm/nvm.sh && \
  nvm install --lts && \
  nvm use --lts

# Dev package install (need rbenv & pyenv)
RUN apt-get install -y gcc \
  g++ \
  make \
  build-essential \
  libssl-dev \
  zlib1g-dev \
  openssl \
  libz-dev \
  libffi-dev \
  libreadline-dev \
  libyaml-dev \
  liblzma-dev \
  libbz2-dev \
  libreadline-dev \
  libsqlite3-dev

# Ruby install
ARG ruby_ver
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv
RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN echo 'export PATH="~/.rbenv/bin:$PATH"' >> ~/.bashrc
RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc
ENV PATH $PATH:~/.rbenv/bin
ENV PATH $PATH:~/.rbenv/shims
RUN rbenv install $ruby_ver
RUN rbenv global $ruby_ver
ENV RUBYOPT -EUTF-8

# Python install
ARG python_ver
RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv
RUN git clone https://github.com/yyuu/pyenv-update.git ~/.pyenv/plugins/pyenv-update
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
RUN echo 'eval "$(pyenv init -)"' >> ~/.bashrc
ENV PATH $PATH:~/.pyenv/bin
ENV PATH $PATH:~/.pyenv/shims
RUN pyenv install $python_ver
RUN pyenv global $python_ver
RUN pyenv rehash
RUN pip install --upgrade pip

# AWS-CLI(v2)
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

# Azure-CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
ENV DEBIAN_FRONTEND=noninteractive

# Google CloudSDK install
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
  tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
  apt-get update -y && apt-get install google-cloud-sdk -y

# Terraform
ARG terraform_ver
RUN git clone https://github.com/tfutils/tfenv.git ~/.tfenv
RUN echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
ENV PATH $PATH:~/.tfenv/bin
RUN tfenv install $terraform_ver
RUN tfenv use $terraform_ver

# certbot
RUN apt-get install -y certbot

# WorkingDir make
RUN mkdir ~/terraform
