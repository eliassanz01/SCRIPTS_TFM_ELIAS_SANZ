library(neuralnet)
library(RSNNS)
library(VGAM)
library(yardstick)
library(nnet)
library(caret)
library(e1071)
library(dplyr)

data <- read.table("all_snps_only_barkibu_breeds.csv", sep=",", header = FALSE) # Read the data

data2 <- read.csv("output_only_barkibu_breeds.csv", sep=",", header=FALSE) # We read the othe file to extract the breeds

Pheno <- data2[, 439] # Extract breeds
Pheno <- as.data.frame(Pheno)

# Create vectors to store accuracy and balanced accuracy
accuracy <- numeric(100)
b_accuracy <- numeric(100)

levels_pheno <- levels(as.factor(Pheno$Pheno))

# Create a loop of 100 iterations randomly selecting SNPs from data 
for (i in 1:100){
  set.seed(123+i)  # Establecer seed
  snps <- sample(data, size=438) # Select randomly 438 SNPs
  
  test_size <- 0.1 # Establish the percentage of samples that are going to be used for test
  
  # Dividing data in train and test sets
  test_indices <- createDataPartition(y = 1:nrow(snps), p = test_size, list = FALSE)
  
  # Create train and test sets
  train_data <- snps[-test_indices, ]
  test_data <- snps[test_indices, ]
  
  train_pheno <- Pheno[-test_indices, ]
  test_pheno <- Pheno[test_indices, ]
  
  factor_pheno <- as.factor(train_pheno)
  
  # Create the model
  model <- neuralnet(factor_pheno ~ ., data=train_data, hidden = 400, act.fct = "logistic", linear.output = FALSE, stepmax = 1000)

  
  # <Make prediction
  predicciones <- predict(model, test_data)
  razas_predichas <- apply(predicciones, 1, which.max)
  razas_predichas <- levels(factor_pheno)[razas_predichas]
  
  # Compute accuracy
  accuracy[i] <- mean(razas_predichas == test_pheno)
  
  # Compute balanced accuracy
  etiquetas_reales <- factor(test_pheno, levels = levels(as.factor(Pheno$Pheno)))
  etiquetas_predichas <- factor(razas_predichas, levels = levels(as.factor(Pheno$Pheno)))
  b_accuracy[i] <- bal_accuracy_vec(truth = etiquetas_reales, estimate = etiquetas_predichas, estimator = "micro")
  
}

# Plot the results
histogram(b_accuracy)
histogram(accuracy)
