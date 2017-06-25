FROM nikunjjain/dependencies-datastage 

ADD . /usr/local/datastage2go

RUN chmod +x /usr/local/datastage2go/scripts/database_config.sh
RUN bash /usr/local/datastage2go/scripts/database_config.sh


