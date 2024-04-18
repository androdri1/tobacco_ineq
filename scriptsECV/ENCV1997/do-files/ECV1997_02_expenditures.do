* Author: Paul Rodriguez (paul.rodriguez@urosario.edu.co)
* Date: 2017.07.13
* Goal: produce total income of the HH for the ECV1997 (no imputation or outlier analysis here!)


if "`c(username)'"=="paul.rodriguez" {
	glo dropbox="D:\Paul.Rodriguez\Dropbox\tabacoDrive" //Paul
}
else {
	glo dropbox="C:\Users\\`c(username)'\Dropbox\tabacoDrive" // Susana
}


********************************************************************************
********************************************************************************
		****************** BASE CON IMPUTACIONES ******************
********************************************************************************
********************************************************************************
// Programa para corregir bases 
cap program drop corregir_base
program define corregir_base , rclass
	args lista
	disp "Correccion de base"
	foreach n in `lista' {
		cap use "$dropbox\Tobacco-health-inequalities\data\ENCV1997\originales\gastor`n'.dta", clear
		cap gen cero=0
		cap egen id_hogar=concat(ident cero idehogar)
		cap rename ident id_vivienda
		cap drop cero
	}
end 

// Programa para limpiar variables
cap program drop cleanvars
program define cleanvars , rclass
	args lista
	disp "Cleaning! `lista'"
	foreach varDep in `lista'	{
				
		* For yes and no questions, set the "no"s as 0s
		cap recode `varDep' (2=0) (8 9 99 98 =.), g(_`varDep')
		cap drop `varDep'
		cap rename _`varDep' `varDep'
	}
end


////////////////////////////////////////////////////////////////////////////////
// Mean imputation for expenditures made individually
////////////////////////////////////////////////////////////////////////////////
cap program drop meanimput
program define meanimput , rclass
	args lista
	disp "Imputation of mean values at the individual level"
	foreach varDep in `lista' {
		cap gen nomiss_`varDep'=`varDep' if (`varDep'==98 | `varDep'==99 | `varDep'!=196 | `varDep'!=197 | `varDep'!=198)
		cap egen mean_`varDep'=mean(nomiss_`varDep'), by(b0503)
		cap replace `varDep'=mean_`varDep' if (`varDep'==98 | `varDep'==99 | `varDep'==196 | `varDep'==197 | `varDep'==198)
		cap egen hogar_`varDep'=total(`varDep'), by (id_hogar)
		cap drop nomiss_`varDep' mean_`varDep' `varDep'
		cap rename hogar_`varDep' `varDep'
	}
end 

////////////////////////////////////////////////////////////////////////////////
// Mean imputation for expenditures made at the household level
////////////////////////////////////////////////////////////////////////////////
cap program drop meanimput_h
program define meanimput_h , rclass
	args lista
	disp "Imputation of mean values at the household level"
	foreach varDep in `lista' {
		cap gen nomiss_`varDep'=`varDep' if (`varDep'!=98 & `varDep'!=99 & `varDep'!=.) 
		cap egen mean_`varDep'=mean(nomiss_`varDep'), by(b0503)
		cap replace `varDep'=mean_`varDep' if (`varDep'==98 | `varDep'==99)
		cap drop nomiss_`varDep' mean_`varDep'
	}
end 


use "$dropbox\Tobacco-health-inequalities\data\ENCV1997\originales\vivienda.dta", clear
rename ident id_vivienda
destring id_vivienda, replace

tempfile vivienda
save `vivienda'

use "$dropbox\Tobacco-health-inequalities\data\ENCV1997\originales\hogar.dta", clear
gen cero=0
egen id_hogar=concat(ident cero idehogar)
rename ident id_vivienda
destring id_vivienda, replace
drop k* l* d07* d08* d09* d13* d14* d15* d16* d17* d18*

merge n:1 id_vivienda using `vivienda', nogen
destring b0503, replace

tempfile viviendas
save `viviendas'
save "$dropbox\Tobacco-health-inequalities\data\ENCV1997\derived\Vivienda_Hogar.dta", replace
 
// GASTOS INDIVIDUALES: SALUD Y EDUCACION 
* Members of the household ********************************************************
if 1==1{
use "$dropbox\Tobacco-health-inequalities\data\ENCV1997\originales\persona.dta", clear
gen cero=0
egen id_hogar=concat(ident cero idehogar)
rename ident id_vivienda

quietly destring 	g02 g06* g07* g08* g09* g10* g11* g12* g13* g14* g15* h14*  ///
					h15* h16* h17* h18* h19* h20* h21* h22* h26 h27* ///
					h23 h24* h31 h32* f01 f03 f06 f0801 f11 f13 f26 ///
					f30* f31* f32* f33* f34* f35* f36* f37* f38*, replace
					
la def f06 1 "Usted y la empresa donde trabaja" 2 "Solo usted" 3 "Es pensionado o tiene pension de sobreviviente" 4 "Solo la empresa" 5 "Familiar del afiliado" 6 "No paga"
la val f06 f06

la def f13 1 "Solo la ESS" 2 "Solo el plan compl." 3 "Recursos propios" 4 "ESS + PC + RP" 5 "ESS + PC" 6 "ESS + RP" 7 "PC + RP"
la val f13 f13 
la val f26 f13
la def g02 1 "Hogar ICBF" 2 "Jardin oficial" 3 "Jardin no oficial" 4 "Colegio/Escuela oficial" 5 "Colegio/Escuela no oficial" 6 "Ninguno"
la val g02 g02
la def frec 1 "Mensual" 2 "Semestral" 3 "Anual" 4 "Esporadico"
la val h2402 frec
la val h2702 frec
la val h3202 frec

merge n:1 id_hogar using `viviendas', nogen

destring orden b05* , replace
cleanvars 	"g0601 g0701 g0801 g0901 g1001 g1101 g1201 g1301 g1401 g1501 h1401 h1501 h1601 h1701 h1801 h1901 h2001 h2101 h2201 h23 h26 h31 f01 f03 f0801 f11 f3001 f3101 f3201 f3301 f3401 f3501 f3601 f3701 f3801"

