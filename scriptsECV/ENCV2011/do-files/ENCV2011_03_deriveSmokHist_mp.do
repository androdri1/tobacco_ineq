* Author: Paul Rodriguez (paul.rodriguez@urosario.edu.co)
* Date: 2017.07.05
* Goal: produce a dataset for ENCV2011 that has total expenditures, tabaco expenditures, income/wealth, age, education level, gender

/*
550_1	Datos de identificacion y de vivienda 

551_1	Datos de Servicios del hogar 
551_3	Datos de tenencia y financiacion de la vivienda que ocupa el hogar 
551_4	Datos condiciones de vida del hogar y tenencia 
551_5	Variables sobre gastos semanales 
551_6	Datos sobre gastos personales 
551_7	Datos de gastos mensuales
551_8	Datos de gastos trimestrales 
551_9	Datos gastos anuales 
551_10	Componente rural

552_1	Datos sobre caracteristicas y composicion del hogar 
552_2	Datos de salud 
552_3	Datos de cuidado de los niños y niñas menores 
552_5	Datos de educacion 
552_6	Datos de fuerza de trabajo 

553_1	Componente rural - Fincas 	
559_1	Componente rural - Cultivos 			
565_1	Componente rural - animales y productos 
*/


if "`c(username)'"=="paul.rodriguez" {
	glo dropbox="D:\Paul.Rodriguez\Dropbox\tabacoDrive" //Paul
}
else {
	glo dropbox="C:\Users\\`c(username)'\Dropbox\tabacoDrive" // Susana
}


*glo main="D:\Dropbox\Dropbox" //Mathieu
*glo main="$dropbox\tabaco" // Paul
glo main="$dropbox"	// Susana




********************************************************************************
* Define individual level info
********************************************************************************
use "$main\Tobacco-health-inequalities\data\ENCV2011\original\dbfp_encv_552_1.sav.dta", clear
merge 1:1 DIRECTORIO SECUENCIA_ENCUESTA using  "$main\Tobacco-health-inequalities\data\ENCV2011\original\dbfp_encv_552_5.sav.dta" , nogen
merge 1:1 DIRECTORIO SECUENCIA_ENCUESTA using  "$main\Tobacco-health-inequalities\data\ENCV2011\original\dbfp_encv_552_2.sav.dta", nogen // El archivo de Susana!!

gen female = P6020==2 if P6020!=.
gen age=P6040

gen student=P8586==1 if P8586!=.

gen     educ_uptoPrim = P6213==1 | P6213==2 | P6213==3  | (P6213==4 & P6213S1<12 )   if student==1 & P6213!=. // At most, still in grade 11
replace educ_uptoPrim = P6219==1 | P6219==2 | P6219==3 | P6219==4 | (P6219==5 & P6219S1<11) if student==0 & P6219!=. // Did not obtained Bachillerato degree

gen     educ_uptoSec = (P6213==4 & P6213S1>=12 )  if student==1 & P6213!=. // If still is Media, it should be above grade 11
replace educ_uptoSec = (P6219==5 & P6219S1>=11)  if student==0 & P6219!=. // obtained Bachillerato degree

gen     educ_tert = inrange(P6213,5,8) if student==1 & P6213!=.
replace educ_tert = inrange(P6219,6,13) if student==0 & P6219!=.
gen edad=P6040

egen numnin = sum(edad < 18), by(DIRECTORIO)
egen numadu = sum(edad > 17), by(DIRECTORIO)
gen hheq = 1 + (0.5*(numadu-1)) + (0.3*numnin) // Equivalencia del hogar de la OCDE
replace hheq = 1 if hheq<1



* >>>>> Mathieu, decide here what is better: take HH head only, or the average for adults... !!!!!!!!!!!!!!!!!!!!!!!!!!!! >>>>>>>>>
*keep if age>15


* Make it HH level dataset .....................................................
rename SECUENCIA_ENCUESTA SECUENCIA_ENCUESTAPER
rename SECUENCIA_P SECUENCIA_ENCUESTA
*collapse (mean) age female educ_uptoPrim educ_uptoSec educ_tert , by(DIRECTORIO SECUENCIA_ENCUESTA)
keep if P6051==1 // Jefe de hogar


********************************************************************************
* Compile household level data
********************************************************************************
merge 1:1 LLAVEHOG using  "$main\Tobacco-health-inequalities\data\ENCV2011\derived\ENCV2011_expenditures1.dta" , nogen
merge m:1 LLAVEHOG using  "$main\Tobacco-health-inequalities\data\ENCV2011\derived\ENCV2011_incomeHH.dta", nogen // El archivo de Susana!!
merge m:1 LLAVEHOG using  "$main\Tobacco-health-inequalities\data\ENCV2011\original\dbfp_encv_551_1.sav.dta" , nogen keepusing(FEX_C)
merge m:1 DIRECTORIO using  "$main\Tobacco-health-inequalities\data\ENCV2011\original\dbfp_encv_550_1.sav.dta" , nogen keepusing(P1_DEPARTAMENTO REGION P3)
destring P1_DEPARTAMENTO, force replace

gen persgast = totalExpenses/hheq
gen persingr = incomeHH/hheq
gen persgastc= GastoCte/hheq
rename REGION region 


*gen 	zona = 1 if P3== 1
*replace zona = 2 if P3== 2 | P3== 3 

*label def zona 1 "Urbano" 2 "Rural"
*label val zona zona 
label var zona "Urbano - Rural"


label def region 1 "Atlantica" 2 "Oriental" 3 "Central" 4 "Pacifica (sin Valle)" 5 "Bogota" 6 "Antioquia"  8 "San Andres y Providencia" 9 "Orinoquia"  7 "Valle"
label val region region

* These are the relevant variables!
*sum tabacoExpenses totalExpenses incomeHH age female educ_uptoPrim educ_uptoSec educ_tert 

saveold "$main\Tobacco-health-inequalities\data\ENCV2011\derived\ENCV2011_tabaco1.dta", replace
