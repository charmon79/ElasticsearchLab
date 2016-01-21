#!/bin/sh
SERVICE_NAME=sqljdbcsvc
PID_PATH_NAME=/usr/local/sqljdbcsvc/pid
case $1 in
    start)
        echo "Starting $SERVICE_NAME ..."
        if [ ! -f $PID_PATH_NAME ]; then
            exec java -classpath /var/lib/java/dbd_jdbc.jar:/var/lib/java/log4j-1.2.17.jar:/var/lib/java/sqljdbc4.jar -Djdbc.drivers=com.microsoft.sqlserver.jdbc.SQLServerDriver -Ddbd.port=9042 com.vizdom.dbd.jdbc.Server 2> /var/log/sqljdbcsvc.log 2>> /var/log/sqljdbcsvc.log &
				echo $! > $PID_PATH_NAME
            echo "$SERVICE_NAME started ..."
        else
            echo "$SERVICE_NAME is already running ..."
        fi
    ;;
    stop)
        if [ -f $PID_PATH_NAME ]; then
            PID=$(cat $PID_PATH_NAME);
            echo "$SERVICE_NAME stoping ..."
            kill $PID;
            echo "$SERVICE_NAME stopped ..."
            rm $PID_PATH_NAME
        else
            echo "$SERVICE_NAME is not running ..."
        fi
    ;;
    restart)
        if [ -f $PID_PATH_NAME ]; then
            PID=$(cat $PID_PATH_NAME);
            echo "$SERVICE_NAME stopping ...";
            kill $PID;
            echo "$SERVICE_NAME stopped ...";
            rm $PID_PATH_NAME
			sleep 1
            echo "$SERVICE_NAME starting ..."
            exec java -classpath /var/lib/java/dbd_jdbc.jar:/var/lib/java/log4j-1.2.17.jar:/var/lib/java/sqljdbc4.jar -Djdbc.drivers=com.microsoft.sqlserver.jdbc.SQLServerDriver -Ddbd.port=9042 com.vizdom.dbd.jdbc.Server 2> /var/log/sqljdbcsvc.log 2>> /var/log/sqljdbcsvc.log &
				echo $! > $PID_PATH_NAME
            echo "$SERVICE_NAME started ..."
        else
            echo "$SERVICE_NAME is not running ..."
        fi
    ;;
esac
