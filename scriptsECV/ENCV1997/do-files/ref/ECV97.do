**********************************************
*** ENCUESTA DE CALIDAD DE VIDA 1997. RNFE ***
**********************************************
clear
set mem 250M
set more off

*** INFORMACIÓN DE LOS HOGARES ***

use "C:\DATA\ECV1997\nucleo.dta", clear
label def region 1 "Atlántica" 2 "Oriental" 3 "Pacífica" 4 "Central" 5 "Antioquia" 6 "Bogotá" 7 "Orinoquía" 8 "San Andrés"  
label val region region

label def depto 27 "Chocó" 19 "Cauca" 52 "Nariño" 76 "Valle" 17 "Caldas" 66 "Risaralda" 63 "Quindio" 73 "Tolima" 41 "Huila" 18 "Caquetá" 11 "Bogotá" 25 "Cundinamarca" 23 "Norte de Stander" 68 "Santander" 15 "Boyacá" 50 "Meta" 5 "Antioquia" 44 "Guajira" 20 "Cesar" 47 "Magdalena" 8 "Atlántico" 13 "Bolivar" 70 "Sucre" 23 "Córdoba" 88 "San Andrés y Prov." 81 "Arauca" 85 "Casanare" 86 "Putumayo" 91 "Amazonas"
label val depto depto

label def regionmo 1 "Atlántica" 2 "Oriental" 3 "Pacífica" 4 "Central" 5 "Antioquia" 6 "Bogotá" 7 "Orinoquía" 8 "San Andrés" 9 "Valle"
label val regionmo regionmo
label var regionmo "regiones separando Valle de Pacífico"

quietly destring clase, replace
label def clase 1 "Cabecera municipal" 2 "Centro poblado" 3 "Rural disperso" 
label val clase clase

rename factor fex

gen cero=0
egen idhogar=concat(ident cero idehogar)
drop cero
sort ident idhogar
save "C:\DATA\ECV1997\nucleo1.dta", replace

use "C:\DATA\ECV1997\vivienda.dta", clear
sort ident
save "C:\DATA\ECV1997\vivienda.dta", replace

merge ident using "C:\DATA\ECV1997\nucleo1.dta"
drop _merge
sort idhogar
save "C:\DATA\ECV1997\nucleo1.dta", replace

use "C:\DATA\ECV1997\hogar.dta", clear
keep idehogar ident c1203 c19 c35 c01 c02 c03 c04 c07-d2401  k02-k0505  k11-k1308  k15 k16
gen cero=0
egen idhogar=concat(ident cero idehogar)
drop cero
sort idhogar
merge idhogar using "C:\DATA\ECV1997\nucleo1.dta"
drop _merge
sort idhogar
save "C:\DATA\ECV1997\97hogares.dta", replace

use "C:\DATA\ECV1997\gastor1.dta", clear
gen cero=0
egen idhogar=concat(ident cero idehogar)
drop cero
sort idhogar
drop l1601-l17
quietly destring  l19, replace
gen au=.
replace au=l20 if l19==1
egen ac1=total(au), by(idhogar)
collapse (mean) ac1, by(idhogar)
label var ac1 "autoconsumo 1"
sort idhogar
save "C:\DATA\ECV1997\gastor1ac.dta", replace

use "C:\DATA\ECV1997\gastor2.dta", clear
gen cero=0
egen idhogar=concat(ident cero idehogar)
drop cero
sort idhogar
drop l2101-l22
quietly destring  l24, replace
gen au=.
replace au=l25 if l24==1
egen ac2=total(au), by(idhogar)
collapse (mean) ac2, by(idhogar)
label var ac2 "autoconsumo 2"
sort idhogar
save "C:\DATA\ECV1997\gastor2ac.dta", replace

use "C:\DATA\ECV1997\gastor3.dta", clear
gen cero=0
egen idhogar=concat(ident cero idehogar)
drop cero
sort idhogar
drop l2601-l27
quietly destring  l29, replace
gen au=.
replace au=l30 if l29==1
egen ac3=total(au), by(idhogar)
collapse (mean) ac3, by(idhogar)
label var ac3 "autoconsumo 3"
sort idhogar
save "C:\DATA\ECV1997\gastor3ac.dta", replace

use "C:\DATA\ECV1997\gastor4.dta", clear
gen cero=0
egen idhogar=concat(ident cero idehogar)
drop cero
sort idhogar
drop l3101-l32
quietly destring l34, replace
gen au=.
replace au=l35 if l34==1
egen ac4=total(au), by(idhogar)
collapse (mean) ac4, by(idhogar)
label var ac4 "autoconsumo 4"
sort idhogar
save "C:\DATA\ECV1997\gastor4ac.dta", replace

