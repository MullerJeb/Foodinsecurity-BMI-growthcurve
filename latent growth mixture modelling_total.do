
set more off
****************************************************
*
* Latent class growth mixture modelling  
* Manuscrpit Title: Title: The effects of food insecurity on BMI trajectories of adolescent in Ethiopia. Growth curve model
*
*********************************************************
	
/* This analysis has three main objectives:
Objective I: identifying the different BMI trajectories in the study population
Objective II: identify factors associated with peoples membership to the different trajetories
Objective III: important predictors of BMI development in the different BMI trajectory groups with special emphasis to food insecurity 

IMPORTANT POINTS:
- Some papers suggest a difference in BMI trajectories by sex; so we start with analysis separately by sex & check if there is difference in results	
- We have two options for modeling BMI development during the study follow-up: 
		i) using time of study follow-up
		ii)using age which seems more appropriate for interpretation; however, we have multiple cohorts as subjects enrolled at different age (13-17) 
		we need to use analysis that allow for different cohorts like the accelerated longitudinal design) 
- analysis is based on case with atleast three measurements
*/

	use "C:\Users\user\Dropbox\latent growth mixture modelling study\ analysis.dta",  clear 
zz
/* Analysis is based on case with atleast three measurements; create an indicator variable (status) for loss to follow-up
/* Data exploration
* From literature, we expect around 3/4 trajectories of BMI change:
- 1) chronic high stable BMI;	
- 2) Increasing BMI rend
- 3) Decresing BMI trend
- 4) stable normal trend
* But, the above possible trends are based on studing from deveolped countries as there is no literature on similar modelling from low-income setting
* so we did further exploration of our data using graphs
*/

	preserve
	keep personid bmi_zs* time* status sex
	reshape long bmi_zs time, i(personid) j(order)
	line bmi_zs time in 1/300 if status==1
	restore 

	set matsize 10000
	
	preserve
	keep personid bmi_zs* time* status sex
	reshape long bmi_zs time, i(personid) j(order)
	spagplot bmi_zs time  in 1/500 if status==1, id(personid) 
	restore 

	preserve
	keep personid bmi_zs* time* status
	reshape long bmi_zs time, i(personid) j(order)
	tw (scatter bmi_zs time) (lowess bmi_zs time) (lfit bmi_zs time) if status==1 
	restore 
	
* graphs for data cleaning
	preserve
	keep personid bmi_zs* time* status
	reshape long bmi_zs time, i(personid) j(order)
	tw (scatter bmi_zs time, mlabel(personid) xlabel(0(10)115)) (lowess bmi_zs time) (lfit bmi_zs time) in 450/500 if status==1
	restore 

** Table 1 run socio demographic by status
	
	bys status: sum age1
	ttest age1, by (status)
	
	bys status:ta sex
	tabulate sex status , chi2
    tabulate sex status, col nofreq all exact
	
	bys status: ta education1
    tabulate status education1, chi2
    tabulate education1 status, col nofreq all exact

	bys status:ta parental
	tabulate status parental, chi2
    tabulate parental status, col nofreq all exact
	
	bys status:ta SES
	tabulate SES status , chi2
    tabulate SES status, col nofreq all exact
	
	bys status: sum bmi_zs1
	ttest bmi_zs1,by(status)
	
	bys status:ta foodinsec1
	tabulate foodinsec1 status , chi2
    tabulate foodinsec1 status, col nofreq all exact
	
	
	bys status:ta hhfinsec_1
	tabulate hhfinsec_1 status , chi2
    tabulate hhfinsec_1 status, col nofreq all exac
	
	bys status: sum dd_index_david
	ttest dd_index_david,by(status)
	
	bys status:sum physical1
    ttest physical1,by(status)
	*/	
**************************************
* Objective I: model specification (identifying trajectories & shape of each trajectory)
**************************************
/*Steps in model selection (determining the optimal number of classes & the preferred order of the polynomial specifying the shape of each trajectory)
i) decide the appropriate nr of trajectory classes in the population:
- start with a simple model containing only one group
- re-model by adding one more trajectory group at every stage and check whether the model fit improves by adding more classes 
- continue until we reach at decision on the final number of trajectories required for our model
- three points are considered for model selection: 1) model performance using BIC; 2) shape of trajectory in relation to existing knowledge and the aim of analysis; 3) the proportion of cohort members in each class 

ii) decide the order of function to use in each trajectory in the final model  

iii) Assess model fit
*/

