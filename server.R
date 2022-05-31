library(ggplot2)
library(plotly)
library(dplyr)
nyc_data <- read.csv("scores.csv", stringsAsFactors = FALSE)

# new columns
nyc_data <- nyc_data %>%
  mutate(english_score = (
    Average.Score..SAT.Reading. + Average.Score..SAT.Writing.) / 2,
    total_score = english_score + Average.Score..SAT.Math.)

nyc_data <- nyc_data %>% 
  mutate(Percent_Asian = paste0(str_replace(nyc_data$Percent.Asian, "%", "")))

nyc_data$Percent_Asian <- as.numeric(nyc_data$Percent_Asian)

nyc_data <- nyc_data %>% 
  mutate(Percent_Black = paste0(str_replace(nyc_data$Percent.Black, "%", "")))

nyc_data$Percent_Black <- as.numeric(nyc_data$Percent_Black)

nyc_data <- nyc_data %>% 
  mutate(Percent_Hispanic = paste0(str_replace(nyc_data$Percent.Hispanic, "%", "")))

nyc_data$Percent_Hispanic <- as.numeric(nyc_data$Percent_Hispanic)

nyc_data <- nyc_data %>% 
  mutate(Percent_White = paste0(str_replace(nyc_data$Percent.White, "%", "")))

nyc_data$Percent_White <- as.numeric(nyc_data$Percent_White)



server <- function(input, output) {
# Introduction Page 

  # First Page (scatterplot)
  output$scatter_plot <- renderPlotly({
    plot_data <- nyc_data %>%
      filter(Borough %in% input$borough_pick,
             Student.Enrollment <= input$student_enrollment) 
    
    plot2 <- plot_ly(plot_data,
                     x = ~Average.Score..SAT.Math.,
                     y = ~Average.Score..SAT.Reading.,
                     type = "scatter",
                     mode = "markers",
                     color = ~Borough,
                     marker = list(size = 20),
                     # interactive texts
                     text = ~paste("<b>Neighborhood:</b>",
                                   plot_data$Borough,
                                   "<br>",
                                   "<b>School Name:</b>",
                                   plot_data$School.Name,
                                   "<br>",
                                   "<b>Average SAT Math Score:</b>",
                                   plot_data$Average.Score..SAT.Math.,
                                   "<br>",
                                   "<b>Average SAT Reading Score:</b>",
                                   plot_data$Average.Score..SAT.Reading.),
                     hoverinfo = "text") %>%
      
      # set title, x, and y axis labels
      layout(title = "Average SAT Scores by Neighborhood",
             xaxis = list(title = "Average SAT Math Score"),
             yaxis = list(title = "Average SAT Reading Score"))
    
    # return the scatter plot
    return(plot2)
    
    
  })
  
  #Second Page Plot
  output$race_scatter_plot <- renderPlotly({
    race_scatter_plot <- ggplot(data = nyc_data) +
      geom_line(mapping = aes(x = tota_score, 
                              y = Percent_White, color = School.Name)) +
      labs(title = "SAT Scores by Race",
           x = "Total SAT Score",
           y = "Race")
    
    return(race_scatter_plot)
  })
  

}