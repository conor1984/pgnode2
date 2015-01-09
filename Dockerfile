#
# example Dockerfile for http://docs.docker.com/examples/postgresql_service/
FROM ubuntu:12.04
MAINTAINER conor.nagle@firmex.com

#Environment 
ENV PATH 		/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/lib/postgresql/9.4/bin
ENV PGDATA		/var/lib/postgresql/9.4/main
ENV PGCONFIG	/etc/postgresql/9.4/main
ENV PGBOUNCE    /etc/pcgbouncer
ENV PGLOG		/var/log/postgresql
ENV PGREP		/etc/postgresql/9.4/repmgr
ENV PGHOME		/var/lib/postgresql
ENV PGRUN       /var/run/postgresql
ENV PSQL        psql --command 

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 &&\
    echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update &&\
    apt-get install -y libc6 python-software-properties software-properties-common postgresql-contrib-9.4  \
    postgresql-9.4  \
    pgbouncer \
    repmgr \
    openssh-server 

ADD repmgr.conf $PGREP/repmgr.conf 
RUN chown -R postgres:postgres $PGREP/* &&\
    chown -R postgres:postgres $PGHOME/* &&\
    chmod 700 $PGREP/*  &&\
    chmod 700 $PGHOME/*  
# Run the rest of the commands as the ``postgres`` user created by the ``postgres-9.3`` package when it was ``apt-get installed``
USER postgres

#Remove data directory and clone from Master through container
RUN     cd $PGDATA  &&\
        rm -rf *
        #ssh-keygen -t rsa  -f $PGHOME/.ssh/id_rsa -q -N ""  &&\
        #cat $PGHOME/.ssh/id_rsa.pub >> $PGHOME/.ssh/authorized_keys &&\
        #chmod go-rwx $PGHOME/.ssh/* &&\

ADD postgresql.conf $PGCONFIG/postgresql.conf
ADD pg_hba.conf $PGCONFIG/pg_hba.conf
ADD .ssh/* $PGHOME/.ssh/
#ADD .pgpass  $PGHOME/.pgpass
ADD pgbouncer.ini $PGBOUNCE/pgbouncer.ini
ADD userlist.txt $PGBOUNCE/userlist.txt
ADD failover.sh $PGHOME/scripts/failover.sh
#ADD run.sh /var/lib/postgresql/9.4/main/run.sh
#RUN chmod +x /var/lib/postgresql/9.4/main/run.sh
#RUN chmod 755 /var/lib/postgresql/9.4/main/run.sh
EXPOSE  5432 6432 22
VOLUME  ["/etc/postgresql", "$PGLOG", "$PGHOME"]
