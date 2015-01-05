library(shiny)
shinyUI(pageWithSidebar(
    headerPanel("Credit risk assesment using public datasets"),
    sidebarPanel(
        sliderInput('age', 'Age',value = 40, min = 18, max = 80, step = 0.5,),
        sliderInput('ncredits', 'Number of credits',value = 1, min = 0, max = 10, step = 1,),
        p(' '),
        checkboxInput("credithist", "Good credit history", FALSE),
        checkboxInput("marital", "marital", FALSE),
        checkboxInput("residence", "residence", FALSE),
        radioButtons("income", "Income:", c("Low" = 1,"Mid" = 2, "High" = 3)),
        actionButton("goButton", "Random Client")        
    ),
    mainPanel(
        p('Predicted risk'),
        plotOutput('newHist'),
        textOutput('text1')
    )
))

