suppressMessages(library(RPostgreSQL))
suppressMessages(library(DBI))
suppressMessages(library(pool))
suppressMessages(library(tidytext))
suppressMessages(library(stopwords))
suppressMessages(library(tokenizers))
suppressMessages(library(Matrix))
suppressMessages(library(magrittr))
suppressMessages(library(lubridate))
suppressMessages(library(dplyr))
suppressMessages(library(readr))
suppressMessages(library(lubridate))
suppressMessages(library(stringr))


pool <- dbPool(
  drv = PostgreSQL(max.con = 16, fetch.default.rec = 500, force.reload = FALSE),
  dbname = Sys.getenv("postgres_dbname"),#pg_dbname,
  port = "5432",#pg_port,
  host = Sys.getenv("postgres_host"),#pg_instance_address,
  user = Sys.getenv("postgres_user"),#pg_user,
  password = Sys.getenv("postgres_password")#pg_password
)


# df <- pool %>% 
#   tbl("rtweet_table") %>%
#   as.data.frame() %>% 
#   select(text, created_at, search_query, word_count_aggregated) %>% 
#   mutate(tweet_date = created %>% date)
con <- poolCheckout(pool)
#this calculating rows_to_process takes a long time as it requires a conditional sum of the whole 
#rtweet_table
#rows_to_process <- dbGetQuery(con, "select count(*) AS unaggregated from rtweet_table where word_count_aggregated = 0;")$unaggregated[1]
#print(paste0(Sys.time()," rows_to_process: ",rows_to_process))
successful_update <- T
rows_to_process <- 1
if (rows_to_process > 0) {
  print("beginning processing")
  
  
  
  #instead of asking how many rows to process we should perform a select and count how many rows are available
  
  
  while (rows_to_process > 0){
    df <- con %>%  
      dbGetQuery("select text, created_at, search_query, word_count_aggregated, status_id::text
               from rtweet_table
               where word_count_aggregated is not true
               limit 500000") 
    
    rows_to_process <- df %>% nrow()
    if (rows_to_process > 0){
      print(paste0(Sys.time(),": ", rows_to_process, " fresh rows read from DB"))
      
      df <- df %>% 
        mutate(tweet_date = created_at %>% date)
      
      tokens <- df %>% 
        select(-word_count_aggregated) %>% 
        group_by(tweet_date, search_query) %>% 
        mutate(text = text %>%
                 str_replace_all("@[:alpha:]*","") %>% 
                 str_replace_all("http.*","") %>% 
                 str_replace_all("[^[:alpha:][:space:]]+", "")) %>%  
        unnest_tokens(word, text)
      print(paste0(Sys.time()," tokens aggregated"))
      
      df <- df %>% select(status_id)
      
      stop_words <- data.frame(word = stopwords(language = "en"), stringsAsFactors = F)
      twitter_stopwords <- data.frame(word = c("rt","amp","realdonaldtrump","btw","dont","im"), lexicon="tweets", stringsAsFactors = F) %>% as.tbl
      
      tokens <- tokens %>% 
        anti_join(stop_words, by = "word")
      tokens <- tokens %>% 
        anti_join(twitter_stopwords, by = "word")
      
      
      word_counts <- tokens %>% group_by(tweet_date, search_query, word) %>% tally() %>% arrange(tweet_date, search_query, desc(n))
      
      #remove tokens from memory and garbage collect
      rm(tokens, stop_words, twitter_stopwords); suppressMessages(gc())
      
      #write our data to the table word_counts
      print(paste0(Sys.time()," writing temp word_counts"))
      dbWriteTable(con,
                   value = word_counts,
                   name = "word_count_temp",
                   overwrite = T,
                   row.names = F)
      #remove word_counts from memory and garbage collect
      rm(word_counts); suppressMessages(gc())
      
      
      ####
      #need to merge word_count_temp into word_count
      #if a row matching the [date,query,word] doesn't exist then add it
      # if a row matching the [date,query,word] does exist then increase the [count] value in word_count by the value in word_count_temp 
      print(paste0(Sys.time()," initiating word_count upsert"))
      dbSendQuery(con,
                  "insert into word_count 
              select tweet_date, search_query, word, n from word_count_temp
              on conflict on constraint word_count_date_query_word_unique
              do
              update 
              set n = excluded.n + word_count.n;")
      print("upsert succesful") # rather assumptive
      
      #check that the write is succesful then update the word_count_aggregator flag for the source rows using the ids
      
      dbWriteTable(con,name="relevant_statuses",value=df,row.names = F,overwrite=T,field.types=c(status_id="bigint"))
      
      if (successful_update){
        query <- paste("update rtweet_table ", 
                        "set word_count_aggregated = true ",
                        "where status_id in (select status_id from relevant_statuses);")
        dbSendQuery(con, query)
        
        #query to make the initial row count table
        #'INSERT INTO row_counts(source_table,n) select 'tweet', count(*) from rtweet_table;'
        
        
      } else {
        #should throw some type of error flag
      }
    }
  }
  #update row count for quick retrieval on app launch as count(*) is slow in postgresql
  print(paste0(Sys.time()," updating row_count"))
#  update_row_count_query <-paste("update row_count ",
# "set n = (select count(*) from rtweet_table) ",
# "where source_table = 'rtweet_table';")
  
  update_row_count_query <- "SELECT n_live_tup
  FROM pg_stat_all_tables
 WHERE relname = 'rtweet_table';"

  dbSendQuery(con, update_row_count_query)
  
  #update the word_count_top100
  print(paste0(Sys.time(),": updating word_count_top100"))
  dbSendQuery(con,paste(
  "with window_query as",
  "(select tweetdate, search_query, word, n, rank()",
  "  over",
  "  (PARTITION BY tweetdate ORDER BY n DESC)",
  "  FROM word_count)",
  "insert into word_count_top100 ",
  "select tweetdate,search_query, word, n from window_query where rank < 100 ",
  "on conflict on constraint word_count_top100_date_query_word_unique ",
  "do update set n = excluded.n;"))
 
  
}else {print("no rows to process")}

print(paste0(Sys.time(),"disconnecting from DB"))


dbClearResult(dbListResults(con)[[1]])

dbDisconnect(con)
poolReturn(con)
poolClose(pool)
suppressMessages(gc())
 print(paste0(Sys.time(),"script finished and DB connection closed"))
rm(list = ls()); suppressMessages(gc()); q(save="no")
