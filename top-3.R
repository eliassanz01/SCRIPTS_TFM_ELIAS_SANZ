library(neuralnet)
library(RSNNS)
library(VGAM)
library(yardstick)
library(nnet)
library(caret)
library(e1071)
library(dplyr)

data <- read.csv("output_only_barkibu_breeds.csv", sep=",", header=FALSE) # Read the data

Pheno <- data[, 439] # Last column of the data corresponds to the breed of each dog
Pheno <- as.data.frame(Pheno)

test_size <- 0.1 # Establish the percentage of samples that are going to be used for test


set.seed(123)  # Establish seed

# Create train and test subsets

test_indices <- createDataPartition(y = 1:nrow(data), p = test_size, list = FALSE) 

train_data <- data[-test_indices, ]
test_data <- data[test_indices, ]
train_pheno <- Pheno[-test_indices, ]
test_pheno <- Pheno[test_indices, ]

# Delete the last column (corresponding to breed)
trainMat <- train_data[, 1:438]
testMat <- test_data[, 1:438]

# Factorize phenotypes table
factor_pheno <- as.factor(train_pheno)

# Create the model
model <- neuralnet(factor_pheno ~ ., data=trainMat, hidden = 100, act.fct = "logistic", linear.output = FALSE, stepmax = 1000)

# Make prediction with probabilities
probabilidades <- predict(model, testMat, type = "prob")

razas_disponibles <- levels(factor_pheno)



# Show three most probable breeds in each prediction, and check if any of them is the real one
correct_predictions <- 0
all_predictions <- 0

for (i in 1:nrow(probabilidades)) {
  pred_prob <- probabilidades[i, ]
  top_3_indices <- order(pred_prob, decreasing = TRUE)[1:3]
  top_3_razas <- razas_disponibles[top_3_indices]
  top_3_porcentajes <- round(pred_prob[top_3_indices] * 100, 2)
  
  cat("Predicción", i, ":\n")  
  for (j in 1:length(top_3_razas)) {
    cat(top_3_razas[j], ": ", top_3_porcentajes[j], "%\n")
  }
  cat("Real pheno: ", test_pheno[i], "\n")
  cat("\n")
  all_predictions <- all_predictions + 1
  if (test_pheno[i] %in% top_3_razas) {
    correct_predictions <- correct_predictions + 1
  }
}

# Compute accuracy
accuracy <- correct_predictions / all_predictions

accuracy