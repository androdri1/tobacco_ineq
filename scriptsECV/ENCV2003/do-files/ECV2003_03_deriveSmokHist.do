* Author: Paul Rodriguez (paul.rodriguez@urosario.edu.co)
* Date: 2017.07.05
* Goal: produce a dataset for ENCV2008 that has total expenditures, tabaco expenditures, income/wealth, age, education level, gender

if "`c(username)'"=="paul.rodriguez" {
	glo dropbox="D:\Paul.Rodriguez\Drive\tabacoDrive" //Paul
}
else {
	glo dropbox="C:\Users\\`c(username)'\Dropbox\tabacoDrive" // Susana
}

glo project="$dropbox\Tobacco-health-inequalities" // Susana folder
********************************************************************************
* Define individual level info
********************************************************************************
use "$project\data\ENCV2003\original\personasL.dta", clear
use "$project\data\ENCV2003\original\personasL.dta", clear

label define region1 1 "Atlantica" 2 "Oriental" 3 "Central" 4 "Pacifica (sin Valle)" 5 "Bogota" 6 "Antioquia"  8 "San Andres y Providencia" 9 "Orinoquia"  7 "Valle"
label val region region1 

merge 1:1 numero e01 using "$project\data\ENCV2003\original/educaL.dta", nogen force
merge n:1 numero using  "$project\data\ENCV2003\original\hogarL.dta" , nogen keepusing(fex region localidad)

gen female = e03==2 if e03!=.
gen age=e02

gen student=i02==1 if i02!=.

gen     educ_uptoPrim = i0701==1 | i0701==2 | (i0701==3 & i0702<12 )   if student==1 & i0701!=. // At most, still in grade 11
replace educ_uptoPrim = i0401==1 | i0401==2 | i0401==3 | (i0401==4 & i0402<11) if student==0 & i0401!=. // Did not obtained Bachillerato degree

gen     educ_uptoSec = (i0701==3 & i0702>=12 )  if student==1 & i0701!=. // If still is Media, it should be above grade 11
replace educ_uptoSec = (i0401==4 & i0402>=11)  if student==0 & i0401!=. // obtained Bachillerato degree

gen     educ_tert = inrange(i0701,4,6) if student==1 & i0701!=.
replace educ_tert = inrange(i0401,5,9) if student==0 & i0401!=.

gen edad=age
egen numnin = sum(edad < 18), by(numero)
egen numadu = sum(edad > 17), by(numero)
gen hheq = 1 + (0.5*(numadu-1)) + (0.3*numnin)
replace hheq = 1 if hheq<1

* >>>>> Mathieu, decide here what is better: take HH head only, or the average for adults... !!!!!!!!!!!!!!!!!!!!!!!!!!!! >>>>>>>>>
*keep if age>15

rename numero id_hogar
rename id_viv id_vivienda
destring id_vivienda, replace 
format id_hogar id_vivienda %20.0f

* Make it HH level dataset .....................................................
*collapse (mean) age female educ_uptoPrim educ_uptoSec educ_tert , by(DIRECTORIO SECUENCIA_ENCUESTA)
keep if e04==1 // Jefe de hogar


********************************************************************************
* Compile household level data
********************************************************************************
merge 1:1 id_hogar using "$project\data\ENCV2003\derived/ECV2003_expenditures1.dta" , nogen
merge 1:1 id_hogar using "$project\data\ENCV2003\derived/ECV2003_incomeHogar.dta", nogen

gen persgast = totalExpenses/hheq
gen persingr = incomeHH/hheq
gen persgastc= GastoCte/hheq

gen 	zona = 1 if clase== 1
replace zona = 2 if clase== 2 | clase== 3 

label def zona 1 "Urbano" 2 "Rural"
label val zona zona 
label var zona "Urbano - Rural"

* These are the relevant variables!
sum tabacoExpenses totalExpenses incomeHH age female educ_uptoPrim educ_uptoSec educ_tert 

saveold "$project\data\ENCV2003\derived\ECV2003_tabaco1.dta", replace

