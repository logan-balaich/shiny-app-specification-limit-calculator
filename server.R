# This is server.R file

#options(shiny.sanitize.errors = TRUE)
wd <- getwd()
setwd(wd)
library(shiny)
library(ggplot2)
library(rstan)
library(rstudioapi)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

shinyServer(function(input, output) {
  # Be able to save and pass objects between different outputs
  makeReactiveBinding('samps')
  makeReactiveBinding('PosteriorMean')
  makeReactiveBinding('PosteriorSigma')
  makeReactiveBinding('input_sample')
  makeReactiveBinding('Upper_Spec_Limit')
  makeReactiveBinding('Lower_Spec_Limit') 
  
  # observeEvent for the Action Button 
  observeEvent(input$do, {
    # Stan Output 
    # Prior is from our sampled data
    prior_data_string <- read.delim(textConnection(input$dat), header = F, sep = ",", stringsAsFactors = F)
    prior_input_data <- as.numeric(prior_data_string[1,])
    PriorMean <- mean(prior_input_data)
    PriorSigma <- sd(prior_input_data)
    #RangeScaled <- (max(prior_input_data) - min(prior_input_data))/length(prior_input_data)
    a <- paste("data{
                      int<lower=0> N; 
                      real y[N]; 
                    }
                    parameters{
                      real mu;
                      real<lower=0> sigma;
                    }
                    model { 
                      // Priors
                      mu ~ normal(", PriorMean ,",",PriorSigma , "); 
                      for (i in 1:N){
                        y[i] ~ normal(mu,sigma);
                      }
                    }")
    write(a, "normal_spec_limits.stan")
    ret <- stanc(file="normal_spec_limits.stan") 
    ret_sm <- stan_model(stanc_ret = ret) 
    df <- read.delim(textConnection(input$dat), header = F, sep = ",", stringsAsFactors = F)
    input_sample <<- as.numeric(df[1,])
    dat <- input_sample
    N <- length(dat)
    stan_dat <- list(N=N, y=dat)
    SpecLimitSim <- sampling(ret_sm, warmup=5000, iter=30000, chains=4, data = stan_dat, control=list(adapt_delta = 0.99), refresh=0)
    samps <<- as.matrix(SpecLimitSim)
    PosteriorMean <<- mean(samps[,1])
    PosteriorSigma <<- mean(samps[,2])
  })
  
  output$plot <- renderPlot({
    # Now Calculate the spec limits first
    spec_limits <- function(cpk, mean, sigma) {
      multiply_factor <- cpk*3
      upr <- mean + (multiply_factor*sigma)
      lwr <- mean - (multiply_factor*sigma)
      output <- list(CPK_Used = cpk, Upper_Spec_Limit = upr, Lower_Spec_Limit = lwr)
      return(output)
    }
    spec_output <- spec_limits((input$cpk),PosteriorMean, PosteriorSigma)
    list_output <- list(Posterior_Mean = PosteriorMean, Posterior_Standard_Deviation = PosteriorSigma, 
                        CPK_Used = spec_output$CPK_Used, Upper_Spec_Limit = spec_output$Upper_Spec_Limit, 
                        Lower_Spec_Limit = spec_output$Lower_Spec_Limit, Data_Used_as_Sample = input_sample)
    
    Upper_Spec_Limit <<- list_output$Upper_Spec_Limit
    Lower_Spec_Limit <<- list_output$Lower_Spec_Limit
    
    # Below is code to generate the histogram plot
    # Create dynamic min & max for when the cpk slider changes, so specs are always on the plot
    plot_max <- PosteriorMean + ((input$cpk)*3.75*PosteriorSigma)
    plot_min <- PosteriorMean - ((input$cpk)*3.75*PosteriorSigma)
    # randomly sample 1000 points from our posterior distribution
    # 1000 points give us a good histogram, but also allow us to see the input sample, even when it is only
    # a few data points 
    post_dat <- rnorm(1000, mean=PosteriorMean, sd=PosteriorSigma)
    # Create a df for ggplot to use
    hist_df <- data.frame(
      Data_From = factor(c(rep("Posterior", length(post_dat)), rep(paste("Sample of size",length(input_sample)),
                                                                   length(input_sample)))),data_points = c(post_dat,input_sample))
    # Create text to be used in the subtitle 
    out_post_text <- paste("Posterior follows a normal distribution with ", "\U03BC", "=",round(PosteriorMean,3), " and ", 
                           "\U03C3", "=",round(PosteriorSigma,3) )
    out_spec_text <- paste("At a CPK of", round((input$cpk),2),  "the spec limits are (", round(Lower_Spec_Limit,3),
                           ",",round(Upper_Spec_Limit,3), ")")
    out_text <- paste(out_post_text, out_spec_text, sep="\n")
    # Histogram of the posterior and the input sample
    qplot(data_points, data=hist_df, geom="histogram", fill=Data_From) +
      scale_fill_manual(name = "Data From:", values = c("#4b75ff", "#ff9c4b")) +
      geom_vline(xintercept = Lower_Spec_Limit, linetype="dotted", size=1.3, col="#ff4b60") +
      geom_vline(xintercept = Upper_Spec_Limit, linetype="dotted", size=1.3, col="#ff4b60") +
      labs(title="Histogram: Posterior & Sampled Data", subtitle=out_text, x="Data", y="Count",
           caption = "*Posterior Histogram shown with 1K of 100K simulated data points") +
      theme(legend.position="top",legend.box = "horizontal") +
      xlim(plot_min,plot_max)
  })
}) 
