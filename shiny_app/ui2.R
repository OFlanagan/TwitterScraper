library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Conversorama - an investigation of big conversations"),
  fluidRow("NB: these stats do not contain retweets and might not include all tweets related to a conversation"),
  fluidRow(
    textOutput("tweet_count")
    
  ), 
  
  
  # Show a plot of the generated distribution
  mainPanel(
    tabsetPanel(type="tabs",
                tabPanel("WordCounts",
                         plotOutput("countchart", width = "auto", height = "800px"),
                         dateInput("word_count_day", label=NULL, value = Sys.Date(), min = NULL, max = NULL,
                                   format = "yyyy-mm-dd", startview = "month", weekstart = 0,
                                   language = "en", width = NULL),
                         numericInput(inputId = "top_n_words",
                                      "How many words to select from DB: ",
                                      value = 30)
                         
                ),
                
                tabPanel("Sample Raw Tweet Data", 
                         numericInput(inputId = "tweets_to_fetch",
                                      "Number of tweets to load from DB: ",
                                      value = 50)
                         ,
                         DT::dataTableOutput("tweet_table")
                         
                ))
    
    
  )
  
))

