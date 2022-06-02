library(dplyr)
library(ggplot2)
library(plotly)
library(tidyr)
library(shiny)
library(stringr)
library(bslib)
library(markdown)
nyc_data <- read.csv("scores.csv", stringsAsFactors = FALSE)

 # my_theme <- bs_theme_update(my_theme, bootswatch = "lux") %>% 
  #s_add_rules(sass::sass_file("custom_theme.scss"))

intro_tab <- tabPanel(
  "Introduction",
  fluidPage(
    # theme = my_theme,
    h1("Analysis of NYC SAT Scores", align = "center"),
    h3("Research Questions", align = "left"),
    renderMarkdown("intro_text.md"),
    h3("Data"),
    renderMarkdown("data_text.md"),
    h3("Limitations"),
    renderMarkdown("limitations_text.md"),
    h3("5 Boroughs of NYC"),
    img("Image of NYC Boroughs", src = "https://blog-www.pods.com/wp-content/uploads/2019/04/MG_1_2_New_York_City_Boroughs-1024x711.png", width = "50%"), 
    )) 

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

# Data for Third Page 
nyc_data <- read.csv("scores.csv", stringsAsFactors = FALSE)
avg_sat_scores <- nyc_data %>% 
  mutate(avg_sat_scores = Average.Score..SAT.Math. + ((Average.Score..SAT.Reading. + Average.Score..SAT.Writing.)/2))

student_enrollment <- avg_sat_scores %>% 
  group_by(Student.Enrollment) %>% 
  summarize(average_sat_score = mean(avg_sat_scores, na.rm = TRUE))

student_enrollment <- na.omit(student_enrollment)

# Third Page Setup
chart_widget <-
  sliderInput(
    inputId = "avg_sat_scores_selection",
    label = "Average SAT Scores",
    min = (min(student_enrollment$average_sat_score)),
    max = (max(student_enrollment$average_sat_score)),
    sep = "",
    value = c(622.5000,1449.0000))
   

scatter_plot <- mainPanel(plotlyOutput(outputId = "third_page_plot"),
                h3("How does the number of students enrolled in a a school impact the average SAT score?"),
                p(""))

third_page <- tabPanel(
  "Student Enrollment VS Average SAT Scores",
  sidebarLayout(sidebarPanel(chart_widget,), 
                             scatter_plot))
  
# Conclusion
conclusion <- tabPanel(
  "Conclusion", 
  h1("Conclusion"),
  p("From this project we were able to conduct a deep dive into a problem that none of us knew very much about when we began. Through jumping into this project we have analyzed the roles that race, funding, and school size play on predicting the SAT scores of students in a particular school."), 
  h3("Neighborhood Income and Test Scores"), 
  p("Our first conclusion was informed from our dot plot that examined the role a neighborhood plays on a schools average SAT scores. From our analysis, we determined that schools in richer neighborhoods are doing better, on average, on their SATs. We used Buisness Insider, and the graph below, to analyze the wealth of the 5 boroughs in NYC. Manhattan, Brooklyn, and parts of Staten Island were found to have the average highest median household incomes. This is demonstrated through our first interactive graph that demonstrates how Manhattan has the highest average SAT scores for their schools. According to Public School Review, in most states, local property taxes make up the majority of funding. This means that a schools funding depends on how wealthy, or poor, a neighborhood is. This leads to many complications and questions about equality and equity in the twenty first century."), 
  img("Image of the wealth breakdown of NYC boroughs", src = "https://i.insider.com/54872d4beab8ead1389000d8", width = "50%"), 
  h3("Race and Test Scores"), 
  p("Our second conclusion pertains to race and its effects on public school funding in New York City. These conclusions were made from analyzing our ________, along with the pie charts we created in ealier steps. Unfortunately in America, schools with more students of color typically receive less funding due to many factors including the property taxes element. We were able to see this first hand through our analysis of the data set when we created pie charts for each neighborhood and looked into the racial makeup of that school zone. We determined that Manhattan, the neighborhood with the highest funding and highest SAT scores on average, is majority white, while the Bronx is majority Hispanic, and on average receives less funding and has lower test scores. Even though we can go back and forth on the exact reasons for these findings, the overarching reason for these results is structural racism and the institutions in America that work to keep people of color down."), 
  img("Image of race breakdowns for NYC boroughs", src = "https://i.pinimg.com/originals/0a/14/d4/0a14d4e0d55633198602265d50625210.png", width = "50%"), 
  h3("Student Enrollment and its Effect on Testing"), 
  p("According to our ________. The conclusion we made from this graph was that student enrollment plays a factor in average SAT scores for the school. This analysis is backed up by research by Danielle Farrier and David Sciarra, who found that 'children in smaller classes achieve better outcomes, both academic and otherwise, and that class size reduction can be an effective strategy for closing racially or socioeconomically based achievement gaps .'  When children are in smaller classes, they are able to get more attention from their teachers and learn in a more focused and adaptive environment that fosters learning."), 
  h3("Works Cited"), 
  p("https://onlinelibrary.wiley.com/doi/full/10.1002/ets2.12098
https://www.publicschoolreview.com/blog/an-overview-of-the-funding-of-public-schools
https://www.businessinsider.com/new-york-city-income-maps-2014-12")
)



ui <- navbarPage(
  "NYC SAT Scores",
  intro_tab, 
  first_page,
  second_page,
  third_page,
  conclusion
)