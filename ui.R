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
student.enrollment <- range(nyc_data$Student.Enrollment)
# manufacturer types
neighborhood_pick <- unique(nyc_data$Borough)

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
first_page <- tabsetPanel(
  tabPanel("SAT Scores and Student Enrollment",
           fluidRow(
             column(city_slider, width = 6),
             column(student_slider, width = 6)
           ),
           fluidRow(
             column(plotlyOutput("scatter_plot"), width = 12))
  ))


race_scatter_plot <- mainPanel(
  plotlyOutput(outputId = "race_scatter_plot")
)

second_page <- tabPanel(
  "Race vs Scores",
  sidebarLayout(race_scatter_plot)
)



ui <- navbarPage(
  "NYC SAT Scores",
  intro_tab, 
  first_page
)