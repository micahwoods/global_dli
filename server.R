# server, v1 was 348 lines, this meant to be much shorter

server <- function(input, output, session) {
  
  switch_page <- function(i) {
    updateTabsetPanel(session, "user_flow", selected = paste0("tab", i))
  }
  
  observeEvent(input$details, switch_page(5))
  observeEvent(input$restart, switch_page(1))
  observeEvent(input$page_12, switch_page(2))
  observeEvent(input$page_21, switch_page(1))
  
  observeEvent(input$page_23, {
   
               req(input$map_click)
           
    # validate(
    #   need(is.null(input$map_click), "Please choose a location on the map first.")
    # )
               switch_page(3)
               })
  
  
  observe({
    if(is.null(input$map_click) && input$page_23 > 0)
      showModal(modalDialog(
        title = "Please select a location on the map first",
        "Click the map to choose a 0.5° by 0.5° grid from which satellite data will be downloaded.",
        easyClose = TRUE,
        footer = NULL
      ))
  })
  # observeEvent(input$n,
  #              shinyFeedback::feedbackWarning(
  #                "n", 
  #                input$n %% 2 != 0,
  #                "Please select an even number"
  #              )  
  # )
  # output$half <- renderText(input$n / 2)
  
  observeEvent(input$page_34, switch_page(4))
  observeEvent(input$page_32, switch_page(2))
  observeEvent(input$page_31, switch_page(1))
  observeEvent(input$page_42, switch_page(2))
  observeEvent(input$page_41, switch_page(1))
  observeEvent(input$page_45, switch_page(5))
  observeEvent(input$page_15, switch_page(5))
  observeEvent(input$page_51, switch_page(1))
  
  # observeEvent(input$restart, {
  #   refresh()
  # })
  # 
  # observeEvent(input$page_51, {
  #   refresh()
  # })
  
  # output$file1_ui <- renderUI({
  #   input$restart ## Create a dependency with the reset button
  #   leafletOutput("map")
  # })
  
  
  # observeEvent(input$restart, {
  #   
  #   leafletProxy("map") %>%
  #     setView(lng = location()[2], lat = location()[1], zoom = 4) 
  # })
  # 
  # observeEvent(input$page_51, {
  #   
  #   leafletProxy("map") %>%
  #     setView(lng = location()[2], lat = location()[1], zoom = 4) 
  # })

 
  
  
  
  # 
  # 
  #   leaflet() %>% 
  #     addProviderTiles(providers$OpenStreetMap,
  #                      options = providerTileOptions(noWrap = FALSE),
  #                      group = "Open Street Map (default)") %>%
  #     addProviderTiles(providers$Esri.WorldImagery, group = "ESRI Imagery") %>%
  #     addProviderTiles(providers$Esri.WorldTopoMap, group = "ESRI Topo") %>%
  #     addProviderTiles(providers$Stamen.TonerLite, group = "Stamen TonerLite") %>%
  #     addLayersControl(
  #       baseGroups = c("Open Street Map (default)", "ESRI Imagery", "ESRI Topo", "Stamen TonerLite"),
  #       options = layersControlOptions(collapsed = TRUE)) %>%
  #     addSearchOSM() %>%
  #     setView(lng = 100, lat = 14, zoom = 5) 
  # 
  # 
  # 
  # 
   output$map <- renderLeaflet({

    leaflet() %>%
      addProviderTiles(providers$OpenStreetMap,
                       options = providerTileOptions(noWrap = FALSE),
                       group = "Open Street Map (default)") %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "ESRI Imagery") %>%
      addProviderTiles(providers$Esri.WorldTopoMap, group = "ESRI Topo") %>%
      addProviderTiles(providers$Stamen.TonerLite, group = "Stamen TonerLite") %>%
      addLayersControl(
        baseGroups = c("Open Street Map (default)", "ESRI Imagery", "ESRI Topo", "Stamen TonerLite"),
        options = layersControlOptions(collapsed = TRUE)) %>%
      addSearchOSM() %>%
      setView(lng = 100, lat= 13.44, zoom = 5)

  })
  
  # Zoom in on user location if given
  observe({
    if(!is.null(input$lat)) {
      map <- leafletProxy("map")
      dist <- 1
      lat <- input$lat
      lng <- input$long
      map %>% fitBounds(lng - dist, lat - dist, lng + dist, lat + dist)
    }
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
                                          formatC(abs(click$lng), digits = 1, format = "f"), "° ", east_west, ".", sep = ""))
    
    text <- paste(formatC(abs(click$lat), digits = 1, format = "f"),  "° ", north_south, 
                  " & ", 
                  formatC(abs(click$lng), digits = 1, format = "f"), "° ", east_west, sep = "")
    
    proxy <- leafletProxy("map")
    
    proxy %>% clearPopups() %>%
      clearShapes() %>%
      addPopups(click$lng, click$lat, text) %>%
      # add here the half-degree boundary box overlay
      addRectangles(lng1 = round_any(click$lng, 0.5, floor),
                    lng2 = round_any(click$lng, 0.5, ceiling),
                    lat1 = round_any(click$lat, 0.5, floor),
                    lat2 = round_any(click$lat, 0.5, ceiling),
                    fill = TRUE, fillColor = "orange", fillOpacity = 0.5,
                    weight = 2, color = "#3f7300") %>%
      addLayersControl(
        baseGroups = c("Open Street Map (default)", "ESRI Imagery", "ESRI Topo", "Stamen TonerLite"),
        options = layersControlOptions(collapsed = TRUE)
      )
    }
  )
  
  # a map to use as png in my output file
  map_reactive <- reactive({
    
     click <- location()
     
     leaflet(height = 540, width = 540) %>% 
      setView(lng = click[2], lat = click[1], zoom = 8) %>%
       addProviderTiles(providers$Stamen.Terrain) %>%
    #   addProviderTiles(providers$Stamen.TonerLite) %>%
      addRectangles(lng1 = round_any(click[2], 0.5, floor),
                    lng2 = round_any(click[2], 0.5, ceiling),
                    lat1 = round_any(click[1], 0.5, floor),
                    lat2 = round_any(click[1], 0.5, ceiling),
                    fill = TRUE, fillColor = "orange", fillOpacity = 0.5,
                    weight = 2, color = "#3f7300")
     
  })
  

  location <- reactive(
    map_click_loc(input$map_click)
  )
  
  # get a year of Rs from the location clicked on map
  dliDataGet <- eventReactive(input$page_23, {
   req(input$map_click) 
    rs_get(input$map_click) 
  }
  )

  # make a plot of a year of daily date, based on that point click