replace b0503=8 if b0501==.

********************************************************************************
// Subsidios y Becas a la Educacion mensualizados
foreach x in h2702 h2402 h3202{
replace `x'=6 	if `x'==2
replace `x'=12 	if `x'==3
replace `x'=1  	if `x'==4 
}

foreach x in h240 h270 h320 {
replace `x'1=(`x'1/`x'2) if (`x'1!=. & `x'1!=0 & `x'2!=.)
}
********************************************************************************
sort id_hogar orden

******** IMPUTATION OF MEAN VALUES FOR EDUCATIONAL AND HEALTH EXPENSES ********

// Health
meanimput "f07 f0802 f14 f26 f3002 f3102 f3202 f3302 f3402 f3502 f3602 f3702 f3802"

// Education
meanimput "g0602 g0702 g0802 g0902 g1002 g1102 g1202 g1302 g1402 g1403 g1502 g1503 h1402 h1502 h1602 h1702 h1802 h1902 h2002 h2102 h2202 h2701 h2401 h3201"
 
save "$dropbox\Tobacco-health-inequalities\data\ENCV1997\derived\Gasto_SaludEduc.dta", replace

foreach vard in g0602 g0702 g0802 g0902 g1002 g1102 g1202 g1302 g1402 g1403 g1502 g1503 h1402 h1502 h1602 h1702 h1802 h1902 h2002 h2102 h2202 h2701 h2401 h3201{
su `vard' 
}


}

if 1==1{
// GASTOS DEL HOGAR: ALIMENTOS, ALCOHOL Y TABACO, VESTIDO Y CALZADO, SERVICIOS DEL HOGAR, 
// MUEBLES Y ENSERES, TRANSPORTE Y COMUNICACIONES, SERVICIOS CULTURALES Y ENTRETENIMIENTO,
// SERVICIOS PERSONALES Y OTROS. 


* 1. Alimentos *****************************************************************
// Demas alimentos consumidos por el hogar
corregir_base "1"
quietly destring  l1602 l18 l1601, replace
cleanvars 	"l1602 l18 l17 l20"
replace l17=. if l1602==0
replace l20=. if l18==0

egen T1_infoav=rowtotal(l1602 l18)
egen T1_expen_7d=rowtotal(l17 l20) if T1_infoav>0 & T1_infoav!=. , missing
replace T1_expen_7d=T1_expen_7d*(30/7) if T1_expen_7d!=. 
rename T1_expen_7d T1_expen_m1_a

collapse (sum) T1_expen_m1_a T1_infoav ///
		 (last) id_vivienda, by(id_hogar)
replace T1_expen_m1_a=. if T1_infoav==0 // If no data was collected, it is clearly a missing!
label var T1_expen_m1_a "Food expenses 7days (monthly)"

gen alimExpenses=T1_expen_m1_a
sum alimExpenses, d
scalar a=r(p99)
dis a
replace alimExpenses = a if alimExpenses>a & alimExpenses!=.

merge 1:1 id_hogar using `viviendas', nogen
destring b0503, replace


*merge 1:1 id_hogar using `gastor1_foodcfc'

rename T1_expen_m1_a T1_expen_m1
 label var T1_expen_m1 "Food expenses 7days (monthly)"

tempfile gastor1_food
save `gastor1_food'


* 2. Alcohol and Tobacco *******************************************************
corregir_base "2"
quietly destring  l2102 l23 l2101, replace
cleanvars 	"l2102 l23 l22 l25"
replace l22=. if l2102==0
replace l25=. if l23==0

egen T2_infoav1=rowtotal(l2102 l23) if (l2101==30 | l2101==33 ) // 30 Tobacco 33 Alcohol
egen T2_expen_7d1=rowtotal(l22 l25) if (T2_infoav1>0 & T2_infoav1!=.), missing
replace T2_expen_7d1=T2_expen_7d1*(30/7) if T2_expen_7d1!=.
label var T2_expen_7d1 "Tob-Alc 7 days (monthly)"
rename T2_expen_7d1 T2_expen_m1

egen T2_infoav1tab=rowtotal(l2102 l23) if l2101==30
egen tabacoExpenses=rowtotal(l22 l25) if (T2_infoav1tab>0 & T2_infoav1tab!=.), missing // 30 Tobacco
replace  tabacoExpenses=tabacoExpenses*(30/7) if tabacoExpenses!=.

egen T2_infoav1alc=rowtotal(l2102 l23) if l2101==33
egen alcoholExpenses=rowtotal(l22 l25) if (T2_infoav1alc>0 & T2_infoav1alc!=.), missing
replace alcoholExpenses=alcoholExpenses*(30/7) if alcoholExpenses!=.


collapse (sum) T2_expen_m1 tabacoExpenses alcoholExpenses T2_infoav1 T2_infoav1tab T2_infoav1alc ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m1 "Tob-Alc 7 days (monthly)"
label var tabacoExpenses "Tabaco expenses (monthly)"
replace T2_expen_m1=. if T2_infoav1==0  // If no data was collected, it is clearly a missing!
replace tabacoExpenses=. if T2_infoav1tab==0
sum tabacoExpenses, d
scalar b=r(p99)
dis b
replace tabacoExpenses = b if tabacoExpenses>b & tabacoExpenses!=.


merge 1:1 id_hogar using `viviendas', nogen
destring b0503, replace

meanimput_h "T2_expen_m1"

tempfile gastor2_alcotob
save `gastor2_alcotob'



// VARIOS //

* 3. CLOTHING AND FOOTWEAR

* Mensuales
********************************************************************************
corregir_base "3"
quietly destring  l2602 l28 l2601, replace
cleanvars 	"l2602 l28 l27 l30"
replace l27=. if l2602==0
replace l30=. if l28==0


egen T2_infoav2_a=rowtotal(l2602 l28) if l2601==43
egen T2_expen_mon2a=rowtotal(l27 l30) if (T2_infoav2_a>0 & T2_infoav2_a!=.), missing
rename T2_expen_mon2a T2_expen_m2a

collapse (sum) T2_expen_m2a  T2_infoav2_a ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m2a "C&F (a)"
replace T2_expen_m2a=. if T2_infoav2_a==0

merge 1:1 id_hogar using `viviendas', nogen
destring b0503, replace

meanimput_h "T2_expen_m2a"

tempfile gastor3_cf
save `gastor3_cf'


* Trimestrales 
********************************************************************************
corregir_base "4"
quietly destring  l3102 l33 l3101, replace
cleanvars 	"l3102 l33 l32 l35"
replace l32=. if l3102==0
replace l35=. if l33==0

egen T2_infoav2_b=rowtotal(l3102 l33) if (l3101==60 | l3101==61 | l3101==62 | l3101==63 )
egen T2_expen_q2b=rowtotal(l32 l35) if (T2_infoav2_b>0 & T2_infoav2_b!=.), missing
replace T2_expen_q2b=T2_expen_q2b*(1/3) if T2_expen_q2b!=.
rename T2_expen_q2b T2_expen_m2b

collapse (sum) T2_expen_m2b  T2_infoav2_b ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m2b "C&F (b)"
replace T2_expen_m2b=. if T2_infoav2_b==0

merge 1:1 id_hogar using `viviendas', nogen
destring b0503, replace

meanimput_h "T2_expen_m2b"

merge 1:1  id_hogar using `gastor3_cf', nogen

egen T2_infoav2=rowtotal(T2_infoav2_b T2_infoav2_a)
egen T2_expen_m2=rowtotal(T2_expen_m2b T2_expen_m2a) if T2_infoav2>0 & T2_infoav2!=. , missing
la var T2_expen_m2 "Clothing and footwear (monthly)"

keep  id_hogar id_vivienda b0503 T2_expen_m2 T2_infoav2
tempfile CF
save `CF'


* 4. HOUSEHOLD SERVICES

* Semanales 
********************************************************************************
corregir_base "2"
quietly destring  l2102 l23 l2101, replace
cleanvars 	"l2102 l23 l22 l25"
replace l22=. if l2102==0
replace l25=. if l23==0

egen T2_infoav3_a=rowtotal(l2102 l23) if (l2101==38) 
egen T2_expen_7d3a=rowtotal(l22 l25) if (l2101==38) & (T2_infoav3_a>0 & T2_infoav3_a!=.), missing
replace T2_expen_7d3a=T2_expen_7d3a*(30/7) if T2_expen_7d3a!=. 
rename T2_expen_7d3a T2_expen_m3a

collapse (sum) T2_expen_m3a  T2_infoav3_a ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m3a "HS (a)"
replace T2_expen_m3a=. if T2_infoav3_a==0

merge 1:1 id_hogar using `viviendas', nogen
destring b0503, replace


tempfile gastor2_hs
save `gastor2_hs'


* Mensuales 
********************************************************************************
corregir_base "3"
quietly destring  l2602 l28 l2601, replace
cleanvars 	"l2602 l28 l27 l30"
replace l27=. if l2602==0
replace l30=. if l28==0

egen T2_infoav3_b=rowtotal(l2602 l28) if (l2601==41 | l2601==44 | l2601==48 | l2601==49)
egen T2_expen_mon3b=rowtotal(l27 l30) if (T2_infoav3_b>0 & T2_infoav3_b!=.), missing
rename T2_expen_mon3b T2_expen_m3b

collapse (sum) T2_expen_m3b  T2_infoav3_b ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m3b "HS (b)"
replace T2_expen_m3b=. if T2_infoav3_b==0

merge 1:1 id_hogar using `viviendas', nogen
destring b0503, replace

meanimput_h "T2_expen_m3b"

tempfile gastor3_hs
save `gastor3_hs'


* Anuales 
********************************************************************************
corregir_base "5"
quietly destring  l3602 l38 l3601, replace
cleanvars 	"l3602 l38 l37 l40"
replace l37=. if l3602==0
replace l40=. if l38==0

egen T2_infoav3_c=rowtotal(l3602 l38) if (l3601==71)
egen T2_expen_y3c=rowtotal(l37 l40) if (T2_infoav3_c>0 & T2_infoav3_c!=.), missing
replace T2_expen_y3c=T2_expen_y3c*(1/12) if T2_expen_y3c!=.
rename T2_expen_y3c T2_expen_m3c

collapse (sum) T2_expen_m3c  T2_infoav3_c ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m3c "HS (c)"
replace T2_expen_m3c=. if T2_infoav3_c==0

merge 1:1 id_hogar using `viviendas', nogen
destring b0503, replace

meanimput_h "T2_expen_m3c"

forval x=2/3{
	merge 1:1  id_hogar using `gastor`x'_hs', nogen
}

egen T2_infoav3=rowtotal(T2_infoav3_c T2_infoav3_b T2_infoav3_a)
egen T2_expen_m3=rowtotal(T2_expen_m3c T2_expen_m3b T2_expen_m3a) if T2_infoav3>0 & T2_infoav3!=. , missing
la var T2_expen_m3 "Household services (monthly)"

keep  id_hogar id_vivienda b0503 T2_expen_m3 T2_infoav3
tempfile HS
save `HS'


* 5. FURNITURE

* Anuales relacionados con Muebles y Enseres
********************************************************************************
corregir_base "5"
quietly destring  l3602 l38 l3601, replace
cleanvars 	"l3602 l38 l37 l40"
replace l37=. if l3602==0
replace l40=. if l38==0

egen T2_infoav4_a=rowtotal(l3602 l38) if (l3601==70 | l3601==72 | l3601==73 | l3601==74)
egen T2_expen_y4a=rowtotal(l37 l40) if  (T2_infoav4_a>0 & T2_infoav4_a!=.), missing
replace T2_expen_y4a=T2_expen_y4a*(1/12) if T2_expen_y4a!=.
rename T2_expen_y4a T2_expen_m4

collapse (sum) T2_expen_m4  T2_infoav4_a ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m4 "F (a)"
replace T2_expen_m4=. if T2_infoav4_a==0

merge 1:1 id_hogar using `viviendas', nogen
destring b0503, replace

meanimput_h "T2_expen_m4"

tempfile F
save `F'


* 6. HEALTH

* Mensuales relacionados con Salud
********************************************************************************
corregir_base "3"
quietly destring  l2602 l28 l2601, replace
cleanvars 	"l2602 l28 l27 l30"
replace l27=. if l2602==0
replace l30=. if l28==0

egen T2_infoav5_a=rowtotal(l2602 l28) if (l2601==42)
egen T2_expen_mon5a=rowtotal(l27 l30) if (T2_infoav5_a>0 & T2_infoav5_a!=.), missing
rename T2_expen_mon5a T2_expen_m5

collapse (sum) T2_expen_m5  T2_infoav5_a ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m5 "H (a)"
replace T2_expen_m5=. if T2_infoav5_a==0

merge 1:1 id_hogar using `viviendas', nogen
destring b0503, replace

meanimput_h "T2_expen_m5"

tempfile H
save `H'



* 7. TRANSPORT AND COMUNICATION

* Semanales 
********************************************************************************
corregir_base "2"
quietly destring  l2102 l23 l2101, replace
cleanvars 	"l2102 l23 l22 l25"
replace l22=. if l2102==0
replace l25=. if l23==0

egen T2_infoav6_a=rowtotal(l2102 l23) if (l2101==32 | l2101==34 | l2101==39) 
egen T2_expen_7d6a=rowtotal(l22 l25) if (T2_infoav6_a>0 & T2_infoav6_a!=.), missing
replace T2_expen_7d6a=T2_expen_7d6a*(30/7) if T2_expen_7d6a!=.
rename T2_expen_7d6a T2_expen_m6a

collapse (sum) T2_expen_m6a  T2_infoav6_a ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m6a "T&C (a)"
replace T2_expen_m6a=0 if T2_infoav6_a==0

merge 1:1 id_hogar using `viviendas', nogen
destring b0503, replace

meanimput_h "T2_expen_m6a"

tempfile gastor2_tc
save `gastor2_tc'


* Trimestrales 
********************************************************************************
corregir_base "4"
quietly destring  l3102 l33 l3101, replace
cleanvars 	"l3102 l33 l32 l35"
replace l32=. if l3102==0
replace l35=. if l33==0

egen T2_infoav6_b=rowtotal(l3102 l33) if (l3101==64)
egen T2_expen_q6b=rowtotal(l32 l35) if (T2_infoav6_b>0 & T2_infoav6_b!=.), missing
replace T2_expen_q6b=T2_expen_q6b*(1/3) if T2_expen_q6b!=.
rename T2_expen_q6b T2_expen_m6b

collapse (sum) T2_expen_m6b  T2_infoav6_b ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m6b "T&C (b)"
replace T2_expen_m6b=0 if T2_infoav6_b==0

merge 1:1 id_hogar using `viviendas', nogen
destring b0503, replace

meanimput_h "T2_expen_m6b"

merge 1:1  id_hogar using `gastor2_tc', nogen 

egen T2_infoav6=rowtotal( T2_infoav6_b T2_infoav6_a)
egen T2_expen_m6=rowtotal(T2_expen_m6b T2_expen_m6a) if T2_infoav6>0 & T2_infoav6!=. , missing
la var T2_expen_m6 "Transport and Comunications (monthly)"
replace T2_expen_m6=0 if T2_expen_m6==. & T2_infoav6==0

keep  id_hogar id_vivienda b0503 T2_expen_m6 T2_infoav6
tempfile TC
save `TC'


* 8. CULTURAL SERVICES AND ENTERTAINMENT 

* Semanales 
********************************************************************************
corregir_base "2"
quietly destring  l2102 l23 l2101, replace
cleanvars 	"l2102 l23 l22 l25"
replace l22=. if l2102==0
replace l25=. if l23==0

egen T2_infoav7_a=rowtotal(l2102 l23) if (l2101==35) 
egen T2_expen_7d7a=rowtotal(l22 l25) if (T2_infoav7_a>0 & T2_infoav7_a!=.), missing
replace T2_expen_7d7a=T2_expen_7d7a*(30/7) if T2_expen_7d7a!=.
rename T2_expen_7d7a T2_expen_m7a

collapse (sum) T2_expen_m7a  T2_infoav7_a ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m7a "CS&E (a)"
replace T2_expen_m7a=0 if T2_infoav7_a==0

merge 1:1 id_hogar using `viviendas', nogen
destring b0503, replace

meanimput_h "T2_expen_m7a"

tempfile gastor2_cse
save `gastor2_cse'


* Mensuales
********************************************************************************
corregir_base "3"
quietly destring  l2602 l28 l2601, replace
cleanvars 	"l2602 l28 l27 l30"
replace l27=. if l2602==0
replace l30=. if l28==0

egen T2_infoav7_b=rowtotal(l2602 l28) if (l2601==47)
egen T2_expen_mon7b=rowtotal(l27 l30) if (T2_infoav7_b>0 & T2_infoav7_b!=.), missing
rename T2_expen_mon7b T2_expen_m7b

collapse (sum) T2_expen_m7b  T2_infoav7_b ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m7b "CS&E (b)"
replace T2_expen_m7b=0 if T2_infoav7_b==0

merge 1:1 id_hogar using `viviendas', nogen
destring b0503, replace

meanimput_h "T2_expen_m7b"

tempfile gastor3_cse
save `gastor3_cse'


* Trimestrales 
********************************************************************************
corregir_base "4"
quietly destring  l3102 l33 l3101, replace
cleanvars 	"l3102 l33 l32 l35"
replace l32=. if l3102==0
replace l35=. if l33==0

egen T2_infoav7_c=rowtotal(l3102 l33) if (l3101==65)
egen T2_expen_q7c=rowtotal(l32 l35) if (T2_infoav7_c>0 & T2_infoav7_c!=.), missing
replace T2_expen_q7c=T2_expen_q7c*(1/3) if T2_expen_q7c!=.
rename T2_expen_q7c T2_expen_m7c

collapse (sum) T2_expen_m7c  T2_infoav7_c ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m7c "CS&E (c)"
replace T2_expen_m7c=0 if T2_infoav7_c==0

merge 1:1 id_hogar using `viviendas', nogen
destring b0503, replace

meanimput_h "T2_expen_m7c"

tempfile gastor4_cse
save `gastor4_cse'


* Anuales 
********************************************************************************
corregir_base "5"
quietly destring  l3602 l38 l3601, replace
cleanvars 	"l3602 l38 l37 l40"
replace l37=. if l3602==0
replace l40=. if l38==0

egen T2_infoav7_d=rowtotal(l3602 l38) if (l3601==75 | l3601==76)
egen T2_expen_y7d=rowtotal(l37 l40) if (T2_infoav7_d>0 & T2_infoav7_d!=.), missing
replace T2_expen_y7d=T2_expen_y7d*(1/12)
rename T2_expen_y7d T2_expen_m7d

collapse (sum) T2_expen_m7d  T2_infoav7_d ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m7d "CS&E (d)"
replace T2_expen_m7d=0 if T2_infoav7_d==0

merge 1:1 id_hogar using `viviendas', nogen
destring b0503, replace

meanimput_h "T2_expen_m7d"


forval x=2/4{
	merge 1:1  id_hogar using `gastor`x'_cse', nogen
}

egen T2_infoav7=rowtotal(T2_infoav7_a T2_infoav7_b T2_infoav7_c T2_infoav7_d)
egen T2_expen_m7=rowtotal(T2_expen_m7a T2_expen_m7b T2_expen_m7c T2_expen_m7d) if T2_infoav7>0 & T2_infoav7!=. , missing
la var T2_expen_m7 "Cultural Services and Entertainment(monthly)"
replace T2_expen_m7=0 if T2_expen_m7==. & T2_infoav7==0

keep  id_hogar id_vivienda b0503 T2_expen_m7 T2_infoav7
tempfile CSE
save `CSE'



* 10. PERSONAL SERVICES AND OTHER PAYMENTS
* Semanales 
********************************************************************************
corregir_base "2"
quietly destring  l2102 l23 l2101, replace
cleanvars 	"l2102 l23 l22 l25"
replace l22=. if l2102==0
replace l25=. if l23==0

egen T2_infoav9_a=rowtotal(l2102 l23) if (l2101==31 | l2101==36 | l2101==37) 
egen T2_expen_7d9a=rowtotal(l22 l25) if (T2_infoav9_a>0 & T2_infoav9_a!=.), missing
replace T2_expen_7d9a=T2_expen_7d9a*(30/7) if T2_expen_7d9a!=. 
rename T2_expen_7d9a T2_expen_m9a

collapse (sum) T2_expen_m9a  T2_infoav9_a ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m9a "PS&OP (a)"
replace T2_expen_m9a=. if T2_infoav9_a==0

merge 1:1 id_hogar using `viviendas', nogen
destring b0503, replace

meanimput_h "T2_expen_m9a"

tempfile gastor2_psop
save `gastor2_psop'


* Mensuales 
********************************************************************************
corregir_base "3"
quietly destring  l2602 l28 l2601, replace
cleanvars 	"l2602 l28 l27 l30"
replace l27=. if l2602==0
replace l30=. if l28==0

egen T2_infoav9_b=rowtotal(l2602 l28) if (l2601==40 | l2601==45 | l2601==46 | l2601==50 | l2601==51)
egen T2_expen_mon9b=rowtotal(l27 l30) if (T2_infoav9_b>0 & T2_infoav9_b!=.), missing
rename T2_expen_mon9b T2_expen_m9b

collapse (sum) T2_expen_m9b  T2_infoav9_b ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m9b "PS&OP (b)"
replace T2_expen_m9b=. if T2_infoav9_b==0

merge 1:1 id_hogar using `viviendas',  nogen
destring b0503, replace

meanimput_h "T2_expen_m9b"

tempfile gastor3_psop
save `gastor3_psop'


* Anuales 
********************************************************************************
corregir_base "5"
quietly destring  l3602 l38 l3601, replace
cleanvars 	"l3602 l38 l37 l40"
replace l37=. if l3602==0
replace l40=. if l38==0

egen T2_infoav9_c=rowtotal(l3602 l38) if (l3601==77 | l3601==78 | l3601==79 | l3601==80 | l3601==81 |  l3601==82 )
egen T2_expen_y9c=rowtotal(l37 l40) if  (T2_infoav9_c>0 & T2_infoav9_c!=.), missing
replace T2_expen_y9c=T2_expen_y9c*(1/12) if T2_expen_y9c!=.
rename T2_expen_y9c T2_expen_m9c

collapse (sum) T2_expen_m9c  T2_infoav9_c ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m9c "CS&E (d)"
replace T2_expen_m9c=. if T2_infoav9_c==0

merge 1:1 id_hogar using `viviendas', nogen
destring b0503, replace

meanimput_h "T2_expen_m9c"


forval x=2/3 {
	merge 1:1  id_hogar using `gastor`x'_psop', nogen
}

egen T2_infoav9=rowtotal(T2_infoav9_a T2_infoav9_b T2_infoav9_c)
egen T2_expen_m9=rowtotal(T2_expen_m9a T2_expen_m9b T2_expen_m9c) if T2_infoav9>0 & T2_infoav9!=. , missing
la var T2_expen_m9 "Personal Services and other payments(monthly)"

keep  id_hogar id_vivienda b0503 T2_expen_m9 T2_infoav9

merge 1:1 id_hogar using `CSE', nogen
merge 1:1 id_hogar using `TC', nogen
merge 1:1 id_hogar using `H', nogen
merge 1:1 id_hogar using `F', nogen
merge 1:1 id_hogar using `HS', nogen
merge 1:1 id_hogar using `CF', nogen
merge 1:1 id_hogar using `gastor2_alcotob', nogen
merge 1:1 id_hogar using `gastor1_food', nogen

save "$dropbox\Tobacco-health-inequalities\data\ENCV1997\derived\Gasto_NoServiciosSaludEduc.dta", replace

}


use "$dropbox\Tobacco-health-inequalities\data\ENCV1997\derived\Gasto_SaludEduc.dta", clear
* 6. Healht ********************************************************************

egen T2_infoav5a=rowtotal(f01 f03 f0801 f11 f3001 f3101 f3201 f3301 f3401 f3501 f3601 f3701 f3801), missing
egen T2_expen_mon5a=rowtotal(f07 f0802 f3002 f3102 f3202 f3302 f3402 f3502 f3602 f3702) if T2_infoav5a>0 & T2_infoav5a!=. , missing
egen T2_expen_y5a=rowtotal(f14 f3802) if T2_infoav5a>0 & T2_infoav5a!=. , missing
replace T2_expen_y5a=T2_expen_y5a*(1/12) if T2_expen_y5a!=.

egen T2_expen_m5a=rowtotal(T2_expen_mon5a T2_expen_y5a) if T2_infoav5a>0 & T2_infoav5a!=. , missing
replace T2_expen_m5a=0 if T2_infoav5a==0

** Categorías del gasto en salud 

// Afiliacion 
egen T2_expen_m5a_afil = rowtotal(f07) if T2_infoav5a>0 & T2_infoav5a!=., missing
replace T2_expen_m5a_afil=0 if f07==0 & f01==1 & T2_expen_m5a_afil==. 

// Plan complementario 
egen T2_expen_m5a_comp = rowtotal(f0802) if T2_infoav5a>0 & T2_infoav5a!=., missing
replace T2_expen_m5a_comp=0 if f0802==0 & f0801==1 & T2_expen_m5a_comp==. 

// Hospitalizacion 12 meses --> mensualizado
egen T2_expen_m5a_hosp = rowtotal(f14) if T2_infoav5a>0 & T2_infoav5a!=., missing
replace T2_expen_m5a_hosp = T2_expen_m5a_hosp*(1/12) if T2_expen_m5a_hosp!=. 

// Consulta médica y odontológica 
egen T2_expen_m5a_cons = rowtotal(f3002 f3102) if T2_infoav5a>0 & T2_infoav5a!=., missing
replace T2_expen_m5a_cons=0 if (f3001==1 & f3002==0 & T2_expen_m5a_cons==.) | (f3101==1 & f3102==0 & T2_expen_m5a_cons==.) 

// Vacunas
egen T2_expen_m5a_vacu = rowtotal(f3202) if T2_infoav5a>0 & T2_infoav5a!=., missing
replace T2_expen_m5a_vacu=0 if (f3201==1 & f3202==0 & T2_expen_m5a_vacu==.) 

// Medicamentos
egen T2_expen_m5a_medi = rowtotal(f3302) if T2_infoav5a>0 & T2_infoav5a!=., missing
replace T2_expen_m5a_medi=0 if (f3301==1 & f3302==0 & T2_expen_m5a_medi==.) 

// Laboratorio 
egen T2_expen_m5a_labo = rowtotal(f3402) if T2_infoav5a>0 & T2_infoav5a!=., missing
replace T2_expen_m5a_labo=0 if (f3401==1 & f3402==0 & T2_expen_m5a_labo==.) 

// Transporte
egen T2_expen_m5a_tran = rowtotal(f3502) if T2_infoav5a>0 & T2_infoav5a!=., missing
replace T2_expen_m5a_tran=0 if (f3501==1 & f3502==0 & T2_expen_m5a_tran==.) 

// Terapias + terapias alternativas
egen T2_expen_m5a_tera = rowtotal(f3602 f3702) if T2_infoav5a>0 & T2_infoav5a!=., missing
replace T2_expen_m5a_tera=0 if (f3601==1 & f3602==0 & T2_expen_m5a_tera==.) | (f3701==1 & f3702==0 & T2_expen_m5a_tera==.) 

// Instrumentos 12 meses --> mensualizado (incluye audífonos, lentes, etc.)
egen T2_expen_m5a_inst1 = rowtotal(f3802) if T2_infoav5a>0 & T2_infoav5a!=., missing
replace T2_expen_m5a_inst1= T2_expen_m5a_inst*(1/12) if T2_expen_m5a_inst!=. 

// Cirugía 12 meses --> mensualizado 
gen T2_expen_m5a_surg = 0


gsort + id_hogar - T2_infoav5a + orden - T2_expen_m5a - T2_expen_m5a_afil - T2_expen_m5a_comp - T2_expen_m5a_hosp - T2_expen_m5a_cons - T2_expen_m5a_vacu - T2_expen_m5a_medi - T2_expen_m5a_labo - T2_expen_m5a_tran - T2_expen_m5a_tera - T2_expen_m5a_inst

collapse (first) T2_expen_m5a T2_expen_m5a_afil T2_expen_m5a_comp T2_expen_m5a_hosp T2_expen_m5a_cons T2_expen_m5a_vacu T2_expen_m5a_medi T2_expen_m5a_labo T2_expen_m5a_tran T2_expen_m5a_tera T2_expen_m5a_inst T2_expen_m5a_surg T2_infoav5a id_vivienda, by(id_hogar)

tempfile Health
save `Health'


use "$dropbox\Tobacco-health-inequalities\data\ENCV1997\derived\Gasto_SaludEduc.dta", clear
* 9. Education *****************************************************************
foreach n in 4 5 {
replace g1`n'02=g1`n'02-g1`n'03
replace g1`n'02=0 if g1`n'02<0
}
egen T2_infoav8=rowtotal(g0601 g0701 g0801 g0901 g1001 g1101 g1201 g1301 g1401 g1501 h1401 h1501 h1601 h1701 h1801 h1901 h2001 h2101 h2201 h23 h26 h31), missing
egen T2_expen_7d8=rowtotal(g1402 g1502) if T2_infoav8>0 & T2_infoav8!=. , missing
replace T2_expen_7d8=T2_expen_7d8*(30) if T2_expen_7d8!=.
egen T2_expen_mon8=rowtotal(g1002 g1102 g1202 g1302 h1802 h1902 h2002 h2102 h2202 h2401 h2701 h3201) if T2_infoav8>0 & T2_infoav8!=. , missing
egen T2_expen_y8=rowtotal(g0602 g0702 g0802 g0902 h1402 h1502 h1602 h1702)  if T2_infoav8>0 & T2_infoav8!=. , missing
replace T2_expen_y8=T2_expen_y8*(1/12) if T2_expen_y8!=.

egen T2_expen_m8=rowtotal(T2_expen_7d8 T2_expen_mon8 T2_expen_y8) if T2_infoav8>0 & T2_infoav8!=. , missing
replace T2_expen_m8=0 if T2_infoav8==0
replace T2_expen_m8=0 if g0601==. & g0701==. & g0801==. & g0901==. & g1001==. & g1101==. & g1201==. & g1301==. & g1401==. & g1501==. & h1401==. & h1501==. & h1601==. & h1701==. & h1801==. & h1901==. & h2001==. & h2101==. & h2201==. & h23==. & h26==. & h31==. 

gsort + id_hogar - T2_infoav8 + orden - T2_expen_m8
 
collapse (first) T2_expen_m8  T2_infoav8 id_vivienda, by(id_hogar)
lab var T2_expen_m8 "HH Expenses on Education(monthly)"

merge 1:1 id_hogar using `Health', nogen
merge 1:1 id_hogar using "$dropbox\Tobacco-health-inequalities\data\ENCV1997\derived\Gasto_NoServiciosSaludEduc.dta", nogen

rename T2_expen_m5 T2_expen_m5b
egen T2_infoav5=rowtotal(T2_infoav5_a T2_infoav5a)
egen T2_expen_m5=rowtotal(T2_expen_m5a T2_expen_m5b) if T2_infoav5>0 & T2_infoav5!=. , missing
la var T2_expen_m5 "HH Expenses on Health (monthly)"

egen T2_expen_m5a_inst = rowtotal(T2_expen_m5a_inst1 T2_expen_m5b) if T2_infoav5>0 & T2_infoav5!=. , missing

la var T2_expen_m5a_afil "HH Expenses on Health - Affiliation (monthly)"
la var T2_expen_m5a_comp "HH Expenses on Health - Comp. healthcare plan (monthly)"
la var T2_expen_m5a_hosp "HH Expenses on Health - Hospitalization (monthly)"
la var T2_expen_m5a_cons "HH Expenses on Health - Medical cons. (monthly)"
la var T2_expen_m5a_vacu "HH Expenses on Health - Vaccination (monthly)"
la var T2_expen_m5a_medi "HH Expenses on Health - Medicine/drugs (monthly)"
la var T2_expen_m5a_labo "HH Expenses on Health - Exams (monthly)"
la var T2_expen_m5a_tran "HH Expenses on Health - Transport to Health Center (monthly)"
la var T2_expen_m5a_tera "HH Expenses on Health - Therapy (monthly)"
la var T2_expen_m5a_inst "HH Expenses on Health - Lens, hearing aid, etc. (monthly)"  
la var T2_expen_m5a_surg "HH Expenses on Health - Surgery. (monthly)"  


rename T2_infoav4_a T2_infoav4

drop T2_expen_m5a T2_expen_m5b T2_infoav5a T2_infoav5_a  T2_infoav1tab T2_expen_m5a_inst1

save "$dropbox\Tobacco-health-inequalities\data\ENCV1997\derived\Gasto_NoServicios.dta", replace


use "$dropbox\Tobacco-health-inequalities\data\ENCV1997\derived\Vivienda_Hogar.dta", clear 
destring b0503, replace
foreach x in c0501 c2401 c2601 c2801 c10 c3401 d1902 d21 d22 d2401{

count if (`x'==98 | `x'==99) 
}

