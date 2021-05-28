FROM  postgres:11

RUN apt-get update 
RUN apt-get install postgresql-plpython-11 python2.7 python-pip m4 -y

COPY ./packages /

RUN apt-get install -f ./madpack.deb -y