output$dliChart1 <- renderPlot( 
  make_chart_1(dliDataGet()), res = 96
)

output$click_loc_test <- renderTable( map_click_loc(input$map_click) )

 dliNormalGet <- eventReactive(input$page_34, {
  rs_normal_get(location())
  
 }
 )
 
 # output$monthly <- renderDataTable(dliNormalGet())

 output$dliChart2 <- renderPlot(
    make_chart_2(dliNormalGet(), dliDataGet()), res = 96
  )
 
 map_get <- eventReactive(input$user_flow == 'tab4', {
   req(input$user_flow == 'tab4')
   
   id4 <- showNotification("Getting location image for chart output", 
                           duration = NULL, closeButton = FALSE, type = "warning")
   on.exit(removeNotification(id4), add = TRUE)
   
   mapshot(map_reactive(),
           vwidth = 540,
           vheight = 540,
           file = "temp.png")
   
   ## see if I can get an output3
   
   img.background <- readPNG("temp.png", native = TRUE)
   
   filename <- "temp.png"

 })

 # I want to get a mapshot, and I know the input
 # so basically I am going to make a new, square map
 
dirNS <- eventReactive(input$page_23, {
  north_south(input$map_click)
}
)

dirEW <- eventReactive(input$page_23, {
  east_west(input$map_click)
}
)

output$dli_chart_3pane <- downloadHandler(
  
  filename = function(){
    paste("dli_lat", 
          round(abs(location()[1])),
          ifelse(location()[1] > 0, "N", "S"),
          "_lon", 
          round(abs(location()[2])), 
          ifelse(location()[2] > 0, "E", "W"), 
          ".png", sep = "")
  },
  
  content = function(file){
    save_plot(file, plot = make_chart_1( dliDataGet()) + 
        (make_chart_2(dliNormalGet(), dliDataGet()) / make_chart_3(map_get())) +
        plot_layout(nrow = 1, widths = c(3, 1)) +
        plot_annotation(theme = theme(plot.background = element_rect(fill = "#f7ffed", color = NA))), 
        base_asp = 1.78, base_height = 1.8, scale = 4)
  }
)

}

