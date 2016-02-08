These are some scripts I've written for myself to quickly spin up Elasticsearch on my own sandbox environment.

I'm assuming Ubuntu Server 14.04 LTS as the operating system.

**ES-dev-install.sh** - Installs everything you need for a working Elasticsearch 1.7 instance, including Oracle JDK 8.x (prerequisite for Elasticsearch as OpenJDK is not currently supported).

**sqljdbcsvc.sh** - *(optional)* This will set up the Microsoft SQL Server JDBC driver to run as a daemon. I wrote this because I'm working on ETL from SQL Server to Elasticsearch, and I didn't want to have to start the JDBC driver manually each time.