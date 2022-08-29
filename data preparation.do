

**Manuscrpit Title
* Title: The effects of food insecurity on BMI trajectories of adolescent in Ethiopia. Growth curve model
* Define path
	
	//use "C:\Users\user\Dropbox\BMI trajectory paper\JLFSY_FINAL_DATA_AUG2016.dta",  clear
	//export excel using "C:\Users\user\Dropbox\BMI trajectory paper\JLFSY_FINAL_DATA_AUG2016.xls",  firstrow(variables)  replace
	//restore
	
	//import excel "C:\Users\user\Dropbox\latent growth mixture modelling study\JLFSYANTHROP20150202.xls", sheet("Anthrops") firstrow clear
	import excel "C:\Users\User\Dropbox\PhD_Project\Project 1 PhD Working Documents\PhD_Manuscript-3\latent growth mixture modelling study\JLFSYANTHROP20150202.xls", sheet("Anthrops") firstrow clear
	*import excel "C:\Users\yemar\Dropbox\latent growth mixture modelling study\JLFSYANTHROP20150202.xls", sheet("Anthrops") firstrow clear
	count  // 2109
	rename ADO1 personid
	
	*merge 1:1 personid using "C:\Users\User\Dropbox\latent growth mixture modelling study\JLFSY_FINAL_DATA_AUG2016.dta" 
	*merge 1:1 personid using "C:\Users\yemar\Dropbox\latent growth mixture modelling study\JLFSY_FINAL_DATA_AUG2016.dta"
	merge 1:1 personid using "C:\Users\User\Dropbox\PhD_Project\Project 1 PhD Working Documents\PhD_Manuscript-3\latent growth mixture modelling study\JLFSY_FINAL_DATA_AUG2016.dta"
	sort personid 
	count 

	**Keep
	tab1 arespond1 arespond2 arespond3 a4respond
	//keep if arespond1==1&arespond2==1&arespond3==1&a4respond==1
	
	keep if arespond1==1|arespond2==1|arespond3==1|a4respond==1

	
	* cleaning 
	**calculate age of subjects at each follow-up
	tab aa1
	destring aa1, replace ignore (" ")
	list personid if aa1==12
	replace aa1=17 if aa1==12
	
	ta aa1
	
	ta aa2be
	replace aa2be=6 if aa2be==0
	ta aa2be

	ta aa2ae   
	ta aa2aw

	**some children have inconsistent date of birth and reported age at baseline 
	
	*generate age based on date of birth
	gen birthdate=(((aa2aw-1900)*12)+aa2bw)
	gen interdate0=(((aa8cw-1900)*12)+aa8bw)
	gen age1=(interdate0-birthdate)/12.
	tab age1
	
			
	ta A2INT_MNTH
	ta A2INT_YEAR
	list personid if A2INT_YEAR==2000|A2INT_YEAR==2001

	foreach var in A2INT_YEAR {
	 replace `var'=2006 if `var'==2000
	 replace `var'=2006 if `var'==2001&personid==13005604|personid==20057104|personid==31010609
	 replace `var'=2007 if `var'==2001&personid==12048705|personid==12057713|personid==33023705|personid==33010305
		}

