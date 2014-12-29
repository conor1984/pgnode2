#Master Node1 

FROM ubuntu:14.04
#MAINTAINER conor.nagle@firmex.com

#Environment 
ENV PATH 		/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/lib/postgresql/9.4/bin:/usr/bin/pgbench
ENV PGDATA		/var/lib/postgresql/9.4/main
ENV PGCONFIG	/etc/postgresql/9.4/main
ENV PGBOUNCE    /etc/pcgbouncer
ENV PGLOG		/var/log/postgresql
ENV PGREP		/etc/postgresql/9.4/repmgr
ENV PGHOME		/var/lib/postgresql
ENV PSQL        psql --command 




RUN 	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 &&\
	echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list

#RUN sudo apt-get update &&\
#    sudo apt-get upgrade &&\
#    sudo apt-get install -y python-software-properties software-properties-common postgresql-9.4 postgresql-client-9.4 postgresql-contrib-9.4 \
#	 libxslt-dev libxml2-dev libpam-dev libedit-dev git expect wget \
#	 pgbouncer repmgr #pgbench pgadmin zabbix-server-pgsql zabbix-frontend-php
	
RUN apt-get update && apt-get install -y python-software-properties software-properties-common postgresql-9.4 postgresql-client-9.4 postgresql-contrib-9.4 openssh-server \

#RUN sudo apt-get install -y libxslt1-dev \
#libxml2-dev \
#libedit-dev \
#libpam-dev \
#python-software-properties \
#software-properties-common \

#postgresql-9.4 \
#postgresql-client-9.4 \
#postgresql-contrib-9.4 \
#libxslt1-dev \
#libxml2-dev \ 
#libedit-dev \
pgbouncer \
repmgr \
sendmail \
mailutils


#SSH
#sudo chown postgres.postgres authorized_keys id_rsa.pub id_rsa &&\
#sudo mkdir -p ~postgres/.ssh &&\
#sudo chown postgres.postgres ~postgres/.ssh &&\
#sudo mv authorized_keys id_rsa.pub id_rsa ~postgres/.ssh &&\
#sudo chmod -R go-rwx ~postgres/.ssh

#USER postgres
#RUN     #pg_ctl stop
	#/etc/init.d/postgresql stop
#USER root
#RUN     sudo adduser maximus --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password &&\
#	echo "maximus:max" | chpasswd #&&\
	#sudo chown -R maximus:maximus /var/lib/postgresql/9.4/main
	#$PGHOME/  $PGLOG/ $PGCONFIG/ $PGDATA/ $PGRUN

#workaround (maybe not required)
#RUN sudo mkdir /etc/ssl/private-copy #; mv /etc/ssl/private/* /etc/ssl/private-copy/; rm -r /etc/ssl/private; mv /etc/ssl/private-copy /etc/ssl/private; chmod -R 0700 /etc/ssl/private; chown -R maximus /etc/ssl/private &&\
    #mkdir /etc/postgresql/9.4/repmgr 
#ssh-keygen -t rsa -f  var/lib/.ssh/id_rsa -q -N ""  &&\

USER postgres
RUN	 cd /var/lib/postgresql/9.4 &&\
         rm -rf *
	 #cd ~/.ssh &&\
	 ######scp id_rsa.pub id_rsa authorized_keys maximus@pgnode2: &&\
	 ######scp id_rsa.pub id_rsa authorized_keys maximus@pgbouncer: &&\ 
     #/etc/init.d/postgresql start &&\
     #pg_ctl start -l $PGLOG/postgresql-9.4-main.log &&\
     
ADD repmgr.conf $PGREP/repmgr.conf

#RUN 	repmgr -D $PGDATA -d Billboard -p 5432 -U repmgr -R postgres --verbose standby clone pgnode1 &&\
#	repmgr  -f $PGREP/repmgr.conf --verbose standby register &&\
#	repmgrd -f $PGREP/repmgr.conf --verbose > $PGREP/repmgr.log 2>&1

     
ADD postgresql.conf $PGCONFIG/postgresql.conf
ADD pg_hba.conf $PGCONFIG/pg_hba.conf
ADD pgbouncer.ini $PGBOUNCE/pgbouncer.ini

ADD userlist.txt $PGBOUNCE/userlist.txt
ADD failover.sh $PGHOME/scripts/failover.sh
#SSH and repmgr
#ADD trigger1 /usr/local/bin/trigger
#RUN chmod +x /usr/local/bin/trigger
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]
EXPOSE 5432 6432 22
CMD ["/usr/lib/postgresql/9.4/bin/postgres", "-D", "/var/lib/postgresql/9.4/main", "-c", "config_file=/etc/postgresql/9.4/main/postgresql.conf"]
