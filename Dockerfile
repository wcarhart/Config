FROM centos:latest

RUN yum install -y git
RUN yum install -y tree
RUN yum install -y vim
RUN yum install -y bind-utils

RUN cd ~ && git clone https://github.com/wcarhart/Konphig.git

CMD /bin/bash
