## load rtweet package
print(paste0(Sys.time()," beginning script"))
suppressMessages(library(rtweet))
suppressMessages(library(RPostgreSQL))
suppressMessages(library(DBI))
suppressMessages(library(pool))
suppressMessages(library(Rmisc))
suppressMessages(library(Matrix))
suppressMessages(library(magrittr))
suppressMessages(library(lubridate))
suppressMessages(library(dplyr))
suppressMessages(library(ggplot2))
suppressMessages(library(readr))
#unpack credentials from flat file
credentials <- read_csv("credentials.csv")
pg_user <- credentials[credentials$service == "postgresql" & credentials$key == "user",]$value
pg_port <- credentials[credentials$service == "postgresql" & credentials$key == "port",]$value
pg_password <- credentials[credentials$service == "postgresql" & credentials$key == "password",]$value
pg_dbname <- credentials[credentials$service == "postgresql" & credentials$key == "dbname",]$value
pg_instance_address <- credentials[credentials$service == "postgresql" & credentials$key == "instance_address",]$value
tw_api_key <- credentials[credentials$service == "twitterapi" & credentials$key == "api_key",]$value
tw_api_secret <- credentials[credentials$service == "twitterapi" & credentials$key == "api_secret",]$value
tw_access_token <- credentials[credentials$service == "twitterapi" & credentials$key == "access_token",]$value
tw_access_token_secret <- credentials[credentials$service == "twitterapi" & credentials$key == "access_token_secret",]$value

create_token(
  app = "Owen Flanagan",
  consumer_key = tw_api_key,
  consumer_secret = tw_api_secret,
  access_token = tw_access_token,
  access_secret = tw_access_token_secret)

PostgreSQL(max.con = 16, fetch.default.rec = 500, force.reload = FALSE)

pool <- dbPool(
  drv = PostgreSQL(max.con = 16, fetch.default.rec = 500, force.reload = FALSE),
  dbname = pg_dbname,
  port = pg_port,
  host = pg_instance_address,
  user = pg_user,
  password = pg_password
)


#gather tweets
query <-  "@realDonaldTrump"
rt <- search_tweets(
  query, 
  n = 18000, 
  include_rts = FALSE, 
  retryonratelimit = T
)

#add the query field and the flag for the aggregator
rt <- rt %>% mutate(search_query = query,
                    word_count_aggregated = 0) %>% 
  as.tbl()

#write data to the storage table, only run once on build
# dbWriteTable(pool, value = rt, 
#              name = "rtweet_table", 
#              overwrite = TRUE,                        
#              row.names = FALSE)

#checkout pool, required for write
con <- poolCheckout(pool)

#write to temporary table
dbWriteTable(con, value = rt, 
             name = "rtweet_table_temp", 
             overwrite = TRUE,                        
             row.names = FALSE)
print(paste0(Sys.time()," raw data read and written to DB, emptying from memory"))
rm(rt); suppressMessages(gc())

#insert new data into DB
# RUN LEFT JOIN...IS NULL QUERY (COMPARE COLS --COL1, COL2, COL3-- ADD/REMOVE AS NEEDED)

#insert new rows into the main table
print(paste0(Sys.time()," beginning DB upsert"))
dbSendQuery(con, paste0("INSERT INTO rtweet_table", 
                        " SELECT rtweet_table_temp.*
                        FROM rtweet_table_temp",
                        " LEFT JOIN rtweet_table",
                        " ON rtweet_table.user_id = rtweet_table_temp.user_id",
                        " AND rtweet_table.status_id = rtweet_table_temp.status_id",
                        "   WHERE rtweet_table.user_id IS NULL",
                        "   OR rtweet_table.status_id IS NULL"))

dbDisconnect(con)
poolClose(pool)
print(paste0(Sys.time(),"script finished and DB connection closed"))
rm(list = ls()); suppressMessages(gc()); q(save="no")