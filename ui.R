library(dplyr)
library(ggplot2)
library(plotly)
library(tidyr)
library(shiny)
library(stringr)
library(bslib)
library(markdown)

nyc_data <- read.csv("scores.csv", stringsAsFactors = FALSE)

my_theme <- bs_theme(bg = "#0b3d91", #background color
                     fg = "white", #foreground color
                     primary = "#FCC780") # primary color
                     
 my_theme <- bs_theme_update(my_theme, bootswatch = "lux") %>% 
  bs_add_rules(sass::sass_file("custom_theme.scss"))

intro_tab <- tabPanel(
  "Introduction",
  fluidPage(
    theme = my_theme,
    h1("Analysis of NYC SAT Scores", align = "center"),
    h3("Research Questions", align = "left"),
    p("Our final project will focus on analyzing patterns within the average SAT scores for NYC public schools. Some initial questions we are posing (which may require additional datasets) include:
1. Which geographical regions (based on borough or zip code) have the highest and lowest average SAT scores?
2. What are the correlations between average SAT scores and school funding?  
3. Similar to the previous question, how do resource disparities (staff, number of AP classes offered, extracurriculars, etc.) impact SAT scores?
4. What patterns of inequity are there between average SAT scores and demographic compositions of public schools (average income, race, parental education level, etc.)?
5. How does class size/total number of students impact SAT scores?

These questions are important to consider since standardized testing is nowhere near an accurate proxy for intelligence; however, SAT scores serve as a way to illuminate the socio-economic conditions of various neighborhoods. Of course, to score well on the SATs, students must study for it in a highly calculated manner. The ability to prepare for these tests is not accessible to everyone, especially due to the expense of paid tutoring and the amount of time one has to dedicate to it outside of school. It will be interesting to investigate these questions to understand the ways in which certain variables impact average scores. This knowledge may influence education policies, public school financing, the design of the SAT, or the norm for colleges to require these scores.

An ethical question we may ask when working with this data is do we have all significant observations needed to conclude information from this data? Could there have been information purposely left out by either of the two contributors? In this case there could have been a lack of information that could result in different outcomes. Some possible limitations with this data is that there are some missing values which leave room for inaccurate drawings. Another limitation is that for one of the observations, not all students were tested which could affect the results we gather from the data."),
    h3("Data"),
    p("We obtained this data from a platform named Kaggle. We attached a link to our data at the bottom of this paragraph. This data was collected and published by the New York City Department of Education along with the College Board who provided scores and testing rates. This data was collected in order to analyze a few different things including which schools received the highest SAT scores, highest performing schools, which borough has higher performing schools, and the relation between smaller schools and performance on the tests. There are 22 observations and 435 features."),
    url <- a("Kaggle Homepage Link", href= "https://www.kaggle.com/"),
    h3("Limitations"),
    p("The dataset that we are diving into and the questions we are trying to answer can have vast implications for the future of education around the country. This dataset will help us to understand the impacts of inequitable funding and racial discrimination on the United States public schooling system. SAT scores may seem like just a number, but in reality, they can open, and just as easily close, doors for many students. Understanding who scores what, and from where, allows us to observe the importance of resource allocation and funding, which is important for policymakers and politicians to see. By giving this information to policymakers, we can work to make public schooling more equitable, and a person's zip code not a determinant of their future. Undertaking this project, we hope to bring awareness to the discrimination in education that has been plaguing the United States for centuries. The current funding system on the United States public school system, ensures that community wealth disparities carry over into education. We hope, that with this information, policymakers can begin to make changes that will allow equal opportunities for all people."),
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
    label = h3("Borough"),
    choices = unique(nyc_data$Borough),
    multiple = TRUE
  ),
  selectInput(
    inputId = "race_selection",
    label = h3("Race"),
    choices = list(Asian = "Percent_Asian",
                   Black = "Percent_Black",
                   Hispanic = "Percent_Hispanic",
                   White = "Percent_White"),
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
  ),
  includeMarkdown("race_chart_text.md"))

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
                h3("How does the number of students enrolled in a school impact the average SAT score?"),
                p("In this graph we are able to analyze the average SAT scores compared to the different amounts of students enrolled in a school. With this scatter plot visualization, we are able to interact with the average scores and see which levels of student enrollment these scores fall under. What this graph is showing is that the higher the student enrollment is, the higher the average SAT score will be."))

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
  p("Our first conclusion was informed from our scatterplot plot on the first page that examined the role a neighborhood plays on a schools average SAT scores. From our analysis, we determined that schools in richer neighborhoods are doing better, on average, on their SATs. We used Buisness Insider, and the graph below, to analyze the wealth of the 5 boroughs in NYC. Manhattan, Brooklyn, and parts of Staten Island were found to have the average highest median household incomes. This is demonstrated through our first interactive graph that demonstrates how Manhattan has the highest average SAT scores for their schools. According to Public School Review, in most states, local property taxes make up the majority of funding. This means that a schools funding depends on how wealthy, or poor, a neighborhood is. This leads to many complications and questions about equality and equity in the twenty first century."), 
  img("Image of the wealth breakdown of NYC boroughs", src = "https://i.insider.com/54872d4beab8ead1389000d8", width = "50%"),
  h3("Race and Test Scores"),
  p("Our second conclusion pertains to race and its effects on public school funding in New York City. These conclusions were made from analyzing our scatterplot on the second page, along with the pie charts we created in ealier weeks. Unfortunately in America, schools with more students of color typically receive less funding due to many factors including the property taxes element. We were able to see this first hand through our analysis of the data set when we created pie charts for each neighborhood and looked into the racial makeup of that school zone. We determined that Manhattan, the neighborhood with the highest funding and highest SAT scores on average, is majority white, while the Bronx is majority Hispanic, and on average receives less funding and has lower test scores. Even though we can go back and forth on the exact reasons for these findings, the overarching reason for these results is structural racism and the institutions in America that work to keep people of color down."),
  img("Image of race breakdowns for NYC boroughs", src = "https://i.pinimg.com/originals/0a/14/d4/0a14d4e0d55633198602265d50625210.png", width = "50%"),
  h3("Student Enrollment and its Effect on Testing"),
  p("According to the scatterplot on our third page, the higher the student enrollment, the higher the school's average SAT scores. The conclusion we made from this graph was that student enrollment plays a factor in average SAT scores for the school. This analysis is backed up by research by MSU professor Spyros Konstantopoulos, who found that “…reducing class size does not automatically guarantee improvements in student performance. Many other classroom processes and dynamics factor in and have to work well together to achieve successful outcomes in student learning.” This leads us to believe that being in larger schools is beneficial to students as they have more resources and learn how to work together in bigger environments. This was shocking to us, as we had assumed the opposite was going to be true."),
  h3("Works Cited"),
  p("https://msutoday.msu.edu/news/2019/study-shows-smaller-class-sizes-not-always-better-for-pupils;
https://www.publicschoolreview.com/blog/an-overview-of-the-funding-of-public-schools;
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