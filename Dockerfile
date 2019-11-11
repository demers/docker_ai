FROM ubuntu:18.04

MAINTAINER FND <fndemers@gmail.com>

ENV TERM=xterm\
    TZ=America/Toronto\
    DEBIAN_FRONTEND=noninteractive

ENV PROJECTNAME=AI

ENV WORKDIRECTORY=/home/ubuntu

# Access SSH login
ENV USERNAME=ubuntu
ENV PASSWORD=ubuntu

RUN apt-get update

RUN apt-get install -y vim-nox curl git exuberant-ctags

# Install a basic SSH server
RUN apt install -y openssh-server
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd
RUN /usr/bin/ssh-keygen -A

# Install Java
RUN apt-get install -qy --no-install-recommends python-dev python3

# Add user to the image
RUN adduser --quiet --disabled-password --shell /bin/bash --home /home/${USERNAME} --gecos "User" ${USERNAME}
# Set password for the jenkins user (you may want to alter this).
RUN echo "$USERNAME:$PASSWORD" | chpasswd

RUN apt-get clean && apt-get -y update && apt-get install -y locales && locale-gen fr_CA.UTF-8
ENV TZ=America/Toronto
#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
#RUN /usr/bin/timedatectl set-timezone $TZ
RUN unlink /etc/localtime
RUN ln -s /usr/share/zoneinfo/$TZ /etc/localtime


RUN apt install -y fish

RUN echo "export PS1=\"\\e[0;31m $PROJECTNAME\\e[m \$PS1\"" >> ${WORKDIRECTORY}/.bash_profile

# Ajout des droits sudoers
RUN apt-get install -y sudo
RUN echo "%ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install all you want here...
RUN apt-get update && apt-get install \
  -y --no-install-recommends python3 python3-virtualenv

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m virtualenv --python=/usr/bin/python3 $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Standard SSH port
EXPOSE 22

# Installation X11.
RUN apt install -y xauth vim-gtk

RUN apt-get install -y build-essential cmake python3-dev

WORKDIR ${WORKDIRECTORY}

RUN cd ${WORKDIRECTORY} \
    && . /opt/venv/bin/activate \
    && pip install --upgrade pip \
    && pip install --upgrade tensorflow \
    && python -c 'import tensorflow as tf; print("Tensorflow version " + tf.__version__)' \
    && deactivate

RUN echo "echo Commande 'python_env' pour utiliser Python 3..." >> ${WORKDIRECTORY}/.bash_profile
RUN echo "echo Commande 'deactivate' pour quitter environnement virtuel Python 3..." >> ${WORKDIRECTORY}/.bash_profile
RUN echo "alias python_env='. /opt/venv/bin/activate && python'" >> ${WORKDIRECTORY}/.bash_profile

RUN cd ${WORKDIRECTORY} \
    && git clone git://github.com/zaiste/vimified.git \
    && ln -sfn vimified/ ${WORKDIRECTORY}/.vim \
    && ln -sfn vimified/vimrc ${WORKDIRECTORY}/.vimrc \
    && cd vimified \
    && mkdir bundle \
    && mkdir -p tmp/backup tmp/swap tmp/undo \
    && git clone https://github.com/gmarik/vundle.git bundle/vundle \
    && echo "let g:vimified_packages = ['general', 'coding', 'fancy', 'indent', 'css', 'os', 'ruby', 'js', 'haskell', 'python', 'color']" > local.vimrc

COPY after.vimrc ${WORKDIRECTORY}/vimified/

COPY extra.vimrc ${WORKDIRECTORY}/vimified

# Générer les tags de ctags.
RUN echo "ctags -f ${WORKDIRECTORY}/mytags -R ${WORKDIRECTORY}" >> ${WORKDIRECTORY}/.bash_profile

#if ! [ -f /run/user/$UID/runonce_myscript ]; then
    #touch /run/user/$UID/runonce_myscript
    #/path/to/myscript
#fi

# Compiling YouCompleteMe only once...
RUN echo "if ! [ -f ~/.runonce_install ]; then" >> ${WORKDIRECTORY}/.bash_profile
RUN echo "touch ~/.runonce_install" >> ${WORKDIRECTORY}/.bash_profile
RUN echo "vim +BundleInstall +qall" >> ${WORKDIRECTORY}/.bash_profile
RUN echo "cd ~/.vim/bundle/YouCompleteMe" >> ${WORKDIRECTORY}/.bash_profile
RUN echo "./install.py --clang-completer" >> ${WORKDIRECTORY}/.bash_profile
RUN echo "fi" >> ${WORKDIRECTORY}/.bash_profile
RUN echo "cd ~/" >> ${WORKDIRECTORY}/.bash_profile

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN cd ${WORKDIRECTORY} \
    && mkdir work \
&& chown -R $USERNAME:$PASSWORD work vimified .vim .vimrc .bash_profile

# Start SSHD server...
CMD ["/usr/sbin/sshd", "-D"]