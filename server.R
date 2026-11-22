## server for the Global DLI app

server <- function(input, output, session) {

  ## page switching, from Wickham's Mastering Shiny
  switch_page <- function(i) {
    updateTabsetPanel(session, "user_flow", selected = paste0("tab", i))
  }

  observeEvent(input$restart, switch_page(1))
  observeEvent(input$page_31, switch_page(1))
  observeEvent(input$page_51, switch_page(1))
  observeEvent(input$details, switch_page(5))
  observeEvent(input$page_15, switch_page(5))
  observeEvent(input$page_34, switch_page(4))

  ## step 1 -> 2 needs a location
  observeEvent(input$page_23, {
    if (is.null(location())) {
      showModal(modalDialog(
        title = "Please select a location on the map first",
        "Click the map to choose a 0.5° by 0.5° grid from which satellite data will be downloaded.",
        easyClose = TRUE,
        footer = NULL
      ))
    } else {
      switch_page(3)
    }
  })

  ## ---- map ------------------------------------------------------------

  ## basemap choices: layer-control label = tile provider, used for both the
  ## interactive map and the map in the downloaded chart (make_chart_3)
  base_tiles <- c("Open Street Map" = "OpenStreetMap",
                  "Satellite"       = "Esri.WorldImagery",
                  "Nat Geo"         = "Esri.NatGeoWorldMap")
  base_groups <- names(base_tiles)

  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(base_tiles[[1]], group = base_groups[1]) %>%
      addProviderTiles(base_tiles[[2]], group = base_groups[2]) %>%
      addProviderTiles(base_tiles[[3]], group = base_groups[3]) %>%
      addLayersControl(baseGroups = base_groups,
                       options = layersControlOptions(collapsed = TRUE)) %>%
      addSearchOSM() %>%
      setView(lng = 100, lat = 13.44, zoom = 5)
  })

  ## zoom to the user's location if the browser shares it (see ui.R)
  observeEvent(input$lat, {
    dist <- 1
    leafletProxy("map") %>%
      fitBounds(input$long - dist, input$lat - dist, input$long + dist, input$lat + dist)
  })

  ## the basemap the user last chose in step 1 (leaflet reports the visible
  ## groups as input$map_groups); the downloaded map uses the same tiles
  map_provider <- reactive({
    shown <- intersect(input$map_groups, base_groups)
    if (length(shown) == 0) base_tiles[[1]] else base_tiles[[shown[1]]]
  })

  ## the selected point, numeric c(lat, lon) with lon wrapped to [-180, 180]
  location <- reactiveVal(NULL)

  observeEvent(input$map_click, {
    loc <- map_click_loc(input$map_click)
    location(loc)

    cell <- grid_cell(loc[1], loc[2])

    ## draw at the clicked (unwrapped) longitude so the box appears where the
    ## user clicked, even if they scrolled past the date line
    shift <- input$map_click$lng - loc[2]

    leafletProxy("map") %>%
      clearPopups() %>%
      clearShapes() %>%
      addPopups(input$map_click$lng, loc[1], format_latlon(loc[1], loc[2])) %>%
      ## same look as the downloaded map: light orange fill, magenta outline
      ## on a wider white casing so it shows on any basemap
      addRectangles(lng1 = cell[["xmin"]] + shift, lng2 = cell[["xmax"]] + shift,
                    lat1 = cell[["ymin"]],         lat2 = cell[["ymax"]],
                    fill = TRUE, fillColor = "orange", fillOpacity = 0.2,
                    weight = 3.75, color = "white", opacity = 1) %>%
      addRectangles(lng1 = cell[["xmin"]] + shift, lng2 = cell[["xmax"]] + shift,
                    lat1 = cell[["ymin"]],         lat2 = cell[["ymax"]],
                    fill = FALSE, weight = 1.5, color = "#E4007C", opacity = 1)
  })

  output$text_location <- renderText({
    req(location())
    paste0("You have selected a point at ", format_latlon(location()[1], location()[2], " and "), ".")
  })

  ## ---- data -----------------------------------------------------------

  ## a year of daily Rs, fetched when the user moves to step 2
  dliDataGet <- eventReactive(input$page_23, {
    req(location())
    tryCatch({
      d <- rs_get(location())
      prep_dli(d)   # check now, so a data problem shows as a message, not a broken chart
      d
    }, error = function(e) {
      showNotification(paste("Could not download data from NASA POWER:", conditionMessage(e)),
                       type = "error", duration = 10)
      req(FALSE)
    })
  })

  dliNormalGet <- eventReactive(input$page_34, {
    req(location())
    tryCatch(rs_normal_get(location()), error = function(e) {
      showNotification(paste("Could not download data from NASA POWER:", conditionMessage(e)),
                       type = "error", duration = 10)
      req(FALSE)
    })
  })

  ## ---- charts ---------------------------------------------------------

  output$dliChart1 <- renderPlot(make_chart_1(dliDataGet()), res = 96)

  output$dliChart2 <- renderPlot(make_chart_2(dliNormalGet(), dliDataGet()), res = 96)

  file_stub <- function() {
    loc <- location()
    sprintf("lat%s%s_lon%s%s",
            formatC(abs(loc[1]), digits = 1, format = "f"), ifelse(loc[1] >= 0, "N", "S"),
            formatC(abs(loc[2]), digits = 1, format = "f"), ifelse(loc[2] >= 0, "E", "W"))
  }

  output$dli_chart_3pane <- downloadHandler(
    filename = function() paste0("dli_", file_stub(), ".png"),
    content = function(file) {
      save_chart_3pane(file, dliDataGet(), dliNormalGet(), location(), map_provider())
    }
  )
}
