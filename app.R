

source("global.R")

#UI#######################################################################################

ui<-shinyUI(dashboardPage(skin=c("red"),
                          
                          dashboardHeader(title = "Interaktivni portal komasacije u Barandi", titleWidth="100%"),
                          
                          dashboardSidebar(
                            sidebarMenu(
                              
                              fluidPage(
                                
                                uiOutput("menu"),
                                uiOutput("menu1"),
                                uiOutput("menu2")
                                
                                
                              ))
                            
                          ),
                          
                          dashboardBody(
                            
                            tabsetPanel(
                              
                              tabPanel("Mapa",
                                       fluidRow(
                                         column(12, box(height ="auto", width = "auto", solidHeader = FALSE, status = "info",
                                                        leafletOutput("m")%>% withSpinner())),
                                         div(dataTableOutput(head("povrsine_st0")))
                                       )),
                              
                              
                              tabPanel("Statistika",
                                       fluidRow(
                                         
                                         column(12, box(height ="auto", width = "auto", solidHeader = FALSE, status = "info",
                                                        plotlyOutput("pie"),
                                                        plotlyOutput("pie1"))
                                                
                                         ))
                              )
                              
                            )))
)

#SERVER#############################################################


server <- function(input, output, session) { 
  
  
  output$m <- renderLeaflet({
    leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
      htmlwidgets::onRender("function(el, x){L.control.zoom({ position: 'bottomright' }).addTo(this)}") %>%
      
      addTiles(group = "OSM (default)") %>%
      
      setView(lng = 20.495850, lat=45.086297, zoom=12)%>%
      
      addPolygons(data = staro_stanje,
                  weight=0.8, 
                  color= "#ff4d4d", 
                  group = "Staro stanje",
                  label=~broj_parce,
                  popup=~povrsina_p)%>%
      
      addPolygons(data = novo_stanje,
                  weight=0.8, 
                  color= "#1a0000", 
                  group = "Novo stanje",
                  label=~broj_parce)%>%
      
      addMarkers(data = bunari,
                 group = "Bunari",
                 label=~broj_parce)%>%
      
      
      addLayersControl(baseGroups=character(0),
                       overlayGroups =c("Staro stanje","Novo stanje","Bunari"),
                       options = layersControlOptions(collapsed=FALSE)
      )%>%
      
      addFullscreenControl(position="bottomright", 
                           pseudoFullscreen = TRUE)%>%
      
      addMeasure(position = "bottomleft",
                 primaryLengthUnit = "meters",
                 primaryAreaUnit = "sqmeters",
                 activeColor = "#3D535D",
                 completedColor = "#7D4479")%>%
      
      addSearchFeatures(
        targetGroups  = c('Staro stanje','Novo stanje','Bunari'),
        options = searchFeaturesOptions(zoom=15, openPopup=TRUE,firstTipSubmit = TRUE))%>%
      
      addScaleBar(position = c("topleft"), options = scaleBarOptions())
    
    
    
  }) #Zavrsavam renderLeaflet funkciju
  
  
  url <- a("Registar cena", href="http://katastar.rgz.gov.rs/RegistarCenaNepokretnosti/")
  
  output$menu <- renderMenu({
    sidebarMenu(
      h3("Javni registar cena"),
      helpText("Na ovoj stranici mozete pronaci"),
      helpText("javni registar cena u Vasoj "),
      helpText("katastarskoj opstini, izvor:RGZ"),
      helpText(
        url
      )
    )
    
    
  })
  
  output$menu1 <- renderMenu({
    sidebarMenu(
      h3("Kratka statistika"),
      helpText("Broj parcela"),
      helpText("u starom stanju:",broj_parcela_st),
      helpText("Broj parcela "),
      helpText("u novom stanju:",broj_parcela_nv)
      
    )
    
    
  })
  
  output$menu2 <- renderMenu({
    sidebarMenu(
      helpText("Broj ucesnika"),
      helpText("u starom stanju:",stari)
      #helpText("Broj ucesnika "),
      #helpText("u novom stanju:",novi)
      
    )
    
    
  })
  
  output$pie<-renderPlotly({
    
    
    colors <- c('rgb(211,94,96)', 'rgb(128,133,133)', 'rgb(144,103,167)', 'rgb(171,104,87)', 'rgb(114,147,203)','rgb(211,94,50)','rgb(211,35,100)')
    
    plot_ly(razredi_data,labels = ~c(X1_raz,X2_raz,X3_raz,X4_raz,X5_raz,X6_raz,komb), values = ~c(X1_raz,X2_raz,X3_raz,X4_raz,X5_raz,X6_raz,komb), type = 'pie',height="400",
            textposition = 'inside',
            textinfo = 'label',
            insidetextfont = list(color = '#FFFFFF'),
            hoverinfo = 'text',
            text = ~c('Prvi razred','Drugi razred','Treci razred','Cetvrti razred','Peti razred','Sesti razred','Kombinacija'),
            marker = list(colors = colors,
                          line = list(color = '#FFFFFF', width = 1)))%>%
      
      layout(title = 'Broj parcela starog stanja po procembenim razredima',
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
    
  }) 
  
  output$pie1<-renderPlotly({
    
    
    colors <- c('rgb(211,94,96)', 'rgb(128,133,133)')
    
    plot_ly(vlasnistvo_data,labels = ~c(br_staro,br_novo), values = ~c(br_staro,br_novo), type = 'pie',height="400",
            textposition = 'inside',
            textinfo = 'label',
            insidetextfont = list(color = '#FFFFFF'),
            hoverinfo = 'text',
            text = ~c('Vlasnika poseduje parcelu u starom stanju','Vlasnika poseduje parcelu u novom stanju'),
            marker = list(colors = colors,
                          line = list(color = '#FFFFFF', width = 1)))%>%
      
      layout(title = 'Broj vlasnika koji poseduju samo 1 parcelu',
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
    
  }) 
  
  output$povrsine_st0 <- renderDT(
    povrsine_st, # data
    class = "display nowrap compact", # style
    rownames = FALSE,
    width="auto",
    colnames = c('Broj parcele', 'Povrsina parcele'),
    caption = 'Tabela u kojoj mozete proveriti povrsinu Vase parcele pre komasacije'
    
  )
  
  
  
  session$onSessionEnded(function(){
    dbDisconnect(con)
  })
  
  
} #Zavrsavam SERVER 
# Run the application 
shinyApp(ui = ui, server = server)