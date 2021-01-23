# server, v1 was 348 lines, this meant to be much shorter

server <- function(input, output, session) {
  
  switch_page <- function(i) {
    updateTabsetPanel(session, "user_flow", selected = paste0("tab", i))
  }
  
  
  observeEvent(input$page_12, switch_page(2))
  observeEvent(input$page_21, switch_page(1))
  observeEvent(input$page_23, switch_page(3))
  observeEvent(input$page_34, switch_page(4))
  observeEvent(input$page_32, switch_page(2))
  observeEvent(input$page_31, switch_page(1))
  observeEvent(input$page_42, switch_page(2))
  observeEvent(input$page_41, switch_page(1))
  observeEvent(input$page_45, switch_page(5))
  observeEvent(input$page_15, switch_page(5))
  observeEvent(input$page_51, switch_page(1))
  
  output$map <- renderLeaflet({
    
    leaflet() %>% 
      addProviderTiles(providers$OpenStreetMap,
                       options = providerTileOptions(noWrap = FALSE),
                       group = "Open Street Map (default)") %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "ESRI Imagery") %>%
      addProviderTiles(providers$Esri.WorldTopoMap, group = "ESRI Topo") %>%
      addLayersControl(
        baseGroups = c("Open Street Map (default)", "ESRI Imagery", "ESRI Topo"),
        options = layersControlOptions(collapsed = FALSE)) %>%
      addSearchOSM() %>%
      setView(lng = 100, lat= 13.44, zoom = 6)
  })

  # find lat lon of user selected point on the map
  # and place a transparent rectangle over it with 0.5 degree lat lon boundaries
  observeEvent(input$map_click, {
    
    click <- (input$map_click)
    
    # adjust the longitude when user scrolls beyond +/- 180
    while (click$lng < -180)  {
      click$lng <- click$lng + 360
    }
    
    while (click$lng > 180)  {
      click$lng <- click$lng - 360
    }
    
    # label as north or south or east or west for chart output
    north_south <- ifelse(click$lat > 0, "N", "S")
    east_west <- ifelse(click$lng > 0, "E", "W")
    
    output$text_location <- renderText(paste("You have selected a point at ",
                                          formatC(abs(click$lat), digits = 1, format = "f"),  "° ", north_south, 
                                          " and ", 
                                          formatC(abs(click$lng), digits = 1, format = "f"), "° ", east_west, sep = ""))
    
    text <- paste(formatC(abs(click$lat), digits = 1, format = "f"),  "° ", north_south, 
                  " & ", 
                  formatC(abs(click$lng), digits = 1, format = "f"), "° ", east_west, sep = "")
    
    proxy <- leafletProxy("map")
    
    proxy %>% clearPopups() %>%
      clearShapes() %>%
      #  addProviderTiles(providers$Esri.WorldImagery, group = "ESRI Imagery") %>%
      # addProviderTiles(providers$Esri.WorldTopoMap, group = "ESRI Topo") %>%
      addPopups(click$lng, click$lat, text) %>%
      # add here the half-degree boundary box overlay
      addRectangles(lng1 = round_any(click$lng, 0.5, floor),
                    lng2 = round_any(click$lng, 0.5, ceiling),
                    lat1 = round_any(click$lat, 0.5, floor),
                    lat2 = round_any(click$lat, 0.5, ceiling),
                    fill = TRUE, fillColor = "yellow", fillOpacity = 0.4,
                    weight = 2, color = "yellow", group = "Outline") %>%
      
      #  addPopups(click$lng, click$lat, group = "Popup") %>%
      addLayersControl(
        baseGroups = c("Open Street Map (default)", "ESRI Imagery", "ESRI Topo"),
        options = layersControlOptions(collapsed = FALSE)
      )
    }
  )

  dliDataGet <- eventReactive(input$page_23, {
    rs_get(input$map_click)
  }
  )

output$dliChart1 <- renderPlot( 
  make_chart_1(dliDataGet()), res = 96
)

dirNS <- eventReactive(input$page_23, {
  north_south(input$map_click)
}
)

dirEW <- eventReactive(input$page_23, {
  east_west(input$map_click)
}
)

output$dli_chart_pane1 <- downloadHandler(
  
  filename = function(){
    paste("dli_lat", 
          round(as.numeric(input$map_click[1])),
          ifelse(as.numeric(input$map_click[2]) > 0, "N", "S"),
          "_lon", 
          round(as.numeric(input$map_click[2])), 
          ifelse(as.numeric(input$map_click[1]) > 0, "E", "W"), 
          ".png", sep = "")
  },
  
  content = function(file){
    save_plot(file, plot = make_chart_1(dliDataGet()), base_asp = 1.78, base_height = 4, scale = 2)
  }
)

}