foreach x in c050 c240 c260 c280 c340 d240{
replace `x'1=`x'1/`x'2 if (`x'1!=98 & `x'1!=99 & `x'1!=. & `x'1!=0 & `x'2!=. & `x'2!=0) 
}

meanimput_h "c0501 c2401 c2601 c2801 c10 c3401 d1902 d21 d22 d2401"

egen T2_expen_mon3_a=rowtotal(c0501 c2401 c2601 c2801 c3401 d1902 c10 d21 d22), missing
gen T2_expen_y3_a=d1902 if d1902!=.
replace T2_expen_y3_a=T2_expen_y3_a*(1/12) if T2_expen_y3_a!=.
egen T2_expen_m3_a=rowtotal(T2_expen_mon3_a  T2_expen_y3_a), missing

merge 1:1 id_hogar using "$dropbox\Tobacco-health-inequalities\data\ENCV1997\derived\Gasto_NoServicios.dta", nogen

rename T2_expen_m3 T2_expen_m3_b
egen T2_expen_m3=rowtotal(T2_expen_m3_b T2_expen_m3_a), missing
drop T2_expen_m3_b T2_expen_m3_a T2_expen_mon3_a T2_expen_y3_a
label var T2_expen_m3 "Household services (monthly)"

* TOTAL EXPENSES HOUSEHOLD *****************************************************
*egen totalExpenses= rowtotal(T1_expen_m1 T2_expen_m1 T2_expen_m2 T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 T2_expen_m8 T2_expen_m9 ) if missing(T1_infoav,T2_infoav1,T2_infoav2,T2_infoav3,T2_infoav4,T2_infoav5,T2_infoav6,T2_infoav7,T2_infoav8,T2_infoav9)==0 & (T1_infoav>0 | T2_infoav1>0 | T2_infoav2>0 | T2_infoav3>0 | T2_infoav4>0 | T2_infoav5>0 | T2_infoav6>0 | T2_infoav7>0 | T2_infoav7>0 | T2_infoav8>0 | T2_infoav9>0)  , missing
egen totalExpenses= rowtotal(T1_expen_m1 T2_expen_m1 T2_expen_m2 T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 T2_expen_m8 T2_expen_m9), missing
label var totalExpenses "Total expenses (monthly)"

