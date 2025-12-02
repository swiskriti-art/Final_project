library(tidymodels)
library(tidyverse)
library(plumber)
library(ggplot2)

#Read our final model
model <- readRDS(file = "final_model.RDS")
diabetes_bin <- readRDS(file = "diabetes_bin.RDS")


#* API endpoint info
#* @get /info

function() {
  list(Name = "Sushila Dawadi",
       URL = "") # Add github pages
}

#* API endpoint for diabetes prediction "pred"
#* @param BMI Body mass index
#* @param Age Age "18-24", "25-29", "30-34", "35-39", "40-44","45-49","50-54","55-59","60-64","65-69","70-74","75-79",">=80"
#* @param Sex Sex "Male"/"Female"
#* @param PhysActivity Physical activity in past 30 days  "Yes"/"No"
#* @param HighChol "High colesterol"/"No high colesterol"
#* @param GenHlth "Excellent","Very good","Good","Fair", "Poor"
#* @get /pred
function(BMI = 28.38, Age = "60-64" , Sex = "Female", PhysActivity = "Yes", HighChol = "No high colesterol", GenHlth = "Very good") {
  bmi <- as.numeric(BMI)
  new_data <- as_tibble(data.frame(BMI = c(bmi), Age = c(Age), Sex = c(Sex), PhysActivity = c(PhysActivity), HighChol = HighChol, GenHlth = GenHlth))
  predict(model, new_data)
}

#example API calls for the pred endpoint
#http://127.0.0.1:29602/pred
#http://127.0.0.1:29602/pred?BMI=30&Age=55-59&Sex=Female&PhysActivity=No&HighChol=High%20colesterol&GenHlth=Poor
#http://127.0.0.1:29602/pred?BMI=35&Age=55-59&Sex=Male&PhysActivity=No&HighChol=High%20colesterol&GenHlth=Good

#* API endpoint to get a confusion matrix plot of the fitted model
#* @serializer png
#* @get /confusion
function() {
  preds <- predict(model, new_data = diabetes_bin, type = "class")
  cf <- conf_mat(diabetes_bin |> mutate(estimate = preds |> pull()),
                 Diabetes_binary,
                 estimate)
  print(autoplot(cf, type = "heatmap"))
}

