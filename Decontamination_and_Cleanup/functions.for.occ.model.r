## Functions to do the Occupancy modelling

##### Functions to do the Occupnacy modeling

## ProbOcc
## given the output of the occupancy modelling, calculate the probability of Ocurrence


ProbOcc=function(x, psi, p11, p10, K){
  (psi*(p11^x)*(1-p11)^(K-x)) / ((psi*(p11^x)*(1-p11)^(K-x))+(((1-psi)*(p10^x))*((1-p10)^(K-x))))
} 


# jags_for_presence
#
### Takes a tibble with the presence /absence data 
### removes the biological information of the sample
### selects random initial points for the three parameters
### calculates the three parameters are the mean value of all estimates




jags_for_presence <- function(.x){
  .x %>% 
    mutate(model =  map_dbl (data,
                             function(.y, doprint=FALSE,p10_max=0.20, ni=3000,nt=2,nc=10,nb=1000,myparallel=TRUE){
                               
                               .y %>% ungroup %>% dplyr::select(-biol) -> .y # Reduce the tibble to just the presence/abs matrix
                               
                               jags.inits <- function()(list(psi=runif(1,0.05,0.95),p11=runif(1, 0.01,1),p10=runif(1,0.001,0.2))) # generates three random starting estimates of psi, p11 and p10
                               jags.data <- list (Y= .y,
                                                  S = nrow(.y),
                                                  K = ncol(.y)-1,
                                                  p10_max = 0.2) 
                               jags.params <- c("psi","p11","p10")
                               model<-jags(data = jags.data, inits = jags.inits, parameters.to.save= jags.params, 
                                           model.file= "RoyleLink_prior.txt", n.thin= nt, n.chains= nc, 
                                           n.iter= ni, n.burnin = nb, parallel=myparallel)
                               
                               psihat <- model$summary["psi","50%"]
                               p11hat <- model$summary["p11","50%"]
                               p10hat <- model$summary["p10","50%"]    
                               
                               
                               nObs   <- max(rowSums(.y))
                               K <- ncol(.y)
                               psimean <- model$summary ["psi", "mean"]
                               p11mean <- model$summary ["p11", "mean"]
                               p10mean <- model$summary ["p10", "mean"] 
                               
                               model.output <- ProbOcc(nObs, psimean, p11mean, p10mean, K) 
                               
                               
                               
                               modelSummaries<-model$summary
                               if (doprint){
                                 printsummres(psihat,thename="estimated psi")
                                 printsummres(p11hat,thename="estimated p11")
                                 printsummres(p10hat,thename="estimated p10")
                               }
                               return(model.output)
                               
                             })) %>% dplyr::select(Hash,model)
  
}
