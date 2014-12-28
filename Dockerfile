#Master Node1 

FROM ubuntu:14.04
MAINTAINER conor.nagle@firmex.com

#Environment 
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/lib/postgresql/9.4/bin:/usr/bin/pgbench
ENV PGDATA /var/lib/postgresql/9.4/main
ENV PGCONFIG /etc/postgresql/9.4/main
ENV PGBOUNCE /etc/pgbouncer
ENV PGLOG /var/log/postgresql
ENV PGREP /etc/postgresql/9.4/repmgr
ENV PGHOME /var/lib/postgresql
ENV PSQL        psql --command 

USER root

RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

#Postgresql 9.4
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.4``.
RUN sudo apt-get update &&\ 
    sudo apt-get upgrade &&\
	sudo apt-get install -y python-software-properties software-properties-common postgresql-9.4 postgresql-client-9.4 postgresql-contrib-9.4 /
    libxslt-dev libxml2-dev libpam-dev libedit-dev flex bison git expect \
    pgbouncer repmgr 
    #git github.com/markokr/plproxy-dev.git

#Create Postgres User
RUN	sudo adduser maximus --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password &&\
	echo "maximus:max" | sudo chpasswd &&\
	sudo usermod -d /var/lib/postgresql maximus

#Symlinks
RUN ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem $PGDATA/server.crt &&\
    ln -s /etc/ssl/private/ssl-cert-snakeoil.key $PGDATA/server.key

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
	sudo chown maximus $PGDATA $PGCONFIG $PGLOG

USER maximus

#Start Postgres     
RUN 
	cd /var/lib/postgresql/9.4/ &&\
	rm -rf * &&\
	pg_ctl start -l $PGLOG &&\
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
EXPOSE 5432 6432
CMD ["/usr/lib/postgresql/9.4/bin/postgres", "-D", "/var/lib/postgresql/9.4/main", "-c", "config_file=/etc/postgresql/9.4/main/postgresql.conf"]