save "$dropbox\Tobacco-health-inequalities\data\ENCV1997\derived\ECV1997_expenditures_a.dta", replace

* 7-day HH expenses **********************************************************

use "$dropbox\Tobacco-health-inequalities\data\ENCV1997\originales\gastor2.dta", clear
gen cero=0
egen idhogar=concat(ident cero idehogar)

quietly destring  l2102 l23, replace
cleanvars 	"l2102 l23 l22 l25"
replace l22=. if l2102==0
replace l25=. if l23==0

egen T1_infoav=rowtotal(l2102 l23) 
egen expend=rowtotal(l22 l25), missing

gen T1_expen_7d=expend*(30/7) if expend!=.
drop expend

collapse (sum) T1_expen_7d T1_infoav, by(idhogar)
label var T1_expen_7d "7day HH expenses (monthly)"
replace T1_expen_7d=. if T1_infoav==0  // If no data was collected, it is clearly a missing!

tempfile gastor1abc
save `gastor1abc'


* Personal HH expenses **********************************************************

use "$dropbox\Tobacco-health-inequalities\data\ENCV1997\originales\gastor1.dta", clear
gen cero=0
egen idhogar=concat(ident cero idehogar)

quietly destring  l1602 l18 l1601, replace
cleanvars 	"l1602 l18 l17 l20"
replace l17=. if l1602==0
replace l20=. if l18==0

egen T2_infoav=rowtotal(l1602 l18)
egen expend=rowtotal(l17 l20) if T2_infoav>0 & T2_infoav!=. , missing

gen T2_expen_pers=expend*(30/7) if expend!=.
drop expend

collapse (sum) T2_expen_pers T2_infoav, by(idhogar)
label var T2_expen_pers "7day personal HH expenses (monthly)"
replace T2_expen_pers=. if T2_infoav==0  // If no data was collected, it is clearly a missing!

tempfile gastor2abc
save `gastor2abc'


