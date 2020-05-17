# Strategy-Structure-Plot
Code for (1) generating individual strategy-structure plot by pulling data from Qualtrics responses; (2) generating interactive strategy-structure plot for a class.

## APP deployment for dot-plot-app-upload.R

1. Change the name of the file to `app.R`.
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

If everything works alright, after running the line "deployApp()", R will open a tab in the browser. Make sure to remember the URL of that page, 
as that will be the page that you want to show the students. Every time you change the Qualtrics survey ID, run the app deployment part again, the app will update itself. 
