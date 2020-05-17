#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


#####---------- APP deployment ----------#####
# RUN THE CODE BELOW IN THE CONSOLE
# setwd('<current file path, do not contain this .R file name>')
# library(rsconnect)
# INFORMATION BELOW CAN BE FOUND ON https://www.shinyapps.io/admin/#/tokens
# rsconnect::setAccountInfo(name='<your Rshiny name>',
#                           token='<shinyio.app token>',
#                           secret='<shinyio.app secret>')
# deployApp()

# If everything works alright, after running the line "deployApp()", 
# R will open a tab in the browser. Make sure to remember the URL of that page, 
# as that will be the page that you want to show the students. 
# Every time you change the Qualtrics survey ID, run the app deployment part again, 
# the app will update itself. 

#####---------- API setup ----------#####
# under Qualtrics -> My Account (by clicking the avatar on the top right corner) -> Qualtrics IDs -> API
qualtricAPI <- "<your qualtrics API>"
# Survey -> Distributions -> Anonymous Link -> the last part of the link, usually starting with "SV_"
surveyID <- '<your survey ID>'

# filter criterion
startDateFilter <- as.Date('2020-5-16')

####--------------------------------#####
library(data.table)
library(ggplot2)
library(ggpubr)
library(qualtRics)
library(shiny)
library(plotly)

get_Qualtrics_data <- function() {
    # qualtrics API key
    Sys.setenv(qualtrics_api_key=qualtricAPI)
    Sys.setenv(qualtrics_base_url="https://northwestern.ca1.qualtrics.com")
    readRenviron("~/.Renviron")
    qualtrics_api_credentials(api_key=Sys.getenv("qualtrics_api_key"),
                              base_url=Sys.getenv("qualtrics_base_url"),
                              install = TRUE,
                              overwrite = TRUE
    )%>% qualtRics::fetch_survey(surveyID = surveyID, force_request = TRUE, label=FALSE, convert=FALSE)
}



runProcessing <- function(dat){
    dat <-  get_Qualtrics_data()
    dat <- dat[dat$Status==0,]
    dat <- dat[dat$StartDate > startDateFilter]
    
    # rename column names
    setnames(dat,paste0('Q',8:32,sep=''),paste0('s',1:25,sep=''))
    
    # reverse coding
    dat$s12 <- 6-dat$s12
    dat$s13 <- 6-dat$s13
    dat$s24 <- 6-dat$s24
    
    # summarize
    dat$strategy <- rowMeans(dat[,paste0('s',c(1,2,3,9,17,18,19,21,22,23),sep='')])
    dat$routine <- rowMeans(dat[, paste0('s', c(4,5,6,8,12,15,16,20), sep='')])
    dat$architecture <- rowMeans(dat[,paste0('s',c(5,8,11,13,15),sep='')])
    dat$culture <- rowMeans(dat[, paste0('s',c(5,6,7,9,14,16),sep='')])
    dat$environment <- rowMeans(dat[,paste0('s',c(10,19,24,25),sep='')])
    dat$structure <- rowMeans(dat[,c('routine','architecture','culture')])
    
    # factorize
    dat$gender <- factor(dat$gender, levels=c(1:4),labels=c('Male','Female','Other','Prefer not to say'))
    dat$rank <- factor(dat$rank, levels=c(1:6), labels=c('CEO/President', 'Other C-level executive', 'Non-executive senior manager', 'Middle manager', 'Supervisor', 'Non-management role'))
    dat$industry <- factor(dat$industry, levels=c(1:10), labels=c('Defense', 'Education', 'Manufacturing/Industrial', 'Financial services', 'Healthcare', 'Consumer/Business services', 'Consumer/Business products', 'Utilities', 'Non-profit', 'Public/Goverment'))
    dat$ownership <- factor(dat$ownership, levels=c(1:4), labels=c('Government', 'Non-profit', 'Privately held', 'Publicly traded'))
    dat$tenure <- factor(dat$tenure, levels=c(1:4), labels=c('Less than two', 'Two to five', 'Five to ten', 'More than ten'))
    dat$mkt_power <- factor(dat$mkt_power, levels=c(1:3), labels=c('Low', 'Medium', 'High'))
    dat$dynamism <- factor(dat$dynamism, levels=c(1:3), labels=c('Low','Medium', 'High'))
    
    dat
}


# Define UI for application that draws a histogram
ui<-(pageWithSidebar(
    # title
    headerPanel("Color Options"),
    
    #input
    sidebarPanel
    (
        # Input: Select a file ----

        # Input: Select separator ----
        radioButtons("group", "Group by",
                     choices = c(gender = "gender",
                                 rank = "rank",
                                 industry = "industry",
                                 ownership ='ownership',
                                 tenure = 'tenure',
                                 market_power = 'mkt_power',
                                 dynamism  = 'dynamism'
                                 ),
                     selected = "gender"),
        # Horizontal line ----
        tags$hr()
    ),
    
    # output
    mainPanel(
        #h3(textOutput("caption")),
        #h3(htmlOutput("caption")),
        plotlyOutput("p") # depends on input
    )
))


# Define server logic required to draw a histogram
server <- function(input, output){
    
    dat <- get_Qualtrics_data()
    dat <- runProcessing(dat)
    
    # output$plot <- renderUI({
    #     plotOutput("p")
    #     })
    
    # output$caption<-renderText({
    #     switch(input$group,
    #            "gender"= "Gender",
    #            "rank" =	"Rank"
    # })
    
    get_data<-reactive({
        obj<-list(group=input$group)
        obj
    })
    
    output$p <- renderPlotly({
        
        plot.obj<-get_data()
        
        p<-ggplot(dat, aes_string(x = "structure", y = "strategy", color=plot.obj$group)) + 
            geom_point(aes(text=paste('Name:',Q1))) + 
            geom_abline(intercept=0,slope=1,color='red') + 
            labs(x='Structure',y='Strategy') +
            xlim(0,5) +
            ylim(0,5) + 
            coord_fixed(ratio=1) +
            theme_minimal()
        
        ggplotly(p, height=500)
    })
}

shinyApp(ui = ui, server = server)
    


