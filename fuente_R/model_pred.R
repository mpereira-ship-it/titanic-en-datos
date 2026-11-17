
library(shiny)
library(shinydashboard)
library(flexdashboard)     
library(dplyr)

# COEF DE LA LOGÍSTICA 
coef <- c(
  intercept        =  0.715985,
  pclass2          = -0.941074,
  pclass3          = -2.083125,
  sexmale          = -2.620183,
  age              = -0.027650,
  fare             =  0.003060,
  fsize_nomPeque   =  2.560083,
  fsize_nomSoltero =  2.571058,
  embarkedQ        = -0.084079,
  embarkedS        = -0.233266,
  child1           =  0.860044
)

predict_prob <- function(pclass, sex, age, fare, fsize, embarked){
  lp <- coef["intercept"] +
    coef["pclass2"]          * (pclass == 2) +
    coef["pclass3"]          * (pclass == 3) +
    coef["sexmale"]          * (sex == "male") +
    coef["age"]              * age +
    coef["fare"]             * fare +
    coef["fsize_nomPeque"]   * (fsize >= 2 & fsize <= 4) +
    coef["fsize_nomSoltero"] * (fsize == 1) +
    coef["embarkedQ"]        * (embarked == "Q") +
    coef["embarkedS"]        * (embarked == "S") +
    coef["child1"]           * (age < 18)
  1 / (1 + exp(-lp))
}

#2. UI 
ui <- dashboardPage(
  dashboardHeader(title = "¿Sobrevivirías al Titanic?"),
  dashboardSidebar(
    sliderInput("age",  "Edad", 1, 80, 25),
    radioButtons("sex", "Sexo", choices = c("male", "female"), inline = TRUE),
    selectInput("pclass", "Clase", choices = c(1,2,3), selected = 3),
    sliderInput("fsize", "Tamaño de familia a bordo", 1, 7, 1),
    numericInput("fare", "Tarifa (£)", 15, 0, 200, step = 1),
    selectInput("embarked", "Puerto de embarque",
                choices = c("C","Q","S"), selected = "S")
  ),
  dashboardBody(
    h3("Resultado de la simulación"),
    gaugeOutput("probGauge", width = "100%", height = 250),
    br(),
    uiOutput("texto"),
    br(),
    helpText("Modelo: regresión logística entrenada con datos históricos (AUC = 0.888).")
  )
)

#3. SERVER 
server <- function(input, output, session){
  
  prob <- reactive({
    predict_prob(
      pclass   = as.numeric(input$pclass),
      sex      = input$sex,
      age      = input$age,
      fare     = input$fare,
      fsize    = input$fsize,
      embarked = input$embarked)
  })
  
  output$probGauge <- renderGauge({
    pr <- as.numeric(prob()*100)            
    gauge(
      value   = pr,
      min     = 0,
      max     = 100,
      label   = "% supervivencia",
      sectors = gaugeSectors(
        success = c(60, 100),   
        warning = c(30, 60),    
        danger  = c(0, 30)      
      )
    )
  })
  
  output$texto <- renderUI({
    pr  <- prob()
    msg <- ifelse(pr >= 0.5, "Alta probabilidad de supervivencia","Baja probabilidad de supervivencia")
    col <- ifelse(pr >= 0.5, "green", "red")
    HTML(sprintf(
      "<h3 style='color:%s;'>%s</h3>
       <p>Probabilidad estimada: <b>%.1f&nbsp;%%</b></p>",
      col, msg, pr*100))
  })
}

#4. RUN 
shinyApp(ui, server)
