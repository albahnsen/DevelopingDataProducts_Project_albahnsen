# Code to prepare the create the prediction algorithms for each dataset
# Authors: Alejandro Correa Bahnsen <al.bahnsen@gmail.com>
# License: BSD 3 clause

# require(caret)
# library(doParallel)
# registerDoParallel(cores=4)

library(randomForest)

load('DevelopingDataProducts_Shiny_albahnsen/datasets.Rda')

# Evaluate a random forest per each set
cla <- vector("list", 3)
for (i in 0:2){
    data.temp = data[data$set == i, -1]
    cla[[i+1]] <- randomForest(factor(default) ~ ., data.temp, 
                               ntree=500, mtry = ceiling(ncol(data.temp)^0.5))
}

save(cla, file='DevelopingDataProducts_Shiny_albahnsen/models.Rda')


# Prediction Function

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

library(randomForest)
load('DevelopingDataProducts_Shiny_albahnsen/datasets.Rda')
load('DevelopingDataProducts_Shiny_albahnsen/models.Rda')

# Evaluate the whole dataset
p_hat <- predict_all(cla, data[,c(-1, -8)])

library(ggplot2)
library(reshape2)

ggplot(melt(p_hat), aes(value, colour=variable)) + geom_density(alpha=.9)


# Create distribution

test = data[c(20080),c(-1, -8)]
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

ggplot() + 
    geom_point(data=df2, aes(x=p_hat, y=pdist), colour='turquoise4', size=3) +
    geom_line(data=df, aes(x=p_hat, y=pdist), colour='firebrick4') + 
    geom_vline(xintercept = mean(x), size=1.5, colour='grey44') +
    geom_vline(xintercept = 0.5, linetype="dashed")


