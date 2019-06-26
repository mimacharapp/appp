#######################################################################################################################33
#IMPORTED LIBRARIES
library(leaflet)
library(shinyWidgets)
library(shiny)
library(shinythemes)
library(leaflet.extras)
library(htmlwidgets)
library(maptools)
library(sp)
library(rgdal)
library(shinycssloaders)
library(shinydashboard)
library(rsconnect)
library(jsonlite)
library(rjson)
library(RJSONIO)
library(rhandsontable); 
library(colourpicker)
library(htmlTable)
library(geojsonio)
library(RPostgreSQL)
library(dbplyr)
library(rpostgis)
library(plotly)
library(DT)

############################################################################################


loadingLogo <- function(href, src, loadingsrc, height = NULL, width = NULL, alt = NULL) {
  tagList(
    tags$head(
      tags$script(
        "setInterval(function(){
        if ($('html').attr('class')=='shiny-busy') {
        $('div.busy').show();
        $('div.notbusy').hide();
        } else {
        $('div.busy').hide();
        $('div.notbusy').show();
        }
},100)")
    ),
    tags$a(href=href,
           div(class = "busy",  
               img(src=loadingsrc,height = height, width = width, alt = alt)),
           div(class = 'notbusy',
               img(src = src, height = height, width = width, alt = alt))
    )
    )
  }

#############################################################################################
#Ubacujem slojeve

bunari<- geojson_read("bunari_wgs84.geojson", what = "sp")

#######

staro_stanje<- geojson_read("staro_stanje_wgs84.geojson", what = "sp")

#######

novo_stanje<- geojson_read("novo_stanje_wgs84.geojson", what = "sp")


###############################################################################

con <- dbConnect(dbDriver("PostgreSQL"),
                 host = "localhost",
                 dbname = "postgis_25_sample",
                 user = "postgres",
                 password = "postgres",
                 port = 5432)

#on.exit(dbDisconnect(con))

###############################################################################

#broj_parcela_st<-c(dbGetQuery(con,
#"SELECT COUNT(id_parcela)
#FROM parcele_operat_staro
#WHERE sifra_reona='K';"))

#broj_parcela_nv<-c(dbGetQuery(con,
#"SELECT COUNT(id)
#FROM parcele_novo;"))


################################################################################


#stari<-c(dbGetQuery(con,
#"SELECT COUNT (id_ucesnik)
#FROM ucesnik;"))

#novi<-c(dbGetQuery(con,
#"SELECT COUNT (id_ucesnik)
#FROM public.ucesnik;"))



#############################################################################################3
razredi_stst = read.csv("razredi_staro_stanje.csv", header = TRUE, sep =';' )
#head(razredi_stst)
razredi_data0<-data.frame("staro_stanje0" = rownames(razredi_stst),razredi_stst)
#View(razredi_data0)

razredi_data <- razredi_data0[c('staro_stanje0','X1_raz','X2_raz','X3_raz','X4_raz','X5_raz','X6_raz','komb')]
#View(razredi_data)

###################################################################################################3
vlasnistvo_stst = read.csv("vlasnistvo_1_1_1.csv", header = TRUE, sep =';' )
#head(vlasnistvo_stst)
vlasnistvo_data0<-data.frame("vlasnistvo_1_parcele" = rownames(vlasnistvo_stst),vlasnistvo_stst)
#View(vlasnistvo_data0)

vlasnistvo_data<- vlasnistvo_data0[c('vlasnistvo_1_parcele','br_staro','br_novo')]
#View(vlasnistvo_data)


################################################################################################

povrsine_st<-read.csv("povrsine_st.csv",header = TRUE, sep =';' )
#View(povrsine_st)