use "C:\DATA\ECV1997\gastor5.dta", clear
gen cero=0
egen idhogar=concat(ident cero idehogar)
drop cero
sort idhogar
drop l3601-l37
quietly destring  l39, replace
gen au=.
replace au=l40 if l39==1
egen ac5=total(au), by(idhogar)
collapse (mean) ac5, by(idhogar)
label var ac5 "autoconsumo 5"
sort idhogar
save "C:\DATA\ECV1997\gastor5ac.dta", replace

forval x=1/5 {
use "C:\DATA\ECV1997\97hogares.dta", clear
merge idhogar using "C:\DATA\ECV1997\gastor`x'ac.dta", sort nokeep
drop _merge
save "C:\DATA\ECV1997\97hogares.dta", replace	
}

egen autoconsumo=rowtotal(ac1 ac2 ac3 ac4 ac5)
label var autoconsumo "autoconsumo total"
order  idhogar  ident idehogar region-regionmo
sort idhogar
save "C:\DATA\ECV1997\97hogares.dta", replace

*** INFORMACIÓN DE LAS PERSONAS ***

use "C:\DATA\ECV1997\persona.dta", clear
keep  orden idehogar ident e02-h0402  h0702-e0602   e09 e1201 e1202 e13  f01 f11  f13 f14 f19 h01 h02 h0401 h0701
gen cero=0
egen idhogar=concat(ident cero idehogar)
egen idpersona=concat(idhogar cero orden)
drop cero

save "C:\DATA\ECV1997\persona1.dta",replace

use "C:\DATA\ECV1997\pet.dta", clear
keep  i09  j02-i02  i09-j2102  j2301-j2602  j2801-j35  j37 j39 j40  j4401- j5501 j5302- ing_tot
gen cero=0
egen idhogar=concat(ident cero idehogar)
egen idpersona=concat(idhogar cero orden)
drop cero
save "C:\DATA\ECV1997\pet1.dta", replace

use "C:\DATA\ECV1997\persona1.dta", clear
merge idpersona using "C:\DATA\ECV1997\pet1.dta", sort
drop _merge
order idpersona idhogar ident idehogar orden
sort idhogar
save "C:\DATA\ECV1997\97personas.dta", replace

merge idhogar using "C:\DATA\ECV1997\97hogares.dta"
drop _merge
drop d05-d1902
order  idpersona-orden  region regionmo depto munpio clase identseg depmun fex
save "C:\DATA\ECV1997\97ECVRNFE.dta", replace

cap erase "C:\DATA\ECV1997\nucleo1.dta"
cap erase "C:\DATA\ECV1997\gastor1ac.dta"
cap erase "C:\DATA\ECV1997\gastor2ac.dta"
cap erase "C:\DATA\ECV1997\gastor3ac.dta"
cap erase "C:\DATA\ECV1997\gastor4ac.dta"
cap erase "C:\DATA\ECV1997\gastor5ac.dta"
cap erase "C:\DATA\ECV1997\gastor5ac.dta"
cap erase "C:\DATA\ECV1997\persona1.dta"
cap erase "C:\DATA\ECV1997\pet1.dta"

label var idpersona "Identificación del individuo"
label var idhogar "Identificación del hogar"

*** DEFINICIONES ***

quietly destring h0401 h0701 j03 j05 j06 j07 j09 j15 j17 j19 j2101 j2902 j3401 j40 j4401 j4402 j4601 j4602 j4701 j4702 j4901 j4903 j4801 j4802 j5001 j5002 j5401 j5501 j5601, replace


*Adulto equivalente

gen edmas12=.
replace edmas12=1 if e02>=12
sort idhogar
by idhogar: egen A = total(edmas12)
label var A "Adultos de 12 años o más"
gen edmenos12 =.
replace edmenos12=1 if e02<12
by idhogar: egen C = total(edmenos12)
label var C "Miembos menores de 12 años"
drop edmas12 edmenos12
gen aeq=(A+(0.5*C))^(0.9)
label var aeq "Adulto equivalente (A+(0.5*C))^(0.9)"
rename e02 edad
rename e03 genero

*Nivel educativo
gen nived=.
replace nived=0 if h0401<3
replace nived=1 if (h0401==3 & h0402<5) | (h0701==3 & h0702<5) 

*Primaria completa modificada. Se eliminaron las opciones con H07

replace nived=2 if (h0401==3 & h0402==5)

*Secundaria incompleta. Se incluyó en h0702 el igual.

