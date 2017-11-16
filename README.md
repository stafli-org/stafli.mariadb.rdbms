# Stafli MariaDB RDBMS
Stafli MariaDB RDBMS builds based on [Debian](https://www.debian.org/) and [CentOS](https://www.centos.org/), and developed as scripts for [Docker](https://www.docker.com/).  
Continues on [Stafli Base System](https://github.com/stafli-org/stafli.base.system) builds.  
This project is part of the [Stafli Application Stack](https://github.com/stafli-org/).

Requires [Docker Compose](https://docs.docker.com/compose/) 1.6.x or higher due to the [version 2](https://docs.docker.com/compose/compose-file/#versioning) format of the docker-compose.yml files.

There are docker-compose.yml files per distribution, as well as docker-compose.override.yml and .env files, which may be used to override configuration.
An optional [Makefile](../../tree/master/Makefile) is provided to help with loading these with ease and perform commands in batch.

Scripts are also provided for each distribution to help test and deploy the installation procedures in non-Docker environments.

The images are automatically built at a [repository](https://hub.docker.com/r/stafli/stafli.mariadb.rdbms) in the Docker Hub registry.

## Distributions
The services use custom images as a starting point:
- __Debian__, from the [Stafli Base System](https://github.com/stafli-org/stafli.base.system)
  - [Debian 8 (jessie)](../../tree/master/debian8)
  - [Debian 7 (wheezy)](../../tree/master/debian7)
- __CentOS__, from the [Stafli Base System](https://github.com/stafli-org/stafli.base.system)
  - [CentOS 7 (centos7)](../../tree/master/centos7)
  - [CentOS 6 (centos6)](../../tree/master/centos6)

## Services
These are the services described by the dockerfile and docker-compose files:
- MariaDB 10.x.x, built on Stafli Base System and additional MariaDB packages

## Images
These are the [resulting images](https://hub.docker.com/r/stafli/stafli.mariadb.rdbms/tags/) upon building:
- MariaDB 10.x.x:
  - stafli/stafli.mariadb.rdbms:debian8_mariadb10
  - stafli/stafli.mariadb.rdbms:debian7_mariadb10
  - stafli/stafli.mariadb.rdbms:centos7_mariadb10
  - stafli/stafli.mariadb.rdbms:centos6_mariadb10

## Containers
These containers can be created from the images:
- MariaDB 10.x.x:
  - debian8_mariadb10_xxx
  - debian7_mariadb10_xxx
  - centos7_mariadb10_xxx
  - centos6_mariadb10_xxx

## Usage

### From Docker Hub repository (manual)

Note: this method will not allow you to use the docker-compose files nor the Makefile.

1. To pull the images, try typing:  
`docker pull <image_url>`
2. You can start a new container interactively by typing:  
`docker run -ti <image_url> /bin/bash`

Where <image_url> is the full image url (lookup the image list above).

Example:
```
docker pull stafli/stafli.mariadb.rdbms:debian8_mariadb10

docker run -ti stafli/stafli.mariadb.rdbms:debian8_mariadb10 /bin/bash
```

### From GitHub repository (automated)

Note: this method allows using docker-compose and the Makefile.

1. Download the repository [zip file](https://github.com/stafli-org/stafli.mariadb.rdbms/archive/master.zip) and unpack it or clone the repository using:  
`git clone https://github.com/stafli-org/stafli.mariadb.rdbms.git`
2. Navigate to the project directory through the terminal:  
`cd stafli.mariadb.rdbms`
3. Type in the desired operation through the terminal:  
`make <operation> DISTRO=<distro>`

Where <distro> is the distribution/directory and <operation> is the desired docker-compose operation.

Example:
```
git clone https://github.com/stafli-org/stafli.mariadb.rdbms.git;
cd stafli.mariadb.rdbms;

# Example #1: quick start, with build
make up DISTRO=debian8;

# Example #2: quick start, with pull
make img-pull DISTRO=debian8;
make up DISTRO=debian8;

# Example #3: manual steps, with build
make img-build DISTRO=debian8;
make net-create DISTRO=debian8;
make vol-create DISTRO=debian8;
make con-create DISTRO=debian8;
make con-start DISTRO=debian8;
make con-ls DISTRO=debian8;
```

Type `make` in the terminal to discover all the possible commands.

## Credits
Stafli MariaDB RDBMS  
Copyright (C) 2016-2017 Stafli  
Luís Pedro Algarvio  
This file is part of the Stafli Application Stack.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
