

library(neuralnet)
library(RSNNS)
library(VGAM)
library(yardstick)
library(nnet)
library(caret)
library(e1071)
library(dplyr)

# Create vectors to store accuracy and balanced accuracy
accuracy <- numeric(10) 
bal_accuracy <- numeric(10)
x_values <- c(50, 100, 150, 200, 250, 300, 350, 400, 450, 500) # Create the vector of values of hidden neurons


for (i in 1:10){ 
  data <- read.csv("output_only_barkibu_breeds.csv", sep=",", header=FALSE) # Read CSV file
  
  Pheno <- data[, 439] # Last column of the file corresponds to the breed of the sample
  Pheno <- as.data.frame(Pheno)
  
  test_size <- 0.1 # Establish the percentage of samples that are going to be used for test
  
  # Dividing data in train and test sets
  set.seed(123)  # Establecer seed
  test_indices <- createDataPartition(y = 1:nrow(data), p = test_size, list = FALSE)
  
  # Create train and test sets
  train_data <- data[-test_indices, ]
  test_data <- data[test_indices, ]
  train_pheno <- Pheno[-test_indices, ]
  test_pheno <- Pheno[test_indices, ]
  
  # Eliminate the last column (breed), in the trainMat and testMat
  trainMat <- train_data[, 1:438]
  testMat <- test_data[, 1:438]
  
  # Factor phenotype table
  factor_pheno <- as.factor(train_pheno)
  
  # Create the model
  model <- neuralnet(factor_pheno ~ ., data=trainMat, hidden = x_values[i], act.fct = "logistic", linear.output = FALSE, stepmax = 1000)
  
  # Perform prediction in test data
  predicciones <- predict(model, trainMat)
  razas_predichas <- apply(predicciones, 1, which.max)
  razas_predichas <- levels(factor_pheno)[razas_predichas]
  accuracy[i] <- mean(razas_predichas == train_pheno)
  
  # Perform balanced accuracy
  etiquetas_reales <- factor(train_pheno, levels = levels(as.factor(Pheno$Pheno)))
  etiquetas_predichas <- factor(razas_predichas, levels = levels(as.factor(Pheno$Pheno)))
  bal_accuracy[i] <- bal_accuracy_vec(truth = etiquetas_reales, estimate = etiquetas_predichas, estimator = "micro")
}


# Plot the values obtained
grid(lwd=2)
plot(x=x_values, y=accuracy, pch=16, col="blue", xlab="Hidden Neurons", ylab="Accuracy", main="Accuracy of the model for training data", ylim= c(0, 1))
lines(x_values, accuracy, col="red")
plot(x=x_values, y=bal_accuracy, pch=16, col="blue", xlab="Hidden Neurons", ylab="Balanced Accuracy", main="Balanced Accuracy of the model for training data", ylim= c(0, 1))
lines(x_values, bal_accuracy, col="red")