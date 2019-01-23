FROM ubuntu:18.04

ENV container docker

RUN apt-get update && \
    apt-get install -y \
    rsyslog systemd dbus git sudo makepasswd

RUN /bin/systemctl set-default multi-user.target

# Don't start any optional services except for the few we need.
RUN find /etc/systemd/system \
    /lib/systemd/system \
    -path '*.wants/*' \
    -not -name '*journald*' \
    -not -name '*systemd-tmpfiles*' \
    -not -name '*systemd-user-sessions*' \
    -exec rm \{} \;

RUN apt-get remove -y makepasswd && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# Create user me with password openthread
RUN useradd -m -s /bin/bash -G sudo -p '$1$w.H9lAuY$Gz2/xRp.2sTrvddqxuYx70' me

USER me
WORKDIR /home/me

STOPSIGNAL SIGRTMIN+3

# Workaround for docker/docker#27202, technique based on comments from docker/docker#9212
CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=journal 3>&1"]
