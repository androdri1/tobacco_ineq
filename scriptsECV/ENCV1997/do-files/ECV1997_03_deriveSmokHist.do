**********************************************
*** ENCUESTA DE CALIDAD DE VIDA 1997. RNFE ***
* Author: Paul Rodriguez

**********************************************
if "`c(username)'"=="paul.rodriguez" {
	glo dropbox="D:\Paul.Rodriguez\Dropbox\tabacoDrive" //Paul
}
else {
	glo dropbox="C:\Users\\`c(username)'\Dropbox\tabacoDrive" // Susana
}

glo project="$dropbox\Tobacco-health-inequalities\data\ENCV1997"



set more off

*** INFORMACIÓN DE LOS HOGARES ***

use  "$project\originales\nucleo.dta", clear

gen 	region1 = . 
replace region1 = 1 if regionmo==1 
replace region1 = 2 if regionmo==2 
replace region1 = 3 if regionmo==4 
replace region1 = 4 if regionmo==3
replace region1 = 5 if regionmo==6 
replace region1 = 6 if regionmo==5
replace region1 = 7 if regionmo==9 
replace region1 = 8 if regionmo==8
replace region1 = 9 if regionmo==7
drop regionmo

gen 	region2 = . 
replace region2 = 1 if region==1 
replace region2 = 2 if region==2 
replace region2 = 3 if region==4 
replace region2 = 4 if region==3
replace region2 = 5 if region==6 
replace region2 = 6 if region==5 
replace region2 = 8 if region==8
replace region2 = 9 if region==7
drop region 

rename region1 region 
rename region2 regionmo


label def region 1 "Atlantica" 2 "Oriental" 3 "Central" 4 "Pacifica (sin Valle)" 5 "Bogota" 6 "Antioquia"  8 "San Andres y Providencia" 9 "Orinoquia"  7 "Valle"
label val region region

label def depto 27 "Choco" 19 "Cauca" 52 "Narino" 76 "Valle" 17 "Caldas" 66 "Risaralda" 63 "Quindio" 73 "Tolima" 41 "Huila" 18 "Caqueta" 11 "Bogota" 25 "Cundinamarca" 23 "Norte de Stander" 68 "Santander" 15 "Boyaca" 50 "Meta" 5 "Antioquia" 44 "Guajira" 20 "Cesar" 47 "Magdalena" 8 "Atlántico" 13 "Bolivar" 70 "Sucre" 23 "Córdoba" 88 "San Andrés y Prov." 81 "Arauca" 85 "Casanare" 86 "Putumayo" 91 "Amazonas"
label val depto depto

label def regionmo 1 "Atlantica" 2 "Oriental" 4 "Pacifica" 3 "Central" 6 "Antioquia" 5 "Bogota" 9 "Orinoquia" 8 "San Andres y Providencia" 
label val regionmo regionmo
label var regionmo "regiones separando Valle de Pacífico"

quietly destring clase, replace
label def clase 1 "Cabecera municipal" 2 "Centro poblado" 3 "Rural disperso" 
label val clase clase

rename factor fex

gen cero=0
egen id_hogar=concat(ident cero idehogar)
drop cero
sort ident id_hogar
cap d

gen 	zona = 1 if clase== 1
replace zona = 2 if clase== 2 | clase== 3 

label def zona 1 "Urbano" 2 "Rural"
label val zona zona 
label var zona "Urbano - Rural"

merge n:1 ident using "$project\originales\vivienda.dta", nogen

tempfile nucleo1
save `nucleo1'
* *******************************************************************************

use "$project\originales\hogar.dta", clear
keep idehogar ident c1203 c19 c35 c01 c02 c03 c04 c07-d2401  k02-k0505  k11-k1308  k15 k16
gen cero=0
egen id_hogar=concat(ident cero idehogar)
drop cero
sort id_hogar
merge 1:1 id_hogar using `nucleo1', nogen

tempfile 97hogares
save `97hogares', replace

////////////////////////////////////////////////////////////////////////////////
// INFORMACIÓN DE LAS PERSONAS 

use "$project\originales\persona.dta", clear
keep  orden idehogar ident e02-h0402  h0702-e0602  f09 e09 e1201 e1202 e13  f01 f10 f11  f13 f14 f15 f18 f19 f20 h01 h02 h0401 h0701
gen cero=0
egen id_hogar=concat(ident cero idehogar)
egen idpersona=concat(id_hogar cero orden)
drop cero

tempfile persona1
save `persona1'

