#
# example Dockerfile for http://docs.docker.com/examples/postgresql_service/
#

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
    apt-get install -y libc6 postgresql-9.4  \
    pgbouncer \
    repmgr \
    openssh-server
    #python-software-properties software-properties-common postgresql-9.4 postgresql-client-9.4 postgresql-contrib-9.4  \

# Run the rest of the commands as the ``postgres`` user created by the ``postgres-9.3`` package when it was ``apt-get installed``
USER postgres

# Create a PostgreSQL role named ``docker`` with ``docker`` as the password and
# then create a database `docker` owned by the ``docker`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN    /etc/init.d/postgresql start &&\
       #/etc/init.d/postgresql stop &&\
       #rm -rf $PGDATA/*
       $PSQL "CREATE USER repmgr WITH SUPERUSER PASSWORD 'repmgr';"  &&\
       createdb -O repmgr repmgr
       #$PSQL "CREATE DATABASE Billboard;" 
       #ssh-keygen -t rsa  -f $PGHOME/.ssh/id_rsa -q -N ""  &&\
       #cat $PGHOME/.ssh/id_rsa.pub >> $PGHOME/.ssh/authorized_keys &&\
       #chmod go-rwx $PGHOME/.ssh/* &&\

ADD postgresql.conf $PGCONFIG/postgresql.conf
ADD pg_hba.conf $PGCONFIG/pg_hba.conf
ADD repmgr.conf $PGDATA/repmgr/repmgr.conf 
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
#CMD ["/usr/lib/postgresql/9.4/bin/postgres", "-D", "/var/lib/postgresql/9.4/main", "-c", "config_file=/etc/postgresql/9.4/main/postgresql.conf"]
