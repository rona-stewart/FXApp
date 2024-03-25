### ui.R
#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny) 
library(shinyFeedback)
library(ggplot2)
library(plotly)
library(xlsx)

# Define UI for application
fluidPage(
        # Application title
        useShinyFeedback(),
        titlePanel("Historic FX Rates"),
        sidebarLayout(
                sidebarPanel(
                        selectInput ("basecur", label = "Select the base currency", 
                                     choices = c("EUR", "GBP", "USD", "YEN")),
                        checkboxGroupInput ("FXlist", label = "Select currencies for translation", 
                                            choices = c("EUR", "GBP", "USD", "YEN"), selected = "GBP"),
                        dateRangeInput ("predrange", label = "Select the date range from which the prediction model should draw:",
                                        start = "2014-01-31", end = "2024-02-29",
                                        min = "2014-01-31", max = "2024-02-29", format = "yyyy-mm-dd"),
                        dateInput("preddate", label = "Select future date for prediction", 
                                  min = "2024-04-01", max = "2027-12-31", value = "2024-05-01", format = "yyyy-mm-dd"),
                        submitButton ("submit")
                ),
                mainPanel(
                        tabsetPanel(type = "tabs",
                                    
                                    tabPanel(title = "Introduction", br(), 
                                             p("This App provides historic exchange rates across the Euro (EUR), GB pound (GBP), US dollar (USD) and Japanese Yen (YEN)."), 
                                             br(),
                                             p("By selecting the base currency in the side bar, and the currencies you wish to translate to, the graph will depict the historic monthly rates over time on the \"Historic Rates\" tab."),
                                             br(),
                                             p("The data are taken from the ",
                                               a("Bank of England, Database G.12", href = "https://www.bankofengland.co.uk/statistics/Tables"),
                                               "as at 2024/03/21."),
                                             br(),
                                             p("The future rates tab uses a very simplistic model to predict future exchange rates based on past data (as determined by the input in the sidebar panel for the historic date range, and future prediction date)."),
                                             p("Note that this prediction should not be used as the basis for any investment or trading decisions.")
                                             ),
                                    
                                    tabPanel (title = "Historic Graph", br(), 
                                              textOutput("errormess"),
                                              br(),
                                              plotlyOutput("graph")
                                    ),                
                                    tabPanel (title = "Future Rates", 
                                              h5(strong("WARNING: This should not be used for any investment or trading decisions",style = "color:red")),
                                              br(),
                                              h5("Based on the input range selected of:"), 
                                                uiOutput("predrange"), 
                                                br(),
                                                h5("And the prediction date of:"), 
                                                uiOutput("preddate"), 
                                                h5("An indicative assessment of the future currency values selected are:"),
                                              br(),
                                              tableOutput("predictions")
                                    )
                                    
                        )
                )))