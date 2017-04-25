FROM ubuntu:14.04 

RUN echo "Starting up Docker build"

ENV modulestore_location ${modulestore_location}

ADD . /usr/local/datastage2go

RUN chmod +x /usr/local/datastage2go/scripts/users.sh
RUN bash /usr/local/datastage2go/scripts/users.sh

RUN chmod +x /usr/local/datastage2go/scripts/dependencies.sh
RUN bash /usr/local/datastage2go/scripts/dependencies.sh