replace nived=3 if (h0401==4 & h0402<11) | (h0701==4 & h0702<=11)

replace nived=4 if (h0401==4 & h0402>=11)

replace nived=5 if h0401==5
replace nived=6 if h0401==6 |	h0701==5
replace nived=7 if h0401==7 | h0401==8 | h0701==6
label def nived 0 "Ninguno" 1 "Primaria incompleta" 2 "Primaria completa" 3 "Secundaria incompleta" 4 "Secundaria completa" 5 "Téctina" 6 "Superior incompleta" 7 "Superior y más"
label val nived nived
label var nived "Nivel educativo"

*Laborales

gen pet=2
replace pet=1 if edad>=12 
label var pet "PET"

gen pea=2 if pet==1
replace pea=1 if pet==1 & (j03<=3 | ((j03>=4 & j03<=8) & (j05==1 | j06==1 | j07==1 | j09==1)))
label var pea "PEA"

gen oc=2 if pea==1
replace oc=1 if pea==1 & (j03<=2 | ((j03>=3 & j03<=8) & (j05==1 | j06==1)))
label var oc "Ocupados"

*Informalidad

gen informal=2 if oc==1
replace informal=1 if oc==1 & ((j17==1 & j2101==2) | (j17==1 & j2101==3 & j19==2) | (j17>=3 & j17<=4 & j3401==2) | (j17>=5 & j17<=8 & j40==2) | (j17==9))
label var informal Informales

foreach var in pet pea oc informal {
label def `var' 1 Si 2 No
label val `var' `var'
}

*INGRESOS

gen j28=j2802/12 if j2802~=99
label var j28 "prima o bonos mensualizado"

*Salario. Se supone que los que reportan trabajar diariamente lo hacen 5.5 días a la semana
gen j29=.
replace j29=j2901 if j2902==1 & j2901~=99
replace j29=j2901*2 if j2902==2 & j2901~=99
replace j29=j2901*3 if j2902==3 & j2901~=99
replace j29=j2901*4.2857 if j2902==4 & j2901~=99
replace j29=j2901*23.5714286 if j2902==5 & j2901~=99
label var j29 "salario mensualizado"

*Ingreso formal

*Si el valor reportado es 99 se supone que es missing value.
recode j2302 j2402 j2502 j2602 j28 j29 j3002 j3102 j3202 j33 j4402 j4602 j4702 j4903 j4802 j5002 j5402 j5502 j5602 (99 = .)

egen wfobpriv=rowtotal(j2302 j2402 j2502 j2602 j28 j29 j3002 j3102 j3202) if ((j17==1 & j2101==1) | (j17==1 & j2101==3 & j19==1))
egen wfobpub=rowtotal(j2302 j2402 j2502 j2602 j28 j29 j3002 j3102 j3202) if j17==2
egen wfpeon=rowtotal(j3002 j3102 j3202) if j17>=3 & j17<=4 & j3401==1
egen wfpeon_a=rowtotal(j29 j3002 j3102 j3202) if j17>=3 & j17<=4 & j3401==1
gen wfindep=j33/3 if j17>=5 & j17<=8 & j40==1

label var wfobpriv "Salario formal mensual obrero privado"
label var wfobpub "Salario formal mensual obrero público"
label var wfpeon "Salario formal mensual peon/doméstico"
label var wfpeon_a "Salario formal mensual peon/doméstico, con j29"
label var wfindep "Salario formal mensual indep. cta. propia, etc."

gen slaboral=.
replace slaboral=1 if (j17==1 & j2101==1) | (j17==1 & j2101==3 & j19==1)
replace slaboral=2 if j17==2
replace slaboral=3 if j17>=3 & j17<=4 & j3401==1
replace slaboral=4 if j17>=5 & j17<=8 & j40==1 
label def slaboral 1 "Obrero empleado particular" 2 "Obrero empleado público" 3 "Jornalero, peón, doméstico" 4 "Independiente, Cta. Propia, Patrón"
label val slaboral slaboral
label var slaboral "Situación laboral de trabajador formal"

gen wformal=.
replace wformal=wfobpriv if wfobpriv~=.
replace wformal=wfobpub if wfobpub~=.
replace wformal=wfpeon if wfpeon~=.
replace wformal=wfindep if wfindep~=.
label var wformal "Salario mensual formal"

*Ingreso informal

