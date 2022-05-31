library(dplyr)
library(ggplot2)
library(plotly)
library(tidyr)
library(shiny)
library(stringr)
library(bslib)
library(markdown)
nyc_data <- read.csv("scores.csv", stringsAsFactors = FALSE)


intro_tab <- tabPanel(
  "Introduction",
  fluidPage(
    h1("Analysis of NYC SAT Scores", align = "center"),
    h3("Research Questions", align = "left"),
    h3("Data"),
    h3("Limitations"))) 

# Data needed for first page widgets #
# city miles range
student.enrollment <- range(nyc_data$Student.Enrollment, na.rm = TRUE)
# manufacturer types
neighborhood_pick <- unique(nyc_data$Borough, na.rm = TRUE)

# First Page #
# selectInput drop down menu to select neighborhood
city_slider <- selectInput(inputId = "borough_pick",
                           label = "Select Neighborhood",
                           choices = neighborhood_pick,
                           selected = neighborhood_pick[1],
                           multiple = TRUE)

# sliderInput for setting only the maximum number of students 
student_slider <- sliderInput(inputId = "student_enrollment",
                              label = "Number of Students Enrolled",
                              min = student.enrollment[1],
                              max = student.enrollment[2],
                              value = student.enrollment[2],
                              step = 1)

# Page setup #
first_page <- tabPanel(
  "SAT Scores and Student Enrollment",
  fluidRow(
    column(city_slider, width = 6),
    column(student_slider, width = 6)
  ),
  fluidRow(
    column(plotlyOutput("scatter_plot"), width = 12)),
  p("This graph is a dot plot which allows us to sort the schools by their neighborhood and then dive deeper to see each individual school represented on the graph. Not only can this graph analyze SAT scores based on neighborhood, but it can also highlight the role school size plays on average SAT scores. From this graph I was able to determine that the Manhattan neighborhood has the highest average SAT scores per school. The Brooklyn and Manhattan neighborhoods have a positive correlation between average SAT score math and average SAT score reading. While other neighborhoods, such as the Bronx, are very bottom heavy, with the vast majority of schools scoring between 300 and 400 on the SAT. If we look at average family median for each of these neighborhoods, these conclusions make sense. According to outside sources, the ten most expensive neighborhoods in New York are all in Manhattan, contributing to greater funding for their public schools.")
)


race_scatter_plot <- mainPanel(
  plotlyOutput(outputId = "race_scatter_plot")
)

second_page <- tabPanel(
  "Race vs Scores",
  race_scatter_plot
)

conclusion <- tabPanel(
  "Conclusion", 
  p("From this project we were able to conduct a deep dive into a problem that none of us knew very much about when we began. Through jumping into this project we have analyzed the roles that race, funding, and school size play on predicting the SAT scores of students in a particular school. The first conclusion we came up with is that schools in richer neighborhoods are doing better, on average, on their SATs. This is demonstrated through our first interactive graph that demonstrates how Manhattan has the highest average SAT scores for their schools. Through outside research we have con...")
)




ui <- navbarPage(
  "NYC SAT Scores",
  intro_tab, 
  first_page,
  second_page, 
  conclusion
)