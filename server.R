library(ggplot2)
library(plotly)
library(dplyr)
nyc_data <- read.csv("scores.csv", stringsAsFactors = FALSE)


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
                     color = ~model,
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
                                   plot_data$verage.Score..SAT.Reading.),
                     hoverinfo = "text") %>%
      
      # set title, x, and y axis labels
      layout(title = "Average SAT Scores by Neighborhood",
             xaxis = list(title = "Average SAT Math Score"),
             yaxis = list(title = "Average SAT Reading Score"))
    
    # return the scatter plot
    return(plot2)
    
    
  }) 
  }