###############################################.
## ScotPHO - Life expectancy - NHS Board ----
###############################################.

# Code to create shiny chart of trends in life expectancy and healthy life expectancy by NHS Board 
# This is published in the following section of the ScotPHO website: 
# Population Dynamics > Deaths and life expectancy > Data > NHS Boards

############################.
## Global ----
############################.
############################.
##Packages 

library(dplyr) #data manipulation
library(plotly) #charts
library(shiny) #shiny apps

# Data file
hb_trend <- readRDS("data/le_hle_hb.rds")

# Use for selection of areas
#board_list <- sort(unique(hb_trend$nhsboard[hb_trend$nhsboard != "Scotland"])) #if Scotland is in datasource
board_list <- sort(unique(hb_trend$nhsboard))

############################.
## Visual interface ----
############################.
#Height and widths as percentages to allow responsiveness
ui <- fluidPage(style="width: 650px; height: 500px; ",
                div(style= "width:100%",
                    h4("Chart 1. Life expectancy and healthy life expectancy at birth by NHS Board"),
                    div(style = "width: 50%; float: left;",
                        selectInput("measure", label = "Select a measure type",
                                    choices = c("Life expectancy", "Healthy life expectancy"), 
                                    selected = "Life expectancy"))),
                
                div(style = "width: 50%; float: left;",
                    selectInput("nhsboard", label = "Select NHS Board", 
                                choices = board_list,
                                selected = "Scotland")),
                
                
                div(style= "width:100%; float: left;", #Main panel
                    plotlyOutput("chart", width = "100%", height = "350px"),
                    p("note: y-axis does not start at zero"),
                    p(div(style = "width: 25%; float: left;", #Footer
                          HTML("Source: <a href='https://www.nrscotland.gov.uk/statistics-and-data/statistics/statistics-by-theme/life-expectancy' target='_blank'>NRS</a>")),
                      div(style = "width: 25%; float: left;",
                          downloadLink('download_data', 'Download data')))
                )
) # fluidPage

############################.
## Server ----
############################.
server <- function(input, output) {
  
  output$chart <- renderPlotly({

    #Data for NHS Board line
    data_hb <- hb_trend %>% subset(nhsboard == input$nhsboard & measure == input$measure) 
    
    # Define number of lines on chart
    num <- length(unique(data_hb$sex))    
    
    # Information to be displayed in tooltip
    tooltip <- c(paste0(input$nhsboard, " - ", data_hb$sex, "<br>",
                        "Time period (3 year average): ", data_hb$year, "<br>",
                        input$measure, " (years): ", data_hb$value, "<br>"))
    
    # y-axis title
    yaxistitle <- paste0(input$measure, " (years)")

    # set number of ticks depending on measure selected
    if (input$measure == "Life expectancy")

    {tick_freq <- 2}

    else {tick_freq <- 1}
# 
#     # Define number of lines on chart
#     num <- length(unique(data_hb$sex))

    # Define line colours
    pal <- c('#9B4393', '#1E7F84')
    
    # Buttons to remove from plot
    bttn_remove <-  list('select2d', 'lasso2d', 'zoomIn2d', 'zoomOut2d',
                         'autoScale2d',   'toggleSpikelines',  'hoverCompareCartesian',
                         'hoverClosestCartesian', 'zoom2d', 'pan2d', 'resetScale2d')
    
    
    plot <- plot_ly(data = data_hb, x=~year, y = ~value, 
                    color= ~sex, colors = pal[1:num], 
                    type = "scatter", mode = 'lines+markers', 
                    symbol= ~sex, symbols = list('circle','square'), marker = list(size= 8),
                    width = 650, height = 350,
                    text=tooltip, hoverinfo="text")  %>%  
      
      # Layout
      layout(annotations = list(), #It needs this because of a buggy behaviour
             yaxis = list(title = yaxistitle, 
                          #rangemode="tozero", 
                          fixedrange=TRUE), 
             xaxis = list(
               title = list(text = "3 year average", standoff=20),
               dtick = tick_freq,
               fixedrange=TRUE#, 
               #tickangle = 0
               ),
             font = list(family = 'Arial, sans-serif'), #font
             margin = list(pad = 4, t = 50), #margin-paddings
             hovermode = 'false',  # to get hover compare mode as default
             legend = list(orientation = "h", x=0, y=1.2)) %>% 
      config(displayModeBar= T, displaylogo = F, editable =F, modeBarButtonsToRemove = bttn_remove) 
    # taking out plotly logo and collaborate button
    
  }) 
  
  
  # Allow user to download data
  output$download_data <- downloadHandler(
    filename =  'le_and_hle_data_hb.csv', 
    content = function(file) {
      write.csv(hb_trend, file, row.names=FALSE) })
  
} # end of server

############################.
## Calling app ----
############################.

shinyApp(ui = ui, server = server)

##END