* Monthly HH expenses **********************************************************

use "$dropbox\Tobacco-health-inequalities\data\ENCV1997\originales\gastor3.dta", clear
gen cero=0
egen idhogar=concat(ident cero idehogar)

quietly destring  l2602 l28, replace
cleanvars 	"l2602 l28 l27 l30"
replace l27=. if l2602==0
replace l30=. if l28==0

egen T3_infoav=rowtotal(l2602 l28)
egen expend=rowtotal(l27 l30), missing

gen T3_expen_month=expend if expend!=.
drop expend

collapse (sum) T3_expen_month T3_infoav, by(idhogar)
label var T3_expen_month "Utilities-sec2 and other monthly expenses (monthly)"
replace T3_expen_month=. if T3_infoav==0  // If no data was collected, it is clearly a missing!

tempfile gastor3abc
save `gastor3abc'


* Quarterly HH expenses ***********************************************************

use "$dropbox\Tobacco-health-inequalities\data\ENCV1997\originales\gastor4.dta", clear
gen cero=0
egen idhogar=concat(ident cero idehogar)

quietly destring  l3102 l33, replace
cleanvars 	"l3102 l33 l32 l35"
replace l32=. if l3102==0
replace l35=. if l33==0

egen T4_infoav=rowtotal(l3102 l33)
egen expend=rowtotal(l32 l35), missing

gen T4_expen_quart=expend/3 if expend!=.
drop expend

collapse (sum) T4_expen_quart T4_infoav, by(idhogar)
label var T4_expen_quart "Quarterly expenses (monthly)"
replace T4_expen_quart=. if T4_infoav==0  // If no data was collected, it is clearly a missing!

tempfile gastor4abc
save `gastor4abc'