use "$project\originales\pet.dta", clear
keep  i09  j02-i02  i09-j2102  j2301-j2602  j2801-j35  j37 j39 j40  j4401- j5501 j5302- ing_tot
gen cero=0
egen id_hogar=concat(ident cero idehogar)
egen idpersona=concat(id_hogar cero orden)
drop cero
tempfile pet1
save `pet1'

use `persona1', clear
merge 1:1  idpersona using `pet1',  nogen

order idpersona id_hogar ident idehogar orden
sort id_hogar

merge n:1  id_hogar using `97hogares' , nogen

drop d05-d1902
order  idpersona-orden  region regionmo depto munpio clase identseg depmun fex

label var idpersona "Identificación del individuo"
label var id_hogar "Identificación del hogar"

*** DEFINICIONES ***

quietly destring h0401 h0701 j03 j05 j06 j07 j09 j15 j17 j19 j2101 j2902 j3401 j40 j4401 j4402 j4601 j4602 j4701 j4702 j4901 j4903 j4801 j4802 j5001 j5002 j5401 j5501 j5601, replace


*Adulto equivalente

gen edmas12=.
replace edmas12=1 if e02>=12
sort id_hogar
by id_hogar: egen A = total(edmas12)
label var A "Adultos de 12 años o más"
gen edmenos12 =.
replace edmenos12=1 if e02<12
by id_hogar: egen C = total(edmenos12)
label var C "Miembos menores de 12 años"
drop edmas12 edmenos12
gen aeq=(A+(0.5*C))^(0.9)
label var aeq "Adulto equivalente (A+(0.5*C))^(0.9)"

////////////////////////////////////////////////////////////////////
destring e02 e03 h02 h0701 h0702 h0401 h0402 , force replace

gen female = e03==2 if e03!=.
gen age=e02

gen student=h02==1 if h02!=.

gen     educ_uptoPrim = h0701==1 | h0701==2 | h0701==3 | (h0701==4 & h0702<12 )   if student==1 & h0701!=. // At most, still in grade 11
replace educ_uptoPrim = h0401==1 | h0401==2 | h0401==3 | (h0401==4 & h0402<11) if student==0 & h0401!=. // Did not obtained Bachillerato degree

gen     educ_uptoSec = (h0701==4 & h0702>=12 )  if student==1 & h0701!=. // If still is Media, it should be above grade 11
replace educ_uptoSec = (h0401==4 & h0402>=11)  if student==0 & h0401!=. // obtained Bachillerato degree

gen     educ_tert = inrange(h0701,5,7) if student==1 & h0701!=.
replace educ_tert = inrange(h0401,5,8) if student==0 & h0401!=.

* .....................

gen edad=age
egen numnin = sum(edad < 18), by(id_hogar)
egen numadu = sum(edad > 17), by(id_hogar)
gen hheq = 1 + (0.5*(numadu-1)) + (0.3*numnin)
replace hheq = 1 if hheq<1

* >>>>> Mathieu, decide here what is better: take HH head only, or the average for adults... !!!!!!!!!!!!!!!!!!!!!!!!!!!! >>>>>>>>>
*keep if age>15


* Make it HH level dataset .....................................................
*collapse (mean) age female educ_uptoPrim educ_uptoSec educ_tert , by(DIRECTORIO SECUENCIA_ENCUESTA)
destring e04, force replace
keep if e04==1 // Jefe de hogar

destring b0503, replace
********************************************************************************
* Compile household level data
********************************************************************************
merge 1:1 id_hogar using "$project\derived\ECV1997_expenditures1.dta", nogen
merge 1:1 id_hogar using "$project\derived\ECV1997_incomeHH.dta", nogen

gen persgast = totalExpenses/hheq
gen persingr = incomeHH/hheq
gen persgastc= GastoCte/hheq

* These are the relevant variables!
*sum tabacoExpenses totalExpenses incomeHH age female educ_uptoPrim educ_uptoSec educ_tert ///
*	T1_expen_m1 T2_expen_m1 T2_expen_m2 T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 ///
*	T2_expen_m7 T2_expen_m8 T2_expen_m9



svyset[pw=fex]
save "$project\derived\ECV1997_tabaco1.dta", replace


