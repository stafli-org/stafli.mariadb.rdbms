
#
#    CentOS 7 (centos7) MariaDB10 RDBMS (dockerfile)
#    Copyright (C) 2016-2017 Stafli
#    Luís Pedro Algarvio
#    This file is part of the Stafli Application Stack.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#
# Build
#

# Base image to use
FROM stafli/stafli.init.supervisor:supervisor31_centos7

# Labels to apply
LABEL description="Stafli MariaDB RDBMS (stafli/stafli.rdbms.mariadb), Based on Stafli Supervisor Init (stafli/stafli.init.supervisor)" \
      maintainer="lp@algarvio.org" \
      org.label-schema.schema-version="1.0.0-rc.1" \
      org.label-schema.name="Stafli MariaDB RDBMS (stafli/stafli.rdbms.mariadb)" \
      org.label-schema.description="Based on Stafli Supervisor Init (stafli/stafli.init.supervisor)" \
      org.label-schema.keywords="stafli, mariadb, rdbms, debian, centos" \
      org.label-schema.url="https://stafli.org/" \
      org.label-schema.license="GPLv3" \
      org.label-schema.vendor-name="Stafli" \
      org.label-schema.vendor-email="info@stafli.org" \
      org.label-schema.vendor-website="https://www.stafli.org" \
      org.label-schema.authors.lpalgarvio.name="Luis Pedro Algarvio" \
      org.label-schema.authors.lpalgarvio.email="lp@algarvio.org" \
      org.label-schema.authors.lpalgarvio.homepage="https://lp.algarvio.org" \
      org.label-schema.authors.lpalgarvio.role="Maintainer" \
      org.label-schema.registry-url="https://hub.docker.com/r/stafli/stafli.rdbms.mariadb" \
      org.label-schema.vcs-url="https://github.com/stafli-org/stafli.rdbms.mariadb" \
      org.label-schema.vcs-branch="master" \
      org.label-schema.os-id="centos" \
      org.label-schema.os-version-id="7" \
      org.label-schema.os-architecture="amd64" \
      org.label-schema.version="1.0"

#
# Arguments
#

ARG app_mariadb_user="mysql"
ARG app_mariadb_group="mysql"
ARG app_mariadb_home="/var/lib/mysql"
ARG app_mariadb_listen_addr="0.0.0.0"
ARG app_mariadb_listen_port="3306"

#
# Environment
#

# Working directory to use when executing build and run instructions
# Defaults to /.
#WORKDIR /

# User and group to use when executing build and run instructions
# Defaults to root.
#USER root:root

#
# Packages
#