* Yearly HH expenses **************************************************************

use "$dropbox\Tobacco-health-inequalities\data\ENCV1997\originales\gastor5.dta", clear

gen cero=0
egen idhogar=concat(ident cero idehogar)

quietly destring  l3602 l38, replace
cleanvars 	"l3602 l38 l37 l40"
replace l37=. if l3602==0
replace l40=. if l38==0

egen T5_infoav=rowtotal(l3602 l38)
egen expend=rowtotal(l37 l40), missing

gen T5_expen_year=expend/12 if expend!=.
drop expend

collapse (sum) T5_expen_year T5_infoav, by(idhogar)
label var T5_expen_year "Yearly expenses (monthly)"
replace T5_expen_year=. if T5_infoav==0  // If no data was collected, it is clearly a missing!

////////////////////////////////////////////////////////////////////////////////

forval x=1/4 {
	merge 1:1  idhogar using `gastor`x'abc', nogen
}
rename idhogar id_hogar
egen GastoCte= rowtotal(T1_expen_7d T2_expen_pers T3_expen_month T4_expen_quart T5_expen_year), missing
label var GastoCte "Current expenses (monthly)"

keep GastoCte id_hogar 

merge 1:1 id_hogar using "$dropbox\Tobacco-health-inequalities\data\ENCV1997\derived\ECV1997_expenditures_a.dta"

gen dif= totalExpenses-GastoCte if totalExpenses!=. & GastoCte!=.
replace GastoCte=totalExpenses if dif<-0.002
drop dif

gen curexpper=GastoCte/totalExpenses
gen alimExpenses1= alimExpenses
save "$dropbox\Tobacco-health-inequalities\data\ENCV1997\derived\ECV1997_expenditures1.dta", replace
