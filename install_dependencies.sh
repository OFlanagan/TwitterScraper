
# https://www.digitalocean.com/community/tutorials/how-to-install-r-on-ubuntu-16-04-2
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu bionic-cran35/'
sudo apt-get update
sudo apt-get -y --allow-unauthenticated install r-base r-base-dev
sudo apt-get -y install default-jre default-jdk
sudo apt-get -y install gdebi libpq-dev whois imagemagick libgsl-dev libssl-dev
sudo apt-get -y install libmagick++-dev libcurl4-openssl-dev  libxml2-dev
sudo apt-get -y install libmariadbclient-dev  libmariadb-client-lgpl-dev # required for DBI

wget https://download2.rstudio.org/server/trusty/amd64/rstudio-server-1.2.5033-amd64.deb
sudo gdebi -n rstudio-server-1.2.5033-amd64.deb
sudo rstudio-server restart

sudo apt-get install -y openjdk-7-jdk
export LD_LIBRARY_PATH=/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server
sudo R CMD javareconf


EOBLOC

# need to rewrite these as bash calls of the form 
sudo su - -c "R -e \"install.packages('shiny', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -e \"install.packages('tidyverse',dependencies=T)\""
sudo su - -c "R -e \"install.packages('rmarkdown',dependencies=T)\""
sudo su - -c "R -e \"install.packages('rtweet',dependencies=T,repos='http://cran.rstudio.com/')\""
sudo su - -c "R -e \"install.packages(c('RPostgreSQL','DBI','pool'),dependencies=T)\""
sudo su - -c "R -e \"install.packages(c('Rmisc','Matrix','lubridate','tidytext','stopwords','tokenizers'),dependencies=T)\""



install.packages("rtweet")
install.packages("RPostgreSQL")
install.packages("DBI")
install.packages("pool")
install.packages("Rmisc")
install.packages("Matrix")
install.packages("magrittr")
install.packages("lubridate")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("readr")
install.packages("tidytext")
install.packages("stopwords")
install.packages("tokenizers")
install.packages("shiny")