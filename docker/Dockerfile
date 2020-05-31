FROM ubuntu:focal

# Install desktop packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-server

# Set up passwordless sudo
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y sudo
COPY --chown=root docker/nopassword /etc/sudoers.d/nopassword
RUN chmod 0440 /etc/sudoers.d/nopassword

# add wgoodall01 user, switch to it
RUN useradd -ms /bin/bash wgoodall01 &&\
	adduser wgoodall01 sudo
USER wgoodall01

# Make home & dev dir, set permissions on it
RUN mkdir -p /home/wgoodall01/Dev &&\
	chown -R wgoodall01:wgoodall01 /home/wgoodall01
WORKDIR /home/wgoodall01/Dev

# Switch to dev directory

# copy in dotfiles, config.sh, then run init.sh
COPY --chown=wgoodall01:wgoodall01 . /home/wgoodall01/Dev/dotfiles
COPY --chown=wgoodall01 docker/config.sh /home/wgoodall01/Dev/dotfiles/config.sh
WORKDIR /home/wgoodall01/Dev/dotfiles
RUN ./init.sh
