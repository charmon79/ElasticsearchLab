#!/bin/sh

#######################################################################
#	!! This script requires root privileges. !!
#
#	Installs & configures Elasticsearch 1.7 for local development use.
#######################################################################

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
apt-get upgrade

# 4. install Oracle Java JDK 8
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
apt-get install oracle-java8-installer

line=$( grep JAVA_HOME /etc/environment )
if [ $? -eq 1 ]
then
	echo "JAVA_HOME=\"/usr/lib/jvm/java-8-oracle\"" | tee -a /etc/environment
	
	# 4.b. JAVA_HOME environment variable won't actually exist for this process at this point,
	# so we need to declare it as a local variable for the rest of this script to complete.
	JAVA_HOME="/usr/lib/jvm/java-8-oracle"
fi

# 5. install elasticsearch
apt-get install elasticsearch
update-rc.d elasticsearch defaults 95 10

# 6. configure a few things in elasticsearch.yml for good measure
#	-	random cluster name (so that your dev instance & someone else's
#		don't try to join a cluster with each other)
#	-	default 1 shard & 0 replicas for indices
cat /etc/elasticsearch/elasticsearch.yml \
| sed "s/#cluster.name: elasticsearch/cluster.name: $var/" > /tmp/elasticsearch.yml.new

service elasticsearch start

# 7. install useful plugins (Marvel, head)