egen wobpriv=rowtotal(j2302 j2402 j2502 j2602 j28 j29 j3002 j3102 j3202) if informal==1
egen wobpub=rowtotal(j2302 j2402 j2502 j2602 j28 j29 j3002 j3102 j3202) if informal==1
egen wpeon=rowtotal(j3002 j3102 j3202) if informal==1
egen wpeon_a=rowtotal(j29 j3002 j3102 j3202) if informal==1
gen windep=j33/3 if informal==1

label var wobpriv "Salario informal mensual obrero privado"
label var wobpub "Salario informal mensual obrero público"
label var wpeon "Salario informal mensual peon/doméstico"
label var wpeon_a "Salario informal mensual peon/doméstico, con j29"
label var windep "Salario informal mensual indep. cta. propia, etc."

gen slaboral_inf=.
replace slaboral_inf=1 if j17==1 & informal==1
replace slaboral_inf=2 if j17==2 & informal==1
replace slaboral_inf=3 if j17>=3 & j17<=4 & informal==1
replace slaboral_inf=4 if j17>=5 & j17<=8 & informal==1 
label def slaboral_inf 1 "Obrero empleado particular" 2 "Obrero empleado privado" 3 "Jornalero, peón, doméstico" 4 "Independiente, Cta. Propia, Patrón"
label val slaboral_inf slaboral_inf
label var slaboral_inf "Situación laboral de trabajador informal"

gen winformal=.
replace winformal=wobpriv if wobpriv~=.
replace winformal=wobpub if wobpub~=.
replace winformal=wpeon if wpeon~=.
replace winformal=windep if windep~=.
label var winformal "Salario mensual informal"

**Note que el siguiente grupo (agrícola) es subgrupo de los de arriba.

*Ingreso por actividad agrícola
gen wagricola=.
replace wagricola=j33/3 if j17==8
label var wagricola "Ingreso por Actividades Agrícolas"

*Ingreso por servicios agrícolas
gen wservag=.
replace wservag=j33/3 if (j17>=5 & j17<=7) & (j15>=11 & j15<=13)
label var wservag "Ingreso por Servicios Agrícolas"

*Ingreso por otros servicios
gen wservicios=.
replace wservicios=j33/3 if (j17>=5 & j17<=7) & (j15>=63 & j15<=96)
label var wservicios "Ingreso por otros Servicios"

*ingreso por actividad comercial
gen wcomercial=.
replace wcomercial=j33/3 if (j17>=5 & j17<=7) & (j15==61 | j15==62)
label var wcomercial "Ingreso por Actividad Comercial"

*ingreso por otras actividades económicas
gen wotras=.
replace wotras=j33/3 if (j17>=5 & j17<=7) & (j15>=21 & j15<=50)
label var wotras "Ingreso por otras activ. económicas"

*Ingreso por segundas actividades
gen wsecundario=. if j17~=. & j4401==1
replace wsecundario=j4402
label var wsecundario "Ingreso por segundo trabajo"

*Pensiones
gen pension=. if j17~=. & j4601==1
replace pension=j4602
label var pension "Pensiones"

*Transferencias
gen j49=j4903/12
egen transf=rowtotal(j4702 j49) if j17~=. & (j4701==1 | j4901==1)
label var transf "Transferencias"

*Ingresos de capital
gen j48=j4802/3
gen j50=j5002/12
egen wcapital=rowtotal(j48 j50) if j17~=. & (j4801==1 | j5001==1)
label var wcapital "Ingresos de Capital"

*Otros ingresos
egen wl=rowtotal(j5402 j5502 j5602) if j17~=. & (j5401==1 | j5501==1 | j5601==1)
gen wloterias=wl/12
drop wl
label var wloterias "Otros ingresos"

* INGRESOS TOTALES (RIQUEZA)
egen income=rowtotal(wformal winformal wagricola wservag wservicios wcomercial wotras wsecundario pension transf wcapital wloterias)
label var income "Ingresos totales"

sort idhogar idpersona

* INGRESO DEL HOGAR
egen incomeh=total(income), by(idhogar)
label var incomeh "Ingresos totales del hogar"

* INGRESO PER CAPITA DEL HOGAR
gen incomepc=incomeh/c35
label var incomepc "Ingreso per cápia del hogar"

* Cantidad de individuos que reportan ingresos por hogar

gen ind=.
replace ind=1 if income~=. & income~=0
egen reportan=total(ind), by(idhogar)
drop ind
label var reportan "Individuos que reportan ingreso en el hogar"

* Porcentaje de individuos que reportan ingresos por hogar

gen razonreporte=reportan/c35
label var razonreporte "Porcentaje de individuos que reportan ingresos por hogar"



svyset[pw=fex]
save "C:\DATA\ECV1997\97ECVRNFE.dta", replace


