library(ggplot2)
library(datasets)

gg_color_hue <- function(n) {
    hues = seq(15, 375, length=n+1)
    hcl(h=hues, l=65, c=100)[1:n]
}

shinyServer(
    function(input, output) {
        
        # Load mtcars data and create a plot
        data(mtcars)
        cars <- mtcars
        cars$cyl <- factor(cars$cyl)
        cars$vs <- factor(cars$vs)
        cars$am <- factor(cars$am, levels = c(0, 1), labels = c("automatic", "manual"))
        cars$gear <- factor(cars$gear)
        cars$carb <- factor(cars$carb)
        p <- qplot(x = wt, y = mpg, color = am, size = hp, data = cars) + ylim(0, NA)
        p <- p + labs(title = "Regression line is drawn for chosen horsepower\n(Prediction is represented by empty circle)\n")
        
        # Load the model
        model <- readRDS("model/modelMPG.RDS")
        betas <- coef(model)
        
        # Form the equations
        # mpg = b0 + b1 * ammanual + b2 * wt + b3 * hp + b4 * ammanual * wt
        # automatic:    mpg = b0 + b2 * wt + b3 * hp
        #                   = 30.95 - 2.52 wt - 0.03 hp
        # manual:       mpg = (b0 + b1) + (b2 + b4) * wt + b3 * hp
        #                   = 42.50 + -6.1 wt - 0.03 hp
        coefs <- data.frame(automatic = c(betas[1],
                                          betas[3],
                                          betas[4]),
                            manual = c(betas[1] + betas[2],
                                       betas[3] + betas[5],
                                       betas[4]))
        row.names(coefs) <- c("intercept", "wt", "hp")
        eqn.auto <- paste("mpg =",
                          round(coefs$automatic[1], 2),
                          ifelse(coefs$automatic[2] < 0, "-", "+"),
                          abs(round(coefs$automatic[2], 2)), "wt",
                          ifelse(coefs$automatic[3] < 0, "-", "+"),
                          abs(round(coefs$automatic[3], 2)), "hp",
                          sep = " ")
        eqn.manual <- paste("mpg =",
                            round(coefs$manual[1], 2),
                            ifelse(coefs$manual[2] < 0, "-", "+"),
                            abs(round(coefs$manual[2], 2)), "wt",
                            ifelse(coefs$manual[3] < 0, "-", "+"),
                            abs(round(coefs$manual[3], 2)), "hp",
                            sep = " ")
        
        # Modify data object with entered values
        row <- cars[1,]
        data <- reactive({
            row$wt <- input$wt
            row$hp <- input$hp
            row$am <- tolower(input$tx)
            row
        })
        
        # Generate output
        output$plot <- renderPlot({
            row <- data()
            row$mpg <- predict(model, data())
            intercept <- coefs[1, row$am] + coefs[3, row$am] * row$hp
            slope <- coefs[2, row$am]
            if(row$am == "automatic")
                col <- gg_color_hue(2)[1]
            else
                col <- gg_color_hue(2)[2]
            
            p <- p + geom_abline(intercept = intercept,
                                 slope = slope, color = col)
            
            p <- p + geom_point(data = row, shape = 1)

            print(p)
            })
        
        output$mpg <- renderText(round(predict(model, data()), 2))
        
        output$eqn <- renderText({
            row <- data()
            row$am
            if(row$am == "automatic") eqn.auto else eqn.manual
        })
    }
)