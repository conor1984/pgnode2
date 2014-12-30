#
# example Dockerfile for http://docs.docker.com/examples/postgresql_service/
#

FROM ubuntu
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
#ENV PGRUN               /var/run/postgresql

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 &&\
    echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update &&\
    apt-get install -y python-software-properties software-properties-common postgresql-9.4 postgresql-client-9.4 postgresql-contrib-9.4 openssh-server  \
    pgbouncer \
    repmgr 

RUN echo "postgres ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Run the rest of the commands as the ``postgres`` user created by the ``postgres-9.3`` package when it was ``apt-get installed``
USER postgres
# Create a PostgreSQL role named ``docker`` with ``docker`` as the password and
# then create a database `docker` owned by the ``docker`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN    	cd $PGDATA &&\
	rm -rf * 
	#/etc/init.d/postgresql start 

#RUN repmgr -f $PGDATA/repmgr/repmgr.conf --verbose master register
ADD repmgr.conf $PGDATA/repmgr/repmgr.conf 
ADD pg_hba.conf $PGCONFIG/pg_hba.conf
ADD addsudo.sh $PGCONFIG/addsudo.sh
ADD postgresql.conf $PGCONFIG/postgresql.conf
ADD .pgpass  $PGHOME/.pgpass
ADD pgbouncer.ini $PGBOUNCE/pgbouncer.ini
ADD userlist.txt $PGBOUNCE/userlist.txt
ADD failover.sh $PGHOME/scripts/failover.sh

#ADD run /usr/local/bin/run
#RUN chmod +x /usr/local/bin/run
EXPOSE  5432 6432 22

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.4/bin/postgres", "-D", "/var/lib/postgresql/9.4/main", "-c", "config_file=/etc/postgresql/9.4/main/postgresql.conf"]
