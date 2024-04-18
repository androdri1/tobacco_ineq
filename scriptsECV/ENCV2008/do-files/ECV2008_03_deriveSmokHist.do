* Author: Susana Otálvaro-Ramírez (susana.otalvaro@urosario.edu.co)
* Date: 2018.07.20
* Goal: produce a dataset for ENCV2008 that has total expenditures, tabaco expenditures, income/wealth, age, education level, gender
if "`c(username)'"=="paul.rodriguez" {
	glo dropbox="D:\Paul.Rodriguez\Drive\tabacoDrive" //Paul
}
else {
	glo dropbox="C:\Users\\`c(username)'\Dropbox\tabacoDrive" // Susana
}

glo project="$dropbox\Tobacco-health-inequalities\data\ENCV2008" // Paul

********************************************************************************
* Define individual level info
********************************************************************************
use "$project\original\personas.sav.dta", clear

gen female = P6020==2 if P6020!=.
gen age=P6040

gen student=P8586==1 if P8586!=.

gen     educ_uptoPrim = P6213==1 | P6213==2 | P6213==3 | (P6213==4 & P6213S1<12)   if student==1 & P6213!=. // At most, still in grade 11
replace educ_uptoPrim = P6219==1 | P6219==2 | P6219==3 | P6219==4 | (P6219==5 & P6219S1<11) if student==0 & P6219!=. // Did not obtained Bachillerato degree

gen		educ_uptoSec = (P6213==3 & P6213S1>=12)  if student==1 & P6213!=. // If still is Media, it should be above grade 11
replace educ_uptoSec = (P6219==4 & P6219S1>=11)  if student==0 & P6219!=. // If still is Media, it should be above grade 11replace educ_uptoSec = (P6213==4)  				 if student==1 & P6213!=. // obtained Bachillerato degree
replace educ_uptoSec = (P6213==4)  				 if student==1 & P6213!=. // If still is Media, it should be above grade 11replace educ_uptoSec = (P6213==4)  				 if student==1 & P6213!=. // obtained Bachillerato degree
*replace educ_uptoSec = (P6219==5)  				 if student==0 & P6219!=. // obtained Bachillerato degree

gen     educ_tert = inrange(P6213,5,8) if student==1 & P6213!=.
replace educ_tert = inrange(P6219,6,13) if student==0 & P6219!=.

gen edad=P6040

egen numnin = sum(edad < 18), by(DIRECTORIO)
egen numadu = sum(edad > 17), by(DIRECTORIO)
gen hheq = 1 + (0.5*(numadu-1)) + (0.3*numnin)
replace hheq = 1 if hheq<1

* >>>>> Mathieu, decide here what is better: take HH head only, or the average for adults... !!!!!!!!!!!!!!!!!!!!!!!!!!!! >>>>>>>>>
*keep if age>15


* Make it HH level dataset .....................................................
rename SECUENCIA_ENCUESTA SECUENCIA_ENCUESTAPER
rename SECUENCIA_P SECUENCIA_ENCUESTA
gen SECUENCIA_P=1
egen id_hogar = concat (DIRECTORIO SECUENCIA_P SECUENCIA_ENCUESTA)
egen id_persona = concat(id_hogar SECUENCIA_ENCUESTAPER)
egen id_vivienda = concat(DIRECTORIO SECUENCIA_P)
destring id_vivienda id_hogar id_persona, replace 
*collapse (mean) age female educ_uptoPrim educ_uptoSec educ_tert , by(DIRECTORIO SECUENCIA_ENCUESTA)
keep if P6051==1 // Jefe de hogar


********************************************************************************
* Compile household level data
********************************************************************************
merge 1:1 id_hogar using "$project\derived/ENCV2008_expenditures1.dta" , nogen
merge 1:1 DIRECTORIO SECUENCIA_ENCUESTA using "$project\derived/ENCV2008_incomeHogar.dta", nogen
merge 1:1 DIRECTORIO SECUENCIA_ENCUESTA using "$project\original/hogares.sav.dta", nogen
merge 1:1 DIRECTORIO SECUENCIA_P SECUENCIA_ENCUESTA using "$project\original/viviendas.sav.dta", gen(matchViv)

destring P1_DEPARTAMENTO, force replace

gen 	region=. 
replace region = 1 if REGION=="01"
replace region = 2 if REGION=="02"
replace region = 3 if REGION=="03"
replace region = 4 if REGION=="04"
replace region = 5 if REGION=="05"
replace region = 6 if REGION=="91"
replace region = 7 if REGION=="92"
replace region = 8 if REGION=="06"
replace region = 9 if REGION=="07"

label def region 1 "Atlantica" 2 "Oriental" 3 "Central" 4 "Pacifica (sin Valle)" 5 "Bogota" 6 "Antioquia"  8 "San Andres y Providencia" 9 "Orinoquia"  7 "Valle"
label val region region


gen persgast = totalExpenses/hheq
gen persingr = incomeHH/hheq
gen persgastc= GastoCte/hheq

*gen 	zona = 1 if P3== 1
*replace zona = 2 if P3== 2 | P3== 3 

*label def zona 1 "Urbano" 2 "Rural"
*label val zona zona 
label var zona "Urbano - Rural"


* These are the relevant variables!
sum tabacoExpenses totalExpenses incomeHH age female educ_uptoPrim educ_uptoSec educ_tert 

saveold "$project\derived\ENCV2008_tabaco1.dta", replace