# Add foreign repositories and GPG keys
#  - N/A: for MariaDB
# Install mariadb packages
#  - MariaDB-server: for mysqld, the MariaDB relational database management system server
#  - MariaDB-client: for mysql, the MariaDB relational database management system client
#  - mytop: for mytop, the MariaDB relational database management system top-like utility
RUN printf "Installing repositories and packages...\n" && \
    \
    printf "Install the foreign repositories and refresh the GPG keys...\n" && \
    printf "# MariaDB repository\n\
[mariadb]\n\
name = MariaDB\n\
baseurl = http://yum.mariadb.org/10.1/centos7-amd64\n\
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB\n\
gpgcheck=1\n\
\n" > /etc/yum.repos.d/mariadb.repo && \
    rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB && \
    \
    printf "Install the mariadb packages...\n" && \
    rpm --rebuilddb && \
    yum makecache && yum install -y \
      MariaDB-server MariaDB-client mytop && \
    \
    printf "Cleanup the package manager...\n" && \
    yum clean all && rm -Rf /var/lib/yum/* && \
    \
    printf "Finished installing repositories and packages...\n";

#
# Configuration
#

# Add users and groups
RUN printf "Adding users and groups...\n" && \
    \
    printf "Add mariadb user and group...\n" && \
    id -g ${app_mariadb_user} \
    || \
    groupadd \
      --system ${app_mariadb_group} && \
    id -u ${app_mariadb_user} && \
    usermod \
      --gid ${app_mariadb_group} \
      --home ${app_mariadb_home} \
      --shell /sbin/nologin \
      ${app_mariadb_user} \
    || \
    useradd \
      --system --gid ${app_mariadb_group} \
      --no-create-home --home-dir ${app_mariadb_home} \
      --shell /sbin/nologin \
      ${app_mariadb_user} && \
    \
    printf "Finished adding users and groups...\n";

# Supervisor
RUN printf "Updading Supervisor configuration...\n" && \
    \
    # /etc/supervisord.d/init.conf \
    file="/etc/supervisord.d/init.conf" && \
    printf "\n# Applying configuration for ${file}...\n" && \
    perl -0p -i -e "s>supervisorctl start rclocal;>supervisorctl start rclocal; supervisorctl start mysql;>" ${file} && \
    printf "Done patching ${file}...\n" && \
    \
    # /etc/supervisord.d/mysql.conf \
    file="/etc/supervisord.d/mysql.conf" && \
    printf "\n# Applying configuration for ${file}...\n" && \
    printf "# MariaDB\n\
[program:mysql]\n\
command=/bin/bash -c \"\$(which mysqld_safe) --defaults-file=/etc/my.cnf\"\n\
autostart=false\n\
autorestart=true\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n\
stdout_events_enabled=true\n\
stderr_events_enabled=true\n\
\n" > ${file} && \
    printf "Done patching ${file}...\n" && \
    \
    # /etc/rc.local
    file="/etc/rc.local" && \
    printf "\n# Applying configuration for ${file}...\n" && \
    perl -0p -i -e "s>\nexit 0>>" ${file} && \
    printf "# Install MySQL\n\
if [ ! -d \"${app_mariadb_home}/mysql\" ]; then\n\
  \$(which mysql_install_db) --user=${app_mariadb_user} --ldata=${app_mariadb_home};\n\
fi;\n\
mkdir -p /var/log/mysql;\n\
chown ${app_mariadb_user}:${app_mariadb_group} /var/log/mysql;\n\
\n\
exit 0\n" >> ${file} && \
    printf "Done patching ${file}...\n" && \
    \
    printf "Finished updading Supervisor configuration...\n";

# MariaDB
RUN printf "Updading MariaDB configuration...\n" && \
    \
    # ignoring /etc/sysconfig/mysql \
    \
    # ignoring /etc/my.cnf \
    \
    # /etc/my.cnf.d/server.cnf \
    file="/etc/my.cnf.d/server.cnf" && \
    printf "\n# Applying configuration for ${file}...\n" && \
    # run as user \
    perl -0p -i -e "s>\[server\]>\[server\]\nuser = ${app_mariadb_user}>" ${file} && \
    # change logging \
    perl -0p -i -e "s>\[server\]>\[server\]\nlog-error = /var/log/mysql/mariadb-error.log>" ${file} && \
    # change interface \
    perl -0p -i -e "s>\[server\]>\[server\]\nbind-address = ${app_mariadb_listen_addr}>" ${file} && \
    # change port \
    perl -0p -i -e "s>\[server\]>\[server\]\nport = ${app_mariadb_listen_port}>" ${file} && \
    # change performance settings \
    perl -0p -i -e "s>\[server\]>\[server\]\nmax_allowed_packet = 128M>" ${file} && \
    # storage engine \
    perl -0p -i -e "s>\[server\]>\[server\]\ndefault-storage-engine = InnoDB>" ${file} && \
    # change engine and collation \
    # https://stackoverflow.com/questions/3513773/change-mysql-default-character-set-to-utf-8-in-my-cnf \
    # https://www.percona.com/blog/2014/01/28/10-mysql-settings-to-tune-after-installation/ \
    # https://dev.mysql.com/doc/refman/5.6/en/charset-configuration.html \
    perl -0p -i -e "s>\[server\]>\[server\]\ncharacter-set-server = utf8>" ${file} && \
    perl -0p -i -e "s>\[server\]>\[server\]\ncollation-server = utf8_general_ci>" ${file} && \
    printf "Done patching ${file}...\n" && \
    \
    # /etc/my.cnf.d/client.cnf \
    file="/etc/my.cnf.d/client.cnf" && \
    printf "\n# Applying configuration for ${file}...\n" && \
    # change protocol \
    perl -0p -i -e "s>\[client\]>\[client\]\nprotocol = tcp>" ${file} && \
    # change port \
    perl -0p -i -e "s>\[client\]>\[client\]\nport = ${app_mariadb_listen_port}>" ${file} && \
    # change engine and collation \
    # https://stackoverflow.com/questions/3513773/change-mysql-default-character-set-to-utf-8-in-my-cnf \
    # https://www.percona.com/blog/2014/01/28/10-mysql-settings-to-tune-after-installation/ \
    # https://dev.mysql.com/doc/refman/5.6/en/charset-configuration.html \
    perl -0p -i -e "s>\[client\]>\[client\]\ndefault-character-set = utf8>" ${file} && \
    printf "Done patching ${file}...\n" && \
    \
    # /etc/my.cnf.d/mysql-clients.cnf \
    file="/etc/my.cnf.d/mysql-clients.cnf" && \
    printf "\n# Applying configuration for ${file}...\n" && \
    # change performance settings \
    perl -0p -i -e "s>\[mysqldump\]>\[mysqldump\]\nquick\nquote-names\nmax_allowed_packet = 24M>" ${file} && \
    printf "Done patching ${file}...\n" && \
    \
    printf "\n# Testing configuration...\n" && \
    echo "Testing $(which mysql):"; $(which mysql) -V && \
    echo "Testing $(which mysqld):"; $(which mysqld) -V && \
    printf "Done testing configuration...\n" && \
    \
    printf "Finished updading MariaDB configuration...\n";

#
# Run
#

# Command to execute
# Defaults to /bin/bash.
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf", "--nodaemon"]

# Ports to expose
# Defaults to 3306
EXPOSE ${app_mariadb_listen_port}

