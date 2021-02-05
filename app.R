library(shiny)
library(shiny.semantic)
library(tidyverse)
library(geosphere)
library(lubridate)
library(shinythemes)
library(semantic.dashboard)
library(shinyWidgets)
library(leaflet)
#marine_data <- read.csv("ships.csv")
#marine_data_big <- read.csv("ship.csv")
#marine_data_sample <- marine_data_big[sample(nrow(marine_data_big), 1000000),]
#write.csv(marine_data_sample, "ship_medium.csv")

marine_data <- read.csv(unz("ship_large.zip", "ship_large.csv"), header = TRUE,                       sep = ",") 

#marine_data <- read.csv("ship_medium.csv")

marine_data2 <- marine_data %>% 
    group_by(SHIP_ID) %>%
    mutate(Distance=distHaversine(cbind(LON, LAT), cbind(lag(LON), lag(LAT)))) %>%
    mutate(across(Distance, ~replace_na(.x, 0))) %>%
    rowid_to_column("ID") %>%
    mutate(previous_lat = lag(LAT)) %>%
    mutate(previous_lon = lag(LON)) %>%
    filter(Distance == (max(Distance))) %>%
    mutate(DATETIME = gsub("T", " ", as.character(DATETIME))) %>%
    mutate(DATETIME = gsub("Z", " ", as.character(DATETIME))) %>%
    mutate(DATETIME = ymd_hms((DATETIME))) %>%
    filter(DATETIME == max(DATETIME)) %>%
    arrange(SHIPNAME)


ui <- semanticPage(
    setBackgroundColor(
        color = "ghostwhite",
        gradient = c("linear", "radial"),
        direction = c("bottom", "top", "right", "left"),
        shinydashboard = FALSE
    ),
    dashboardBody(
        fluidRow(
            infoBoxOutput("TravelDate"),
            infoBoxOutput("preLonBox"),
            infoBoxOutput("preLatBox")
        ),
        fluidRow(
            infoBoxOutput("DistanceBox"),
            infoBoxOutput("LonBox"),
            infoBoxOutput("LatBox")
        ),
        box(
            class = "basic",
            a(class="ui blue ribbon label", "Destinations"),
            leafletOutput("map"),
            color = "blue",
            width = 16
        ),
        fluidRow(
            box(
                title = "Select Vessal Type", 
                width = 8, 
                solidHeader = TRUE, 
                color = "teal",
                status = "primary",
                dropdown_input("simple_dropdown", 
                               marine_data2 %>% ungroup() %>% distinct(ship_type)),
            ),
            
            box(
                title = "Select Vessal Name", 
                width = 8, 
                solidHeader = TRUE,
                color = "teal",
                dropdown_input("simple_dropdown2", choices = NULL), 
                
            ),
        )       
        
        # class = "basic",
        # a(class="ui blue ribbon label", "Leaflet demo"),
        # leafletOutput("map"),
        
        
    )
)