********************************************
* using ALA for BMI trajectories through age
******************************************
*********************************************
*decide the appropriate nr of trajectory classes in the population:
*For the whole sample :
sum bmila* 
*i) decide the appropriate nr of trajectory classes in the population:
** Model-I with only one group using quadratic polynomial functions 
	
	traj,model(cnorm) var(bmila*) indep(timela*) order (1) max( 2.868217) min(-3.975078) 
	trajplot,  xlabel(12(1)25)
	
		 //BIC= -7170.35 (N=5158)  BIC= -7168.46 (N=1458)  AIC= -7160.53  L= -7157.53
	     // shape seem non linear
		 //linear fn-significant
		 
	traj,model(cnorm) var(bmila*) indep(timela*) order (2) max( 2.868217) min(-3.975078) 
	trajplot,  xlabel(12(1)25)
	//BIC= -7174.04 (N=5158)  BIC= -7171.52 (N=1458)  AIC= -7160.95  L= -7156.95	
	//quadriatic non signficant (p= 0.2802)
	
	traj, model(cnorm) var(bmila*) indep(timela*) order (3) max( 2.868217) min(-3.975078) 
	trajplot,  xlabel(12(1)25)	
		
	  //BIC= -7176.26 (N=5158)  BIC= -7173.10 (N=1458)  AIC= -7159.88  L= -7154.88
	  //cubic term is significant (P=0.04)
	  ** I chose to start from cubic
	preserve
     *the average posterior probability
	keep if status==1 
	gen Mp = 0 	
    foreach i of varlist _traj_ProbG* {
        replace Mp = `i' if `i' > Mp 
    }
    	*the odds of correct classification
    bys _traj_Group: gen countG = _N
    bys _traj_Group: egen groupAPP = mean(Mp)   //average posterior probability 
    bys _traj_Group: gen counter = _n
    gen n = groupAPP/(1 - groupAPP)
    gen p = countG/ _N
    gen d = p/(1-p)
    gen occ = n/d      //odds of correct classification
	*Estimated proportion for each group
	 scalar c = 0
	 gen TotProb = 0
    foreach i of varlist _traj_ProbG*{
	   quietly summarize `i'
       replace TotProb = r(sum)/_N 
	   }
	list _traj_Group countG groupAPP occ p TotProb if counter==1
	sum _traj_ProbG* groupAPP occ
	bys _traj_Group: sum _traj_ProbG* groupAPP occ
restore	
						
** Model-II with two trajectory groups using cubic polynomial functions 	
	
	traj, model(cnorm) var(bmila*) indep(timela*) order (3 3) max( 2.868217) min(-3.975078)
	trajplot,  xlabel(12(1)25)
	
	//BIC= -6506.10 (N=5158)  BIC= -6499.79 (N=1458)  AIC= -6473.36  L= -6463.36
	
	traj, model(cnorm) var(bmila*) indep(timela*) order (2 3) max( 2.868217) min(-3.975078)
	trajplot,  xlabel(12(1)25)
		//   BIC= -6502.18 (N=5158)  BIC= -6496.49 (N=1458)  AIC= -6472.71  L= -6463.71
		//dis exp(-6502.18-(-7176.26))  //5.61e+292 moderate evidence for model II

		preserve
     *the average posterior probability
	keep if status==1 
	gen Mp = 0 	
    foreach i of varlist _traj_ProbG* {
        replace Mp = `i' if `i' > Mp 
    }
    	*the odds of correct classification
    bys _traj_Group: gen countG = _N
    bys _traj_Group: egen groupAPP = mean(Mp)   //average posterior probability 
    bys _traj_Group: gen counter = _n
    gen n = groupAPP/(1 - groupAPP)
    gen p = countG/ _N
    gen d = p/(1-p)
    gen occ = n/d      //odds of correct classification
	*Estimated proportion for each group
	 scalar c = 0
	 gen TotProb = 0
    foreach i of varlist _traj_ProbG*{
	   quietly summarize `i'
       replace TotProb = r(sum)/_N 
	   }
	
	list _traj_Group countG groupAPP occ p TotProb if counter==1
	sum _traj_ProbG* groupAPP occ
	bys _traj_Group: sum _traj_ProbG* groupAPP occ
	restore	
	
	
** Model-III with three classes
	traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 3) max(2.868217) min(-3.975078)
	trajplot,  xlabel(12(1)25)
	//    BIC= -6282.22 (N=5158)  BIC= -6272.75 (N=1458)  AIC= -6233.11  L= -6218.11
	
			dis exp(-6282.22-(-6502.18))  //3.368e+95 md evidence for model III

		preserve
     *the average posterior probability
	keep if status==1 
	gen Mp = 0 	
    foreach i of varlist _traj_ProbG* {
        replace Mp = `i' if `i' > Mp 
    }
    	*the odds of correct classification
    bys _traj_Group: gen countG = _N
    bys _traj_Group: egen groupAPP = mean(Mp)   //average posterior probability 
    bys _traj_Group: gen counter = _n
    gen n = groupAPP/(1 - groupAPP)
    gen p = countG/ _N
    gen d = p/(1-p)
    gen occ = n/d      //odds of correct classification
	*Estimated proportion for each group
	 scalar c = 0
	 gen TotProb = 0
    foreach i of varlist _traj_ProbG*{
	   quietly summarize `i'
       replace TotProb = r(sum)/_N 
	   }
	
	list _traj_Group countG groupAPP occ p TotProb if counter==1
	sum _traj_ProbG* groupAPP occ
	bys _traj_Group: sum _traj_ProbG* groupAPP occ
	restore	
	
		
** Model-IV 
	traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 3 3) max(2.868217) min(-3.975078)
	trajplot,xlabel(12(1)25)
	 // BIC= -6235.39 (N=5158)  BIC= -6222.76 (N=1458)  AIC= -6169.91  L= -6149.91
	 	 
	 	//BIC- Bayes factor method
		dis exp(-6235.39-(-6282.22))  //1.034e+22  wk evidence for model IV
	 	dis exp(-6235.39-(-6506.10))  //3.70e+117  md evidence for model IV

	traj, model(cnorm) var(bmila*) indep(timela*) order (3 2 0 3) max(2.868217) min(-3.975078)
	trajplot,xlabel(12(1)25)	
		
		
		
		preserve
     *the average posterior probability
	keep if status==1 
	gen Mp = 0 	
    foreach i of varlist _traj_ProbG* {
        replace Mp = `i' if `i' > Mp 
    }
    	*the odds of correct classification
    bys _traj_Group: gen countG = _N
    bys _traj_Group: egen groupAPP = mean(Mp)   //average posterior probability 
    bys _traj_Group: gen counter = _n
    gen n = groupAPP/(1 - groupAPP)
    gen p = countG/ _N
    gen d = p/(1-p)
    gen occ = n/d      //odds of correct classification
	*Estimated proportion for each group
	 scalar c = 0
	 gen TotProb = 0
    foreach i of varlist _traj_ProbG*{
	   quietly summarize `i'
       replace TotProb = r(sum)/_N 
	   }
	
	list _traj_Group countG groupAPP occ p TotProb if counter==1
	sum _traj_ProbG* groupAPP occ
	bys _traj_Group: sum _traj_ProbG* groupAPP occ
	restore	
			
** Model-V 
	traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 3 3 3) max(2.868217) min(-3.975078)
	trajplot,xlabel(12(1)25)
	//    BIC= -6212.99 (N=5158)  BIC= -6197.19 (N=1458)  AIC= -6131.13  L= -6106.13
	
	traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 2 2 3) max(2.868217) min(-3.975078)
	trajplot,xlabel(12(1)25)
	
	 //BIC= -6205.43 (N=5158)  BIC= -6190.90 (N=1458)  AIC= -6130.13  L= -6107.13
		//dis exp(-6216.11-(-6235.39)) 2.362e+0858820442 //wk evidence for model V  
	preserve
     *the average posterior probability
	keep if status==1 
	gen Mp = 0 	
    foreach i of varlist _traj_ProbG* {
        replace Mp = `i' if `i' > Mp 
    }
    	*the odds of correct classification
    bys _traj_Group: gen countG = _N
    bys _traj_Group: egen groupAPP = mean(Mp)   //average posterior probability 
    bys _traj_Group: gen counter = _n
    gen n = groupAPP/(1 - groupAPP)
    gen p = countG/ _N
    gen d = p/(1-p)
    gen occ = n/d      //odds of correct classification
	*Estimated proportion for each group
	 scalar c = 0
	 gen TotProb = 0
    foreach i of varlist _traj_ProbG*{
	   quietly summarize `i'
       replace TotProb = r(sum)/_N 
	   }
		
	list _traj_Group countG groupAPP occ p TotProb if counter==1
	sum _traj_ProbG* groupAPP occ
	bys _traj_Group: sum _traj_ProbG* groupAPP occ
	restore	
		
	  	**bayes factor
		dis exp(-6222.76-(-6272.75))  //moderate evidence for model 4
		dis exp(-6272.75-(-6222.76))  //moderate evidence for model 4
		
	* Decision*
//based on BIC, and bayes factor and shapes it seems that model III, IV are potential candidates

/** based on consideration of shapes of the trajectorie, 
* ii) decide the order of function to use in each trajectory in the final model (Model III) 
	traj if status==1, model(cnorm) var(bmila*) indep(timela*) order (3 3 3)  max(2.868217) min(-3.975078)
	trajplot, xlabel(12(1)25)
			//     BIC= -6282.22 (N=5158)  BIC= -6272.75 (N=1458)  AIC= -6233.11  L= -6218.11
	traj if status==1, model(cnorm) var(bmila*) indep(timela*) order (1 3 3)  max(2.868217) min(-3.975078)
	trajplot, xlabel(13(1)25)
				//  BIC= -6277.25 (N=5158)  BIC= -6269.04 (N=1458)  AIC= -6234.69  L= -6221.69
	traj if status==1, model(cnorm) var(bmila*) indep(timela*) order (2 2 3)  max(2.868217) min(-3.975078)
	trajplot, xlabel(13(1)25)
		  //BIC= -6283.66 (N=5158)  BIC= -6275.45 (N=1458)  AIC= -6241.09  L= -6228.09
		  		  
	traj if status==1, model(cnorm) var(bmila*) indep(timela*) order (1 2 3)  max(2.868217) min(-3.975078)
	trajplot, xlabel(13(1)25)	  
	 // BIC= -6280.10 (N=5158)  BIC= -6272.52 (N=1458)  AIC= -6240.81  L= -6228.81	  
		
	traj if status==1, model(cnorm) var(bmila*) indep(timela*) order (3 1 0)  max(2.868217) min(-3.975078)
	trajplot,xlabel(13(1)25)
	 //BIC= -6277.75 (N=5158)  BIC= -6270.80 (N=1458)  AIC= -6241.74  L= -6230.74
	*/	
	
	* based on consideration of shapes of the trajectorie,  model V groups
* ii) decide the order of function to use in each trajectory in the final model  
	traj , model(cnorm) var(bmila*) indep(timela*) order (3 3 3 3 3)  max(2.868217) min(-3.975078)
	trajplot, xlabel(12(1)25)
		//  BIC= -6212.99 (N=5158)  BIC= -6197.19 (N=1458)  AIC= -6131.13  L= -6106.13
	traj , model(cnorm) var(bmila*) indep(timela*) order (3 3 2 2 3)  max(2.868217) min(-3.975078)
	trajplot, xlabel(12(1)25)
	//BIC= -6205.43 (N=5158)  BIC= -6190.90 (N=1458)  AIC= -6130.13  L= -6107.13
	traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 1 1 3)  max(2.868217) min(-3.975078)
	trajplot, xlabel(12(1)25)
	//BIC= -6201.24 (N=5158)  BIC= -6187.97 (N=1458)  AIC= -6132.48  L= -6111.48
		
	traj , model(cnorm) var(bmila*) indep(timela*) order (3 3 1 1 2)  max(2.868217) min(-3.975078)
	trajplot, xlabel(12(1)25)
	//BIC= -6198.23 (N=5158)  BIC= -6188.12 (N=1458)  AIC= -6145.84  L= -6129.84	
		preserve
     *the average posterior probability
	keep if status==1 
	gen Mp = 0 	
    foreach i of varlist _traj_ProbG* {
        replace Mp = `i' if `i' > Mp 
    }
    	*the odds of correct classification
    bys _traj_Group: gen countG = _N
    bys _traj_Group: egen groupAPP = mean(Mp)   //average posterior probability 
    bys _traj_Group: gen counter = _n
    gen n = groupAPP/(1 - groupAPP)
    gen p = countG/ _N
    gen d = p/(1-p)
    gen occ = n/d      //odds of correct classification
	*Estimated proportion for each group
	 scalar c = 0
	 gen TotProb = 0
    foreach i of varlist _traj_ProbG*{
	   quietly summarize `i'
       replace TotProb = r(sum)/_N 
	   }
		
	list _traj_Group countG groupAPP occ p TotProb if counter==1
	sum _traj_ProbG* groupAPP occ
	bys _traj_Group: sum _traj_ProbG* groupAPP occ
	restore	
				
*iii) Assessing model fit: we check three indices of model fit below
/*	- average posterior probability for each group >=0.7
	- odds of correct classification >=5.0 
	- the proportion of a sample assigned to a certain group is close to the proportion estimated from the model; 
	- 99 % confidence intervals of the estimated proportion are reasonably narrow. 	
*/
	end
This should work after any model as long as the naming conventions for the assigned groups are _traj_Group and the posterior probabilities are in the variables _traj_ProbG*. So when you run

summary_table_procTraj
You get this ugly table:

     | _traj_~p   countG   groupAPP        occ       p    TotProb |
     |------------------------------------------------------------|
  1. |        1      103    .937933   43.57431   .2575   .2573651 |
104. |        2      161   .9935606   229.0434   .4025   .4064893 |
265. |        3      136   .9607248   47.48378     .34   .3361456 |
	
	
    *This displays the group number, the count per group, the average posterior probability for each group,
    *the odds of correct classification, and the observed probability of groups versus the probability 
    *based on the posterior probabilities
      * model adequacy 
	// when change in BIC is not that informative, we use the Bayes factor, which is denoted by Bij (measures the posterior odds of i being the correct model given the data) 	
	// use approximate estimation for Bayes factor & Jeffreys’s scale
	// other option for comparing a model with set of different models
	//**In the second stage, the focus turns to determining the preferred order of the polynomial specifying the shape of each
	//trajectory given the first-stage decision on number of groups. 
		** Checking that considering two trajectory groups instead of one improved the model fit using the 
	** continue the same process untill we have number of trajectory groups that sufficiently explain our data both statistically and conceptually
	//the interplay of formal statistical criteria and subjective judgment that is required for making a well-founded decision on the number of
	//groups to include in the model. It 
   */
	** Graph
	*set scheme sj
	*set scheme  s2mono 
	*set scheme  s2manual
	*set scheme   s2gmanual
	*set scheme  s1mono 
	set scheme  s1manual  
	*set scheme s2color

	traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 1 1 2)  max(2.868217) min(-3.975078)
	trajplot, xlabel(12(1)25) xtitle("Age of adolescents") ylabel(-3.0(1)2.0)ytitle("BMI zscore") ci  
	
	**individual trajectories within each members
	preserve
	reshape long bmila timela, i(personid) j(round)
	
	gen bmila_jit = bmila + ( 0.2*runiform()-0.1 )
	graph twoway scatter bmila_jit timela, c(L) by(_traj_Group) msize(tiny) mcolor(gray)  lcolor(gray)
  	restore
	
	
	preserve 
	traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 1 1 2)  max(2.868217) min(-3.975078)
	trajplot
	
	keep bmila* timela* personid sex cohort _traj_Group
	reshape long bmila timela,i(personid) j(round)
	tw(lowess bmila timela if _traj_Group==1)(lowess bmila timela if _traj_Group==2) (lowess bmila timela if _traj_Group==3)  ///
	(lowess bmila timela if _traj_Group==4)(lowess bmila timela if _traj_Group==5),xlabel(12(1)26)xtitle("Age of adolescents") ///
	ylabel(-3.0(1)2.0)ytitle("BMI zscore")legend( order(1 "X" 2 "Y" 3 "Z" 4 "W" 5 "V"))legend(off) 
    restore
	
	
	**Final Objectives
	
	
	
	
		***************Predictors of group membership trajectory 
		
	gen female=0
	replace female=1 if sex==2
	gen male=0
	replace male=1 if sex==1
	
	**Adding time stable covariates
		**wealth

		traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 1 1 2)  max(2.868217) min(-3.975078) risk(wealth1)refgroup(3)
**residence
		traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 1 1 2)  max(2.868217) min(-3.975078) risk(urban)refgroup(3)
		traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 1 1 2)  max(2.868217) min(-3.975078) risk(rural)refgroup(3)

** religiosity
		traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 1 1 2)  max(2.868217) min(-3.975078) risk(relig)refgroup(3)

**parental educ
ta paeduc1
ta paeduc2
		traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 1 1 2)  max(2.868217) min(-3.975078) risk(paeduc1)refgroup(3)
		traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 1 1 2)  max(2.868217) min(-3.975078) risk(paeduc2)refgroup(3)
		
** sex
		traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 1 1 2)  max(2.868217) min(-3.975078) risk(female) refgroup(3)
		traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 1 1 2)  max(2.868217) min(-3.975078) risk(male) refgroup(3)
**household food security
		traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 1 1 2)  max(2.868217) min(-3.975078) risk(hhfinsec1) refgroup(3)
		traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 1 1 2)  max(2.868217) min(-3.975078) risk(hhfinsec2) refgroup(3)

	**diet diversity score
			traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 1 1 2)  max(2.868217) min(-3.975078) risk(dd_score)refgroup(3)
**social support
		traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 1 1 2)  max(2.868217) min(-3.975078) risk(netexch)refgroup(3)
** foodinsecurity 
		traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 1 1 2)  max(2.868217) min(-3.975078) risk(foodinsec1)refgroup(3)

		
	**By Block
	
	**Model I:(Null model)
	**Foodinsec-Time Varying Covaiate
    	matrix tc1 = (0, 0, 0, 0, 0, 0, 0, 0)
		matrix tc2 = (0, 0, 0, 1, 1, 1, 1, 1)
		
			traj, model(cnorm) var(bmila*) indep(timela*) tcov(foodinsecla*) order (3 3 1 1 2)  max(2.868217) min(-3.975078)plottcov(tc2) 
	*Model II (adding time stable covariates)
			traj, model(cnorm) var(bmila*) indep(timela*) tcov(foodinsecla*) order (3 3 1 1 2)  max(2.868217) min(-3.975078) risk(age1 female wealth1 rural elem1 femhead paeduc1) refgroup(5) 
		
			traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 1 1 2)  max(2.868217) min(-3.975078) risk(foodinsec1 female wealth1 rural elem1 femhead paeduc1) refgroup(3) 
		
			traj, model(cnorm) var(bmila*) indep(timela*) order (3 3 1 1 2)  max(2.868217) min(-3.975078) risk(foodinsec1 female wealth1 urban elem1 femhead paeduc1 hhfinsec1)refgroup(3) 
		
		
		
	traj, model(cnorm) var(bmila*) indep(timela*) tcov(foodinsecla*) order (3 2 0 3) max(2.868217) min(-3.975078)
		
	traj, model(cnorm) var(bmila*) indep(timela*) tcov(foodinsecla*)order (3 3 3) max(2.868217) min(-3.975078)
		
		
				
**Multinomial Model multinomial logit model with base outcome the most frequent


gen groupt=0
replace groupt=1 if _traj_Group==1|_traj_Group==2|_traj_Group==3
replace groupt=2 if _traj_Group==4
replace groupt=3 if _traj_Group==5
		
	*Dependent variables has 5 categories 1-2-3-4-5
		
		des $ylist $xlist $zlist $wlist
		sum $ylist $xlist $zlist $wlist
		tab $ylist
			
		global ylist _traj_Group
		global xlist foodinsec1 
		global zlist female wealth1 rural relig paeduc1 femhead elem1 age1 
		global wlist hhfinsec1 riskfact1 physical1 dd_score
		
	**By Block
		*Model I
		mlogit $ylist $xlist
		mlogit $ylist $xlist,baseoutcome(2)
		
		
		*Model II
				mlogit $ylist $xlist $zlist,baseoutcome(2)
				mlogit $ylist $xlist $zlist

		*Model III
				mlogit $ylist $xlist $zlist $wlist

												
				
		**multinomial logit margnial effects
		mfx,predict(pr outcome(1))
		mfx,predict(pr outcome(2))
		mfx,predict(pr outcome(3))
		mfx,predict(pr outcome(4))
		mfx,predict(pr outcome(5))
				
		
		*multinomial logit predicted probablities
		predict pmlogit1 pmlogit2 pmlogit3 pmlogit4,pr
		sum pmlogit1 pmlogit2 pmlogit3 pmlogit4
		tab $ylist
		
		
		
		
		
		**Longitudinal Multinomial 
		
			preserve 
			reshape long health bmila timela foodinsecla bmi_zs elem sec age education physical illness riskfact difficult tired foodinsec smoke hhfinsec, i(personid) j(time)
		
