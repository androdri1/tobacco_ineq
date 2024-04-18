* Author: Paul Rodriguez (paul.rodriguez@urosario.edu.co) & Susana Otálvaro-Ramírez (susana.otalvaro@urosario.edu.co)
* Date: 2018.07.20
* Goal:

if "`c(username)'"=="paul.rodriguez" {
	glo mainE="D:\Paul.Rodriguez\Dropbox\tabaco\tabacoDrive\tobacco-health-inequalities" //Paul
}
else {
	*glo mainE="C:\Users\\`c(username)'\Dropbox\tabacoDrive\Tobacco-health-inequalities" // Susana
	glo mainE="C:\Users\\`c(username)'\Dropbox\tabaco\tabacoDrive\tobacco-health-inequalities" // Paul	
}

glo mainF="$mainE\procesamiento\derived" // Susana


////////////////////////////////////////////////////////////////////////////////
if 1==0 { // Figure 1
	use "$mainE\..\superBaseECVSusanaOtalvaro\IPC\ipc nacional1.dta", clear
	tsset year, y

	gen  ipctab2011=ipc_tabacoAd if year==2011
	egen Ipctab2011=max(ipctab2011)
	gen  cigprice=121*ipc_tabacoAd/Ipctab2011
	keep if year>=1997 & year<=2012

	tw (tsline ipc_tabacoAd , lwidth(thick)) ///
	   (tsline ipc_total , lwidth(thick)) , tlabel(1997(2)2012)  legend(order(1 "CPI tobacco" 2 "CPI all goods index")) scheme(Plotplain) name(a1, replace)
	graph export "$mainE\document\images\CigPrice.pdf", as(pdf) replace

	gen  cigpriceR=cigprice*100/ipc_total
	gen ficticia97= 0

	tw (tsline cigprice , lwidth(thick) ) ///
	   (tsline cigpriceR , lwidth(thick) ) ,  ///
	   legend(order(1 "Cigarrete nominal price" 2 "Cigarrete 2008 prices")) ///
	   scheme(Plotplain) name(a2, replace)
	   
	graph export "$mainE\document\images\CigPriceTax.pdf", as(pdf) replace
	*graph export "$mainE\ document\images\CigPriceTax.png", as(png) replace
}

////////////////////////////////////////////////////////////////////////////////
use "$mainF\ECVrepeat_a8.dta", clear

