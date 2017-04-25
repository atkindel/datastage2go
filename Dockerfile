FROM ubuntu:14.04 

RUN chmod +x /usr/local/datastage2go/scripts/users.sh
RUN chmod +x /usr/local/datastage2go/scripts/users.sh

RUN bash /usr/local/datastage2go/scripts/dependencies.sh
RUN bash /usr/local/datastage2go/scripts/dependencies.sh

