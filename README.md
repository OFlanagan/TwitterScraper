# TwitterScraper
This is a twitter scraping project, the goal of which is to perform analytics on multiple corpuses from different backgrounds to look for signals of bias.

This is the github repository for the Conversorama web app. This project involves gathering data from twitter using the API, storing it in a database and performing analytics in production. The app can be found here: http://conversorama.com/

## Phase One

This article is the first part of a series documenting my twitter data analysis project. The project will consist of me building an automated twitter scraper in the cloud, storing the data from that in a database, and then analysing the data. This will be my first project using a lot of the tools and techniques involved and so will be a real learning experience. It will also mean that I will need to make a lot of decisions without having the best understanding of what I am doing, but my philosophy here can best be described as: Do the best I can at this stage without too much research in order to get all of the project done, there's heaps of spare time in the future.

# Sources
source for connecting to rds db from ec2
https://blog.davisvaughan.com/post/rds-and-r/

Soure for instructions on setting up rstudio server on ec2
http://www.win-vector.com/blog/2018/01/setting-up-rstudio-server-quickly-on-amazon-ec2/


# The Plumbing
The first step in this project was setting up the infrastructure required to make this all work.
I chose to use an AWS ec2 instance, and and AWS RDS instance for this project to process the data and store it respectively. O decided to use a postgresql database for this project, this may have been a mistake. I had initially narrowed my choices to MySQL and PosgreSQL and chose PostgreSQL as I had used it before. Once I had set up and installed the database and instances and had set up all the firewalls, the rstudio server and all the other tasks I found out that the library I was using to query the twitter API (twitteR) had built in functions to automatically search and store the data in a database, but only for MySQL or SQLLite. This means that I have to write my own code to store this, but also means that there is a job for someone to write this feature for PostgreSQL.

# Plumbing
The first stage of this project was setting up the insfrastructure required for the project.
I chose to use an Ubuntu instance on AWS EC2 with rstudio server as my work environment.
I chose to use a postgreSQL database on AWS RDS for the storage. After I spent a day installing all the packages, setting up github and learning how to configure the security rules I was ready to start the project proper. The package I am using to access the twitter API is twitteR and this package has a fucntion search_and_Store awhich will perform a search of the twitter api and then store the result in a database that just has to be configured through a standard R DBI handle. Unfortunately this is only available for SQLLite and MySQL databases so one of these may have been a better choice for this project.


# The first script
The first functioning script was set up, with a cron job activating it using rscript every 15 minutes as the twitter API allows for 18,000 tweets to be gathered every 15 minutes.
*/5 * * * * Rscript R/TwitterScraper/main_read.R
cronjobs
https://www.ostechnix.com/a-beginners-guide-to-cron-jobs/
