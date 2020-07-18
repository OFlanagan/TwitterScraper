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
library(tidyverse)
library(scales)

library(RPostgreSQL)
library(DBI)
library(pool)
library(Rmisc)
library(Matrix)
library(magrittr)
library(lubridate)
library(dplyr)
library(ggplot2)
library(readr)
# df <- con %>%
#   dbGetQuery("select text, created_at, search_query, word_count_aggregated, status_id::text
#                from rtweet_table
#                limit 500000")
# df %>% write_csv("~/data/twitterscraper/sample_text.csv")


    scale_x_reordered <- function(..., sep = "___") {
      reg <- paste0(sep, ".+$")
      ggplot2::scale_x_discrete(labels = function(x) gsub(reg, "", x), ...)
    }
    reorder_within <- function(x, by, within, fun = mean, sep = "___", ...) {
      new_x <- paste(x, within, sep = sep)
      stats::reorder(new_x, by, FUN = fun)
    }


df <- read_csv("~/data/twitterscraper/sample_text.csv")
    
      
df <- df %>% 
  mutate(tweet_date = created_at %>% date)

df <- df %>% as.tbl() 
      

create_chart <- function(df,input_date){
     
tokens <- df %>% 
        select(-word_count_aggregated) %>% 
        group_by(tweet_date, search_query) %>% 
        mutate(text = text %>%
                 #str_replace_all("@[:alpha:]*","") %>%
                 str_replace_all("http.*","") %>% 
                 str_replace_all("[^[:alpha:][:space:]]+", "")
                 ) %>%  
        unnest_tokens(word, text)
     
     
stop_words <- data.frame(word = stopwords(language = "en"), stringsAsFactors = F)

twitter_stopwords1 <- data.frame(word = c("rt","amp","realdonaldtrump","btw","dont","im"), lexicon="tweets", stringsAsFactors = F) %>% as.tbl
      
twitter_stopwords2 <- data.frame(word = c("trump","president","like","just","youre","get","us","now","hes","thats",
                                          "people","know","can","see","want","cant","go","going",
                                          "say","said","one", "even", "think", "said", "let", "say",
                                          "never", "ever","really","take","didnt",
                                          "well","still","way","much","doesnt",
                                          "got","every","please","u","lol"), lexicon="tweets", stringsAsFactors = F) %>% as.tbl

tokens <- tokens %>% 
  anti_join(stop_words, by = "word")
tokens <- tokens %>% 
  anti_join(twitter_stopwords1, by = "word")
      
tokens <- tokens %>% 
  anti_join(twitter_stopwords2, by = "word")
      
word_counts <- tokens %>% group_by(tweet_date, search_query, word) %>% tally() %>% arrange(tweet_date, search_query, desc(n))

word_counts %>% 
      group_by(tweet_date,search_query) %>%
      top_n(50,n) %>%
      ungroup %>%
      filter(tweet_date == input_date) %>% 
      ggplot(aes(stats::reorder(word, n), n)) +
      geom_col(fill = "steelblue") +
      scale_x_reordered() +
      labs(x = "", y = "") +
      coord_flip() +
      theme_minimal()+
      #alternative way to specify text size 
      #https://www.rdocumentation.org/packages/ggplot2/versions/2.1.0/topics/rel
    theme(axis.text=element_text(size= rel(2.5)))
}


create_chart(df,"2020-01-25")

create_chart(df,"2020-01-26")

create_chart(df,"2020-01-27")

create_chart(df,"2020-01-28")

df$text[grepl(".* trumps .*",df$text)]

#potential words to remove. Need to think more about it
"lol","keep","mr","trumps","make","american","america","great","love",
"oh","thank","donald"
"call","right","good","yes","many","country","better","thing"
