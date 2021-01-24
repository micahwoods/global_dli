# ui

ui <- (fluidPage( 
  
  tags$script(HTML(
    "document.body.style.backgroundColor = '#f7ffed';"
  )),
  
  tabsetPanel(
  id = "user_flow",
  type = "hidden",
  tabPanel("tab1", 
           
           h2("This app shows recent DLI at any location"),
           
           "See details, data sources, and technical background at the ", 
           actionLink("page_15", "app details"), 
           " page.",
           
           p("You can select a location on the map to highlight the encompassing 0.5° x 0.5° grid.  Is there a place you'd like to check?"),
           
  
  actionButton("page_12", "Choose a location", icon("globe-americas"), style = atc_style)
  ),
  
  tabPanel("tab2",
           
           tags$h4("Step 1"),
           
          p("Find the location on the map you'd like to check. Click the map to mark the location. A yellow rectangle will appear over the 0.5° x 0.5° grid that includes this location."),
        
           leafletOutput("map"),
          
          textOutput("text_location"),
           
           p("Global solar irradiance data are then obtained from the NASA POWER agroclimatology dataset and are converted to DLI."),
           
           actionButton(inputId = "page_23", " Get DLI data", icon("chart-bar"), style = atc_style),
          
          actionButton(inputId = "page_21", "Back to start", icon("play-circle"), style = atc2_style)
           ),
  
  tabPanel("tab3",
           
           tags$h4("Step 2"),
           
           "View the chart for the grid we've looked at.",
           
           dataTableOutput("row1"),
           
           plotOutput("dliChart1"),
           
           "Would you like to download this chart?",
           
           downloadButton("dli_chart_pane1", label = "Download chart", style = atc2_style),
           
           actionButton(inputId = "page_34", " See monthly normal DLI", icon("calendar-check"), style = atc_style),
           
           actionButton("page_32", "Check another location", icon("globe-americas"), style = atc2_style),
           
           actionButton("page_31", "Back to start",  icon("play-circle"), style = atc2_style)
           ),
  
  tabPanel("tab4",
           
           "Here's monthly and normal.",
           
           tableOutput("click_loc_test"),
           
           "There's supposed to be a test text above here if the event reactive happened.",
           
           dataTableOutput("monthly"),
           
           plotOutput("dliChart2"),
           
           actionButton("page_42", "Check another location", icon("globe-americas"), style = atc2_style),
      
           actionButton("page_45", "App details", icon("info"), style = atc_style),
           
           actionButton("page_41", "Back to start",  icon("play-circle"), style = atc2_style)
  ),
  
  tabPanel("tab5",  
           includeMarkdown("dli_details.md"),
           actionButton("page_51", "Back to start", icon("play-circle"), style = atc_style)
           )

           
           )
      )
)
  
