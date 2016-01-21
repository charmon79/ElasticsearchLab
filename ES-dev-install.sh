#!/bin/sh

#######################################################################
#	!! This script requires root privileges. !!
#
#	Installs & configures Elasticsearch 1.7 for local development use.
#######################################################################

# Fail script if not root
me=$( whoami )
if [ "$me" != "root" ]
then
	echo "You need to be root to run this script. Elevate yourself with sudo."
	exit -1
fi

# 1. add apt repo for Oracle Java JDK install via webupd8team PPA
add-apt-repository ppa:webupd8team/java

# 2. add apt repo for Elasticsearch
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -

if [ ! -e /etc/apt/sources.list.d/elasticsearch-1.7.list ]
then
	echo "deb http://packages.elastic.co/elasticsearch/1.7/debian stable main" | tee -a /etc/apt/sources.list.d/elasticsearch-1.7.list
fi

# 3. run apt-get update & apt-get-upgrade so we have the latest things
apt-get update
apt-get -y upgrade

# 4. install Oracle Java JDK 8
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
apt-get -y install oracle-java8-installer

line=$( grep JAVA_HOME /etc/environment )
if [ $? -eq 1 ]
then
	echo "JAVA_HOME=\"/usr/lib/jvm/java-8-oracle\"" | tee -a /etc/environment
	
	# 4.b. JAVA_HOME environment variable won't actually exist for this process at this point,
	# so we need to declare it as a local variable for the rest of this script to complete.
	JAVA_HOME="/usr/lib/jvm/java-8-oracle"
fi

# 5. install elasticsearch
apt-get -y install elasticsearch
update-rc.d elasticsearch defaults 95 10

# 6. Get preconfigured elasticsearch.yml from GitHub. Back up original file before replacing.
wget https://raw.githubusercontent.com/charmon79/ElasticsearchLab/master/elasticsearch.yml
cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.orig
mv elasticsearch.yml /etc/elasticsearch/

service elasticsearch start

# 7. install useful plugins (Marvel, head)
/usr/share/elasticsearch/bin/plugin -install elasticsearch/marvel/latest
/usr/share/elasticsearch/bin/plugin -install mobz/elasticsearch-head

