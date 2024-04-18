* Author: Paul Rodriguez (paul.rodriguez@urosario.edu.co) & Susana Otálvaro-Ramírez (susana.otalvaro@urosario.edu.co)
* Date: 2018.07.20
* Goal: compile information at the HH level (pseudo-panel)


if "`c(username)'"=="paul.rodriguez" {
	glo remainF="D:\Paul.Rodriguez\Dropbox\tabaco/tabacoDrive" //Paul
}
else {
	glo remainF="C:\Users\\`c(username)'\Dropbox\tabacoDrive" // Susana
}




////////////////////////////////////////////////////////////////////////////////
use  "$remainF\superBaseECVSusanaOtalvaro\ENCV1997\derived\ECV1997_tabaco1.dta", clear 
keep 	tabacoExpenses totalExpenses alimExpenses alimExpenses1 T1_expen_m1 T2_expen_m1 T2_expen_m2 ///
		T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 ///
		T2_expen_m8 T2_expen_m9 T2_expen_m5a_afil T2_expen_m5a_comp ///
		T2_expen_m5a_hosp T2_expen_m5a_cons T2_expen_m5a_vacu T2_expen_m5a_medi ///
		T2_expen_m5a_labo T2_expen_m5a_tran T2_expen_m5a_tera T2_expen_m5a_inst ///
		hheq edad educ_uptoSec educ_tert female region fex depto f09 zona ///
		educ_uptoPrim persgast persingr numnin numadu incomeHH GastoCte f18 f20 f10 f01 ///
		persgastc curexpper alcoholExpenses 
rename curexpper curexpper_old
gen year=1997
destring f01 f09 f18 f20 f10, replace
rename f09 sr_health
recode sr_health (4=0 "Bad")(3=1 "Regular")(2=2 "Good")(1=3 "Very good"), g(auto_health)

recode f01 (1=1 "Yes")(2=0 "No"), g(afil)
recode f18 (1=1 "Yes")(2=0 "No"), g(acceso_medYN)
recode f20 (1/2=1 "Attend MC/EPS")(3/8=0 "Did not attend MC/EPS"), g(acceso_medCat)

recode f10 (1=1 "Yes")(2=0 "No"), g(acceso_prevYN)

replace tabacoExpenses=0 if tabacoExpenses==.
replace alcoholExpenses=0 if alcoholExpenses==.

xtile quintile=persgast, n(5)
xtile decile=persgast, n(10)
*keep if depto==11
drop if quintile==.

xtile quintileI=persingr, n(5)
xtile decileI=persingr, n(10)
drop if quintileI==.

xtile quintileC=GastoCte, n(5)
xtile decileC=GastoCte, n(10)
drop if quintileC==.


tempfile ecv1997
save `ecv1997'

********************************************************************************
use  "$remainF\superBaseECVSusanaOtalvaro\ENCV2003\derived\ECV2003_tabaco1.dta", clear 
keep 	tabacoExpenses totalExpenses alimExpenses alimExpenses1 T1_expen_m1 T2_expen_m1 T2_expen_m2 ///
		T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 ///
		T2_expen_m8 T2_expen_m9 hheq edad educ_uptoSec educ_tert female ///
		fex region e1102 region f08 zona educ_uptoPrim ///
		persgast persingr numnin numadu incomeHH GastoCte persgastc alcoholExpenses f01
gen year=2003
rename e1102 depto
rename f08 sr_health
recode sr_health (4=0 "Bad")(3=1 "Regular")(2=2 "Good")(1=3 "Very good"), g(auto_health)

recode f01 (1 2 3 4 5 6 7 8 9=1 "Yes")(10=0 "No"), g(afil)

replace tabacoExpenses=0 if tabacoExpenses==.
replace alcoholExpenses=0 if alcoholExpenses==.

xtile quintile=persgast, n(5)
xtile decile=persgast, n(10)
*keep if depto==11
*keep if region==5 

xtile quintileI=persingr, n(5)
xtile decileI=persingr, n(10)
drop if quintileI==.

xtile quintileC=GastoCte, n(5)
xtile decileC=GastoCte, n(10)
drop if quintileC==.


tempfile ecv2003
save `ecv2003'