.
	destring aa2be, replace ignore (" ")
	gen interdate=(((A2INT_YEAR-1900)*12)+A2INT_MNTH)
	gen age2=(interdate-birthdate)/12.
	tab age2

	
	*Age-r3
	ta A3INTYEAR
	ta a3intyearw
	ta a3intmonthw

	recode a3intmonthw 0=.
	recode a3intyearw 0=.

	gen interdate1=(((a3intyearw-1900)*12)+a3intmonthw)
	gen age3=(interdate1-birthdate)/12.
	tab age3

	*Age_r4
	ta a4intmonthw
	ta a4intyearw

	gen interdate2=(((a4intyearw-1900)*12)+a4intmonthw)
	gen age4=(interdate2-birthdate)/12.
	tab age4

	
	/*foreach var in age1 age2 age3 age4 {
	replace `var'=`var'/12
	}
	*/
	sum age1 age2 age3 age4


	
	gen time1=0
	gen time2=age2-age1
	gen time3=age3-age1
	gen time4=age4-age1
	
	replace time1=. if am1==7777 | am1==.
	replace time2=. if A2H1==999.99 | A2H1==.
	replace time3=. if A3M1==.
	replace time4=. if A4U1==.
	
	replace time2=time2+1 if time2<=0	
	sum time*
	
	sort time2
	count
	count if time2!=.
	count if time2<1
	count if time2<=.5
	count if time2<=.8
	
	list personid aa8cw aa8bw A2INT_YEAR A2INT_MNTH a3intyearw a3intmonthw a4intyearw a4intmonthw time2 am1 A2H1 if time2<=0.5
	
	
	 **change age year to months
   foreach var in age1 age2 age3 age4 {
   replace `var'=`var'*12.
   }
   
	sum age1 age2 age3 age4 
	
	*Socio demographic and economic variables
	*religion of the respondents
	tab ab19
	gen religion=.
	replace religion=1 if ab19==1
	replace religion=2 if ab19==2
	replace religion=3 if ab19>=3 & !missing(ab19)
	* label define religion 
	label define religion1 1 "Muslim" 2 "Orthodox" 3 "Others"
	label values religion religion1
	ta religion

	*creating dummy variables for religion (orthodox and Others(protestant, catholics)
	gen orthodox=.
	replace orthodox=1 if ab19==2
	replace orthodox=0 if ab19!=2 & !missing(ab19)

	gen others=.
	replace others=1 if ab19>=3
	replace others=0 if ab19!=3&ab19!=4&ab19!=6&ab19!=7&ab19!=11&ab19!=12 & !missing(ab19)


	gen muslim=.
	replace muslim=1 if ab19==1
	replace muslim=0 if ab19!=1 & !missing(ab19)

	tab1 ab19 religion orthodox muslim others
	* educational status round 1
	tab ab4
	gen education1=.
	replace education1=1 if ab4<=3
	replace education1=2 if ab4>=4&ab4<=6
	replace education1=3 if ab4>=7&ab4<=16 & !missing(ab4)

	* label define education  
	label define education11 1 "No schooling" 2 "Primary" 3 "Sec&above"
	label values education1 education11
	*creating dummy variables for adolescent education round1
	gen elem1=.
	replace elem1=1 if ab4>=4&ab4<=6
	replace elem1=0 if ab4!=4&ab4!=5&ab4!=6 &!missing(ab4)
	gen sec1=.
	replace sec1=1 if ab4>=7&ab4<=13
	replace sec1=0 if ab4!=7&ab4!=8&ab4!=9&ab4!=10&ab4!=11&ab4!=12&ab4!=13&!missing(ab4)

	tab1 elem1 sec1 education1

	* educational status at round 2
	tab A2A1
	gen education2=.
	replace education2=1 if A2A1<=3
	replace education2=2 if A2A1>=4&A2A1<=6
	replace education2=3 if A2A1>=7&A2A1<=16 & !missing(A2A1)

	* label define education  
	label define education22 1 "No schooling" 2 "Primary" 3 "Sec&above"
	label values education2 education22

	*creating dummy for adolescent education round2
	gen elem2=.
	gen sec2=.
	replace elem2=1 if A2A1>=4&A2A1<=6
	replace elem2=0 if A2A1!=4& A2A1!=5&A2A1!=6 &!missing(A2A1)
	replace sec2=1 if A2A1>=7&A2A1<=13
	replace sec2=0 if A2A1!=7&A2A1!=8&A2A1!=9&A2A1!=10&A2A1!=11&A2A1!=12&A2A1!=13&!missing(A2A1)

	tab1 elem2 sec2 education2

	* educational status at round 3
	tab A3A1
	gen education3=.
	replace education3=1 if A3A1<=3
	replace education3=2 if A3A1>=4&A3A1<=6
	replace education3=3 if A3A1>=7&A3A1<=16 & !missing(A3A1)

	* label define education  
	label define education33 1 "No schooling" 2 "Primary" 3 "Sec&above"
	label values education3 education33

	*creating dummy variables for educational status at round3
	tab A3A1
	gen elem3=.
	gen sec3=.
	replace elem3=1 if A3A1>=4&A3A1<=6
	replace elem3=0 if A3A1!=4& A3A1!=5&A3A1!=6 &!missing(A3A1)
	replace sec3=1 if A3A1>=7&A3A1<=16
	replace sec3=0 if A3A1!=7&A3A1!=8&A3A1!=9&A3A1!=10&A3A1!=11&A3A1!=12&A3A1!=13&A3A1!=14&A3A1!=15&A3A1!=16 & !missing(A3A1)

	tab1 education3 elem3 sec3 
	tab1 education1 education2 education3

	**Education--round 4
	
	 ta A4H1
	 
	gen education4=.
	replace education4=1 if A4H1<=3
	replace education4=2 if A4H1>=4&A4H1<=6
	replace education4=3 if A4H1>=7&A4H1<=19 & !missing(A4H1)

	* label define education  
	label define education44 1 "No schooling" 2 "Primary" 3 "Sec&above"
	label values education4 education44

	*creating dummy variables for educational status at round4
	tab A4H1
	gen elem4=.
	gen sec4=.
	replace elem4=1 if A4H1>=4&A3A1<=6
	replace elem4=0 if A4H1!=4& A3A1!=5&A3A1!=6 &!missing(A4H1)
	replace sec3=1 if A4H1>=7&A4H1<=19
	replace sec3=0 if A4H1!=7&A4H1!=8&A4H1!=9&A4H1!=10&A4H1!=11&A4H1!=12&A4H1!=13&A4H1!=14&A4H1!=15&A4H1!=16&A4H1!=17 &A4H1!=18&A4H1!=19 & !missing(A4H1)

	tab1 education4 elem4 sec4
	tab1 education1 education2 education3 education4
	
		//FAMILY EDUCATIONAL STATUS//
	* Family Educational status (father)
	tab fatheduc
	gen father_educ=.
	replace father_educ=1 if fatheduc<=3
	replace father_educ=2 if fatheduc>=4&fatheduc<=6
	replace father_educ=3 if fatheduc>=7&fatheduc<=18 & !missing(fatheduc)

	* label define education  
	label define father_educ1 1 "No schooling" 2 "Primary" 3 "Sec&above"
	label values father_educ father_educ1

	* creating dummy for father education
	gen educfath1=.
	gen educfath2=.
	replace educfath1=1 if fatheduc>=4&fatheduc<=6
	replace educfath1=0 if fatheduc!=4& fatheduc!=5&fatheduc!=6 &!missing(fatheduc)
	replace educfath2=1 if fatheduc>=7&fatheduc<=18
	replace educfath2=0 if fatheduc!=7&fatheduc!=8&fatheduc!=9&fatheduc!=10&fatheduc!=11&fatheduc!=12&fatheduc!=13&fatheduc!=14&fatheduc!=15&fatheduc!=16 &fatheduc!=17 &fatheduc!=18& !missing(fatheduc)


	tab1 educfath1 educfath2 father_educ

	*family education status(mother)
	tab motheduc
	gen mother_educ=.
	replace mother_educ=1 if motheduc<=3
	replace mother_educ=2 if motheduc>=4&motheduc<=6
	replace mother_educ=3 if motheduc>=7&motheduc<=16 & !missing(motheduc)

	* label define education  
	label define mother_educ1 1 "No schooling" 2 "Primary" 3 "Sec&above"
	label values mother_educ mother_educ1
	*creating dummy varialbe for mother education 
	gen educmoth1=.
	gen educmoth2=.
	replace educmoth1=1 if motheduc>=4&motheduc<=6
	replace educmoth1=0 if motheduc!=4& motheduc!=5&motheduc!=6 &!missing(motheduc)
	replace educmoth2=1 if motheduc>=7&motheduc<=16
	replace educmoth2=0 if motheduc!=7&motheduc!=8&motheduc!=9&motheduc!=10&motheduc!=11&motheduc!=12&motheduc!=13&motheduc!=14&motheduc!=15&motheduc!=16 &!missing(motheduc)

	tab1 educmoth1 educmoth2 mother_educ

	* Parental education(both mother and father)
	replace fatheduc=motheduc if fatheduc==.
	replace motheduc=fatheduc if motheduc==.
	replace fatheduc=0 if fatheduc==.&motheduc==.&!missing(fatheduc)
	replace motheduc=0 if fatheduc==.&motheduc==.&!missing(motheduc)

	gen paeducf=fatheduc if fatheduc>=motheduc
	replace paeducf=motheduc if fatheduc<motheduc
	tab paeducf
	gen parental=.
	replace parental=1 if paeducf<=3
	replace parental=2 if paeducf>=4&paeducf<=6
	replace parental=3 if paeducf>=7&paeducf<=18&!missing(paeducf)
	* label define parental education  
	label define parental_educ 1 "No schooling" 2 "Primary" 3 "Sec&above"
	label values parental parental_educ
	tab parental

	*creating dummuy variables for parental education
	gen paeduc1=0
	gen paeduc2=0
	replace paeduc1=1 if paeducf>=4&paeducf<=6
	replace paeduc2=1 if paeducf>=7& paeducf<=18
	tab paeduc1
	tab paeduc2

	*/
	* religiousity index(adolescent)
	tab relig
	sum relig
	* Place
	tab1 place
	gen residence=.
	replace residence=1 if place==1
	replace residence=2 if place==2
	replace residence=3 if place==3 &!missing(place)
	tab residence
	* label define place  
	label define residence_1 1 "Urban" 2 "Semiurban" 3 "Rural"
	label values residence residence_1
	tab residence
	gen urban=.
	replace urban=1 if residence==1
	replace urban=0 if residence==2|residence==3
	tab urban

	gen rural=.
	replace rural=1 if residence==3
	replace rural=0 if residence==1|residence==2
	tab rural


	tab house
	sum house
	tab sanit
	sum sanit
	*/
	tab vulner
	sum vulner
	tab serill

	//diet diversity score
	sum dietdiv, detail
	sum dd_score,detail
	tab dd_index_david
	*source of drinking water supply and garbage
	tab garb_dispos
	tab source_drink
	tab hadtoilet
	*work index-r1
	tab workind
	sum workind
	*Wealth index (dhs)
	tab dhswind
	qladder dhswind

	sum dhswind
	sum sesrural 
	sum sesurban

	* hhincome
	tab hhincome
	qladder hhincome
	gen hhincome_s =sqrt(hhincome)

	*household income based on tertile
	tab hh_income_2

	* Wealth index (dhs)
	alpha hc2 hc20_1 hc20_2 hc20_3 hc20_4 hc20_5 hc20_6 hc3 hc4 hc20_18  hc15 hc11 hc18 hc20_12 hc20_16 hc20_13,item label asis
	egen wealth=rowmean(hc2 hc20_1 hc20_2 hc20_3 hc20_4 hc20_5 hc20_6 hc20_18  hc15 hc3 hc4  hc11 hc18 hc20_12 hc20_16 hc20_13)
	summarize wealth,detail
	hist wealth,norm freq

	alpha hc20_1 hc20_2 hc20_6 hc20_7 hc20_9 hc3 hc6 hc18 hc15 hc20_16,item label asis
	factor hc20_1 hc20_2 hc20_6 hc20_7 hc3 hc6 hc18 hc15 hc20_16 , pcf
	predict wealth_indexf1 wealth_indexf2

	centile wealth_indexf1, centile(33.3, 66.7)

	gen SES=0
	replace SES=1 if wealth_indexf1 < = -.6515729
	replace SES=2 if wealth_indexf1>.4017634 & wealth_indexf1!=.
	tab SES

	label var SES "socio-economic score"
	label define SES1 0 "low" 2 "high" 1 "average"
	label values SES SES1
	tab SES

	* Wealth index (dhs)
	alpha hc2 hc20_1 hc20_2 hc20_3 hc20_4 hc20_5 hc20_6 hc3 hc4 hc20_18  hc15 hc11 hc18 hc20_12 hc20_16 hc20_13,item label asis
	egen wealth1=rowmean(hc2 hc20_1 hc20_2 hc20_3 hc20_4 hc20_5 hc20_6 hc20_18  hc15 hc3 hc4  hc11 hc18 hc20_12 hc20_16 hc20_13)
	summarize wealth1,detail
	hist wealth1,norm freq

	** alpha when all variables are included
	alpha hc2 hc20_1 hc20_2 hc20_3 hc20_4 hc20_5 hc20_6 hc3 hc4 hc20_18  hc15 hc11 hc18 hc20_12 hc20_16 hc20_13,item label asis
	factor hc2 hc20_1 hc20_2 hc20_3 hc20_4 hc20_5 hc20_6 hc3 hc4 hc20_18  hc15 hc11 hc18 hc20_12 hc20_16 hc20_13, pcf
	predict wealth_indexf3 


	centile wealth_indexf3, centile(33.3, 66.7)
	gen SES_1=0
	replace SES_1=1 if wealth_indexf3<= -.3713825 
	replace SES_1=2 if wealth_indexf3> .4228686 & wealth_indexf3!=.
	tab SES_1

	label var SES_1 "socio-economic score"
	label define SES_11 0 "low" 2 "high" 1 "average"
	label values SES_1 SES_11
	tab SES_1

	
	/**wealth status-round 2 
	 tab1 h2c1 h2c10 h2c11 h2c12 h2c13 h2c14 h2c15 h2c16_1 h2c16_2 h2c17 h2c18 h2c19 h2c2 h2c20 h2c21 h2c22 h2c23 h2c24 h2c25 h2c26_1 h2c26_10 h2c26_11 h2c26_12 h2c26_13 ///
	  h2c26_14 h2c26_15 h2c26_16 h2c26_17 h2c26_18 h2c26_19 h2c26_2 h2c26_20 h2c26_21 h2c26_22 h2c26_23 h2c26_24 h2c26_3 h2c26_4 h2c26_5 h2c26_6 h2c26_7 h2c26_8 h2c26_9 ///
	  h2c27_1a h2c27_1b h2c27_2a h2c27_2b h2c27_3a h2c27_3b h2c27_4a h2c27_4b h2c27_5a h2c27_5b h2c27_6a h2c27_6b h2c3 h2c30 h2c31 h2c32
	
	** round 4 diet diversity
	*Diet diversity-FFQ
	  A4R1PERWEEK A4R1PERMONTH A4R2PERDAY A4R2PERWEEK A4R2PERMONTH A4R3PERDAY A4R3PERWEEK A4R3PERMONTH A4R4PERDAY A4R4PERWEEK A4R4PERMONTH A4R5PERDAY ///
	  A4R5PERWEEK A4R5PERMONTH A4R6PERDAY A4R6PERWEEK A4R6PERMONTH A4R7PERDAY A4R7PERWEEK A4R7PERMONTH A4R8PERDAY A4R8PERWEEK A4R8PERMONTH A4R9PERDAY A4R9PERWEEK ///
	  A4R9PERMONTH A4R10PERDAY A4R10PERWEEK A4R10PERMONTH A4R11PERDAY A4R11PERWEEK A4R11PERMONTH A4R12PERDAY A4R12PERWEEK A4R12PERMONTH A4R13PERDAY A4R13PERWEEK ///
	  A4R13PERMONTH A4R14PERDAY A4R14PERWEEK A4R14PERMONTH A4R15PERDAY A4R15PERWEEK A4R15PERMONTH A4R16PERDAY A4R16PERWEEK A4R16PERMONTH A4R17PERDAY A4R17PERWEEK ///
	  A4R17PERMONTH A4R18PERDAY A4R18PERWEEK A4R18PERMONTH A4R19PERDAY A4R19PERWEEK A4R19PERMONTH A4R20PERDAY A4R20PERWEEK A4R20PERMONTH A4R21PERDAY A4R21PERWEEK ///
	  A4R21PERMONTH A4R22PERDAY A4R22PERWEEK A4R22PERMONTH A4R23PERDAY A4R23PERWEEK A4R23PERMONTH A4R24PERDAY A4R24PERWEEK A4R24PERMONTH A4R25PERDAY A4R25PERWEEK ///
	  A4R25PERMONTH A4R26PERDAY A4R26PERWEEK A4R26PERMONTH A4R27PERDAY A4R27PERWEEK A4R27PERMONTH A4R28PERDAY A4R28PERWEEK A4R28PERMONTH A4R29PERDAY A4R29PERWEEK ///
	  A4R29PERMONTH A4R30PERDAY A4R30PERWEEK A4R30PERMONTH A4R31PERDAY A4R31PERWEEK A4R31PERMONTH A4R1PERDAY
	*/
	*fam size
	tab members
	*fam head
	tab femhead
	*social support ND NETWORK
	tab nethelp
	sum nethelp
	sum netgive 
	sum netexch
	** Economic stress/shock
	*/

	*food insecurity status for each round
	********************************************food security-r1 
	tab ak1
	tab ak2
	tab ak3
	tab ak4 
	alpha ak1 ak2 ak3 ak4
	/*Test scale = mean(unstandardized items)

	Average interitem covariance:     .0863326
	Number of items in the scale:            4
	Scale reliability coefficient:      0.8254
	*/
	pca ak1 ak2 ak3 ak4
	correlate ak1 ak2 ak3 ak4
	summarize ak1 ak2 ak3 ak4
	recode ak1 (1=0)
	recode ak1 (2=1)
	recode ak1 (3=1)
	recode ak1 (4=1)
	tab ak1

	recode ak2 (1=0)
	recode ak2 (2=1)
	recode ak2 (3=1)
	recode ak2 (4=1)
	tab ak2

	recode ak3 (1=0)
	recode ak3 (2=1)
	recode ak3 (3=1)
	recode ak3 (4=1)
	tab ak3

	recode ak4 (1=0)
	recode ak4 (2=1)
	recode ak4 (3=1)
	recode ak4 (4=1)
	tab ak4
	alpha ak1 ak2 ak3 ak4
	/*after recoding
	Test scale = mean(unstandardized items)

	Average interitem covariance:     .0428264
	Number of items in the scale:            4
	Scale reliability coefficient:      0.7798 */

	egen foodsecr1 =rsum(ak1 ak2 ak3 ak4)
	tab foodsecr1
	gen foodinsec1=0
	replace foodinsec1=1 if foodsecr1==1|foodsecr1==2|foodsecr1==3|foodsecr1==4
	tab foodinsec1

	egen sevfoodr1=rsum(ak2 ak3)
	gen sevfood1=0
	replace sevfood1=1 if sevfoodr1==1|sevfoodr1==2
	tab sevfood1

	***************************************************************************************** food security round 2
	alpha A2A48 A2A49 A2A50 A2A51 A2A52
	/*Test scale = mean(unstandardized items)
	Average interitem covariance:     .1160945
	Number of items in the scale:            5
	Scale reliability coefficient:      0.7961
	*/
	pca A2A48 A2A49 A2A50 A2A51 A2A52
	correlate A2A48 A2A49 A2A50 A2A51 A2A52
	summarize A2A48 A2A49 A2A50 A2A51 A2A52
	recode A2A48 (1=0)
	recode A2A48 (2=1)
	recode A2A48 (3=1)
	recode A2A48 (4=1)
	tab A2A48
	recode A2A49 (1=0)
	recode A2A49 (2=1)
	recode A2A49 (3=1)
	recode A2A49 (4=1)
	tab A2A49

	recode A2A50 (1=0)
	recode A2A50 (2=1)
	recode A2A50 (3=1)
	recode A2A50 (4=1)
	tab A2A50

	recode A2A51 (1=0)
	recode A2A51 (2=1)
	recode A2A51 (3=1)
	recode A2A51 (4=1)
	tab A2A51

	recode A2A52 (1=0)
	recode A2A52 (2=1)
	recode A2A52 (3=1)
	recode A2A52 (4=1)
	tab A2A52
	alpha A2A48 A2A49 A2A50 A2A51 A2A52
	/*Test scale = mean(unstandardized items)
	Average interitem covariance:     .0749571
	Number of items in the scale:            5
	Scale reliability coefficient:      0.8019
	end of do-file
	*/
	egen foodsecr2 =rsum(A2A48 A2A49 A2A50 A2A51 A2A52)
	tab foodsecr2
	gen foodinsec2=0
	replace foodinsec2=1 if foodsecr2==1|foodsecr2==2|foodsecr2==3|foodsecr2==4|foodsecr2==5
	tab foodinsec2

	egen sevfoodr2 =rsum(A2A49 A2A50 A2A51)
	gen sevfood2=0
	replace sevfood2=1 if sevfoodr2==1|sevfoodr2==2|sevfoodr2==3
	tab sevfood2

	************************************************************************************************** food sec round 3
	tab1 A3C1 A3C2 A3C3 A3C4 A3C5
	alpha A3C1 A3C2 A3C3 A3C4 A3C5
	pca A3C1 A3C2 A3C3 A3C4 A3C5
	correlate A3C1 A3C2 A3C3 A3C4 A3C5
	summarize A3C1 A3C2 A3C3 A3C4 A3C5
	recode A3C1 (1=0)
	recode A3C1 (2=1)
	recode A3C1 (3=1)
	recode A3C1 (4=1)
	tab A3C1
	recode A3C2 (1=0)
	recode A3C2 (2=1)
	recode A3C2 (3=1)
	recode A3C2 (4=1)
	tab A3C2
	recode A3C3 (1=0)
	recode A3C3 (2=1)
	recode A3C3 (3=1)
	recode A3C3 (4=1)
	tab A3C3
	recode A3C4 (1=0)
	recode A3C4 (2=1)
	recode A3C4 (3=1)
	recode A3C4 (4=1)
	tab A3C4
	recode A3C5 (1=0)
	recode A3C5 (2=1)
	recode A3C5 (3=1)
	recode A3C5 (4=1)
	tab A3C5
	tab1 A3C1 A3C2 A3C3 A3C4 A3C5
	gen A3C1_1=.
	replace A3C1_1=1 if A3C1==1
	replace A3C1_1=0 if A3C1!=1 
	tab A3C1_1

	alpha A3C1_1 A3C2 A3C3 A3C4 A3C5
	/*Test scale = mean(unstandardized items)

	Average interitem covariance:     .0659085
	Number of items in the scale:            5
	Scale reliability coefficient:      0.8607
	*/
	egen foodsecr3 =rsum(A3C1_1 A3C2 A3C3 A3C4 A3C5)
	tab foodsecr3
	gen foodinsec3=0
	replace foodinsec3=1 if foodsecr3==1|foodsecr3==2|foodsecr3==3|foodsecr3==4|foodsecr3==5
	tab foodinsec3

	tab1 foodsecr1 foodsecr2 foodsecr3
	tab1 foodinsec1 foodinsec2 foodinsec3

	egen sevfoodr3 =rsum(A3C2 A3C3 A3C4)
	gen sevfood3=0
	replace sevfood3=1 if sevfoodr3==1|sevfoodr3==2|sevfoodr3==3
	tab sevfood3
	****************************************************************************************Food insecurity round 4
	 tab1 A4A1 A4A2 A4A3 A4A4 A4A5
	 recode A4A5 (0=1)
	 tab1 A4A1 A4A2 A4A3 A4A4 A4A5
	 alpha  A4A1 A4A2 A4A3 A4A4 A4A5
	 pca  A4A1 A4A2 A4A3 A4A4 A4A5
	 summarize A4A1 A4A2 A4A3 A4A4 A4A5

	recode A4A1 (1=0)
	recode A4A1 (2=1)
	recode A4A1 (3=1)
	recode A4A1 (4=1)
	tab A4A1

	recode A4A2 (1=0)
	recode A4A2 (2=1)
	recode A4A2 (3=1)
	recode A4A2 (4=1)
	tab A4A2

	recode A4A3 (1=0)
	recode A4A3 (2=1)
	recode A4A3 (3=1)
	recode A4A3 (4=1)
	tab A4A3

	recode A4A4 (1=0)
	recode A4A4 (2=1)
	recode A4A4 (3=1)
	recode A4A4 (4=1)
	tab A4A4

	recode A4A5 (1=0)
	recode A4A5 (2=1)
	recode A4A5 (3=1)
	recode A4A5 (4=1)
	tab A4A5

	 tab1 A4A1 A4A2 A4A3 A4A4 A4A5
	 alpha A4A1 A4A2 A4A3 A4A4 A4A5
	 

	egen foodsecr4 =rsum(A4A1 A4A2 A4A3 A4A4 A4A5)
	tab foodsecr4
	gen foodinsec4=0
	replace foodinsec4=1 if foodsecr4==1|foodsecr4==2|foodsecr4==3|foodsecr4==4|foodsecr4==5
	tab foodinsec4
	 
	 	*Household food insecurity-r1
	tab1 hd1_1 hd1_2 hd1_5 hd1_6
	recode hd1_5 (8888=1)
	alpha hd1_1 hd1_2 hd1_5 hd1_6
	pca hd1_1 hd1_2 hd1_5 hd1_6
	correlate hd1_1 hd1_2  hd1_5 hd1_6
	egen hhfinsec1=rsum(hd1_1 hd1_2 hd1_5 hd1_6)
	tab hhfinsec1
	
	gen hhfinsec_1=0
	replace hhfinsec_1=1 if hhfinsec1==1|hhfinsec1==2|hhfinsec1==3|hhfinsec1==4
	tab hhfinsec_1

	tab1 foodsecr1 foodsecr2 foodsecr3 
	tab1 foodinsec1 foodinsec2 foodinsec3 
	
	**household food insecurity round 2
	tab1 h2d11 h2d12 h2d13 h2d14 h2d15 h2d16
	alpha h2d11 h2d12 h2d13 h2d14 h2d15 h2d16
	pca h2d11 h2d12 h2d13 h2d14 h2d15 h2d16
	correlate h2d11 h2d12 h2d13 h2d14 h2d15 h2d16
	egen hhfinsec2=rsum(h2d11 h2d12 h2d13 h2d14 h2d15 h2d16)
	tab hhfinsec2
	
	gen hhfinsec_2=0
	replace hhfinsec_2=1 if hhfinsec2==1|hhfinsec2==2|hhfinsec2==3|hhfinsec2==4|hhfinsec2|hhfinsec2==6
	tab hhfinsec_2

		
	* General Health self rated health status -r1 (outcome variables)
	tab ae1
	rename ae1 srh1
	tab srh1


	gen health1=.
	replace health1=1 if srh1==2|srh1==3|srh1==4
	replace health1=0 if srh1==1
	tab health1


	*Tired/ lack of energy
	tab ae2
	gen tired1=.
	replace tired1=1 if ae2==1|ae2==2|ae2==3
	replace tired1=0 if ae2==4
	tab tired1

	*difficulty
	tab ae3
	gen difficult1=.
	replace difficult1=1 if ae3==1|ae3==2|ae3==3
	replace difficult1=0 if ae3==4
	tab difficult1

	*last time sick
	tab ae4
	gen illness1=0
	replace illness1=1 if ae4==1|ae4==2|ae4==3
	tab illness1
	
	**self rated health -4th round
 
	ta A4B5
	rename A4B5 srh4
	gen health4=.
	replace health4=1 if srh4==2|srh4==3|srh4==4
	replace health4=0 if srh4==1
	tab health4
	
	* feel tired
	tab A4B6
	gen tired4=0
	replace tired4=1 if A4B6==1|A4B6==2|A4B6==3
	tab tired4

	*had difficulty
	tab A4B7
	gen difficult4=0
	replace difficult4=1 if A4B7==1|A4B7==2|A4B7==3
	tab difficult4
	
	*PSYCOMATIC HEALTH COMPLAINTS_r1
	tab ae5
	rename ae5 fever1
	tab ae6
	rename ae6 cough1
	tab ae7
	rename ae7 breath1
	tab ae8
	rename ae8 diarhea1
	tab ae9
	rename ae9 vomit1
	tab ae10
	rename ae10 eat1
	tab ae11
	rename ae11 apain1
	tab ae12
	rename ae12 ulcer1
	tab ae13
	rename ae13 depress1
	tab ae14
	rename ae14 others1
	tab ae15
	rename ae15 injury1
	tab injury1

	* physical health index 1
	egen physical1 = rsum(fever1 cough1 breath1 diarhea1 vomit1 eat1 apain1 ulcer1 injury1 depress1 others1) 
	tab physical1

	* risk factors_r1
	tab af1
	tab af2
	tab af3
	tab af4
	tab af5
	tab af6
	tab af7
	tab af8
	*smoking by someone in HH
	rename af4 smoke1
	tab smoke1

	*comsumption of beer_r1
	gen beer1=0
	replace beer1=1 if af5==1|af5==2|af5==3|af5==4|af5==5
	tab beer1
	gen localbr1=0
	replace localbr1=1 if af6==1|af6==2|af6==3|af6==4|af6==5|af6==7
	tab localbr1
	*Tej_r1
	gen tej1=0
	replace tej1=1 if af7==1|af7==2|af7==3
	tab tej1
	*khat-r1
	gen khat1=0
	replace khat1=1 if af8==1|af8==2|af8==3|af8==4|af8==5|af8==6|af8==7
	tab khat1
	*********************************************************************************************************************************************
	* compute multiple risk behaviors
	egen riskfact1=rsum( af1 af2 beer1 localbr1 khat1 tej1)
	tab riskfact1

	gen riskfac1=.
	replace riskfac1=1 if riskfact1==1|riskfact1==2| riskfact1==3|riskfact1==4
	replace riskfac1=0 if riskfact1!=1&riskfact1!=2&riskfact1!=3&riskfact1!=4&!missing(riskfact1)
	tab riskfac1

	*self rated health status round 2
	* general health-r2
	tab A2A40
	rename A2A40 srh2
	ta srh2

	recode srh2(8889=4)
	tab srh2

	gen health2=.
	replace health2=1 if srh2==2|srh2==3|srh2==4
	replace health2=0 if srh2==1
	tab health2

	* feel tired-r2
	tab A2A41
	gen tired2=0
	replace tired2=1 if A2A41==1|A2A41==2|A2A41==3
	tab tired2
	*had difficulty-r2
	tab A2A42
	gen difficult2=0
	replace difficult2=1 if A2A42==1|A2A42==2|A2A42==3
	tab difficult2
	*last time sick
	tab A2A43
	gen illness2=0
	replace illness2=1 if A2A43==1|A2A43==2|A2A43==3
	tab illness2

	*PSYCOMATIC HEALTH COMPLAINTS-round2
	tab A2A44_1
	gen fever2=.
	replace fever2=1 if A2A44_1==1
	replace fever2=0 if A2A44_1==8888|A2A44_1==0
	tab fever2

	tab A2A44_2
	gen cough2=.
	replace cough2=1 if A2A44_2==1
	replace cough2=0 if A2A44_2==8888|A2A44_1==0
	tab cough2

	tab A2A44_3
	gen breath2=.
	replace breath2=1 if A2A44_3==1
	replace breath2=0 if A2A44_3==8888|A2A44_3==0
	tab breath2

	tab A2A44_4
	gen diarhea2=.
	replace diarhea2=1 if A2A44_4==1
	replace diarhea2=0 if A2A44_4==8888|A2A44_4==0
	tab diarhea2

	tab A2A44_5
	gen vomit2=.
	replace vomit2=1 if A2A44_5==1
	replace vomit2=0 if A2A44_5==8888|A2A44_5==0
	tab vomit2

	tab A2A44_6
	gen eat2=.
	replace eat2=1 if A2A44_6==1
	replace eat2=0 if A2A44_6==8888|A2A44_6==0
	tab eat2

	tab A2A44_7
	gen apain2=.
	replace apain2=1 if A2A44_7==1
	replace apain2=0 if A2A44_7==8888|A2A44_7==0
	tab apain2

	tab A2A44_8
	gen ulcer2=.
	replace ulcer2=1 if A2A44_8==1
	replace ulcer2=0 if A2A44_8==8888|A2A44_8==0
	tab ulcer2

	tab A2A44_9
	gen depress2=.
	replace depress2=1 if A2A44_9==1
	replace depress2=0 if A2A44_9==8888|A2A44_9==0
	tab depress2

	tab A2A44_10
	gen others2=.
	replace others2=1 if A2A44_10==1
	replace others2=0 if A2A44_10==8888|A2A44_10==0
	tab others2

	* physical health index 2
	egen physical2= rsum(fever2 cough2 diarhea2 breath2 eat2 ulcer2 vomit2 depress2 apain2 others2)
	tab physical2

	*risk factors_round 2

	* someone smokes in HH
	tab A2A63
	rename A2A63 smokee2
	tab smokee2
	tab smokee2, miss
	gen smoke2=0
	replace smoke2=1 if smokee2==1
	ta smoke2

	*beer consumption 
	tab A2A64
	gen beer2=0
	replace beer2=1 if A2A64==1|A2A64==2|A2A64==3|A2A64==4|A2A64==5
	tab beer2
	*local beer
	tab A2A65
	gen localbr2=0
	replace localbr2=1 if A2A65==1|A2A65==2|A2A65==3|A2A65==4|A2A65==5|A2A65==6|A2A65==7
	tab localbr2
	tab A2A66
	*drink tej
	gen tej2=0
	replace tej2=1 if A2A66==1|A2A66==2|A2A66==3|A2A66==4|A2A66==7
	tab tej2
	*khat use
	tab A2A67
	gen khat2=0
	replace khat2=1 if A2A67==1|A2A67==2|A2A67==3|A2A67==4|A2A67==5|A2A67==6|A2A67==7
	tab khat2

	*compute multiple risk factors 
	egen riskfact2=rsum( beer2 khat2 localbr2 tej2)
	tab riskfact2

	/*gen riskfac2=.
	replace riskfac2=1 if riskfact2==0|riskfact2==1|riskfact2==2| riskfact2==3|riskfact2==5|riskfact2==6|riskfact2==8
	replace riskfac=0 if riskfact2==8888|riskfact2=8889| riskfact2=8890|riskfact2=8891|riskfact2=8892
	tab riskfac2*/
	*************************************************************************************************************************************************
	*self rated health status round 3
	* general health
	tab A3B11
	recode A3B11 (0=4)
	rename A3B11 srh3
	tab srh3

	gen health3=.
	replace health3=1 if srh3==2|srh3==3|srh3==4
	replace health3=0 if srh3==1
	tab health3
	* feel tired
	tab A3B12
	gen tired3=0
	replace tired3=1 if A3B12==1|A3B12==2|A3B12==3
	tab tired3

	*had difficulty
	tab A3B13
	gen difficult3=0
	replace difficult3=1 if A3B13==1|A3B13==2|A3B13==3
	tab difficult3

	*last time sick
	tab A3B14
	gen illness3=0
	replace illness3=1 if A3B14==1|A3B14==2|A3B14==3
	tab illness3

	*PSYCOMATIC HEALTH COMPLAINTS-round3
	tab A3B15_1
	gen fever3=.
	replace fever3=1 if A3B15_1==1
	replace fever3=0 if A3B15_1==.|A3B15_1==0
	tab fever3

	tab A3B15_2
	gen cough3=.
	replace cough3=1 if A3B15_2==1
	replace cough3=0 if A3B15_2==.|A3B15_2==0
	tab cough3

	tab A3B15_3
	gen breath3=.
	replace breath3=1 if A3B15_3==1
	replace breath3=0 if A3B15_3==.|A3B15_3==0
	tab breath3

	tab A3B154_4
	gen diarhea3=.
	replace diarhea3=1 if A3B154_4==1
	replace diarhea3=0 if A3B154_4==.|A3B154_4==0
	tab diarhea3

	tab A3B15_5
	gen vomit3=.
	replace vomit3=1 if A3B15_5==1
	replace vomit3=0 if A3B15_5==.|A3B15_5==0
	tab vomit3

	tab A3B15_6
	gen eat3=.
	replace eat3=1 if A3B15_6==1
	replace eat3=0 if A3B15_6==.|A3B15_6==0
	tab eat3

	tab A3B15_7
	gen apain3=.
	replace apain3=1 if A3B15_7==1
	replace apain3=0 if A3B15_7==.|A3B15_7==0
	tab apain3

	tab A3B15_8
	gen ulcer3=.
	replace ulcer3=1 if A3B15_8==1
	replace ulcer3=0 if A3B15_8==.|A3B15_8==0
	tab ulcer3

	tab A3B15_9
	gen depress3=.
	replace depress3=1 if A3B15_9==1
	replace depress3=0 if A3B15_9==.|A3B15_9==0
	tab depress3

	tab A3B15_10a
	gen others3=.
	replace others3=1 if A3B15_10a==1
	replace others3=0 if A3B15_10a==.|A3B15_10a==0
	tab others3

	tab A3B17a
	gen injury3=.
	replace injury3=1 if A3B17a==1
	replace injury3=0 if A3B17a==.|A3B17a==0
	tab injury3

	* physical health index
	egen physical3= rsum( fever3 cough3 breath3 vomit3 diarhea3 ulcer3 depress3 others3 injury3 apain3 eat3)
	tab physical3

	* risk factors round3
	*smoke cigrete
	tab A3B20
	gen smoke3=0
	replace smoke3=1 if A3B20==1|A3B20==2|A3B20==3|A3B20==4|A3B20==5|A3B20==7
	tab smoke3
	*someone smoke in the HH
	tab A3B21
	* alcohol
	tab A3B22
	gen beer3=0
	replace beer3=1 if A3B22==1|A3B22==2|A3B22==3|A3B22==4|A3B22==7
	tab beer3
	*localbr
	tab A3B23
	gen localbr3=0
	replace localbr3=1 if A3B23==1|A3B23==2|A3B23==3|A3B23==4|A3B23==5|A3B23==6|A3B23==7
	tab localbr3
	*khat use
	tab A3B25
	gen khat3=0
	replace khat3=1 if A3B25==1|A3B25==2|A3B25==3|A3B25==4|A3B25==5|A3B25==6|A3B25==7
	tab khat3
	* ever had sexual intercourse r3tab A3G8
	recode A3G7_6 (8888=2222)
	recode A3G7_6 (329=2222)
	recode A3G7_6 (479=2222)
	recode A3G7_6 (562=2222)
	recode A3G8  (16=2222)
	recode A3G8 (505=2222)
	recode A3G8 (619=2222) 
	recode A3G8 (759=2222)
	recode A3G8 (8888=2222)
	recode A3G8 (1=1111)
	replace A3G8=2222 if A3G8==.
	replace A3A12=1 if A3A6==1 
	replace A3G8=1111 if A3A6==1
	replace A3G8=1111 if (A3A12==1&A3G8==2222&(A3G10==1|A3G10==2))
	replace A3A12=0 if (A3A12 ==1&A3G8==2222& A3G9==8888&A3G10==8888)
	replace A3G8=1111 if((A3G9>10&A3G9<25)&A3G8==2222)
	replace A3G8=1111 if (A3G7_6==1111 & A3G8==2222)
	replace A3G8=1111 if (A3H14==1111 &(A3H18==1111|A3H19==1111)&A3G8==2222)
	tab A3G8
	gen A3G8_1=0
	replace A3G8_1=1 if A3G8==1111
	tab A3G8_1
	*multiple risk factors index
	egen riskfact3=rsum(A3B21 beer3 localbr3 khat3 A3G8_1)
	tab riskfact3
	/*mental health questionnaire -round 4
	tab1 A4B8 A4B9 A4B10 A4B11 A4B12 A4B13 A4B14 A4B15 A4B16 A4B17 A4B18 A4B19 //
	A4B20 A4B21 A4B22 A4B23 A4B24 A4B25 A4B26 A4B27 A4B28 A4B29 A4B30
	*/
*multipel risk factor- round 4
	tab1 A4B31 A4B32 A4B33 A4B34 A4B35 A4B36 A4B37
	ta A4B31
	gen smoke4=0
	replace smoke4=1 if A4B31==1|A4B31==2|A4B31==3|A4B31==4|A4B31==5|A4B31==7
	**beer
	gen beer4=0
	replace beer4=1 if A4B34==1|A4B34==2|A4B34==3|A4B34==4|A4B34==5|A4B34==7
	**khat use
	gen khat4=0
	replace khat4=1 if A4B37==1|A4B37==2|A4B37==3|A4B37==4|A4B37==5|A4B37==6|A4B37==7
	*multiple risk factors index
	egen riskfact4=rsum(smoke4 beer4 khat4)
	tab riskfact4
	
	** ever had sex-round 4
	ta A4D9
	**ever been pregnant-round 4 
	ta  A4E19
	****************************************************************************************************************************************************
	*Lifecourse barriers-round 3- the higher score corresponds to high percieved life course barrier
	tab A3D8_1
	gen lc1=0
	replace lc1=1 if A3D8_1==4
	replace lc1=2 if A3D8_1==3
	replace lc1=3 if A3D8_1==2
	replace lc1=4 if A3D8_1==1
	tab lc1

	tab A3D8_2
	gen lc2=0
	replace lc2=1 if A3D8_2==4
	replace lc2=2 if A3D8_2==3
	replace lc2=3 if A3D8_2==2
	replace lc2=4 if A3D8_2==1
	tab lc2

	tab A3D8_1
	gen lc3=0
	replace lc3=1 if A3D8_3==4
	replace lc3=2 if A3D8_3==3
	replace lc3=3 if A3D8_3==2
	replace lc3=4 if A3D8_3==1
	tab lc3

	tab A3D8_4
	gen lc4=0
	replace lc4=1 if A3D8_4==4
	replace lc4=2 if A3D8_4==3
	replace lc4=3 if A3D8_4==2
	replace lc4=4 if A3D8_4==1
	tab lc4

	tab A3D8_5
	gen lc5=0
	replace lc5=1 if A3D8_5==4
	replace lc5=2 if A3D8_5==3
	replace lc5=3 if A3D8_5==2
	replace lc5=4 if A3D8_5==1
	tab lc5

	tab A3D8_6
	gen lc6=0
	replace lc6=1 if A3D8_6==4
	replace lc6=2 if A3D8_6==3
	replace lc6=3 if A3D8_6==2
	replace lc6=4 if A3D8_6==1
	tab lc6

	tab A3D8_7
	gen lc7=0
	replace lc7=1 if A3D8_7==4
	replace lc7=2 if A3D8_7==3
	replace lc7=3 if A3D8_7==2
	replace lc7=4 if A3D8_7==1
	tab lc7

	tab A3D8_8
	gen lc8=0
	replace lc8=1 if A3D8_8==4
	replace lc8=2 if A3D8_8==3
	replace lc8=3 if A3D8_8==2
	replace lc8=4 if A3D8_8==1
	tab lc8

	tab A3D8_9
	gen lc9=0
	replace lc9=1 if A3D8_9==4
	replace lc9=2 if A3D8_9==3
	replace lc9=3 if A3D8_9==2
	replace lc9=4 if A3D8_9==1
	tab lc9

	alpha lc1 lc2 lc3 lc4 lc5 lc6 lc7 lc8 lc9 
	pca lc1 lc2 lc3 lc4 lc5 lc6 lc7 lc8 lc9  
	correlate lc1 lc2 lc3 lc4 lc5 lc6 lc7 lc8 lc9  
	summarize lc1 lc2 lc3 lc4 lc5 lc6 lc7 lc8 lc9 
	screeplot
	egen lifecourse = rsum (lc1 lc2 lc3 lc4 lc5 lc6 lc7 lc8 lc9)
	tab lifecourse
	sum lifecourse
	*self image-round 3 (the higher score corresponds to low self image)
	alpha A3D9_1 A3D9_2 A3D9_3 A3D9_4 A3D9_5 A3D9_6 A3D9_7 A3D9_8 A3D9_9 A3D9_10 A3D9_11 A3D9_12
	pca A3D9_1 A3D9_2 A3D9_3 A3D9_4 A3D9_5 A3D9_6 A3D9_7 A3D9_8 A3D9_9 A3D9_10 A3D9_11 A3D9_12 
	correlate A3D9_1 A3D9_2 A3D9_3 A3D9_4 A3D9_5 A3D9_6 A3D9_7 A3D9_8 A3D9_9 A3D9_10 A3D9_11 A3D9_12
	summarize A3D9_1 A3D9_2 A3D9_3 A3D9_4 A3D9_5 A3D9_6 A3D9_7 A3D9_8 A3D9_9 A3D9_10 A3D9_11 A3D9_12
	screeplot
	egen selfimage = rsum (A3D9_1 A3D9_2 A3D9_3 A3D9_4 A3D9_5 A3D9_6 A3D9_7 A3D9_8 A3D9_9 A3D9_10 A3D9_11 A3D9_12)
	tab selfimage
	sum selfimage

	*self efficcacy-round 3- the higher score corresponds to the higher self efficacy
	gen se6=0
	replace se6=1 if A3D11_6==4
	replace se6=2 if A3D11_6==3
	replace se6=3 if A3D11_6==2
	replace se6=4 if A3D11_6==1
	tab se6

	gen se7=0
	replace se7=1 if A3D11_7==4
	replace se7=2 if A3D11_7==3
	replace se7=3 if A3D11_7==2
	replace se7=4 if A3D11_7==1
	tab se7
	alpha A3D11_1 A3D11_2 A3D11_3 A3D11_4 A3D11_5 se6 se7
	pca A3D11_1 A3D11_2 A3D11_3 A3D11_4 A3D11_5 se6 se7
	correlate A3D11_1 A3D11_2 A3D11_3 A3D11_4 A3D11_5 se6 se7
	summarize A3D11_1 A3D11_2 A3D11_3 A3D11_4 A3D11_5 se6 se7
	screeplot
	egen efficacy = rsum (A3D11_1 A3D11_2 A3D11_3 A3D11_4 A3D11_5 se6 se7)
	tab efficacy
	sum efficacy


	
	gen chronicfd=0
	replace chronicfd=1 if chronic_hhfis_2==1
	ta chronicfd
		*Anthropometry data 
		*Define Age
		gen sex=aa6sex
		recode sex (0=2) (1=1)
		lab define sexlb 1"male" 2"female"
		lab values sex sexlb

		gen str6 ageunit="months"				/* or gen ageunit="days", gen ageunit="years" */
		lab var ageunit "months"
		
		*table on socio demographic characteristics 

	preserve
	table1,vars (religion cat\sex cat\age3 contn\education3 cat\hhincome_s contn\hh_income_2 cat \dhswind contn\foodinsec1 cat\foodinsec2 cat\foodinsec3 cat\dietdiv contn\dd_score contn\parental cat\ residence cat \health1 bin\ health2 bin\health3 bin\femhead bin\khat3 bin\illness3 bin\efficacy contn\ lifecourse contn\selfimage contn)format(%2.1f)onecol plusminus clear
	replace value=subinstr(value, "%", "", .)
	restore

	
	
	
	*Body mass Index-r1
	rename am1 weight1
	rename am2 height1

	rename A2H1 weight2
	rename A2H2 height2

	rename A3M1 weight3
	rename A3M2 height3

	rename A4U1 weight4
	rename A4U2A height4
		
foreach var in height1 height2 height3 height4 weight1 weight2 weight3 weight4  {
	recode `var' 7777=. 
	recode `var' 999.99=.
	recode `var' 99.99=.
	}
replace weight2=weight2*100 if weight2<1 & weight2>0	
replace height2=height2*100 if height2>1 & height2<2	

*weight1
count if kg1!=weight1
list personid kg1 weight1 if kg1!=weight1 
list age1 kg1 weight1 kg2 weight2 KG3 weight3  if personid==20069207
replace weight1=55.8 if personid==20069207
 
 list personid age1 kg1 weight1 weight2 weight3 weight4 if weight1<=20|weight1>=70
 replace weight1=(weight2+weight3)/2 if personid==40037504
 
 **Note personid 11056205 has weight1=18 but no subsequent measurements//


*weight2
count if kg2!=weight2
replace weight2 =54.7 if personid==10065202
recode weight2 165.5=65.6 if personid==12027004
recode weight2 150.5=50.5 if personid==20007905 
replace weight2 =58 if personid==30028906
recode weight2 22=. if personid==15069805

list personid age1 weight1 weight2 kg2 KG3 weight3 weight4 if kg2!=weight2
recode weight2 38=54.4 if personid==20036409

*weight3
tab weight3
count if KG3!=weight3
list personid KG3 weight3 if KG3!=weight3
replace weight3=45.6 if personid==10032606
replace weight3=50.1 if personid==23038205
replace weight3=42.7 if personid==20061307
recode weight3 164=64 if personid==11020402
recode weight3 .5=50 if personid==12051504   
list personid age1 weight1 weight2 kg2 KG3 weight3 weight4 if KG3!=weight3

*Weight4
tab weight4
list personid weight1 weight2 weight3 weight4 if weight4<40    //16cases
 replace weight4=(weight2+weight3)/2 if personid==21053403
 replace weight4=(weight2+weight3)/2 if personid== 10044804 
 replace weight4=(weight2+weight3)/2 if personid== 15020904 
 replace weight4=(weight2+weight3)/2 if personid== 15141003 
 replace weight4=(weight2+weight3)/2 if personid== 30031903
 
list personid weight1 weight2 weight3 weight4 if weight4>90   //13cases
   
    
**Height1
count if height1!=cm1
list personid height1 cm1 if height1!=cm1
 
 foreach var in height1{
 replace height1=cm1 if height1!=cm1
 }
 
**Height2

count if height2!=cm2
list personid height1 height2 cm2 if height2!=cm2

recode height2 .=154.6 if personid==10065202 
recode height2 56.6=156.6 if personid==12027004
recode height2 16.4=164 if personid==15174805
recode height2 38.2=138.2 if personid==20007905
recode height2 117.5=171.5 if personid==43016006
recode height2 1662=166.2 
recode height2 .=170 if personid==30028906

	list personid aa8cw aa8bw A2INT_YEAR A2INT_MNTH a3intyearw a3intmonthw a4intyearw a4intmonthw time2 weight1 weight2 if time2<=0.5

**Height3 
tab height3 
count if height3!=CM3

gen newvar=string(height3)
gen newvar2=substr(newvar,2,.)	
destring newvar2, replace
drop height3 newvar
rename newvar2 height3
	
list personid height3 CM3 if height3!=CM3

recode height3 .=171.2 if personid==23038205
recode height3 .=152.5 if personid==20061307
recode height3 .=162 if personid==10032606
recode height3 55=155 if personid==33076706
recode height3 68=168 if personid==13056309
recode height3 15=151 if personid==33043503
recode height3 71=171 if personid== 13056308  
recode height3 70.3=170.3 if personid==13050703 
recode height3 62.5=162.5 if personid==15083906 
recode height3 68=168 if personid==13053905 
recode height3 60.5=160.5 if personid==13056713
recode height3 66=166 if personid==13049106

** Height4
 tab height4
 list personid height1 height2 height3 height4 if height4<100|height4>=180
 replace height4= (height2+height3)/2 if personid==30034509
 replace height4= (height2+height3)/2 if personid==22008104
 
 recode height4 56.5=156.5 if personid==11059704
 
   **change age months to year
   foreach var in age1 age2 age3 age4 {
   replace `var'=`var'/12.
   }
   
		sum age1 age2 age3 age4 weight1 weight2 weight3 weight4 height1 height2 height3 height4
	
  	list personid age2 age3 weight1 weight2 weight3 weight4 height1 height2 height3 height4 if height1>=height2+10 & height1!=.
 	list personid age2 age3 weight1 height1 weight2 height2 weight3 height3 weight4 height4 if height1>=height3+20.5 & height1!=.
	list personid age2 age3 weight1 height1 weight2 height2 weight3 height3 weight4 height4 if height1>=height4+20.5 & height1!=.
 	list personid weight1 height1 weight2 height2 weight3 height3 weight4 height4 if height2>=height3+10 & height2!=.
 	list personid weight1 height1 weight2 height2 weight3 height3 weight4 height4 if height2>=height4+10 & height2!=.
 	list personid weight1 height1 weight2 height2 weight3 height3 weight4 height4 if height3>=height4+20 & height3!=.

* if both height and weight are problematic, consider as missing 
*** we need to discuss this issues-
	
gen index1=0
replace index1=1 if height1>=height2+10 & height1!=. 

reg height2 height1 height3 age2 sex if index1==0
predict y_hat1
replace height2=y_hat1 if index1==1
	
** replace 
replace height3=(height2+height4)/2 if personid== 31009606
replace height3=(height2+height1)/2 if personid== 40085009
replace height4=(height2+height3)/2 if personid== 20058706
replace height4=(height2+height3)/2 if personid== 42010706
replace height4=(height2+height3)/2 if personid== 12002105 
replace height4=(height2+height3)/2 if personid== 31026704 
replace height4=(height2+height3)/2 if personid== 42010706
replace height4=(height2+height3)/2 if personid== 31026704
replace height4=(height2+height3)/2 if personid== 13014804
replace height4=(height2+height3)/2 if personid== 20058706 	
replace height4=(height2+height3)/2 if personid== 12002105 


drop agemons

*BMI-1
	br personid weight1 height1 weight2 height2 weight3 height3 if weight1<40&personid==11056205|personid==41006603|personid==31010608|personid==15062304|personid==12053603|personid==20011010|personid==42002609|personid==220579002|personid==41013903
	gen index2=0
	replace index2=1 if weight1<40&personid==11056205|personid==41006603|personid==31010608|personid==15062304|personid==12053603| ///
	personid==200110110|personid==42002609|personid==22057902|personid==41013903
	reg weight1 height1 age1 sex if index2==0
	predict y_hat2
	replace weight1=y_hat2 if index2==1	
			
*BMI-2

	br personid weight1 height1 weight2 height2 weight3 height3 if weight1<40&personid==40038507|personid==20059006|personid==20020910|personid==11028704|personid==33078209| ///
	personid==33014105|personid==10023604|personid==15164803|personid==41013903|personid==20059006|personid==10023604
	
	gen index3=0
	replace index3=1 if weight1<40&personid==40038507|personid==20059006|personid==20020910|personid==11028704|personid==33078209| ///
	personid==33014105|personid==10023604|personid==15164803|personid==41013903|personid==20059006|personid==10023604
	
	reg weight2 height2 weight1 height1 age2 sex if index3==0
	predict y_hat3
	replace weight2=y_hat3 if index3==1	
		
**BMI_3
	br personid weight3 height3 if personid==33061105
	gen index4=0
	replace index4=1 if height3==165&personid==33061105 
	reg height3 height1 weight1 height2 weight2 weight3 age3 sex if index4==0
	predict y_hat4
	replace height3=y_hat4 if index4==1	
				
	
	br personid age* sex weight* height*
	sum age*  weight* height*

	
	   foreach var in age1 age2 age3 age4 {
   replace `var'=`var'*12.
   }
	 
			
*/
	
forvalues i=1(1)4 {
	gen bmi`i'=weight`i'*10000/(height`i'*height`i')
	}


	

*BMI WHO z score 
 forvalues i=1(1)4 {
	egen bmi_zs`i'= zanthro(bmi`i',ba,WHO), xvar(age`i') gender(sex) gencode(male=1, female=2) ageunit(month) nocutoff
	egen bmi_cat`i' = zbmicat(bmi`i'), xvar(age`i') gender(sex) gencode(male=1, female=2) ageunit(month)
	gen underweight`i'=0
	replace underweight`i'=1 if bmi_cat`i'==-3 | bmi_cat`i'==-2 | bmi_cat`i'==-1
	gen normal`i'=0
	replace normal`i'=1 if bmi_cat`i'==0
	gen overweight`i'=0
	replace overweight`i'=1 if bmi_cat`i'==1 | bmi_cat`i'==2
		}
		
	**calculate z scores for those age>19 using the median and SD for the 19 years in the refernce population
	* girls: median=21.4; SD for -1 (18.7)=2.7; +1 (25.0)=3.6; for -2 (16.5)=2.45 for +2 (29.7)=4.15 for -3 (14.7)=2.2333333; for +3 (36.2)=4.9333333
	* boys: median=22.2; SD for -1 (19.6)=2.6; +1 (25.4)=3.2; -2 (17.6)= 2.3; +2 (29.7)=3.75; -3 (15.9)= 2.1; +3 (35.5)=4.43

	replace bmi_zs3=(bmi3-21.4)/2.7 if bmi3<21.4 & bmi3>=18.7 & sex==2 & age3>228
	replace bmi_zs3=(bmi3-21.4)/3.6 if bmi3>=21.4 & bmi3<=25.0 & sex==2 & age3>228
	replace bmi_zs3=(bmi3-21.4)/2.45 if bmi3<18.7 & bmi3>=16.5 & sex==2 & age3>228	
	replace bmi_zs3=(bmi3-21.4)/4.15 if bmi3>25.0 & bmi3<=29.7 & sex==2 & age3>228
	replace bmi_zs3=(bmi3-21.4)/2.23 if bmi3<16.5 & sex==2 & age3>228
	replace bmi_zs3=(bmi3-21.4)/4.93 if bmi3>29.7 & sex==2 & age3>228
	
	replace bmi_zs3=(bmi3-22.2)/2.6 if bmi3<22.2 & bmi3>=19.6 & sex==1 & age3>228
	replace bmi_zs3=(bmi3-22.2)/3.2 if bmi3>=22.2 & bmi3<=25.4 & sex==1 & age3>228
	replace bmi_zs3=(bmi3-22.2)/2.3 if bmi3<19.6 & bmi3>=17.6 & sex==1 & age3>228	
	replace bmi_zs3=(bmi3-22.2)/3.75 if bmi3>25.4 & bmi3<=29.7 & sex==1 & age3>228
	replace bmi_zs3=(bmi3-22.2)/2.1 if bmi3<15.9 & sex==1 & age3>228
	replace bmi_zs3=(bmi3-22.2)/4.43 if bmi3>35.5 & sex==1 & age3>228

	replace bmi_zs4=(bmi4-21.4)/2.7 if bmi4<21.4 & bmi4>=18.7 & sex==2 & age4>228
	replace bmi_zs4=(bmi4-21.4)/3.6 if bmi4>=21.4 & bmi4<=25.0 & sex==2 & age4>228
	replace bmi_zs4=(bmi4-21.4)/2.45 if bmi4<18.7 & bmi4>=16.5 & sex==2 & age4>228	
	replace bmi_zs4=(bmi4-21.4)/4.15 if bmi4>25.0 & bmi4<=29.7 & sex==2 & age4>228
	replace bmi_zs4=(bmi4-21.4)/2.23 if bmi4<16.5 & sex==2 & age4>228
	replace bmi_zs4=(bmi4-21.4)/4.93 if bmi4>29.7 & sex==2 & age4>228
	
	replace bmi_zs4=(bmi4-22.2)/2.6 if bmi4<22.2 & bmi4>=19.6 & sex==1 & age4>228
	replace bmi_zs4=(bmi4-22.2)/3.2 if bmi4>=22.2 & bmi4<=25.4 & sex==1 & age4>228
	replace bmi_zs4=(bmi4-22.2)/2.3 if bmi4<19.6 & bmi4>=17.6 & sex==1 & age4>228	
	replace bmi_zs4=(bmi4-22.2)/3.75 if bmi4>25.4 & bmi4<=29.7 & sex==1 & age4>228
	replace bmi_zs4=(bmi4-22.2)/2.1 if bmi4<15.9 & sex==1 & age4>228
	replace bmi_zs4=(bmi4-22.2)/4.43 if bmi4>35.5 & sex==1 & age4>228

	sum bmi_zs*
	sum bmi_zs* if age4>=228

	 ****************************************************************************************	
	foreach var in bmi_zs1 bmi_zs2 bmi_zs3 bmi_zs4  {
	drop if (`var'>5 & `var'!=.) | `var'<-4
	}
	count
	
	* Preparing variables for sequantial modeling 

	sum age* bmi_zs*
	
	misstable sum bmi_zs1 bmi_zs2 bmi_zs3 bmi_zs4
	misstable patterns bmi_zs1 bmi_zs2 bmi_zs3 bmi_zs4
	misstable sum bmi_zs*, generate(miss_)
	egen status=rowtotal(miss_bmi_zs1  miss_bmi_zs2   miss_bmi_zs3  miss_bmi_zs4)
	recode status (0=1) (2=0) (3=0) (4=0) 
			
	
	**change months to year
   foreach var in age1 age2 age3 age4 {
   replace `var'=`var'/12.
   }
	

	forvalues x=1/8 {
		gen timela`x'=.
		}
* cohort 1
gen cohort=1 if age1<13
replace cohort=2 if  age1>=13 & age1<14	
replace cohort=3 if  age1>=14 & age1<15
replace cohort=4 if  age1>=15 & age1<16
replace cohort=5 if  age1>=16 & age1!=.
ta cohort

	replace timela1=age1 if cohort==1 & status==1
	replace timela2=age2 if cohort==1 & status==1
	replace timela3=age3 if cohort==1 & status==1
	replace timela4=age4 if cohort==1 & status==1
	
	replace timela2=age1 if cohort==2 & status==1
	replace timela3=age2 if cohort==2 & status==1
	replace timela4=age3 if cohort==2 & status==1
	replace timela5=age4 if cohort==2 & status==1
	
	replace timela3=age1 if cohort==3 & status==1
	replace timela4=age2 if cohort==3 & status==1
	replace timela5=age3 if cohort==3 & status==1
	replace timela6=age4 if cohort==3 & status==1
	
	replace timela4=age1 if cohort==4 & status==1
	replace timela5=age2 if cohort==4 & status==1
	replace timela6=age3 if cohort==4 & status==1
	replace timela7=age4 if cohort==4 & status==1
	
	replace timela5=age1 if cohort==5 & status==1
	replace timela6=age2 if cohort==5 & status==1
	replace timela7=age3 if cohort==5 & status==1 
	replace timela8=age4 if cohort==5 & status==1
	

	forvalues x=1/8 {
		gen bmila`x'=.
		}
		
	replace bmila1=bmi_zs1 if cohort==1 & status==1
	replace bmila2=bmi_zs2 if cohort==1 & status==1
	replace bmila3=bmi_zs3 if cohort==1 & status==1
	replace bmila4=bmi_zs4 if cohort==1 & status==1
	
	replace bmila2=bmi_zs1 if cohort==2 & status==1
	replace bmila3=bmi_zs2 if cohort==2 & status==1
	replace bmila4=bmi_zs3 if cohort==2 & status==1
	replace bmila5=bmi_zs4 if cohort==2 & status==1
	
	replace bmila3=bmi_zs1 if cohort==3 & status==1
	replace bmila4=bmi_zs2 if cohort==3 & status==1
	replace bmila5=bmi_zs3 if cohort==3 & status==1
	replace bmila6=bmi_zs4 if cohort==3 & status==1
	
	replace bmila4=bmi_zs1 if cohort==4 & status==1
	replace bmila5=bmi_zs2 if cohort==4 & status==1
	replace bmila6=bmi_zs3 if cohort==4 & status==1
	replace bmila7=bmi_zs4 if cohort==4 & status==1
		
	replace bmila5=bmi_zs1 if cohort==5 & status==1
	replace bmila6=bmi_zs2 if cohort==5 & status==1
	replace bmila7=bmi_zs3 if cohort==5 & status==1
	replace bmila8=bmi_zs4 if cohort==5 & status==1
	
		forvalues x=1/8 {
		gen bmir`x'=.
		}
	replace bmir1=bmi1 if cohort==1 & status==1
	replace bmir2=bmi2 if cohort==1 & status==1
	replace bmir3=bmi3 if cohort==1 & status==1
	replace bmir4=bmi4 if cohort==1 & status==1
	
	replace bmir2=bmi1 if cohort==2 & status==1
	replace bmir3=bmi2 if cohort==2 & status==1
	replace bmir4=bmi3 if cohort==2 & status==1
	replace bmir5=bmi4 if cohort==2 & status==1
	
	replace bmir3=bmi1 if cohort==3 & status==1
	replace bmir4=bmi2 if cohort==3 & status==1
	replace bmir5=bmi3 if cohort==3 & status==1
	replace bmir6=bmi4 if cohort==3 & status==1
	
	replace bmir4=bmi1 if cohort==4 & status==1
	replace bmir5=bmi2 if cohort==4 & status==1
	replace bmir6=bmi3 if cohort==4 & status==1
	replace bmir7=bmi4 if cohort==4 & status==1
		
	replace bmir5=bmi1 if cohort==5 & status==1
	replace bmir6=bmi2 if cohort==5 & status==1
	replace bmir7=bmi3 if cohort==5 & status==1
	replace bmir8=bmi4 if cohort==5 & status==1
	
	
	forvalues x=1/8 {
		gen foodinsecla`x'=.
		}
	
	replace foodinsecla1=foodinsec1 if cohort==1 & status==1
	replace foodinsecla2=foodinsec2 if cohort==1 & status==1
	replace foodinsecla3=foodinsec3 if cohort==1 & status==1
	replace foodinsecla4=foodinsec4 if cohort==1 & status==1
	
	replace foodinsecla2=foodinsec1 if cohort==2 & status==1
	replace foodinsecla3=foodinsec2 if cohort==2 & status==1
	replace foodinsecla4=foodinsec3 if cohort==2 & status==1
	replace foodinsecla5=foodinsec4 if cohort==2 & status==1
	
	replace foodinsecla3=foodinsec1 if cohort==3 & status==1
	replace foodinsecla4=foodinsec2 if cohort==3 & status==1
	replace foodinsecla5=foodinsec3 if cohort==3 & status==1
	replace foodinsecla6=foodinsec4 if cohort==3 & status==1
	
	replace foodinsecla4=foodinsec1 if cohort==4 & status==1
	replace foodinsecla5=foodinsec2 if cohort==4 & status==1
	replace foodinsecla6=foodinsec3 if cohort==4 & status==1
	replace foodinsecla7=foodinsec4 if cohort==4 & status==1
	
	replace foodinsecla5=foodinsec1 if cohort==5 & status==1
	replace foodinsecla6=foodinsec2 if cohort==5 & status==1
	replace foodinsecla7=foodinsec3 if cohort==5 & status==1
	replace foodinsecla8=foodinsec4 if cohort==5 & status==1
	
	
	
	forvalues x=1/8 {
		gen riskfactla`x'=.
		}
	
	replace riskfactla1=riskfact1 if cohort==1 & status==1
	replace riskfactla2=riskfact2 if cohort==1 & status==1
	replace riskfactla3=riskfact3 if cohort==1 & status==1
	replace riskfactla4=riskfact4 if cohort==1 & status==1
	
	replace riskfactla2=riskfact1 if cohort==2 & status==1
	replace riskfactla2=riskfact2 if cohort==2 & status==1
	replace riskfactla2=riskfact3 if cohort==2 & status==1
	replace riskfactla2=riskfact4 if cohort==2 & status==1
	
	replace riskfactla3=riskfact1 if cohort==3 & status==1
	replace riskfactla3=riskfact2 if cohort==3 & status==1
	replace riskfactla3=riskfact3 if cohort==3 & status==1
	replace riskfactla3=riskfact4 if cohort==3 & status==1
	
	replace riskfactla4=riskfact1 if cohort==4 & status==1
	replace riskfactla4=riskfact2 if cohort==4 & status==1
	replace riskfactla4=riskfact3 if cohort==4 & status==1
	replace riskfactla4=riskfact4 if cohort==4 & status==1

	replace riskfactla5=riskfact1 if cohort==5 & status==1
	replace riskfactla5=riskfact2 if cohort==5 & status==1
	replace riskfactla5=riskfact3 if cohort==5 & status==1
	replace riskfactla5=riskfact4 if cohort==5 & status==1
	
	replace riskfactla6=riskfact1 if cohort==6 & status==1
	replace riskfactla6=riskfact2 if cohort==6 & status==1
	replace riskfactla6=riskfact3 if cohort==6 & status==1
	replace riskfactla6=riskfact4 if cohort==6 & status==1
	
	replace riskfactla7=riskfact1 if cohort==7 & status==1
	replace riskfactla7=riskfact2 if cohort==7 & status==1
	replace riskfactla7=riskfact3 if cohort==7 & status==1
	replace riskfactla7=riskfact4 if cohort==7 & status==1
	
	replace riskfactla8=riskfact1 if cohort==8 & status==1
	replace riskfactla8=riskfact2 if cohort==8 & status==1
	replace riskfactla8=riskfact3 if cohort==8 & status==1
	replace riskfactla8=riskfact4 if cohort==8 & status==1
	
	
	forvalues x=1/8 {
		gen physicalla`x'=.
		}

	
	replace physicalla1=physical1 if cohort==1 & status==1
	replace physicalla1=physical2 if cohort==1 & status==1
	replace physicalla1=physical3 if cohort==1 & status==1
	*replace physicalla1=physical4 if cohort==1 & status==1
	
	replace physicalla2=physical1 if cohort==2 & status==1
	replace physicalla2=physical2 if cohort==2 & status==1
	replace physicalla2=physical3 if cohort==2 & status==1
	*replace physicalla2=physical4 if cohort==2 & status==1
	
	replace physicalla3=physical1 if cohort==3 & status==1
	replace physicalla3=physical2 if cohort==3 & status==1
	replace physicalla3=physical3 if cohort==3 & status==1
	*replace physicalla3=physical4 if cohort==3 & status==1
	
	replace physicalla4=physical1 if cohort==4 & status==1
	replace physicalla4=physical2 if cohort==4 & status==1
	replace physicalla4=physical3 if cohort==4 & status==1
	*replace physicalla4=physical4 if cohort==4 & status==1
	
	replace physicalla5=physical1 if cohort==5 & status==1
	replace physicalla5=physical2 if cohort==5 & status==1
	replace physicalla5=physical3 if cohort==5 & status==1
	*replace physicalla5=physical4 if cohort==5 & status==1
	
	replace physicalla6=physical1 if cohort==6 & status==1
	replace physicalla6=physical2 if cohort==6 & status==1
	replace physicalla6=physical3 if cohort==6 & status==1
	*replace physicalla6=physical4 if cohort==6 & status==1
	
	replace physicalla7=physical1 if cohort==7 & status==1
	replace physicalla7=physical2 if cohort==7 & status==1
	replace physicalla7=physical3 if cohort==7 & status==1
	*replace physicalla7=physical4 if cohort==7 & status==1
	
	replace physicalla8=physical1 if cohort==8 & status==1
	replace physicalla8=physical2 if cohort==8 & status==1
	replace physicalla8=physical3 if cohort==8 & status==1
	*replace physicalla8=physical4 if cohort==8 & status==1
	
		**foodinsecurity traj (group based traje)
		forvalues x=1/4{
		gen time`x'=.
		}
		replace tim1=1 if arespond1==1
		replace tim2=2 if arespond2==1
		replace tim3=3 if arespond3==1
		replace tim4=4 if a4respond==1
	
	
	
		forvalues i=1(1)4 {
	egen ha_zs`i'= zanthro(height`i',ha,WHO), xvar(age`i') gender(sex) gencode(male=1, female=2) ageunit(month) nocutoff
	}
	
	.
	ta ha_zs1
	/*	
	br personid age1 weight* height* bmi_zs* if abs(bmi_zs1)>5&bmi_zs1!=.
	br personid age2 weight* height* bmi_zs* if abs(bmi_zs2)>5 & bmi_zs2!=.
	br personid age2 weight* height* bmi_zs* if abs(bmi_zs2)<-4 & bmi_zs2!=.
	count if abs(bmi_zs2)>5 & bmi_zs2!=.
	br personid age2 weight* height* bmi_zs* if abs(bmi_zs3)>5|abs(bmi_zs1)<-4& bmi_zs3!=.	
	count if abs(bmi_zs3)>5 & bmi_zs3!=.	
	br personid age2 weight* height* bmi_zs* if abs(bmi_zs4)>5|abs(bmi_zs1)<-4 & bmi_zs4!=.	
	count if abs(bmi_zs4)>5 & bmi_zs4!=.	
	
	***************************************************************************************
	*/
	
	/*
	foreach var in age2 age3 age4  {
	replace `var'=`var'/12
	}
	
	foreach var in time1 time2 time3 time4   {
	drop if `var'<0
	}
	
		tab1 time*
	
	count if time1>=time2 | time2>=time3 | time3>=time4
	drop if time1>=time2 | time2>=time3 | time3>=time4
	
x
	count if abs(time1-time2)<=.5
	drop if abs(time1-time2)<=.5
	tab1 time*
*/
	//save "C:\Users\User\Dropbox\latent growth mixture modelling study/ analysis",replace
	save "C:\Users\User\Dropbox\PhD_Project\Project 1 PhD Working Documents\PhD_Manuscript-3\latent growth mixture modelling study\ analysis",replace
