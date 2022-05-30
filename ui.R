library(dplyr)
library(ggplot2)
library(plotly)
library(tidyr)
library(shiny)
library(stringr)
library(bslib)
library(markdown)



intro_tab <- tabPanel(
  "Introduction",
  
  fluidPage(
    h1("Analysis of NYC SAT Scores", align = "center"),
    h3("Research Questions", align = "left"),
    h3("Data"),
    h3("Limitations")))


ui <- navbarPage(
  "NYC SAT Scores",
  intro_tab
)