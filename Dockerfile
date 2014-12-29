#Master Node1 

FROM ubuntu:14.04
#MAINTAINER conor.nagle@firmex.com

#Environment 
ENV PATH 		/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/lib/postgresql/9.4/bin:/usr/bin/pgbench
ENV PGDATA		/var/lib/postgresql/9.4/cluster
ENV PGCONFIG	/etc/postgresql/9.4/cluster
ENV PGBOUNCE    /etc/pcgbouncer
ENV PGLOG		/var/log/postgresql
ENV PGREP		/etc/postgresql/9.4/repmgr
ENV PGHOME		/var/lib/postgresql
ENV PSQL        psql --command 

USER root

RUN 	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 &&\
	echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN sudo apt-get update &&\
    sudo apt-get upgrade &&\
    sudo apt-get install -y python-software-properties software-properties-common postgresql-9.4 postgresql-client-9.4 postgresql-contrib-9.4 \
	 libxslt-dev libxml2-dev libpam-dev libedit-dev git expect wget \
	 pgbouncer repmgr #pgbench pgadmin zabbix-server-pgsql zabbix-frontend-php
	
USER postgres
RUN  cd /var/lib/postgresql/9.4 &&\
     rm -rf *
     
USER root
RUN     adduser maximus --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password &&\
	echo "maximus:max" | chpasswd &&\
	usermod -d /var/lib/postgresql maximus &&\
	sudo chown -R maximus $PGHOME  $PGLOG /etc/postgresql /var/lib/postgresql /var/run/postgresql
	
	
	
RUN mkdir /etc/ssl/private-copy; mv /etc/ssl/private/* /etc/ssl/private-copy/; rm -r /etc/ssl/private; mv /etc/ssl/private-copy /etc/ssl/private; chmod -R 0700 /etc/ssl/private; chown -R maximus /etc/ssl/private &&\
    mkdir /etc/postgresql/9.4/repmgr 

#SSH
#RUN 
	#sudo chown maximus.maximus authorized_keys id_rsa.pub id_rsa &&\
	#sudo mkdir -p ~maximus/.ssh &&\
	#sudo chown maximus.maximus ~maximus/.ssh &&\
	#sudo mv authorized_keys id_rsa.pub id_rsa ~maximus/.ssh &&\
	#sudo chmod -R go-rwx ~maximus/.ssh

# /etc/ssl/private can't be accessed from within container for some reason
# (@andrewgodwin says it's something AUFS related)
RUN sudo mkdir /etc/ssl/private-copy; sudo mv /etc/ssl/private/* /etc/ssl/private-copy/; sudo rm -r /etc/ssl/private; sudo mv /etc/ssl/private-copy /etc/ssl/private; sudo chmod -R 0700 /etc/ssl/private; sudo chown -R maximus /etc/ssl/private &&\
    sudo mkdir /etc/postgresql/9.4/repmgr &&\
	sudo chown maximus $PGHOME $PGLOG  /etc/postgresql /var/lib/postgresql /var/run/postgresql

USER maximus

#Start Postgres     
RUN     cd /var/lib/postgresql/9.4 &&\
	pg_createcluster 9.4 cluster &&\
	pg_ctl start -p 5433 -l $PGLOG &&\
	createdb Repmgr &&\
	#NOTE form https://github.com/2ndQuadrant/repmgr/blob/master/QUICKSTART.md
	#Additionally, repmgr requires a dedicated PostgreSQL superuser account and a database in which to store monitoring and replication data
	$PSQL "CREATE ROLE repmgr LOGIN SUPERUSER;" &&\
	#repmgr -d Repmgr -U repmgr -h pgnode1 standby clone &&\
	#repmgr -f $PGREP/repmgr.conf --verbose standby register &&\
	#repmgrd -f $PGREP/repmgr.conf > $PGLOG/repmgr.log 2>&1 &&\
	mkdir ~/scripts

ADD postgresql.conf $PGCONFIG/postgresql.conf
ADD pg_hba.conf $PGCONFIG/pg_hba.conf
ADD pgbouncer.ini $PGBOUNCE/pgbouncer.ini
ADD repmgr.conf $PGREP/repmgr.conf
ADD userlist.txt $PGBOUNCE/userlist.txt
ADD failover.sh $PGHOME/scripts/failover.sh
#SSH and repmgr
#ADD trigger1 /usr/local/bin/trigger
#RUN chmod +x /usr/local/bin/trigger
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]
EXPOSE 5433 6432
CMD ["/usr/lib/postgresql/9.4/bin/postgres", "-D", "/var/lib/postgresql/9.4/cluster", "-c", "config_file=/etc/postgresql/9.4/cluster/postgresql.conf"]
