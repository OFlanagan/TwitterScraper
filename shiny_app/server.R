#good resource on pool with some good code on how to integrate control into sql queries
#https://shiny.rstudio.com/articles/pool-basics.html

library(RPostgreSQL)
library(DBI)
library(pool)
library(Rmisc)
library(Matrix)
library(magrittr)
library(lubridate)
library(dplyr)
library(ggplot2)


credentials <- read_csv("../credentials.csv")
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

#use only the top 100 words as you can't really display more than that and the load time of the whole word_count table is way too big
word_counts <- pool %>% dbReadTable("word_count_top100")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  output$tweet_count <- renderText({
    #row_count <- dbGetQuery(pool, "select count(*) from rtweet_table")[1,1]
    row_count <- dbGetQuery(pool,"select n from row_counts where source_table = 'rtweet_table';")[1,1]
    paste0("Total number of tweets currently collected: ",row_count)
  })
  

  
  
 output$tweet_table <- renderDataTable({
   query <- paste0("select text, created_at, screen_name, is_retweet, favorite_count, "
                   ,"retweet_count, location, followers_count, description, friends_count, ",
                   "statuses_count, account_created_at, verified, search_query ",
                   "from rtweet_table ",
                   "order by created_at desc ",
                   "limit ", input$tweets_to_fetch,";")
   pool %>% dbGetQuery(query)
   },
   options = list(autoWidth=F,
                  columDefs = list(list(width = '400px', targets = c(0))))
   )
 
 outputOptions(output, "tweet_table", suspendWhenHidden = T)
 
 #more tricks
 #https://shiny.rstudio.com/articles/plot-interaction.html
 output$countchart <- renderPlot({
   
   scale_x_reordered <- function(..., sep = "___") {
     reg <- paste0(sep, ".+$")
     ggplot2::scale_x_discrete(labels = function(x) gsub(reg, "", x), ...)
   }
   reorder_within <- function(x, by, within, fun = mean, sep = "___", ...) {
     new_x <- paste(x, within, sep = sep)
     stats::reorder(new_x, by, FUN = fun)
   }
   
   word_counts %>% 
     group_by(tweet_date,search_query) %>%
     top_n(input$top_n_words,n) %>%
     ungroup %>%
                                   filter(tweet_date == input$word_count_day) %>% 
                                   ggplot(aes(stats::reorder(word, n), n)) +
                                   geom_col(fill = "steelblue") +
                                   scale_x_reordered() +
                                   labs(x = "", y = "") +
                                   coord_flip() +
                                   theme_minimal()+
     #alternative way to specify text size 
     #https://www.rdocumentation.org/packages/ggplot2/versions/2.1.0/topics/rel
     theme(axis.text=element_text(size= rel(2.5)))
     
     })
 

})








