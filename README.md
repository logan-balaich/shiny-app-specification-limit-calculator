# shiny-app-specification-limit-calculator

## Shiny app to calculate specification limits at a given CPK. Takes an input sample of data to create a prior then runs over 100K simulations to estimate parameters necessary to constructing specification limits.

### Files in this repository 
This Shiny application is broken up into two R scripts, ui.R and server.R. The ui.R file dictates what the user interface for the app will include and look like. The server.R file contains the code to make the app function and do the actual analysis to produce the results one would care to see. 

### Use case of this app
There are many instances in which a specification limit needs to be calculated. Often times a sufficiently large enough sample can be too expensive or not practical to acquire. This application can work with smaller sample sizes to still produce specification limits at a given process capability index (CPK). CPK for any given metric with accompanying specification limits is often asked for either internally or from external customers to measure the ability of a process to reliably produce high quality product. 

### How this app works, from a user perspective  
A user would being by inputting their sampled data for whatever data they would like to create a specification limit for. This data all needs to be comma separated. Once the user clicks on the "Calculate Spec Limits" button then the input data is read in and used as prior information. This prior information is used to create a normal_spec_limits.stan file. This is the file that Rstan uses to run simulations to estimate parameters. Once posterior estimates for the mean and standard deviation are calculated they are then used to calculate a specification limit at a given CPK level (whatever the user selects using the selection slider). All of the key information is then plotted to give a visualization of the resulting specification limits. You can then adjust the CPK slider as you desire and the histogram visual will update. 

### How to use/view this app on your computer 
For those not familiar with Shiny apps there are a ton of great resources online. If you are using RStudio then you can simply copy and paste the two R scripts (ui.R and server.R) to your local machine. In RStudio while viewing either of the two scripts there is a green play button (looks like a triangle) and next to the button it wil say "Run App". Once you click that button a version of the app will initialize. You will need to make sure that you have all of the required packages installed before running the app. 