********************************************************************************
use  "$remainF\superBaseECVSusanaOtalvaro\ENCV2008\derived\ENCV2008_tabaco1.dta", clear
keep 	tabacoExpenses totalExpenses alimExpenses alimExpenses1 T1_expen_m1 T2_expen_m1 T2_expen_m2 ///
		T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 ///
		T2_expen_m8 T2_expen_m9 hheq edad educ_uptoSec educ_tert female ///
		region FACTOR_EXPANSION P1_DEPARTAMENTO P6127 zona educ_uptoPrim ///
		persgast persingr numnin numadu incomeHH GastoCte persgastc alcoholExpenses P6091
rename FACTOR_EXPANSION fex
gen year=2008
rename P1_DEPARTAMENTO depto
rename P6127 sr_health
recode sr_health (4=0 "Bad")(3=1 "Regular")(2=2 "Good")(1=3 "Very good"), g(auto_health)

recode P6091 (1=1 "Yes")(2=0 "No")(9=.), g(afil)


xtile quintile=persgast, n(5)
xtile decile=persgast, n(10)
*keep if depto==11

xtile quintileI=persingr, n(5)
xtile decileI=persingr, n(10)
drop if quintileI==.

xtile quintileC=GastoCte, n(5)
xtile decileC=GastoCte, n(10)
drop if quintileC==.


replace tabacoExpenses=0 if tabacoExpenses==.
replace alcoholExpenses=0 if alcoholExpenses==.

tempfile ecv2008
save `ecv2008'

********************************************************************************
use "$remainF\tobacco-health-inequalities\procesamiento\EPF\gasto_personas.dta", clear
keep if year==2017

gen fex=1 // Falta esta var...

clonevar quintile=quint
rename quint quint17

gen T1_expen_m1=alimExpenses

replace tabacoExpenses=0 if tabacoExpenses==.
replace alcoholExpenses=0 if alcoholExpenses==.

foreach k in 2 3 4 5 6 7 8 9 { // Apart from food, the others can be 0
	replace T2_expen_m`k'=0 if T2_expen_m`k'==. 
}


