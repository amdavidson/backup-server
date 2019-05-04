FROM debian:stretch-slim 

RUN apt-get update && \
    apt-get upgrade -y

RUN apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd

RUN apt-get install -y rsync borgbackup ca-certificates

ADD https://github.com/restic/restic/releases/download/v0.9.4/restic_0.9.4_linux_amd64.bz2 /tmp/

RUN bunzip2 /tmp/restic_0.9.4_linux_amd64.bz2 && mv /tmp/restic_0.9.4_linux_amd64 /usr/local/bin/restic && chmod +x /usr/local/bin/restic

RUN mkdir -p /bkup/.ssh \
&& groupadd -g 1111 bkup \
&& useradd -u 1111 -g 1111 -d /bkup bkup \
&& passwd -l bkup \
&& chown -Rh bkup:bkup /bkup

VOLUME /bkup

EXPOSE 22

CMD /usr/sbin/sshd -De
