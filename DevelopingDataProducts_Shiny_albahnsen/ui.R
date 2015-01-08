library(shiny)
shinyUI(pageWithSidebar(
    headerPanel("Credit risk assesment using public datasets"),
    sidebarPanel(
        h4('Introduce the parameters to evaluate the scorecards'),
        sliderInput('age', 'Age',value = 40, min = 18, max = 80, step = 0.5,),
        sliderInput('ncredits', 'Number of credits',value = 1, min = 0, max = 10, step = 1,),
        p(' '),
        checkboxInput("credithist", "Good credit history?", FALSE),
        checkboxInput("marital", "Marital status = Single?", FALSE),
        checkboxInput("residence", "Own house?", FALSE),
        radioButtons("income", "Income level:", c("Low" = 1,"Mid" = 2, "High" = 3)),
        actionButton("goButton", "Random Input")        
    ),
    mainPanel(
        h3('Risk profile'),
        p('Each point represents the estimated risk score using each one of the three databases. 
          The higher the score the lower the risk. From a financial intitution perpective, customers
          with a scorecard lower than 500 is not suitable for a loan.
          '),
        plotOutput('newHist'),
        textOutput('text_score'),
        textOutput('text1'),
        h6('Disclaimer: The information on the Site is provided for educational or information purposes only; 
           it is not intended to be a substitute for an actual credit risk (scorecard) estimator.')
    )
))

