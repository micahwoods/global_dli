# ui

ui <- (fluidPage( 
  
  tags$head(includeHTML(("google_analytics.html"))),
  
  
  
  tags$script(HTML(
    "document.body.style.backgroundColor = '#f7ffed';"
  )),
  
  tags$head(tags$style(
    HTML('
         #sidebar {
            background-color: #f7ffed;
        }

        '))),
  
  tags$script('
              $(document).ready(function () {
              navigator.geolocation.getCurrentPosition(onSuccess, onError);
              
              function onError (err) {
              Shiny.onInputChange("geolocation", false);
              }
              
              function onSuccess (position) {
              setTimeout(function () {
              var coords = position.coords;
              console.log(coords.latitude + ", " + coords.longitude);
              Shiny.onInputChange("geolocation", true);
              Shiny.onInputChange("lat", coords.latitude);
              Shiny.onInputChange("long", coords.longitude);
              }, 1100)
              }
              });
              '),
  
  shinyFeedback::useShinyFeedback(),
  
  # useShinyjs(),
  
  titlePanel("DLI anywhere: daily light integral at any location"),

sidebarLayout(
    sidebarPanel(width = 2,
                 
                 id = "sidebar",
                 
                 actionButton(inputId = "restart", " Back to start", icon("play-circle"), style = atc2_style),
                 
                 p(),
                 
                 actionButton("details", " App details", icon("info"), style = atc2_style),
                 
                 p(),
                 
                 actionButton("par_atc", "PAR info @ ATC", icon("cloud-sun"), style = atc2_style,
                              onclick = "window.open('https://www.asianturfgrass.com/tag/light/', '_blank')"),
                 
                 p(),
                 
                 a(href = "https://www.asianturfgrass.com", 
                   img(src = "atc.png", height = 80))
                 
                 ),
mainPanel(width = 10,
  tabsetPanel(
  id = "user_flow",
  type = "hidden",
  tabPanel("tab1", 
           
           p("This app allows you to select a point on the map, and then shows the past year of photosynthetically active radiation (PAR) for that location. The PAR is expressed as daily totals, or as monthly averages, of the daily light integral (DLI)."),
           
           tags$ul(
             tags$li("Quick app summary: generates a summary chart of PAR for the past year at any location."), 
             tags$li("This app gets satellite data of global solar radiation on 0.5° latitude by 0.5° longitude grid from the",
                     a("NASA POWER Agroclimatology dataset", href="https://power.larc.nasa.gov/docs/methodology/communities/ag/"),
                     "using the",
                     tags$code(tags$a("nasapower", href='https://docs.ropensci.org/nasapower/index.html')),
                     "R package by",
                     a("Adam Sparks.", href="https://twitter.com/adamhsparks")), 
             tags$li("See full details, data sources, and more technical information on the",  actionLink("page_15", "app details"), "page.")
             ),
             
          tags$h4("Getting started"),
          
          p("The green buttons are the recommended flow through the app. First you'll choose a location on the map, then obtain DLI data for that area. At the end, you'll be able to download a summary chart for the location you've selected."),
          
          p("Is there a place you'd like to check? Let's get started."),
          
          tags$h4("Step 1"), 
          
          p("Find the location on the map you'd like to check. Click the map at that point to mark the location. A transparent orange rectangle will appear over the 0.5° x 0.5° grid that includes this location."),
          
          leafletOutput("map"),
          
       #   uiOutput('file1_ui'),
          
          tags$strong(textOutput("text_location")),
          
          p("Click the button below to download satellite data for that location."),
          
          actionButton(inputId = "page_23", " Get DLI data", icon("chart-bar"), style = atc_style),
          
          br()
          
  ),
           
#  actionButton("page_12", "See map", icon("globe-americas"), style = atc_style)
 # ),
  
 # tabPanel("tab2",
  
  tabPanel("tab3",
           
           tags$h4("Step 2"),
           
           p("This chart shows the past year of DLI. You'll be able to download a formatted version of this chart on the next page."),
           
           withSpinner(plotOutput("dliChart1"), color = "#3f7300"),
           
           p("Now check the normal DLI for this location."),
           
           actionButton(inputId = "page_34", " See monthly normal DLI", icon("calendar-check"), style = atc_style)
          
           ),
  
  tabPanel("tab4",
           
           tags$h4("Step 3"),
           
           p("This is the climatological normal DLI for this location, and the past year's actual DLI."), 
         
           withSpinner(plotOutput("dliChart2"), color = "#3f7300"),
           
           downloadButton("dli_chart_3pane", label = "Download DLI chart", style = atc_style)
    
  ),
  
  tabPanel("tab5",  
           includeMarkdown("dli_details.md"),
           actionButton(inputId = "page_51", "Back to start", icon("play-circle"), style = atc_style)
           )

           
           )
      )

),
hr(),
tags$small(paste("Last updated on", today(), "by Micah Woods"))
)
)