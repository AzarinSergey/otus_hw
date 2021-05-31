FROM  postgres:11

RUN apt-get update 
RUN apt-get install postgresql-plpython-11 python2.7 python-pip m4 git -y

COPY ./packages /

RUN apt-get install -f ./madpack.deb -y

RUN git clone https://github.com/postgrespro/hunspell_dicts
RUN make USE_PGXS=1 install -C /hunspell_dicts/hunspell_en_us