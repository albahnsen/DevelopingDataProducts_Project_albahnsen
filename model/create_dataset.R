# Code to prepare the datasets for the prediction algorithms
# 3 different credit scoring datasets are used:
#   German credit (http://archive.ics.uci.edu/ml/datasets/Statlog+%28German+Credit+Data%29)
#   Kaggle Credit (http://www.kaggle.com/c/GiveMeSomeCredit)
#   PAKDD Credit  (http://sede.neurotech.com.br:443/PAKDD2009/)
#
# Only the features present in all the datasets are selected
# Final dataset structure:
# F0 (cat)  Dataset                = (G:2, K:1, P:0)
# F1 (bool) Perfect credit history = (G:A30=1, K:(x3+x10+x7=0), P:0)
# F2 (num)  Age                    = (G:A13, K:x2, P:AGE)
# F3 (num)  Number of credits      = (G:A16, K:(x6+x9), P:(OTHER_CARD + QUANT_B))
# F4 (bool) Marital Status Single  = (G:(A93+A95), K:X11=0, P:MARITAL_STATUS = S)
# F5 (cat)  Residence type         = (G:A15, K:0, P:RESIDENCE_TYPE)
# F6 (num)  Income Range (H, M, L) = (G:A6, K:x5, P:PERSONAL_NET_INCOME)
# Y  (bool) Default                = (G:last, K:SeriousDlqin2yrs, P:TARGET_LABEL_BAD)
# 
# 
# Authors: Alejandro Correa Bahnsen <al.bahnsen@gmail.com>
# License: BSD 3 clause

library(ROSE)

####### PAKDD DATASET #########################################################

# Load and return the credit scoring Kaggle Credit competition dataset
data0 <- read.table(gzfile("data/creditscoring2.csv.gz"), sep="\t", header=TRUE)
# Keep only compleate cases
data0$X <- NULL
data0 <- data0[complete.cases(data0),]
data0 <- data0[data0$TARGET_LABEL_BAD.1 != 'N', ]
nrows <- nrow(data0)

# Create empty dataset
data0.new <- data.frame(matrix(data=NA, nrow = nrows, ncol = 8))
colnames(data0.new) <- c('set', 'credithist', 'age', 'ncredits', 'marital', 'residence', 'income', 'default')

# Fill features og KAggle set
data0.new$set <- 0
data0.new$credithist <- 0
data0.new$age <- data0$AGE
data0.new$ncredits <- data0$QUANT_BANKING_ACCOUNTS + (data0$FLAG_OTHER_CARD == 'Y')
data0.new$marital <- (data0$MARITAL_STATUS == 'S') * 1
temp_ <- rank(data0$PERSONAL_NET_INCOME, ties.method='first') # <- this forces tie breaks
data0.new$income <- cut(temp_, breaks = quantile(temp_,probs= c(seq(0,1,0.3334),1)),
                        include.lowest=TRUE, right=FALSE, labels = FALSE)
data0.new$default <- (data0$TARGET_LABEL_BAD.1 == 1) * 1
data0.new$residence <- (data0$RESIDENCE_TYPE == 'P') * 1

# Undesampling since nrows is high
table(data0.new$default)
data0.balanced <- ovun.sample(default~., data=data0.new, p=0.5, seed=1, method="under")$data
table(data0.balanced$default)


####### KAGGLE DATASET #########################################################

# Load and return the credit scoring Kaggle Credit competition dataset
data1 <- read.table(gzfile("data/creditscoring1.csv.gz"), sep=",", header=TRUE)
# Keep only compleate cases
data1 <- data1[complete.cases(data1),]
nrows <- nrow(data1)

# Create empty dataset
data1.new <- data.frame(matrix(data=NA, nrow = nrows, ncol = 8))
colnames(data1.new) <- c('set', 'credithist', 'age', 'ncredits', 'marital', 'residence', 'income', 'default')

# Fill features og KAggle set
data1.new$set <- 1
data1.new$credithist <- 0
filter_ <- data1$NumberOfTime30.59DaysPastDueNotWorse + 
    data1$NumberOfTime60.89DaysPastDueNotWorse + 
    data1$NumberOfTimes90DaysLate > 1
data1.new$credithist[filter_] <- 1
data1.new$age <- data1$age
data1.new$ncredits <- data1$NumberOfOpenCreditLinesAndLoans + data1$NumberRealEstateLoansOrLines
data1.new$marital <- (data1$NumberOfDependents == 0) * 1
temp_ <- rank(data1$MonthlyIncome, ties.method='first') # <- this forces tie breaks
data1.new$income <- cut(temp_, breaks = quantile(temp_,probs= c(seq(0,1,0.3334),1)),
                       include.lowest=TRUE, right=FALSE, labels = FALSE)
data1.new$default <- data1$SeriousDlqin2yrs
data1.new$residence <- 0

# Undesampling since nrows is high
data1.balanced <- ovun.sample(default~., data=data1.new, p=0.5, seed=1, method="under")$data


####### GERMAN DATASET #########################################################

# Load and return the credit scoring Kaggle Credit competition dataset
data2.cat <- read.table("data/german.data")
data2.con <- read.table("data/german.data-numeric")

nrows <- nrow(data2.cat)

# Create empty dataset
data2.new <- data.frame(matrix(data=NA, nrow = nrows, ncol = 8))
colnames(data2.new) <- c('set', 'credithist', 'age', 'ncredits', 'marital', 'residence', 'income', 'default')

# Fill features og KAggle set
data2.new$set <- 2
data2.new$credithist <- (data2.cat$V3 == 'A30') * 1
data2.new$age <- data2.con$V10
data2.new$ncredits <- data2.con$V12
data2.new$marital <- (data2.cat$V9 == 'A93' | data2.cat$V9 == 'A95') * 1
data2.new$income <- 1
data2.new$income[data2.cat$V1 == 'A12'] <- 2
data2.new$income[data2.cat$V1 == 'A13'] <- 3

data2.new$default <- (data2.cat$V21 == 2) * 1
data2.new$residence <- (data2.cat$V15 == 'A152') * 1

# Undesampling and Oversampling
table(data2.new$default)
data2.balanced <- ovun.sample(default~., data=data2.new, p=0.5, seed=1, N=10000, method="both")$data
table(data2.balanced$default)

############## JOIN DATASETS ######################
data <- rbind(data0.balanced, data1.balanced, data2.balanced)
save(data, file='model/datasets.Rda')