tempfile epf2017
save `epf2017'


********************************************************************************
use  "$remainF\superBaseECVSusanaOtalvaro\ENCV2011\derived\ENCV2011_tabaco1.dta", clear
keep 	tabacoExpenses totalExpenses alimExpenses alimExpenses1 T1_expen_m1 T2_expen_m1 ///
		T2_expen_m2 T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 ///
		T2_expen_m8 T2_expen_m9 T2_expen_m5a_afil T2_expen_m5a_comp ///
		T2_expen_m5a_hosp T2_expen_m5a_cons T2_expen_m5a_vacu T2_expen_m5a_medi ///
		T2_expen_m5a_labo T2_expen_m5a_tran T2_expen_m5a_tera T2_expen_m5a_inst ///
		hheq edad educ_uptoSec educ_tert female region FEX_C P1_DEPARTAMENTO P6127 ///
		zona educ_uptoPrim persgast persingr numnin numadu incomeHH GastoCte ///
		persgastc alcoholExpenses P5665 P6143 P8552 P6091
rename FEX_C fex
gen year=2011
rename P1_DEPARTAMENTO depto
rename P6127 sr_health
recode sr_health (4=0 "Bad")(3=1 "Regular")(2=2 "Good")(1=3 "Very good"), g(auto_health)

recode P6091 (1=1 "Yes")(2=0 "No")(9=.), g(afil)
recode P5665 (1=1 "Yes")(2=0 "No"), g(acceso_medYN)
recode P6143 (1/2=1 "Attend MC/EPS")(3/8=0 "Did not attend MC/EPS"), g(acceso_medCat)

recode P8552 (1/3=1 "Yes")(4=0 "No"), g(acceso_prevYN)

xtile quintile=persgast, n(5)
xtile decile=persgast, n(10)
*keep if depto==11
xtile quintileI=persingr, n(5)
xtile decileI=persingr, n(10)
drop if quintileI==.

xtile quintileC=GastoCte, n(5)
xtile decileC=GastoCte, n(10)
drop if quintileC==.


replace tabacoExpenses=0 if tabacoExpenses==.
replace alcoholExpenses=0 if alcoholExpenses==.

////////////////////////////////////////////////////////////////////////////////
// Collect the data
////////////////////////////////////////////////////////////////////////////////
append using `ecv2008'
append using `ecv2003'
append using `ecv1997'
append using `epf2017' 
gen id=_n

merge n:1 year using "$remainF\superBaseECVSusanaOtalvaro\IPC\ipc nacional1.dta", nogen keep(master match)

drop ipc_bebnoal ipc_gaseosas

////////////////////////////////////////////////////////////////////////////////
// Constant prices cigarettes
////////////////////////////////////////////////////////////////////////////////
foreach varDep in persgast persingr totalExpenses GastoCte T2_expen_m4 {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*ipc_total/100
}

foreach varDep in T2_expen_m2 {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*ipc_vestuario/100
}

foreach varDep in T2_expen_m3 T2_expen_m9 {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*ipc_vivienda/100
}

foreach varDep in T2_expen_m5 T2_expen_m5a_afil T2_expen_m5a_comp T2_expen_m5a_hosp T2_expen_m5a_cons T2_expen_m5a_vacu T2_expen_m5a_medi T2_expen_m5a_labo T2_expen_m5a_tran T2_expen_m5a_tera T2_expen_m5a_inst{
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*ipc_salud/100
}

// No sé si usar el ipc de transporte o de comunicaciones (se unen las dos categorías del gasto)
foreach varDep in T2_expen_m6 {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*(ipc_transporte+ipc_comunicaciones)/200 if ipc_comunicaciones!=.
	replace `varDep'=`varDep'*(ipc_transporte)/100 if ipc_comunicaciones==.

}

foreach varDep in T2_expen_m7 {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*(ipc_diversion)/100
}

foreach varDep in T2_expen_m8 {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*(ipc_educacion)/100
}

foreach varDep in tabacoExpenses {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*ipc_tabacoAd/100
}

foreach varDep in alimExpenses alimExpenses1 {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*ipc_alimentos/100
}

foreach varDep in alcoholExpenses {
	gen OR_`varDep'=`varDep'
	replace `varDep'=`varDep'*ipc_bebal/100
}
*
gen  ipctab2011=ipc_tabacoAd if year==2011
egen Ipctab2011=max(ipctab2011)
gen  cigprice=121*ipc_tabacoAd/Ipctab2011


* Según la base de datos de contrabando el precio más bajo de cigarrillos 
* legales es 85 pesos y el más alto es 2500, sin embargo, para evitar un reporte 
* sobreestimado por confusion de los encuestados entre stick y cajetilla se usa 
* el valor del intervalo de confianza superior

gen  Lcigprice=85*ipc_tabacoAd/Ipctab2011
gen  Ucigprice=450*ipc_tabacoAd/Ipctab2011

gen 	p_Uquintile=cigprice
replace p_Uquintile=Lcigprice if quintile==5 

keep if quintile!=.

tab region, gen(region_)

// 42% de los hogares no reporta gasto en clothing
// menos del 1% no reporta gasto en servicios del hogar
// 68% de los hogares no reporta gasto en muebles
// 4% de los hogares no reporta gasto en salud
replace T2_expen_m5=0 if T2_expen_m5==.
// se ajusto gasto en transporte
// se ajusto gasto en cultura
// menos del 1% no reporta gasto en educación
// el 1% de los hogares no reporta gasto en otros


save "$remainF\tobacco-health-inequalities\procesamiento\derived\ECVREP1.dta", replace

