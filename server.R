#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(shinyFeedback)
library(plotly)
library(ggplot2)
library(dplyr)
library(tidyr)
library(xlsx)

# Define server logic required to plot the rates and predict future rates
shinyServer(function(input, output) {
        base <- reactive ({ input$basecur })
        translation <- reactive ({input$FXlist})
        
        # Define rates for input
        FXlist <- reactive ({ 
                lapply(translation(), function(x) paste(base(), x, sep = "."))
                })
        
        output$errormess <- renderText ({
                ifelse(input$basecur %in% input$FXlist, "Base currency selected as translation currency will not be plotted."," ")
        })
        
        # Create the plotly graph
        output$graph <- renderPlotly({
     
        # Load the data
        FX <- read.xlsx("FX_data.xlsx", sheetIndex = 1, startRow = 3, header = TRUE, keepFormulas = FALSE)
        
        # Identify relevant column indices for the FX rates
        FXindices <- c()
        for (i in 1:length(FXlist())){
        FXindices <- c(FXindices, grep(FXlist()[i], colnames(FX)))
        }
        
        # Subset the main dataset using only those indices, then transform to a long data frame
        if(length(FXindices) > 1) { 
               FXsub <- FX[, FXindices] %>%
                       gather(currency, value) %>%
                       mutate(Date = rep(FX[,1], length(FXindices)))
        }
        else {
                currencies <- FXlist()
                FXsub <- data.frame(value = FX[, FXindices], Date = FX[,1], currency = rep(currencies[[1]], nrow(FX)))
        }
                
        g <- ggplot(FXsub, aes(x=Date, y=value, color = currency)) +
                geom_line(aes(color = currency)) +
                ylab (input$basecur) + 
                labs (title = "Historic Exchange Rates") +
                theme_bw()
        ggplotly(g)
        
        })
        
        ### Create prediction models
        
        output$predictions <- renderTable({
    
                # ReLoad the data
                FX2 <- read.xlsx("FX_data.xlsx", sheetIndex = 1, startRow = 3, header = TRUE, keepFormulas = FALSE)
                
                # Identify relevant column indices for the FX rates
                FXindices <- c()
                for (i in 1:length(FXlist())){
                        FXindices <- c(FXindices, grep(FXlist()[i], colnames(FX2)))
                }
                
                # Subset the main dataset using only those indices, then filter to date range
                FXsub <- FX2[, c(1,FXindices)]
                FXsub <- filter(FXsub, Date >= as.Date(input$predrange)[1] & 
                                Date <= as.Date(input$predrange)[2])
                
                
                # Create prediction table variables
                predvals <- numeric(ncol(FXsub) - 1)
                relDate <- as.Date(input$preddate)
                colNames <- names(FXsub)
                
                # Using a loop, create individual models and predictions for each currency exchange selected
                for (i in 2:ncol(FXsub)){
                        formula <- as.formula(paste(colNames[i], "~ Date"))
                        model <- lm(formula, data = FXsub)
                        newdata <- data.frame(Date = relDate)
                        predvals[i-1] <- round(predict(model, newdata = newdata),3)
                }
                
                # Create a vector of the FX translation identifiers
                predhead <- names(FXsub[-1])
                
                # Create a table of predictions and FX translation identifiers
                predictions <- rbind(predhead,predvals)
                predictions
        })
        
        ### Create output objects for use in text format
        output$predrange <- renderUI({paste(as.Date(input$predrange)[1],as.Date(input$predrange)[2],sep=" to ")})
        output$preddate <- renderUI({as.Date(input$preddate)})
})