********************************************************************************
* DESCRIPTIVES   <<<< Sin ajustar
********************************************************************************				
if 1==0{

if 1==0{
* Characterization of the smokers
table year [pw = fex] if numcig>0, contents(mean edad ) // Age
table year [pw = fex] if (edadg>1 & numcig>0), contents(mean female) // Gender
table year [pw = fex] if (edadg>1 & numcig>0), contents(mean zona)  // Zone
table year [pw = fex] if numcig>0, contents(mean educ_uptoSec) // Education
table year [pw = fex] if numcig>0, contents(mean educ_uptoPrim) // Education
table year [pw = fex] if numcig>0, contents(mean educ_tert) 
table year [pw = fex] if numcig>0, contents(mean mala_salud) 

* Prevalence by characteristic
table edadg year [pw = fex], contents(mean anycig )  //Prevalence by age group 
table female year [pw = fex] if edadg>1, contents(mean anycig) 
table zona year [pw = fex] if edadg>1, contents(mean anycig) 
table educ_uptoSec year [pw = fex], contents(mean anycig) 
*table year educ_tert [pw = fex], contents(mean anycig) 



* Characterization by quintile (all sample)
table year quintile [pw = fex], contents(mean edad) 
table year quintile [pw = fex] if edadg>1, contents(mean female) 
table year quintile [pw = fex] if edadg>1, contents(mean zona)
table year quintile [pw = fex] if edadg>1, contents(mean educ_uptoSec)
*table year quintile [pw = fex] if edadg>1, contents(mean educ_tert)
table year quintile [pw = fex] if edadg>1, contents(mean mala_salud)

* Characterization by quintile (smokers)
table year quintile [pw = fex] if numcig>0, contents(mean edad) 
table year quintile [pw = fex] if edadg>1 & numcig>0, contents(mean female) 
table year quintile [pw = fex] if edadg>1 & numcig>0, contents(mean zona)
table year quintile [pw = fex] if edadg>1 & numcig>0, contents(mean educ_uptoSec)
table year quintile [pw = fex] if edadg>1 & numcig>0 & year==1997, contents(mean educ_tert)
table year quintile [pw = fex] if edadg>1 & numcig>0, contents(mean educ_tert)
table year quintile [pw = fex] if edadg>1 & numcig>0, contents(mean educ_uptoPrim)
table year quintile [pw = fex] if edadg>1 & numcig>0 & year==2011, contents(mean educ_uptoPrim)
table year quintile [pw = fex] if edadg>1 & numcig>0, contents(mean mala_salud)


* Prevalence by characteristic
table edadg quintile [pw = fex], contents(mean anycig)  //Prevalence by age group and quintile 
table female quintile [pw = fex], contents(mean anycig)  //Prevalence by gender and quintile 
table zona quintile [pw = fex], contents(mean anycig)  //Prevalence by zone and quintile 
table educ_uptoSec quintile [pw = fex], contents(mean anycig)  //Prevalence by terciary education and quintile 
*table educ_tert quintile [pw = fex], contents(mean anycig)  //Prevalence by terciary education and quintile 
table mala_salud quintile [pw = fex], contents(mean anycig)  //Prevalence by health status and quintile 


* Prevalence by characteristic and year
table edadg quintile [pw = fex] if year==1997, contents(mean anycig )  //Prevalence by age group and quintile - 1997 
table edadg quintile [pw = fex] if year==2011, contents(mean anycig )  //Prevalence by age group and quintile - 2011

table female quintile [pw = fex] if year==1997, contents(mean anycig)  //Prevalence by gender and quintile 
table female quintile [pw = fex] if year==2011, contents(mean anycig)  //Prevalence by gender and quintile 

table zona quintile [pw = fex] if year==1997, contents(mean anycig)  //Prevalence by zone and quintile 
table zona quintile [pw = fex] if year==2011, contents(mean anycig)  //Prevalence by zone and quintile 

table educ_uptoSec quintile [pw = fex] if year==1997, contents(mean anycig)  //Prevalence by terciary education and quintile 
table educ_uptoSec quintile [pw = fex] if year==2011, contents(mean anycig)  //Prevalence by terciary education and quintile 

table educ_tert quintile [pw = fex] if edadg>1 & numcig>0 & year==1997, contents(mean anycig)
table educ_tert quintile [pw = fex] if edadg>1 & numcig>0 & year==2011, contents(mean anycig)
table educ_uptoPrim quintile [pw = fex] if edadg>1 & numcig>0 & year==1997, contents(mean anycig)
table educ_uptoPrim quintile [pw = fex] if edadg>1 & numcig>0 & year==2011, contents(mean anycig)

table mala_salud quintile [pw = fex] if year==1997, contents(mean anycig)  //Prevalence by health status and quintile 
table mala_salud quintile [pw = fex] if year==2011, contents(mean anycig)  //Prevalence by health status and quintile 

forvalues i=1/9 {
*table year region_`i' [pweight = fex], contents(mean anycig )
table year quintile [pw = fex] if region_`i'==1, contents(mean anycig )
}
*

foreach i in 1 2 3 4 ///
{
table year [pweight = fex], contents(mean sr_health`i') 
table year [pweight = fex] if numcig>0, contents(mean sr_health`i') 
table year quintile [pweight = fex] if sr_health`i'==1, contents(mean anycig )
}
*

*Smokers and Non-Smokers
table quintile year [pw = fex] if anycig!=0, contents(mean edad ) // Age Smokers
table quintile year [pw = fex] if anycig==0, contents(mean edad ) // Age Non-Smokers

table quintile year [pw = fex] if (edadg1>1 & anycig!=0), contents(mean female) // Gender Smokers
table quintile year [pw = fex] if (edadg1>1 & anycig==0), contents(mean female) // Gender Non-Smokers

table quintile year [pw = fex] if (edadg1>1 & anycig!=0), contents(mean zona)  // Zone
table quintile year [pw = fex] if (edadg1>1 & anycig==0), contents(mean zona)  // Zone

table quintile year [pw = fex] if anycig!=0, contents(mean educ_uptoSec) // Education
table quintile year [pw = fex] if anycig==0, contents(mean educ_uptoSec) // Education

table quintile year [pw = fex] if anycig!=0, contents(mean educ_tert) // Education
table quintile year [pw = fex] if anycig==0, contents(mean educ_tert) // Education

*table year [pw = fex], contents(mean educ_tert) 
table year [pw = fex], contents(mean mala_salud) 
}


********************************************************************************	
label var numcigFUM "Cig. consumed"
*label var LnumcigFUM "Cig. consumed (precio bajo)"
*label var UnumcigFUM "Cig. consumed (precio alto)"
label var persgast "HH Consumption"
	
	loc i=1
	foreach y in 1997 2008 2011 {
		qui conindex numcigFUM if year==`y' [pw=fex], rankvar(persgast)  truezero graph
		loc CI   : disp %3.2f r(CI)
		loc CIse : disp %3.2f r(CIse)
		graph rename a`i', replace
		gr_edit .title.text.Arrpush "`y'"
		gr_edit .subtitle.text.Arrpush "CI: `CI' (`CIse')"
		loc i=1+`i'
	}
	graph combine a1 a2 a3, scheme(plotplain) cols(2) rows(2)
graph export "$mainE\document\images\Tobacco_CI.pdf", as(pdf) replace
graph export "$mainE\document\images\Tobacco_CI.png", as(png) replace
									
table year quintile [pweight = fex], contents(mean numcigFUM ) // Pero los que queda son los que mas fuman
						

}

////////////////////////////////////////////////////////////////////////////////
// Figure 2: Smoking Prevalence and Tobacco Budget Share by Total Expenditures Quintile
cd "$mainE\document\images" 
if 1==0 {

	* **************************************************************************
	* SMOKING PREVALENCE
	use "$mainF\ECVrepeat_a8.dta", clear
	keep if muestraOrig==1 // Usar la version antes del matching

	foreach i in 1 2 3 4 5 {
		gen 	anycig`i'= smokers if quintile==`i'
	}

	collapse(mean) ca1=anycig1 ca2=anycig2 ca3=anycig3 ca4=anycig4 ca5=anycig5 ///
			(semean) caSE1=anycig1 caSE2=anycig2 caSE3=anycig3 caSE4=anycig4 caSE5=anycig5 ///
			(count) n=anycig1  [aweight = fex], by(year) 
	reshape long ca caSE , i(year) j(cat) 

	replace ca  =ca*100
	replace caSE=caSE*100
	format %2.1f ca

	* Intervalos de confianza
	gen caUL = ca + invttail(n-1,0.025)*caSE
	gen caLL = ca - invttail(n-1,0.025)*caSE

	* Este es el paso 2 de la trampa, el desfase tiene como objetivo: 1) crear un espacio entre categorías, 2) dejar urbano/rural lado a lado para comparar
	gen     catAd=cat*30 if year==1997
	replace catAd=cat*30+5 if year==2003
	replace catAd=cat*30+10 if year==2008
	replace catAd=cat*30+15 if year==2011
	
	drop if year==2017

	local opt_mlabel="msize(zero) mcolor(orange) mlabcolor(black) mlabposition(12) mlabangle(45) mlabgap(small) mlabs(vsmall)" 
	tw 	(bar ca catAd if year==1997, barw(5) ) ///
		(bar ca catAd if year==2003, barw(5) ) ///
		(bar ca catAd if year==2008, barw(5) ) ///
		(bar ca catAd if year==2011, barw(5) ) ///	
		(rcap caLL caUL catAd  ) ///
		(scatter ca catAd if year==1997, mlabel(ca) `opt_mlabel') ///
		(scatter ca catAd if year==2003, mlabel(ca) `opt_mlabel' ) ///
		(scatter ca catAd if year==2008, mlabel(ca) `opt_mlabel' ) ///
		(scatter ca catAd if year==2011, mlabel(ca) `opt_mlabel' ) , /// 
		legend(row(1) order(1 "1997" 2 "2003" 3 "2008" 4 "2011") pos(6) ) ///
		xlabel( 36 "1" 67 "2" 97 "3" 127 "4" 158 "5" , noticks) ///
		xtitle("Quintile") ytitle("Prevalence") ///
		ymtick(0(10)30) ylabel(0 "0.0" 10 "10.0" 20 "20.0"  30 "30.0") ///
		scheme(plotplainblind) name(SmokPrev, replace) 
	*graph export "$mainE\document\images\SmokPrev_quintile.pdf", as(pdf) replace
	*graph export "$mainE\document\images\SmokPrev_quintile.png", as(png) replace

	* **************************************************************************
	* Household Tobacco Budget Share Total Expenses, by Quintile

	use "$mainF\ECVrepeat_a8.dta", clear
	keep if muestraOrig==1 // Usar la version antes del matching

	foreach i in 1 2 3 4 5 {
	gen 	tabexpperFUM`i'= tabexpperFUM if quintile==`i'
	}

	collapse(mean) ca1=tabexpperFUM1 ca2=tabexpperFUM2 ca3=tabexpperFUM3 ca4=tabexpperFUM4 ca5=tabexpperFUM5 ///
		(semean) caSE1=tabexpperFUM1 caSE2=tabexpperFUM2 caSE3=tabexpperFUM3 caSE4=tabexpperFUM4 caSE5=tabexpperFUM5 ///
		(count) n=tabexpperFUM1  [aweight = fex], by(year) 
	reshape long ca caSE , i(year) j(cat) 
	
	replace ca  =ca*100
	replace caSE=caSE*100
	format %2.1f ca
	
	* Intervalos de confianza
	gen caUL = ca + invttail(n-1,0.025)*caSE
	gen caLL = ca - invttail(n-1,0.025)*caSE

	* Este es el paso 2 de la trampa, el desfase tiene como objetivo: 1) crear un espacio entre categorías, 2) dejar urbano/rural lado a lado para comparar
	gen     catAd=cat*30 if year==1997
	replace catAd=cat*30+5 if year==2003
	replace catAd=cat*30+10 if year==2008
	replace catAd=cat*30+15 if year==2011
	
	local opt_mlabel="msize(zero) mcolor(orange) mlabcolor(black) mlabposition(12) mlabangle(45) mlabgap(small) mlabs(vsmall)" 
	tw 	(bar ca catAd if year==1997, barw(5) ) ///
		(bar ca catAd if year==2003, barw(5) ) ///
		(bar ca catAd if year==2008, barw(5) ) ///
		(bar ca catAd if year==2011, barw(5) ) ///	
		(rcap caLL caUL catAd, lcolor(green)) ///
		(scatter ca catAd if year==1997, mlabel(ca) `opt_mlabel') ///
		(scatter ca catAd if year==2003, mlabel(ca) `opt_mlabel' ) ///
		(scatter ca catAd if year==2008, mlabel(ca) `opt_mlabel' ) ///
		(scatter ca catAd if year==2011, mlabel(ca) `opt_mlabel' ) , /// 
		legend(row(1) order(1 "1997" 2 "2003" 3 "2008" 4 "2011") pos(6) ) ///
		xlabel( 36 "1" 67 "2" 97 "3" 127 "4" 158 "5" , noticks) ///
		xtitle("Quintile") ytitle("Budget share") ///
		ymtick(0(2)8) ///			
		scheme(Plotplainblind) name(BS_TobT, replace) 
	*graph export "$mainE\document\images\BS_Tob_Total.pdf", as(pdf) replace
	*graph export "$mainE\document\images\BS_Tob_Total.png", as(png) replace

	grc1leg  SmokPrev BS_TobT, col(1) iscale(0.8) scheme(plotplainblind)
	
	
	* **************************************************************************
	* Household Tobacco Budget Share Total Expenses, by Quintile

	use "$mainF\ECVrepeat_a8.dta", clear
	keep if muestraOrig==1 // Usar la version antes del matching

	foreach i in 1 2 3 4 5 {
		gen	tabexpperFUM`i'   = tabexpperFUM    if quintile==`i'
		gen	healthexpperFUM`i'= healthexpperFUM if quintile==`i'
		gen educexpperFUM`i' = educexpperFUM if quintile==`i'
		gen HyEdexpperFUM`i' = healthexpperFUM`i'+educexpperFUM`i'
	}

	collapse(mean) ca1=HyEdexpperFUM1 ca2=HyEdexpperFUM2 ca3=HyEdexpperFUM3 ca4=HyEdexpperFUM4 ca5=HyEdexpperFUM5 ///
		(semean) caSE1=HyEdexpperFUM1 caSE2=HyEdexpperFUM2 caSE3=HyEdexpperFUM3 caSE4=HyEdexpperFUM4 caSE5=HyEdexpperFUM5 ///
		(count) n=tabexpperFUM1  [aweight = fex], by(year) 
	reshape long ca caSE , i(year) j(cat) 
	
	replace ca  =ca*100
	replace caSE=caSE*100
	format %2.1f ca
	
	* Intervalos de confianza
	gen caUL = ca + invttail(n-1,0.025)*caSE
	gen caLL = ca - invttail(n-1,0.025)*caSE

	* Este es el paso 2 de la trampa, el desfase tiene como objetivo: 1) crear un espacio entre categorías, 2) dejar urbano/rural lado a lado para comparar
	gen     catAd=cat*30 if year==1997
	replace catAd=cat*30+5 if year==2003
	replace catAd=cat*30+10 if year==2008
	replace catAd=cat*30+15 if year==2011
	
	local opt_mlabel="msize(zero) mcolor(orange) mlabcolor(black) mlabposition(12) mlabangle(45) mlabgap(small) mlabs(vsmall)" 
	tw 	(bar ca catAd if year==1997, barw(5) ) ///
		(bar ca catAd if year==2003, barw(5) ) ///
		(bar ca catAd if year==2008, barw(5) ) ///
		(bar ca catAd if year==2011, barw(5) ) ///	
		(rcap caLL caUL catAd, lcolor(green)) ///
		(scatter ca catAd if year==1997, mlabel(ca) `opt_mlabel') ///
		(scatter ca catAd if year==2003, mlabel(ca) `opt_mlabel' ) ///
		(scatter ca catAd if year==2008, mlabel(ca) `opt_mlabel' ) ///
		(scatter ca catAd if year==2011, mlabel(ca) `opt_mlabel' ) , /// 
		legend(row(1) order(1 "1997" 2 "2003" 3 "2008" 4 "2011") pos(6) ) ///
		xlabel( 36 "1" 67 "2" 97 "3" 127 "4" 158 "5" , noticks) ///
		xtitle("Quintile") ytitle("Budget share") ///
		ymtick(0(2)8) ///			
		scheme(Plotplainblind) name(BS_EyTT, replace) 
	*graph export "$mainE\document\images\BS_EyTT.pdf", as(pdf) replace
	*graph export "$mainE\document\images\BS_EyTT.png", as(png) replace
	

	grc1leg  SmokPrev BS_TobT, col(1) iscale(0.8) scheme(plotplainblind)
	grc1leg  BS_TobT BS_EyTT, col(1) iscale(0.8) scheme(plotplainblind)
	
		
	
	
	
	
	
	
	
	
}

////////////////////////////////////////////////////////////////////////////////
// Figure 3: Self-reported Health Status and Affiliation with the Health System
if 1==0 {
	* Self-reported Health Status **********************************************

	use "$mainF\ECVrepeat_a8.dta", clear
	keep if muestraOrig==1 // Usar la version antes del matching

	la def smokers 0 "Non-smokers" 1 "Smokers" 
	la val smokers smokers
	foreach i in 1 2 3 4 5 {
		gen 	bad_health`i'= bad_health if quint==`i'
	}

	collapse(mean) ca1=bad_health1 ca2=bad_health2 ca3=bad_health3 ca4=bad_health4 ca5=bad_health5 ///
			(semean) caSE1=bad_health1 caSE2=bad_health2 caSE3=bad_health3 caSE4=bad_health4 caSE5=bad_health5 ///
			(count) n=bad_health1 , by(smokers year) 
	reshape long ca caSE , i(smokers year) j(cat) 
	
	replace ca  =ca*100
	replace caSE=caSE*100
	format %2.1f ca
	
	* Intervalos de confianza
	gen caUL = ca + invttail(n-1,0.025)*caSE
	gen caLL = ca - invttail(n-1,0.025)*caSE

	* Este es el paso 2 de la trampa, el desfase tiene como objetivo: 1) crear un espacio entre categorías, 2) dejar urbano/rural lado a lado para comparar
	gen     catAd=cat*30 if year==1997
	replace catAd=cat*30+5 if year==2003
	replace catAd=cat*30+10 if year==2008
	replace catAd=cat*30+15 if year==2011
	
	gen cay=ca + 3
	
	local opt_mlabel="msize(zero) mcolor(gs14) mlabcolor(black) mlabposition(12) mlabangle(horizontal) mlabgap(small) mlabs(vsmall)" 
	tw 	(bar ca catAd if year==1997, by(smokers) subtitle(,lcolor(none) nobox ) barw(5) ) ///
		(bar ca catAd if year==2003, by(smokers) subtitle(,lcolor(none) nobox ) barw(5) ) ///	
		(bar ca catAd if year==2008, by(smokers) subtitle(,lcolor(none) nobox ) barw(5) ) ///	
		(bar ca catAd if year==2011, by(smokers) subtitle(,lcolor(none) nobox ) barw(5) ) ///	
		(rcap caLL caUL catAd, lcolor(gs2)) ///
		(scatter cay catAd if year==1997 | year==2011, mlabel(ca) `opt_mlabel' ) , /// 
		legend(row(1) order(1 "1997" 2 "2003" 3 "2008" 4 "2011" ) pos(6) ) ///
		xlabel( 32.5 "1" 62.5 "2" 92.5 "3" 122.5 "4" 152.5 "5" , noticks) ///
		xtitle("Quintile") ytitle("Percentage") ///
		ymtick(0(20)60) ylabel(0 "0.0" 20 "20.0"  40 "40.0" 60 "60.0") ///
		scheme(Plotplainblind) note(" ", size(vsmall)) name(HS_SR, replace) 
	*graph export "$mainE\document\images\SelfRHealth.pdf", as(pdf) replace

	* Affiliation **************************************************************
	
	use "$mainF\ECVrepeat_a8.dta", clear
	keep if muestraOrig==1 // Usar la version antes del matching	

	la def smokers 0 "Non-smokers" 1 "Smokers" 
	la val smokers smokers
	foreach i in 1 2 3 4 5 {
		gen 	afil`i'= afil if quint==`i' & afil!=. 
	}

	collapse(mean) ca1=afil1 ca2=afil2 ca3=afil3 ca4=afil4 ca5=afil5 ///
			(semean) caSE1=afil1 caSE2=afil2 caSE3=afil3 caSE4=afil4 caSE5=afil5 ///
			(count) n=afil1 , by(smokers year) 
	reshape long ca caSE , i(smokers year) j(cat) 
	
	replace ca  =ca*100
	replace caSE=caSE*100
	format %2.1f ca
	
	* Intervalos de confianza
	gen caUL = ca + invttail(n-1,0.025)*caSE
	gen caLL = ca - invttail(n-1,0.025)*caSE

	* Este es el paso 2 de la trampa, el desfase tiene como objetivo: 1) crear un espacio entre categorías, 2) dejar urbano/rural lado a lado para comparar
	gen     catAd=cat*30 if year==1997
	replace catAd=cat*30+5 if year==2003
	replace catAd=cat*30+10 if year==2008
	replace catAd=cat*30+15 if year==2011
	
	gen cay=ca + 3
	
	local opt_mlabel="msize(zero) mcolor(gs14) mlabcolor(black) mlabposition(12) mlabangle(horizontal) mlabgap(small) mlabs(vsmall)" 
	tw 	(bar ca catAd if year==1997 , by(smokers) barw(5) ) ///
		(bar ca catAd if year==2003 , by(smokers) barw(5) )  ///	
		(bar ca catAd if year==2008 , by(smokers) barw(5) )  ///	
		(bar ca catAd if year==2011 , by(smokers) barw(5) )  ///	
		(rcap caLL caUL catAd, lcolor(gs2)) ///
		(scatter ca catAd if year==1997 | year==2011 , mlabel(ca) `opt_mlabel' ) , /// 
		legend(row(1) order(1 "1997" 2 "2003" 3 "2008" 4 "2011" ) pos(6) size(vsmall)) ///
		xlabel( 32.5 "1" 62.5 "2" 92.5 "3" 122.5 "4" 152.5 "5" , noticks labsize(vsmall)) ///
		xtitle("Quintile", size(small)) ytitle("Percentage")   ///
		ymtick(0(20)100) ylabel(0 "0.0" 20 "20.0"  40 "40.0" 60 "60.0" 80 "80.0" 100 "100.0", labsize(vsmall)) ///
		scheme(Plotplainblind) note(" ", size(vsmall))  name(Medical_affiliationSmokers, replace) ///
		ysize(3) xsize(6)
	*graph export "$mainE\document\images\Medical_affiliationSmokers.pdf", as(pdf) replace

	grc1leg  HS_SR Medical_affiliationSmokers, col(1) iscale(0.8) scheme(plotplainblind)
}