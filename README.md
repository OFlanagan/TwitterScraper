# TwitterScraper
This is a twitter scraping project, the goal of which is to perform analytics on multiple corpuses from different backgrounds to look for signals of bias
=======
This is a twitter scraping project, the goal of which is to perform analytics on multiple corpuses from different backgrounds to look for signals of bias.

This is the github repository for the Conversorama web app. This project involves gathering data from twitter using the API, storing it in a database and performing analytics in production. The app can be found here: http://conversorama.com/

NB: This repository has had the commit hitory destroyed before the 6th of January 2019 as this was when the credentials.csv file was introduced to hide the usernames and passwords when distributing on GitHub.

# Background and Motivation
It is widely accepted that we live in times that could be euphemistically described as "interesting". The global power structures that have prevailed since my birth (1992 CE) are being challenged. The trend towards a liberal, globalist, capitalist world appears to have been replaced with a trend towards nationalistism, populism and authoritarianism. There are reports of a growing divide in beliefs between groups inside of western societies and an inability to find constructive compromise. People speak of fake news and apparently hold their own beliefs to be greater than objective truth. People speak of ideological echo chambers brought about by algorithms designed to keep people engaged rather than informed.
(citations needed)

## Bias
My personal interest in this deviciseveness was picqued when I was over exposed to a particular publications articles on social media. These articles consistently presented facts in an ideological wrapper that I didn't entirely agree with. They were fundamentally biassed towards ideological views that I do not hold and towards the end of my time on that social media platform, my main interactions with this publications articles was: read the headline, be annoyed, read the hate in the comments. That was an ideological position that I do not agree with, but the digidal media channel provided interesting information to me regularly and I digested it. 

(talk about Fox news) (talk about indoctrination)

### Definition of Bias
Bias is tricky
Bias in my terms is a skewing of facts
This is tricky because we are all fundamentally biased. 
For example, I believe that the lives of individuals are fundamentally valuable. This is a belief of mine, it biases my thoughts. It may be the prevaling view in the western world, but it is not universal. It is things like this that will influence how we feel about things and how we percieve things. Philosophy has provided useful tools such as rationalism and empiricism to fight these, but we are still biased animals and have to be vigilant.

My goal with this project is dual:
1) to improve my skills and understanding of natural language processing
2) to have fun investigating an interesting question:
  Can we quantify bias?
  
Quantifying bias is quite the rabbit hole and so it is necessary to split the project into acheivable sub projects that can be completed.

# Implementation
This section provides an overview of the implementation of this project. This project is a work in progress.
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
