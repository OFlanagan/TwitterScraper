FROM rocker/r-ubuntu:18.04
RUN apt-get -y update &&  apt-get -y install \
default-jre \
default-jdk \
gdebi \
libpq-dev \
whois \
imagemagick \
libgsl-dev \
libssl-dev \
libmagick++-dev \
libcurl4-openssl-dev \
libxml2-dev \
libmariadbclient-dev \
libmariadb-client-lgpl-dev \
libbz2-dev \
libpcre3-dev \
liblzma-dev
&& apt-get purge -y && apt-get autoremove -y && apt-get clean
RUN R -e "install.packages('tidyverse',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('rtweet',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('rtweet',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('RPostgreSQL',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('DBI',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('pool',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('Rmisc',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('Matrix',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('magrittr',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('lubridate',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('dplyr',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('readr',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('tidytext',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('stopwords',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('tokenizers',dependencies=TRUE, repos='http://cran.rstudio.com/')"
