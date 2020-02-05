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
suppressMessages(library(readr))

#unpack credentials from flat file
### should replace this with reading environment variables


# after digging deeper into the documentation it appears that we only need to create a token once, this can then be reused
create_token(
  app = "Owen Flanagan",
  consumer_key = Sys.getenv("consumer_key"), #tw_api_key,
  consumer_secret = Sys.getenv("consumer_secret"), #tw_api_secret,
  access_token = Sys.getenv("access_token"), #tw_access_token,
  access_secret = Sys.getenv("access_secret"),#tw_access_token_secret)
)

#get_token()


PostgreSQL(max.con = 16, fetch.default.rec = 500, force.reload = FALSE)

pool <- dbPool(
  drv = PostgreSQL(max.con = 16, fetch.default.rec = 500, force.reload = FALSE),
  dbname = Sys.getenv("postgres_dbname"),#pg_dbname,
  port = "5432",#pg_port,
  host = Sys.getenv("postgres_host"),#pg_instance_address,
  user = Sys.getenv("postgres_user"),#pg_user,
  password = Sys.getenv("postgres_password")#pg_password
)


#gather tweets
query <-  "@realDonaldTrump"
rt <- search_tweets(
  query,
  n=18000,
  include_rts = FALSE,
  retryonratelimit = T
)

#add the query field and the flag for the aggregator
rt <- rt %>% 
  mutate(search_query = query,
         word_count_aggregated = 0,
         
  ) %>% 
  as.tbl()


# 
# #write data to the storage table, only run once on build
# dbWriteTable(pool, value = rt,
#              name = "rtweet_table",
#              overwrite = TRUE,
#              row.names = FALSE,
#              field.types=c(user_id="bigint",status_id="bigint",
#                            created_at="timestamp",screen_name="varchar",
#                            text="varchar",source="varchar",
#                            display_text_width="integer",reply_to_status_id="bigint",
#                            reply_to_user_id="bigint",reply_to_screen_name="varchar",
#                            is_quote="boolean",is_retweet="boolean",favorite_count="integer",
#                            retweet_count="integer",quote_count="integer",reply_count="integer",
#                            hashtags="varchar",symbols="varchar",urls_url="varchar",
#                            urls_t.co="varchar",urls_expanded_url="varchar",
#                            media_url="varchar",media_t.co="varchar",media_expanded_url="varchar",
#                            media_type="varchar",ext_media_url="varchar",ext_media_t.co="varchar",
#                            ext_media_expanded_url="varchar",ext_media_type="varchar",mentions_user_id="varchar",
#                            mentions_screen_name="varchar",lang="varchar",quoted_status_id="bigint",
#                            quoted_text="varchar",quoted_created_at="timestamp",quoted_source="varchar",
#                            quoted_favorite_count="integer",quoted_retweet_count="integer",quoted_user_id="bigint",
#                            quoted_screen_name="varchar",quoted_name="varchar",quoted_followers_count="integer",
#                            quoted_friends_count="integer",quoted_statuses_count="integer",quoted_location="varchar",
#                            quoted_description="varchar",quoted_verified="boolean",retweet_status_id="bigint",
#                            retweet_text="varchar",retweet_created_at="timestamp",retweet_source="varchar",retweet_favorite_count="integer",
#                            retweet_retweet_count="integer",retweet_user_id="bigint",retweet_screen_name="varchar",retweet_name="varchar",
#                            retweet_followers_count="integer",retweet_friends_count="integer",retweet_statuses_count="integer",
#                            retweet_location="varchar",retweet_description="varchar",retweet_verified="boolean",place_url="varchar",
#                            place_name="varchar",place_full_name="varchar",place_type="varchar",country="varchar",
#                            country_code="varchar",geo_coords="varchar",coords_coords="varchar",bbox_coords="varchar",
#                            status_url="varchar",name="varchar",location="varchar",description="varchar",url="varchar",
#                            protected="boolean",followers_count="integer",friends_count="integer",listed_count="integer",
#                            statuses_count="integer",favourites_count="integer",account_created_at="timestamp",verified="boolean",
#                            profile_url="varchar",profile_expanded_url="varchar",account_lang="varchar",profile_banner_url="varchar",
#                            profile_background_url="varchar",profile_image_url="varchar",search_query="varchar",
#                            word_count_aggregated="integer"
#              ))

#checkout pool, required for write
con <- poolCheckout(pool)

#write to temporary table
dbWriteTable(con, value = rt, 
             name = "rtweet_table_temp", 
             overwrite = TRUE,                        
             row.names = FALSE,
             field.types=c(user_id="bigint",status_id="bigint",
                           created_at="timestamp",screen_name="varchar",
                           text="varchar",source="varchar",
                           display_text_width="integer",reply_to_status_id="bigint",
                           reply_to_user_id="bigint",reply_to_screen_name="varchar",
                           is_quote="boolean",is_retweet="boolean",favorite_count="integer",
                           retweet_count="integer",quote_count="integer",reply_count="integer",
                           hashtags="varchar",symbols="varchar",urls_url="varchar",
                           urls_t.co="varchar",urls_expanded_url="varchar",
                           media_url="varchar",media_t.co="varchar",media_expanded_url="varchar",
                           media_type="varchar",ext_media_url="varchar",ext_media_t.co="varchar",
                           ext_media_expanded_url="varchar",ext_media_type="varchar",mentions_user_id="varchar",
                           mentions_screen_name="varchar",lang="varchar",quoted_status_id="bigint",
                           quoted_text="varchar",quoted_created_at="timestamp",quoted_source="varchar",
                           quoted_favorite_count="integer",quoted_retweet_count="integer",quoted_user_id="bigint",
                           quoted_screen_name="varchar",quoted_name="varchar",quoted_followers_count="integer",
                           quoted_friends_count="integer",quoted_statuses_count="integer",quoted_location="varchar",
                           quoted_description="varchar",quoted_verified="boolean",retweet_status_id="bigint",
                           retweet_text="varchar",retweet_created_at="timestamp",retweet_source="varchar",retweet_favorite_count="integer",
                           retweet_retweet_count="integer",retweet_user_id="bigint",retweet_screen_name="varchar",retweet_name="varchar",
                           retweet_followers_count="integer",retweet_friends_count="integer",retweet_statuses_count="integer",
                           retweet_location="varchar",retweet_description="varchar",retweet_verified="boolean",place_url="varchar",
                           place_name="varchar",place_full_name="varchar",place_type="varchar",country="varchar",
                           country_code="varchar",geo_coords="varchar",coords_coords="varchar",bbox_coords="varchar",
                           status_url="varchar",name="varchar",location="varchar",description="varchar",url="varchar",
                           protected="boolean",followers_count="integer",friends_count="integer",listed_count="integer",
                           statuses_count="integer",favourites_count="integer",account_created_at="timestamp",verified="boolean",
                           profile_url="varchar",profile_expanded_url="varchar",account_lang="varchar",profile_banner_url="varchar",
                           profile_background_url="varchar",profile_image_url="varchar",search_query="varchar",
                           word_count_aggregated="integer"
             ))




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

