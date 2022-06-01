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
    renderMarkdown("intro_text.md"),
    h3("Data"),
    renderMarkdown("data_text.md"),
    h3("Limitations"),
    renderMarkdown("limitations_text.md"))) 

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
  h3("How does the neighborhood of the school play a role in the average SAT scores of the students?"), 
  p("This graph is a dot plot which allows us to sort the schools by their neighborhood and then dive deeper to see each individual school represented on the graph. Not only can this graph analyze SAT scores based on neighborhood, but it can also highlight the role school size plays on average SAT scores. From this graph I was able to determine that the Manhattan neighborhood has the highest average SAT scores per school. The Brooklyn and Manhattan neighborhoods have a positive correlation between average SAT score math and average SAT score reading. While other neighborhoods, such as the Bronx, are very bottom heavy, with the vast majority of schools scoring between 300 and 400 on the SAT. If we look at average family median for each of these neighborhoods, these conclusions make sense. According to outside sources, the ten most expensive neighborhoods in New York are all in Manhattan, contributing to greater funding for their public schools.")
)

# Second Page set up 
page2_panel_widget <- sidebarPanel(
  selectInput(
    inputId = "borough_selection",
    label = h3("Borough", align = "left"),
    choices = unique(nyc_data$Borough),
    multiple = TRUE
  ),
  selectInput(
    inputId = "race_selection",
    label = h3("Race", align = "left"),
    choices = list(Asian = 'nyc_data$Percent_Asian',
                   Black = 'nyc_data$Percent_Black',
                   Hispanic = 'nyc_data$Percent_Hispanic',
                   White = 'nyc_data$Percent_White'),
    multiple = FALSE
  ))


race_scatter_plot <- mainPanel(
  plotlyOutput(outputId = "race_scatter_plot", width = "100%")
)

second_page <- tabPanel(
  "Race vs Scores",
  sidebarLayout(
    race_scatter_plot,
    page2_panel_widget
  ))

# Third Page Setup
chart_widget <-
  selectInput(
    inputId = "avg_sat_scores_selection",
    label = "Average SAT Scores",
    choices = student_enrollment$average_sat_score,
    multiple = TRUE)

scatter_plot <- mainPanel(plotlyOutput(outputId = "student_enrollment"))

third_page <- tabPanel(
  "Student Enrollment VS Average SAT Scores",
  sidebarLayout(sidebarPanel(chart_widget, 
                             scatter_plot)))
  
# Conclusion
conclusion <- tabPanel(
  "Conclusion", 
  p("From this project we were able to conduct a deep dive into a problem that none of us knew very much about when we began. Through jumping into this project we have analyzed the roles that race, funding, and school size play on predicting the SAT scores of students in a particular school. The first conclusion we came up with is that schools in richer neighborhoods are doing better, on average, on their SATs. This is demonstrated through our first interactive graph that demonstrates how Manhattan has the highest average SAT scores for their schools. According to Public School Review, in most states, local property taxes make up the majority of funding. This means that a schools funding depends on how wealthy, or poor, a neighborhood is. This leads to many complications and questions about equality and equity in the twenty first century.")
)



ui <- navbarPage(
  "NYC SAT Scores",
  intro_tab, 
  first_page,
  second_page,
  third_page,
  conclusion
)