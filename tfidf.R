# # TFIDF
#from kxx https://www.kaggle.com/kailex/r-eda-for-q-gru/code
# [TFIDF](https://en.wikipedia.org/wiki/Tf%E2%80%93idf) (short for term frequency–inverse document frequency) 
# helps to find  important words by decreasing the weight for commonly used words and increasing
# the weight for words that can be specific for the document. 

suppressMessages(library(RPostgreSQL))
suppressMessages(library(DBI))
suppressMessages(library(pool))
suppressMessages(library(tidytext))
suppressMessages(library(stopwords))
suppressMessages(library(tokenizers))
suppressMessages(library(tidyverse))
suppressMessages(library(lubridate))


credentials <- read_csv("credentials.csv")
pg_user <- credentials[credentials$service == "postgresql" & credentials$key == "user",]$value
pg_port <- credentials[credentials$service == "postgresql" & credentials$key == "port",]$value
pg_password <- credentials[credentials$service == "postgresql" & credentials$key == "password",]$value
pg_dbname <- credentials[credentials$service == "postgresql" & credentials$key == "dbname",]$value
pg_instance_address <- credentials[credentials$service == "postgresql" & credentials$key == "instance_address",]$value

PostgreSQL(max.con = 16, fetch.default.rec = 500, force.reload = FALSE)
pool <- dbPool(
  drv = PostgreSQL(max.con = 16, fetch.default.rec = 500, force.reload = FALSE),
  dbname = pg_dbname,
  port = pg_port,
  host = pg_instance_address,
  user = pg_user,
  password = pg_password
)

con <- poolCheckout(pool)
df <- con %>%  
  dbGetQuery("select text, created_at, search_query, word_count_aggregated, status_id
               from rtweet_table
               limit 100000") 

tokens <- df %>%
  mutate(question_text = (text %>% 
                            str_replace_all("@[:alpha:]*","") %>% 
                            str_replace_all("http.*","") %>% 
                            str_replace_all("[^[:alpha:][:space:]]+", ""))) %>%  
  unnest_tokens(word, question_text)

  tokens %>% 
  count(word, sort = TRUE) %>%
  top_n(10, n)

tokens <- tokens %>% 
  anti_join(stop_words, by = "word")

df <- df %>% mutate(status_id = status_id %>% as.numeric)
tokens <- tokens %>% mutate(status_id = status_id %>% as.numeric)

tfidf <- tokens %>%
  count(status_id, word, sort = TRUE) %>% 
  bind_tf_idf(word, status_id, n) %>% 
  left_join(df, by = "status_id") %>% as.tbl()


tfidf %>% 
  group_by(date = date(created_at)) %>%
  arrange(tf_idf %>% desc) %>% 
  top_n(30,n)
#need to remove the twitter handles and urls for this to be more useful


dbDisconnect(con)
poolClose(pool)
