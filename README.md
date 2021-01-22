# Strategy-Structure Plot

Strategy-Structure plot is a tool developed for Ned's MBA class to intuitively demonstrate the idea behind strategy-structure fit of organizations. The code has two primary functions: (1) It will pull individual survey responses from a corresponding Qualtrics survey; (2) it will generaet interactive strategy-structure plot with individual-level characteristics (e.g., demographic) filters for class demonstration.

## APP deployment for dot-plot-app-upload.R

1. Change the name of the file `dot-plot-app-upload.R` to `app.R`.
2. Run the code below in R console.

```
setwd('<current file path, do not contain this .R file name>')
library(rsconnect)
# INFORMATION BELOW CAN BE FOUND ON https://www.shinyapps.io/admin/#/tokens
rsconnect::setAccountInfo(name='<your Rshiny name>',
                           token='<shinyio.app token>',
                           secret='<shinyio.app secret>')
deployApp()
```

If everything works alright, after running the line "deployApp()", R will open a tab in the browser. Make sure to copy the URL of that page, because that will be the page that you want to show the students. Every time you change the Qualtrics survey ID, run the app deployment part again, the app will update itself. 
