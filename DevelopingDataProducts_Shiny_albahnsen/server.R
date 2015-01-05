library(shiny)
library(ggplot2)
library(reshape2)
library(randomForest)

predict_all <- function(classifiers, x){
  n_classifiers <- length(classifiers)
  n_obs <- dim(x)[1]
  p_hat <- data.frame(matrix(data=NA, nrow = n_obs, ncol = n_classifiers))
  colnames(p_hat) <- c('M1','M2','M3')
  
  for(i in 1:n_classifiers){
    p_hat[, i] <- predict(classifiers[[i]], x, type='prob')[,1]
  }
  return (p_hat)
}

load('datasets.Rda')
load('models.Rda')

accept <<- 'init'

shinyServer(
    function(input, output) {
        output$newHist <- renderPlot({
          
          test = data[c(1),c(-1, -8)]
          test$age = input$age
          test$ncredits = input$ncredits
          test$credithist = as.integer(input$credithist)
          test$income = input$income
          test$marital = input$marital
          test$residence = input$residence
          
          # TODO: Add random user
          #input$goButton
          #  isolate(test = data[c(20080),c(-1, -8)])

          p_test <- predict_all(cla, test)
          
          x <- melt(p_test)$value
          xfit <-seq(0,1,length=1000)
          hx <- dnorm(xfit,mean=mean(x),sd=sd(x))
          df <- data.frame(xfit, hx)
          colnames(df) <- c('p_hat', 'pdist')
          
          # Create points from models and average
          hx2 <- dnorm(x,mean=mean(x),sd=sd(x))
          df2 <- data.frame(x, hx2)
          colnames(df2) <- c('p_hat', 'pdist')
          
          # Adjust output
          if (mean(x) <= 0.5) accept <<- "Decline Client"
          else accept <<- "Accept Client"

          # Create Plot
            ggplot() + 
                geom_point(data=df2, aes(x=p_hat, y=pdist), colour='turquoise4', size=3) +
                geom_line(data=df, aes(x=p_hat, y=pdist), colour='firebrick4') + 
                geom_vline(xintercept = mean(x), size=1.5, colour='grey44') +
                geom_vline(xintercept = 0.5, linetype="dashed")
        })
        output$text1 <- renderPrint({          
            
            # Regardless of the change variable update accept
            test = input$age
            test = input$ncredits
            test = as.integer(input$credithist)
            test = input$income
            test = input$marital
            test = input$residence
                                     
            accept
        })
        
    }
)


# shinyServer(
#     function(input, output) {
#         output$newHist <- renderPlot({
#             hist(galton$child, xlab='child height', col='lightblue',main='Histogram')
#             mu <- input$mu
#             lines(c(mu, mu), c(0, 200),col="red",lwd=5)
#             mse <- mean((galton$child - mu)^2)
#             text(63, 150, paste("mu = ", mu))
#             text(63, 140, paste("MSE = ", round(mse, 2)))
#         })
#         
#     }
# )
