# This is the ui.R file 

wd <- getwd()
setwd(wd)
library(shiny)
library(ggplot2)
library(rstan)
# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("
               Specification Limit Calculator"),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      tags$head(tags$style(type="text/css", "
             #loadmessage {
               position: fixed;
               top: 0px;
               left: 0px;
               width: 100%;
               padding: 0px 0px 0px 0px;
               text-align: center;
               font-size: 100%;
               color: #ffffff;
               background-image: linear-gradient(to right, #118349 , #345275);
               z-index: 105;
             }
             .shiny-output-error { visibility: hidden; }
             .shiny-output-error:before { visibility: hidden; }
          ")),
      
      conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                       tags$div("Simulation is currently running, please wait for results",id="loadmessage")),
      
      actionButton("do", "Calculate Spec Limits"),
      
      # textInput("PriorMean", "Prior Mean", 0), 
      # textInput("PriorSd", "Prior Standard Deviation", 1),
      
      helpText("Please enter the sample data below.", 
               "Each value MUST be separated by a comma."),
      textInput("dat", "Sampled Data"), 
      sliderInput("cpk", "Please select a CPK", min=1.0, max=3.0, value=1.33, step=0.01),
      
      h4("Assumptions to be aware of before using the Spec Limit Calculator:"),
      h6("Use of this spec limit calculator means that you are assuming the distribution of the data for which you are setting a spec limit is 
               normal. It is also key to note that a proper and well performed sampling of data was conducted. More data is always one of the best, if not
               the best way, to improve the accuracy of the spec limits. However, this tool can be used to calculate spec limits from a smaller sample size
               if necessary.")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      h3("How to use the Specification Limit Calculator:"), 
      h5("1. Input the sample data, with each data point being separated by a comma. If using historical or a larger dataset please omit outliers."),
      h5("2. Click on the 'Calculate Spec Limits' button to begin the simulation"),
      h5("It will take a minute or two to run the simulation and produce the spec limits."),
      h5("Once the simulation is complete, you can adjust the CPK slider to update the spec limits."),
      plotOutput("plot")
    )
  )
))