server <- function(input, output, session) {
    
    points <- eventReactive(input$simple_dropdown2, {
        cbind(marine_data2 %>%
                  #filter(ship_type == input$simple_dropdown) %>%
                  filter(SHIPNAME == input$simple_dropdown2) %>%
                  select(LON) %>%
                  flatten_dbl(),
              marine_data2 %>%
                  #filter(ship_type == input$simple_dropdown) %>%
                  filter(SHIPNAME == input$simple_dropdown2) %>%
                  select(LAT) %>%
                  flatten_dbl())
    }, ignoreNULL = FALSE)
    
    points2 <- eventReactive(input$simple_dropdown2, {
        cbind(marine_data2 %>%
                  #filter(ship_type == input$simple_dropdown) %>%
                  filter(SHIPNAME == input$simple_dropdown2) %>%
                  select(previous_lon) %>%
                  flatten_dbl(),
              marine_data2 %>%
                  #filter(ship_type == input$simple_dropdown) %>%
                  filter(SHIPNAME == input$simple_dropdown2) %>%
                  select(previous_lat) %>%
                  flatten_dbl())
    }, ignoreNULL = FALSE)
    
    # output$table <- DT::renderDataTable(
    #     semantic_DT(marine_data2 %>% filter(ship_type == input$simple_dropdown))
    # )
    
    observeEvent(input$simple_dropdown, {
        update_dropdown_input(session, "simple_dropdown2", 
                              choices = unique(marine_data2$SHIPNAME[marine_data2$ship_type == input$simple_dropdown]))
    })
    
    output$DistanceBox <- renderInfoBox({
        infoBox(
            value = tags$p(paste(c(round(marine_data2 %>% 
                                             filter(SHIPNAME == input$simple_dropdown2) %>% 
                                             ungroup() %>% select(Distance) %>% 
                                             flatten_dbl(), 2) , "meters"), collapse = " "), style = "font-size: 25%;"), 
            subtitle = tags$p("Distance Traveled", style = ("font-size: 50%;")),
            color = "purple"
        )
    })
    
    output$LonBox <- renderInfoBox({
        infoBox(
            value = tags$p(round(marine_data2 %>% 
                                     filter(SHIPNAME == input$simple_dropdown2) %>% 
                                     ungroup() %>% select(LON) %>% 
                                     flatten_dbl(), 2), style = "font-size: 25%;"), 
            subtitle = tags$p("Ending Longitude", style = ("font-size: 50%;")),
            color = "blue"
        )
    })
    
    output$LatBox <- renderInfoBox({
        infoBox(
            value = tags$p(round(marine_data2 %>% 
                                     filter(SHIPNAME == input$simple_dropdown2) %>% 
                                     ungroup() %>% select(LAT) %>% 
                                     flatten_dbl(), 2), style = "font-size: 25%;"), 
            subtitle = tags$p("Ending Latitude", style = ("font-size: 50%;")),
            color = "blue"
        )
    })
    
    
    output$TravelDate <- renderInfoBox({
        infoBox(
            value = tags$p(marine_data2 %>% 
                               filter(SHIPNAME == input$simple_dropdown2) %>% 
                               ungroup() %>% select(DATETIME)
                           , style = "font-size: 25%;"), 
            subtitle = tags$p("Travel Date", style = ("font-size: 50%;")),
            color = "purple"
        )
    })
    
    output$preLonBox <- renderInfoBox({
        infoBox(
            value = tags$p(marine_data2 %>% 
                               filter(SHIPNAME == input$simple_dropdown2) %>% 
                               ungroup() %>% select(previous_lon)
                           , style = "font-size: 25%;"), 
            subtitle = tags$p("Starting Longitude", style = ("font-size: 50%;")),
            color = "green"
        )
    })
    
    output$preLatBox <- renderInfoBox({
        infoBox(
            value = tags$p(marine_data2 %>% 
                               filter(SHIPNAME == input$simple_dropdown2) %>% 
                               ungroup() %>% select(previous_lat)
                           , style = "font-size: 25%;"), 
            subtitle = tags$p("Starting Latitude", style = ("font-size: 50%;")),
            color = "green"
        )
    })
    
    output$map <- renderLeaflet({
        m <- leaflet() %>% addTiles()
        m <- m %>% setView(21.00, 52.21, zoom = 2.5) %>%
            addCircleMarkers(data = points(), 
                             radius = 2,
                             color = "blue") %>%
            addCircleMarkers(data = points2(), 
                             radius = 2,
                             color = "green") %>%
            addProviderTiles(providers$CartoDB.Positron) %>%
            addLegend(position = "topright", 
                      colors =c("green",  "blue"),
                      labels= c("Starting Location", "Ending Location"),
                      title= "Vessel Observation",
                      opacity = 1) %>%
            addMiniMap(tiles = providers$Esri.WorldStreetMap,
                       toggleDisplay = TRUE) 
        #addLegend("bottomright", values = "hi", color = "green")
        m
    })
}
shinyApp(ui, server)