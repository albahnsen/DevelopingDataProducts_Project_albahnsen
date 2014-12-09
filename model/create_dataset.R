# Code to prepare the datasets for the prediction algorithms
# 3 different credit scoring datasets are used:
#   German credit (http://archive.ics.uci.edu/ml/datasets/Statlog+%28German+Credit+Data%29)
#   Kaggle Credit (http://www.kaggle.com/c/GiveMeSomeCredit)
#   PAKDD Credit  (http://sede.neurotech.com.br:443/PAKDD2009/)
#
# Only the features present in all the datasets are selected
# Final dataset structure:
# F0 (cat)  Dataset                = (G:0, K:1, P:2)
# F1 (bool) Perfect credit history = (G:A30=1, K:(x3+x10+x7=0), P:0)
# F2 (num)  Age                    = (G:A13, K:x2, P:AGE)
# F3 (num)  Number of credits      = (G:A16, K:(x6+x9), P:(OTHER_CARD + QUANT_B))
# F4 (bool) Marital Status Single  = (G:(A93+A95), K:X11=0, P:MARITAL_STATUS = S)
# F5 (cat)  Recidence type         = (G:A15, K:0, P:RESIDENCE_TYPE)
# F6 (num)  Income Range (H, M, L) = (G:A6, K:x5, P:PERSONAL_NET_INCOME)
# Y  (bool) Default                = (G:last, K:SeriousDlqin2yrs, P:TARGET_LABEL_BAD)
# 
# 
# Authors: Alejandro Correa Bahnsen <al.bahnsen@gmail.com>
# License: BSD 3 clause


