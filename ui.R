shinyUI(pageWithSidebar(
    headerPanel("Predict MPG from weight and horsepower of a car"),
    sidebarPanel(
        h4('Enter your inputs here'),
        br(),
        sliderInput('wt', 'Select a value for weight',value = 3.00, min = 1.5, max = 5.4, step = 0.01),
        sliderInput('hp', 'Select a value for horsepower',value = 100, min = 50, max = 300, step = 1),
        radioButtons('tx', 'Transmission', list("Manual", "Automatic")),
        submitButton('Submit')
        #actionButton('action', 'Submit')
    ),
    mainPanel(
        tabsetPanel(
            tabPanel("Prediction",
                    h4('Predicted MPG'),
                    p(textOutput('mpg')),
                    h4('Equation'),
                    p(textOutput("eqn")),
                    br(),
                    h4('Plot of mtcars dataset: MPG vs weight for different horsepowers'),
                    plotOutput('plot')
                    ),
            tabPanel("Documentation",
                     h3("About this app"),
                     p("This app uses a linear regression model fitted on the mtcars dataset in R to predict MPG from weight and horsepower for automatic and manual cars."),
                     h3("How to use this app"),
                     p("Select the weight, horsepower and transmission type of the car. Hit \"Submit\"."),
                     p("View the results on the \"Prediction\" tab:"),
                     p(strong("Predicted MPG"),
                       " is the MPG predicted using the model."),
                     p(strong("Equation"),
                       " gives the linear relationship between MPG, weight and horsepower for the chosen transmission type modeled in the regression model."),
                     p("The regression line is shown in the plot and the prediction point is represented by an empty circle on the line. Notice how the regression line is shifted up/down as the horsepower is varied.")
                     
                     )
        )
    )
))