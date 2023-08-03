library(neuralnet)
library(RSNNS)
library(VGAM)
library(yardstick)
library(nnet)
library(caret)
library(e1071)
library(dplyr)

# Establish a value of k
k <- 10

# Create two vectors to store the results of the cross validation
accuracy <- numeric(k)
bal_accuracy <- numeric(k)

# Make a loop of k iterations to create k models
for (i in 1:k) {
  data <- read.csv("output_only_barkibu_breeds.csv", sep=",", header=FALSE) # Read data
  Pheno <- data[, 439] # Last column of the data corresponds to the breed of each dog
  factor_pheno <- as.factor(Pheno)
  Pheno <- as.data.frame(Pheno)
  trainMat <- data[, 1:438]

  # Split the data into training and validation sets
  set.seed(123 + i)  # Change the seed for each fold
  folds <- sample(x = 1:k, size = nrow(trainMat), replace = TRUE)
  trainData <- trainMat[folds != i, ]
  trainPheno <- factor_pheno[folds != i]
  validationData <- trainMat[folds == i, ]
  validationData_pheno <- Pheno[folds==i, ]

  # Train the model on training data
  model <- neuralnet(trainPheno ~ ., data = trainData, hidden = 400, act.fct = "logistic", linear.output = FALSE, stepmax = 1000)
  
  # Performing prediction on validation data
  predicciones <- predict(model, validationData)
  razas_predichas <- apply(predicciones, 1, which.max)
  razas_predichas <- levels(factor_pheno)[razas_predichas]
  
  # Perform balanced accuracy
  etiquetas_reales <- factor(validationData_pheno, levels = levels(as.factor(Pheno$Pheno)))
  etiquetas_predichas <- factor(razas_predichas, levels = levels(as.factor(Pheno$Pheno)))
  bal_accuracy[i] <- bal_accuracy_vec(truth = etiquetas_reales, estimate = etiquetas_predichas, estimator = "micro")
  
  # Perform accuracy
  true_classes <- factor_pheno[folds == i]
  accuracy[i] <- sum(razas_predichas == validationData_pheno) / length(validationData_pheno)
}

# Calculate the mean precision and standard deviation of the cross-validation.
mean_accuracy <- mean(accuracy)
std_accuracy <- sd(accuracy)

mean(bal_accuracy)
sd(bal_accuracy)

grid(lwd=2)
plot(accuracy, pch=16, col="blue", xlab="iteration", ylab="Accuracy", main="Cross-validation Accuracy", ylim= c(0, 1))
lines(accuracy, col="red")

plot(bal_accuracy, pch=16, col="blue", xlab="iteration", ylab="Balanced Accuracy", main="Cross-validation Balanced Accuracy", ylim= c(0, 1))
lines(bal_accuracy, col="red")

# Print the results
cat("Precisión media:", mean_accuracy, "\n")
cat("Desviación estándar de la precisión:", std_accuracy, "\n")