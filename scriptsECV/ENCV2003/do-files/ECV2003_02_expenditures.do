* Author: Paul Rodriguez (paul.rodriguez@urosario.edu.co)
* Date: 2017.07.05
* Goal: produce a dataset for ECV2003 that has total expenditures, tabaco expenditures

if "`c(username)'"=="paul.rodriguez" {
	glo dropbox="D:\Paul.Rodriguez\Drive\tabacoDrive" //Paul
}
else {
	glo dropbox="C:\Users\\`c(username)'\Dropbox\tabacoDrive" // Susana
}


// Programa para limpiar variables
cap program drop cleanvars
program define cleanvars , rclass
	args lista
	disp "Cleaning! `lista'"
	foreach varDep in `lista'	{
		destring `varDep', replace
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
		cap egen mean_`varDep'=mean(nomiss_`varDep'), by(b04012)
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
		cap egen mean_`varDep'=mean(nomiss_`varDep'), by(b04012)
		cap replace `varDep'=mean_`varDep' if (`varDep'==98 | `varDep'==99)
		cap drop nomiss_`varDep' mean_`varDep'
	}
end 


use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\hogarL.dta", clear
rename id_viv id_vivienda
rename numero id_hogar
destring id_vivienda id_hogar b04012, replace
format id_vivienda id_hogar %20.0f

la def estrato 0 "Sin estrato (Pirata)" 1 "Bajo-Bajo" 2 "Bajo" 3 "Medio-Bajo" 4 "Medio" 5 "Medio-Alto" 6 "Alto" 9 "No sabe, planta"
la val b04012 estrato
destring b04011, replace

replace b04012=8 if b04011==.

tempfile viviendas
save `viviendas'

save "$dropbox\Tobacco-health-inequalities\data\ENCV2003\derived\Vivienda_Hogar.dta", replace

* Members of the household individual expenditures imputation*****************************
if 1==1{
// GASTOS INDIVIDUALES: EDUCACION 
**** EDUCACION MENORES 
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\menoresL.dta", clear
rename id_viv id_vivienda
rename numero id_hogar
rename e01 orden 
destring id_vivienda region, replace 
format id_vivienda id_hogar %20.0f

merge n:1 id_hogar using `viviendas' // Solo hace match con los ninos que estudian 
drop if _merge==2
drop _merge 

cleanvars 	"g0401 g0501 g0601 g0701 g0801 g0901 g1001 g1101 g1201 g1301"
sort id_hogar orden

meanimput "g0402 g0502 g0602 g0702 g0802 g0902 g1002 g1102 g1202 g1203 g1302 g1303"

tempfile Educ_men
save `Educ_men'

save "$dropbox\Tobacco-health-inequalities\data\ENCV2003\derived\Gasto_EducMENORES.dta", replace

**** EDUCACION "MAYORES" 5+
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\educaL.dta", clear
rename id_viv id_vivienda
rename numero id_hogar
rename e01 orden 

format id_vivienda id_hogar %20.0f
merge n:1 id_hogar using `viviendas' // Todos hicieron match

cleanvars 	"i1401 i1501 i1601 i1701 i1801 i1901 i2001 i2101 i2201 i23 i26"

***********************************************o*********************************
// Subsidios y Becas a la Educacion mensualizados
foreach x in  i2401 i2702{
replace `x'=6 	if `x'==3
replace `x'=12 	if `x'==4 
}

replace i2402=i2402/i2401 if i2402!=. & i2401!=0 & i2401!=.
replace i2701=i2701/i2702 if i2701!=. & i2702!=0 & i2702!=.

sort id_hogar orden

meanimput "i1402 i1502 i1602 i1702 i1802 i1902 i2002 i2102 i2202 i2402 i2701"

save "$dropbox\Tobacco-health-inequalities\data\ENCV2003\derived\Gasto_EducMAYORES.dta", replace

append using `Educ_men', gen(matchMenores5)


foreach vard in g0402 g0502 g0602 g0702 g0802 g0902 g1002 g1102 g1202 g1203 g1302 g1303 { 
	replace `vard'=0 if matchMenores5==0 // No tienen niños de menos de 5 años
}

save "$dropbox\Tobacco-health-inequalities\data\ENCV2003\derived\Gasto_Educ.dta", replace

// GASTOS INDIVIDUALES: SALUD
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\personasL.dta", clear
rename id_viv id_vivienda
rename numero id_hogar
rename e01 orden 
destring id_vivienda id_hogar orden, replace

format id_vivienda id_hogar %20.0f
merge n:1 id_hogar using `viviendas' // Todos hicieron match

recode f01 (1/9=1 "Si") (10=2 "No"), g(f001)
drop f01
rename f001 f01
 
destring  f0601 f0602 f0603 f0604 f0605, replace 
gen 	f0801=.
replace f0801=0 if f0605==5
replace f0801=1 if (f0601!=. | f0602!=. | f0603!=. | f0604!=.) & f0605!=5

destring f2001 f2002 f2003 f2004 f2005 f2006 f2007, replace 
gen 	f3001=. 
replace f3001=0 if f2007==7
replace f3001=1 if (f2001!=. | f2002!=. | f2003!=. | f2004!=. | f2005!=. | f2006!=.) & f2007!=7

destring f2501 f2502 f2503 f2504 f2505, replace 
gen 	f3101=0 
replace f3101=1 if (f2501!=. | f2502!=. | f2503!=. | f2504!=. | f2505!=.)


cleanvars "f01 f0501 f0801 f11 f24 f3001 f22 f3101" // f11 hospitalizacion 30 dias, f24 hospitalizacion 12 meses 

meanimput "f07 f21 f26 f04"

merge 1:1 id_hogar orden using "$dropbox\Tobacco-health-inequalities\data\ENCV2003\derived\Gasto_Educ.dta" , gen(match5a11)

foreach vard in i1402 i1502 i1602 i1702 i1802 i1902 i2002 i2102 i2202 i2402 i2701{ 
	replace `vard'=0 if match5a11==0 // No tienen niños mayores a 5 años
}

save "$dropbox\Tobacco-health-inequalities\data\ENCV2003\derived\Gasto_SaludEduc.dta", replace
}

// GASTOS DEL HOGAR: ALIMENTOS, ALCOHOL Y TABACO, VESTIDO Y CALZADO, SERVICIOS DEL HOGAR, 
// MUEBLES Y ENSERES, TRANSPORTE Y COMUNICACIONES, SERVICIOS CULTURALES Y ENTRETENIMIENTO,
// SERVICIOS PERSONALES Y OTROS. 
if 1==1{
* 1. Alimentos *****************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL.dta", clear
rename id_viv id_vivienda
rename numero id_hogar
qui destring id_vivienda id_hogar, replace
format id_vivienda id_hogar %20.0f

cleanvars "compra adq_no_com"

replace vr_compra=. if compra!=1	
replace vr_compra=. if vr_compra==98 | vr_compra==99 // Missings for all
replace vr_estimado=. if adq_no_com!=1	
replace vr_estimado=. if vr_estimado==98 | vr_estimado==99 // Missings for all

gen     periodicity=.
replace periodicity=1 if inrange(articulos,1,22)	// HH weekly   ****Por qué los gastos semanales y anuales llevan la misma periodicidad
replace periodicity=1 if inrange(articulos,25,36) 	// Personales
replace periodicity=2 if inrange(articulos,40,52)	// Monthly
replace periodicity=3 if inrange(articulos,60,65)	// Quarterly
replace periodicity=4 if inrange(articulos,70,87)	// Yearly

label def periodicity ///
	1 "Weekly" ///
	2 "Monthly" ///
	3 "Quarterly" ///
	4 "Yearly" , replace
label val periodicity periodicity
save "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL1.dta", replace

egen T1_infoav=rowtotal(compra adq_no_com) if articulos<=22
egen T1_expen_7d=rowtotal(vr_compra vr_estimado) if T1_infoav>0 & T1_infoav!=. , missing
replace T1_expen_7d=T1_expen_7d*(30/7) if T1_expen_7d!=.
rename T1_expen_7d T1_expen_m1_a

collapse (sum) T1_expen_m1_a T1_infoav ///
		 (last) id_vivienda, by(id_hogar)
replace T1_expen_m1_a=. if T1_infoav==0 // If no data was collected, it is clearly a missing!

gen alimExpenses=T1_expen_m1_a
sum alimExpenses, d
scalar a=r(p99)
dis a
replace alimExpenses = a if alimExpenses>a & alimExpenses!=.

label var T1_expen_m1_a "Food expenses 7days (monthly)"

merge 1:1 id_hogar using `viviendas', nogen

meanimput_h "T1_expen_m1_a"

rename T1_expen_m1_a T1_expen_m1
label var T1_expen_m1 "Food expenses 7days (monthly)"

tempfile gastor1_food
save `gastor1_food'


* 2. Alcohol and Tobacco *******************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL1.dta", clear 
egen T2_infoav1=rowtotal(compra adq_no_com) if (articulos==25 | articulos==28 ) // 25 Tobacco 28 Alcohol
egen T2_expen_7d1=rowtotal(vr_compra vr_estimado) if (T2_infoav1>0 & T2_infoav1!=.), missing
replace T2_expen_7d1=T2_expen_7d1*(30/7) if T2_expen_7d1!=.
rename T2_expen_7d1 T2_expen_m1

egen T2_infoav1tab=rowtotal(compra adq_no_com) if (articulos==25)
egen tabacoExpenses=rowtotal(vr_compra vr_estimado) if (T2_infoav1tab>0 & T2_infoav1tab!=.), missing 
replace  tabacoExpenses=tabacoExpenses*(30/7) if tabacoExpenses!=.

egen T2_infoav1alc=rowtotal(compra adq_no_com) if (articulos==28)
egen alcoholExpenses= rowtotal(vr_compra vr_estimado) if (T2_infoav1alc>0 & T2_infoav1alc!=.), missing
replace alcoholExpenses=alcoholExpenses*(30/7) if alcoholExpenses!=. 


collapse (sum) T2_expen_m1 tabacoExpenses alcoholExpenses T2_infoav1 T2_infoav1tab T2_infoav1alc ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m1 "Tob-Alc 7 days (monthly)"
label var tabacoExpenses "Tabaco expenses (monthly)"
replace T2_expen_m1=. if T2_infoav1==0  // If no data was collected, it is clearly a missing!
sum tabacoExpenses, d
scalar b=r(p99)
dis b
*replace tabacoExpenses = b if tabacoExpenses>a & tabacoExpenses!=.

merge 1:1 id_hogar using `viviendas', nogen

meanimput_h "T2_expen_m1"

tempfile gastor2_alcotob
save `gastor2_alcotob'

// VARIOS //
* 3. CLOTHING AND FOOTWEAR
* Semanales
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL1.dta", clear 
egen T2_infoav2_c=rowtotal(compra adq_no_com) if articulos==31
egen T2_expen_7d2c=rowtotal(vr_compra vr_estimado) if (T2_infoav2_c>0 & T2_infoav2_c!=.), missing
replace T2_expen_7d2c=T2_expen_7d2c*(30/7) if T2_expen_7d2c!=.
rename T2_expen_7d2c T2_expen_m2c

collapse (sum) T2_expen_m2c  T2_infoav2_c ///
		 (last) id_vivienda, by(id_hogar)
		 
label var T2_expen_m2c "C&F (c)"
replace T2_expen_m2c=. if T2_infoav2_c==0

merge 1:1 id_hogar using `viviendas', nogen

meanimput_h "T2_expen_m2a"

tempfile gastor3_cf1
save `gastor3_cf1'

* Mensuales
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL1.dta", clear 
egen T2_infoav2_a=rowtotal(compra adq_no_com) if (articulos==43)
egen T2_expen_mon2a=rowtotal(vr_compra vr_estimado) if (T2_infoav2_a>0 & T2_infoav2_a!=.), missing
rename T2_expen_mon2a T2_expen_m2a

collapse (sum) T2_expen_m2a  T2_infoav2_a ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m2a "C&F (a)"
replace T2_expen_m2a=. if T2_infoav2_a==0

merge 1:1 id_hogar using `viviendas', nogen

meanimput_h "T2_expen_m2a"


tempfile gastor3_cf
save `gastor3_cf'


* Trimestrales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL1.dta", clear 
egen T2_infoav2_b=rowtotal(compra adq_no_com) if (articulos==60 | articulos==61 | articulos==62 | articulos==63)
egen T2_expen_q2b=rowtotal(vr_compra vr_estimado) if (T2_infoav2_b>0 & T2_infoav2_b!=.), missing
replace T2_expen_q2b=T2_expen_q2b/3 if T2_expen_q2b!=.
rename T2_expen_q2b T2_expen_m2b

collapse (sum) T2_expen_m2b  T2_infoav2_b ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m2b "C&F (b)"
replace T2_expen_m2b=. if T2_infoav2_b==0

merge 1:1 id_hogar using `viviendas', nogen

meanimput_h "T2_expen_m2b"

merge 1:1 id_hogar using `gastor3_cf', nogen
merge 1:1 id_hogar using `gastor3_cf1', nogen

egen T2_infoav2=rowtotal(T2_infoav2_c T2_infoav2_b T2_infoav2_a)
egen T2_expen_m2=rowtotal(T2_expen_m2c T2_expen_m2b T2_expen_m2a) if T2_infoav2>0 & T2_infoav2!=. , missing
la var T2_expen_m2 "Clothing and footwear (monthly)"

keep  id_hogar id_vivienda b04012 T2_expen_m2 T2_infoav2

tempfile CF
save `CF'


* 4. HOUSEHOLD SERVICES

* Semanales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL1.dta", clear 
egen T2_infoav3_a=rowtotal(compra adq_no_com) if (articulos==35) // 
egen T2_expen_7d3a=rowtotal(vr_compra vr_estimado) if (T2_infoav3_a>0 & T2_infoav3_a!=.), missing
replace T2_expen_7d3a=T2_expen_7d3a*(30/7) if T2_expen_7d3a!=. 
rename T2_expen_7d3a T2_expen_m3a

collapse (sum) T2_expen_m3a  T2_infoav3_a ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m3a "HS (a)"
replace T2_expen_m3a=. if T2_infoav3_a==0

merge 1:1 id_hogar using `viviendas', nogen
destring b0503, replace

meanimput_h "T2_expen_m3a"

tempfile gastor2_hs
save `gastor2_hs'


* Mensuales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL1.dta", clear 
egen T2_infoav3_b=rowtotal(compra adq_no_com) if (articulos==41 | articulos==44 | articulos==48 | articulos==49)
egen T2_expen_mon3b=rowtotal(vr_compra vr_estimado) if (T2_infoav3_b>0 & T2_infoav3_b!=.), missing
rename T2_expen_mon3b T2_expen_m3b

collapse (sum) T2_expen_m3b  T2_infoav3_b ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m3b "HS (b)"
replace T2_expen_m3b=. if T2_infoav3_b==0

merge 1:1 id_hogar using `viviendas', nogen

meanimput_h "T2_expen_m3b"

tempfile gastor3_hs
save `gastor3_hs'


* Anuales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL1.dta", clear 
egen T2_infoav3_c=rowtotal(compra adq_no_com) if (articulos==71)
egen T2_expen_y3c=rowtotal(vr_compra vr_estimado) if (T2_infoav3_c>0 & T2_infoav3_c!=.), missing
replace T2_expen_y3c=T2_expen_y3c*(1/12) if T2_expen_y3c!=.
rename T2_expen_y3c T2_expen_m3c

collapse (sum) T2_expen_m3c  T2_infoav3_c ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m3c "HS (c)"
replace T2_expen_m3c=. if T2_infoav3_c==0

merge 1:1 id_hogar using `viviendas', nogen

meanimput_h "T2_expen_m3c"


forval x=2/3{
	merge 1:1  id_hogar using `gastor`x'_hs', nogen force
}

egen T2_infoav3=rowtotal(T2_infoav3_c T2_infoav3_b T2_infoav3_a)
egen T2_expen_m3=rowtotal(T2_expen_m3c T2_expen_m3b T2_expen_m3a) if T2_infoav3>0 & T2_infoav3!=. , missing
la var T2_expen_m3 "Household services (monthly)"

keep  id_hogar id_vivienda b04011 b04012 T2_expen_m3 T2_infoav3
tempfile HS
save `HS'

* 5. FURNITURE

* Anuales relacionados con Muebles y Enseres
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL1.dta", clear 
egen T2_infoav4_a=rowtotal(compra adq_no_com) if (articulos==70 | articulos==72 | articulos==73 | articulos==74)
egen T2_expen_y4a=rowtotal(vr_compra vr_estimado) if (T2_infoav4_a>0 & T2_infoav4_a!=.), missing
replace T2_expen_y4a=T2_expen_y4a*(1/12) if T2_expen_y4a!=.
rename T2_expen_y4a T2_expen_m4

collapse (sum) T2_expen_m4  T2_infoav4_a ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m4 "F (a)"
replace T2_expen_m4=. if T2_infoav4_a==0

merge 1:1 id_hogar using `viviendas', nogen

meanimput_h "T2_expen_m4"

tempfile F
save `F'

* 6. HEALTH

* Mensuales relacionados con Salud
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL1.dta", clear 
egen T2_infoav5_a=rowtotal(compra adq_no_com) if (articulos==42 | articulos==52)
egen T2_expen_mon5a=rowtotal(vr_compra vr_estimado) if (T2_infoav5_a>0 & T2_infoav5_a!=.), missing
rename T2_expen_mon5a T2_expen_m5

collapse (sum) T2_expen_m5  T2_infoav5_a ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m5 "H (a)"
replace T2_expen_m5=. if T2_infoav5_a==0

merge 1:1 id_hogar using `viviendas', nogen

meanimput_h "T2_expen_m5"

tempfile H
save `H'


* 7. TRANSPORT AND COMUNICATION

* Semanales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL1.dta", clear 
egen T2_infoav6_a=rowtotal(compra adq_no_com) if (articulos==27 | articulos==29 | articulos==30 | articulos==36) 
egen T2_expen_7d6a=rowtotal(vr_compra vr_estimado) if (T2_infoav6_a>0 & T2_infoav6_a!=.), missing
replace T2_expen_7d6a=T2_expen_7d6a*(30/7) if T2_expen_7d6a!=.
rename T2_expen_7d6a T2_expen_m6a

collapse (sum) T2_expen_m6a  T2_infoav6_a ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m6a "T&C (a)"
replace T2_expen_m6a=0 if T2_infoav6_a==0

merge 1:1 id_hogar using `viviendas', nogen

meanimput_h "T2_expen_m6a"

tempfile gastor2_tc
save `gastor2_tc'


* Trimestrales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL1.dta", clear 
egen T2_infoav6_b=rowtotal(compra adq_no_com) if (articulos==64)
egen T2_expen_q6b=rowtotal(vr_compra vr_estimado) if (T2_infoav6_b>0 & T2_infoav6_b!=.), missing
replace T2_expen_q6b=T2_expen_q6b*(1/3) if T2_expen_q6b!=.
rename T2_expen_q6b T2_expen_m6b

collapse (sum) T2_expen_m6b  T2_infoav6_b ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m6b "T&C (b)"
replace T2_expen_m6b=0 if T2_infoav6_b==0

merge 1:1 id_hogar using `viviendas', nogen
meanimput_h "T2_expen_m6b"

tempfile gastor2_tc1
save `gastor2_tc1'

* Anuales
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL1.dta", clear 
egen T2_infoav6_c=rowtotal(compra adq_no_com) if (articulos==87)
egen T2_expen_q6c=rowtotal(vr_compra vr_estimado) if (T2_infoav6_c>0 & T2_infoav6_c!=.), missing
replace T2_expen_q6c=T2_expen_q6c*(1/12) if T2_expen_q6c!=.
rename T2_expen_q6c T2_expen_m6c

collapse (sum) T2_expen_m6c  T2_infoav6_c ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m6c "T&C (c)"
replace T2_expen_m6c=0 if T2_infoav6_c==0

merge 1:1 id_hogar using `viviendas', nogen
meanimput_h "T2_expen_m6c"


merge 1:1  id_hogar using `gastor2_tc1', nogen 
merge 1:1  id_hogar using `gastor2_tc', nogen 

egen T2_infoav6=rowtotal(T2_infoav6_c T2_infoav6_b T2_infoav6_a)
egen T2_expen_m6=rowtotal(T2_expen_m6c T2_expen_m6b T2_expen_m6a) if T2_infoav6>0 & T2_infoav6!=. , missing
la var T2_expen_m6 "Transport and Comunications (monthly)"
replace T2_expen_m6=0 if T2_expen_m6==. & T2_infoav6==0

keep  id_hogar id_vivienda b04012 T2_expen_m6 T2_infoav6
tempfile TC
save `TC'


* 8. CULTURAL SERVICES AND ENTERTAINMENT 

* Semanales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL1.dta", clear 
egen T2_infoav7_a=rowtotal(compra adq_no_com) if (articulos==32) 
egen T2_expen_7d7a=rowtotal(vr_compra vr_estimado) if (T2_infoav7_a>0 & T2_infoav7_a!=.), missing
replace T2_expen_7d7a=T2_expen_7d7a*(30/7) if T2_expen_7d7a!=. 
rename T2_expen_7d7a T2_expen_m7a

collapse (sum) T2_expen_m7a  T2_infoav7_a ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m7a "CS&E (a)"
replace T2_expen_m7a=0 if T2_infoav7_a==0

merge 1:1 id_hogar using `viviendas', nogen

meanimput_h "T2_expen_m7a"

tempfile gastor2_cse
save `gastor2_cse'


* Mensuales
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL1.dta", clear 
egen T2_infoav7_b=rowtotal(compra adq_no_com) if (articulos==47)
egen T2_expen_mon7b=rowtotal(vr_compra vr_estimado) if (T2_infoav7_b>0 & T2_infoav7_b!=.), missing
rename T2_expen_mon7b T2_expen_m7b

collapse (sum) T2_expen_m7b  T2_infoav7_b ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m7b "CS&E (b)"
replace T2_expen_m7b=0 if T2_infoav7_b==0

merge 1:1 id_hogar using `viviendas', nogen

meanimput_h "T2_expen_m7b"

tempfile gastor3_cse
save `gastor3_cse'


* Trimestrales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL1.dta", clear 
egen T2_infoav7_c=rowtotal(compra adq_no_com) if (articulos==65)
egen T2_expen_q7c=rowtotal(vr_compra vr_estimado) if (T2_infoav7_c>0 & T2_infoav7_c!=.), missing
replace T2_expen_q7c=T2_expen_q7c*(1/3) if T2_expen_q7c!=. 
rename T2_expen_q7c T2_expen_m7c

collapse (sum) T2_expen_m7c  T2_infoav7_c ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m7c "CS&E (c)"
replace T2_expen_m7c=0 if T2_infoav7_c==0

merge 1:1 id_hogar using `viviendas', nogen

meanimput_h "T2_expen_m7c"

tempfile gastor4_cse
save `gastor4_cse'


* Anuales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL1.dta", clear 
egen T2_infoav7_d=rowtotal(compra adq_no_com) if (articulos==75 | articulos==76)
egen T2_expen_y7d=rowtotal(vr_compra vr_estimado) if (T2_infoav7_d>0 & T2_infoav7_d!=.), missing
replace T2_expen_y7d=T2_expen_y7d*(1/12) if T2_expen_y7d!=.
rename T2_expen_y7d T2_expen_m7d

collapse (sum) T2_expen_m7d  T2_infoav7_d ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m7d "CS&E (d)"
replace T2_expen_m7d=0 if T2_infoav7_d==0

merge 1:1 id_hogar using `viviendas', nogen

meanimput_h "T2_expen_m7d"

forval x=2/4{
	merge 1:1  id_hogar using `gastor`x'_cse', nogen
}

egen T2_infoav7=rowtotal(T2_infoav7_a T2_infoav7_b T2_infoav7_c T2_infoav7_d)
egen T2_expen_m7=rowtotal(T2_expen_m7a T2_expen_m7b T2_expen_m7c T2_expen_m7d) if T2_infoav7>0 & T2_infoav7!=. , missing
la var T2_expen_m7 "Cultural Services and Entertainment(monthly)"
replace T2_expen_m7=0 if T2_expen_m7==. & T2_infoav7==0

keep  id_hogar id_vivienda b04012 T2_expen_m7 T2_infoav7
tempfile CSE
save `CSE'


* 10. PERSONAL SERVICES AND OTHER PAYMENTS

* Semanales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL1.dta", clear 
egen T2_infoav9_a=rowtotal(compra adq_no_com) if (articulos==26 | articulos==33 | articulos==34) 
egen T2_expen_7d9a=rowtotal(vr_compra vr_estimado) if (T2_infoav9_a>0 & T2_infoav9_a!=.), missing
replace T2_expen_7d9a=T2_expen_7d9a*(30/7) if T2_expen_7d9a!=. 
rename T2_expen_7d9a T2_expen_m9a

collapse (sum) T2_expen_m9a  T2_infoav9_a ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m9a "PS&OP (a)"
replace T2_expen_m9a=. if T2_infoav9_a==0

merge 1:1 id_hogar using `viviendas', nogen

meanimput_h "T2_expen_m9a"

tempfile gastor2_psop
save `gastor2_psop'

* Mensuales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL1.dta", clear 
egen T2_infoav9_b=rowtotal(compra adq_no_com) if (articulos==40 | articulos==45 | articulos==46 | articulos==50 | articulos==51)
egen T2_expen_mon9b=rowtotal(vr_compra vr_estimado) if (T2_infoav9_b>0 & T2_infoav9_b!=.), missing
rename T2_expen_mon9b T2_expen_m9b

collapse (sum) T2_expen_m9b  T2_infoav9_b ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m9b "PS&OP (b)"
replace T2_expen_m9b=. if T2_infoav9_b==0

merge 1:1 id_hogar using `viviendas',  nogen

meanimput_h "T2_expen_m9b"

tempfile gastor3_psop
save `gastor3_psop'

* Anuales 
********************************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL1.dta", clear 
egen T2_infoav9_c=rowtotal(compra adq_no_com) if (articulos==77 | articulos==78 | articulos==79 | articulos==80 | articulos==81 | articulos==82 | articulos==83 | articulos==84 | articulos==85 | articulos==86)
egen T2_expen_y9c=rowtotal(vr_compra vr_estimado) if (T2_infoav9_c>0 & T2_infoav9_c!=.), missing
replace T2_expen_y9c=T2_expen_y9c*(1/12) if T2_expen_y9c!=.
rename T2_expen_y9c T2_expen_m9c

collapse (sum) T2_expen_m9c  T2_infoav9_c ///
		 (last) id_vivienda, by(id_hogar)
label var T2_expen_m9c "CS&E (d)"
replace T2_expen_m9c=. if T2_infoav9_c==0

merge 1:1 id_hogar using `viviendas', nogen

meanimput_h "T2_expen_m9c"

forval x=2/3 {
	merge 1:1  id_hogar using `gastor`x'_psop', nogen
}

egen T2_infoav9=rowtotal(T2_infoav9_a T2_infoav9_b T2_infoav9_c)
egen T2_expen_m9=rowtotal(T2_expen_m9a T2_expen_m9b T2_expen_m9c) if T2_infoav9>0 & T2_infoav9!=. , missing
la var T2_expen_m9 "Personal Services and other payments(monthly)"

keep  id_hogar id_vivienda b04012 T2_expen_m9 T2_infoav9

merge 1:1 id_hogar using `CSE', nogen
merge 1:1 id_hogar using `TC', nogen
merge 1:1 id_hogar using `H', nogen
merge 1:1 id_hogar using `F', nogen
merge 1:1 id_hogar using `HS', nogen
merge 1:1 id_hogar using `CF', nogen
merge 1:1 id_hogar using `gastor2_alcotob', nogen
merge 1:1 id_hogar using `gastor1_food', nogen

save "$dropbox\Tobacco-health-inequalities\data\ENCV2003\derived\Gasto_NoServiciosSaludEduc.dta", replace
}

// GASTOS INDIVIDUALES A NIVEL HOGAR
if 1==1{
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\derived\Gasto_SaludEduc.dta", clear
egen T2_infoav5a=rowtotal(f01 f0501 f0801 f11 f24 f3001 f22 f3101), missing
egen T2_expen_mon5a=rowtotal(f07 f21  f04) if T2_infoav5a>0 & T2_infoav5a!=. , missing
egen T2_expen_y5a=rowtotal(f26) if T2_infoav5a>0 & T2_infoav5a!=. , missing
replace T2_expen_y5a=T2_expen_y5a*(1/12) if T2_expen_y5a!=. 

egen T2_expen_m5a=rowtotal(T2_expen_mon5a T2_expen_y5a) if T2_infoav5a>0 & T2_infoav5a!=. , missing
replace T2_expen_m5a=. if T2_infoav5a==0

gsort + id_hogar - T2_infoav5a + orden - T2_expen_m5a
collapse (first) T2_expen_m5a  T2_infoav5a id_vivienda, by(id_hogar)

tempfile Health
save `Health'

use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\derived\Gasto_SaludEduc.dta", clear
* 9. Education *****************************************************************
foreach n in 2 3 {
replace g1`n'02=g1`n'02-g1`n'03
replace g1`n'02=0 if g1`n'02<0
}

egen T2_infoav8=rowtotal(g0401 g0501 g0601 g0701 g0801 g0901 g1001 g1101 g1201 g1301 i1401 i1501 i1601 i1701 i1801 i1901 i2001 i2101 i2201 i23 i26)
egen T2_expen_7d8=rowtotal(g1202 g1302) if T2_infoav8>0 & T2_infoav8!=. , missing
replace T2_expen_7d8=T2_expen_7d8*(30) if T2_expen_7d8!=.
egen T2_expen_mon8=rowtotal(g0802 g0902 g1002 g1102 i1802 i1902 i2002 i2202 i2402 i2701) if T2_infoav8>0 & T2_infoav8!=. , missing
egen T2_expen_y8=rowtotal(g0402 g0502 g0602 g0702 i1402 i1502 i1602 i1702 i2102)  if T2_infoav8>0 & T2_infoav8!=. , missing
replace T2_expen_y8=T2_expen_y8*(1/12) if T2_expen_y8!=.

egen T2_expen_m8=rowtotal(T2_expen_7d8 T2_expen_mon8 T2_expen_y8), missing
replace T2_expen_m8=. if T2_infoav8==0
replace T2_expen_m8=0 if g0401==. & g0501==. & g0601==. & g0701==. & g0801==. & g0901==. & g1001==. & g1101==. & g1201==. & g1301==. & i1401==. & i1501==. & i1601==. & i1701==. & i1801==. & i1901==. & i2001==. & i2101==. & i2201==. & i23==. & i26==. 

gsort + id_hogar - T2_infoav8 + orden - T2_expen_m8
collapse (first) T2_expen_m8  T2_infoav8 id_vivienda, by(id_hogar)
lab var T2_expen_m8 "HH Expenses on Education(monthly)"

merge 1:1 id_hogar using `Health', nogen
merge 1:1 id_hogar using "$dropbox\Tobacco-health-inequalities\data\ENCV2003\derived\Gasto_NoServiciosSaludEduc.dta", nogen

rename T2_expen_m5 T2_expen_m5b
egen T2_infoav5=rowtotal(T2_infoav5_a T2_infoav5a)
egen T2_expen_m5=rowtotal(T2_expen_m5a T2_expen_m5b) if T2_infoav5>0 & T2_infoav5!=. , missing
la var T2_expen_m5 "HH Expenses on Health (monthly)"

rename T2_infoav4_a T2_infoav4

drop T2_expen_m5a T2_expen_m5b T2_infoav5a T2_infoav5_a  T2_infoav1tab

save "$dropbox\Tobacco-health-inequalities\data\ENCV2003\derived\Gasto_NoServicios.dta", replace
}

// GASTOS DEL HOGAR: SERVICIOS Y ARRIENDO
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\derived\Vivienda_Hogar.dta", clear 
cleanvars "c03 c10 c15 c23 c29 c33 c36 c38"

foreach x in c040 c110 c160 c240 c340 c370 c390 d060 {
replace `x'1=`x'1/`x'2 if (`x'1!=98 & `x'1!=99 & `x'1!=. & `x'1!=0 & `x'2!=. & `x'2!=0) 
}

meanimput_h "c0401 c1101 c1601 c2401 c3401 c3701 c3901 c30 d07 d12 d13 d14"

egen T2_expen_mon3_a=rowtotal(c0401 c1101 c1601 c2401 c3401 c3701 c3901 c30 d12 d13 d14 ), missing
egen T2_expen_y3_a=rowtotal(d07 d0601), missing
replace T2_expen_y3_a=T2_expen_y3_a*(1/12) if T2_expen_y3_a!=.
egen T2_expen_m3_a=rowtotal(T2_expen_mon3_a  T2_expen_y3_a), missing

merge 1:1 id_hogar using "$dropbox\Tobacco-health-inequalities\data\ENCV2003\derived\Gasto_NoServicios.dta", nogen

rename T2_expen_m3 T2_expen_m3_b
egen T2_expen_m3=rowtotal(T2_expen_m3_b T2_expen_m3_a)
drop T2_expen_m3_b T2_expen_m3_a T2_expen_mon3_a T2_expen_y3_a
label var T2_expen_m3 "Household services (monthly)"

replace alimExpenses=0 if T1_expen_m1==0

* TOTAL EXPENSES HOUSEHOLD *****************************************************
*egen totalExpenses= rowtotal(T1_expen_m1 T2_expen_m1 T2_expen_m2 T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 T2_expen_m8 T2_expen_m9 ) if missing(T1_infoav,T2_infoav1,T2_infoav2,T2_infoav3,T2_infoav4,T2_infoav5,T2_infoav6,T2_infoav7,T2_infoav8,T2_infoav9)==0 & (T1_infoav>0 | T2_infoav1>0 | T2_infoav2>0 | T2_infoav3>0 | T2_infoav4>0 | T2_infoav5>0 | T2_infoav6>0 | T2_infoav7>0 | T2_infoav7>0 | T2_infoav8>0 | T2_infoav9>0)  , missing
egen totalExpenses= rowtotal(T1_expen_m1 T2_expen_m1 T2_expen_m2 T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 T2_expen_m8 T2_expen_m9), missing 
label var totalExpenses "Total expenses (monthly)"

keep 	id_hogar tabacoExpenses alcoholExpenses totalExpenses alimExpenses T1_expen_m1 T2_expen_m1 T2_expen_m2 ///
		T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 ///
		T2_expen_m8 T2_expen_m9 
save "$dropbox\Tobacco-health-inequalities\data\ENCV2003\derived\ECV2003_expenditures_a.dta", replace

use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\gastosL.dta", clear

////////////////////////////////////////////////////////////////////////////////
// Clean the data
////////////////////////////////////////////////////////////////////////////////

replace vr_compra=. if compra!=1	
replace vr_compra=. if vr_compra==98 | vr_compra==99 // Missings for all

replace vr_estimado=. if adq_no_com!=1	
replace vr_estimado=. if vr_estimado==98 | vr_estimado==99 // Missings for all


gen     periodicity=.
replace periodicity=1 if inrange(articulos,1,22)	// HH weekly   ****Por qué los gastos semanales y anuales llevan la misma periodicidad
replace periodicity=1 if inrange(articulos,25,36) 	// Personales
replace periodicity=2 if inrange(articulos,40,52)	// Monthly
replace periodicity=3 if inrange(articulos,60,65)	// Quarterly
replace periodicity=4 if inrange(articulos,70,87)	// Yearly

label def periodicity ///
	1 "Weekly" ///
	2 "Monthly" ///
	3 "Quarterly" ///
	4 "Yearly" , replace
label val periodicity periodicity

egen expend=rowtotal(vr_compra vr_estimado), missing

gen     GastoCte=expend if periodicity==2
replace GastoCte=expend*(30/7) if periodicity==1
replace GastoCte=expend/3 if periodicity==3
replace GastoCte=expend/12 if periodicity==4

gen  T2_expen_pers=expend*4 if articulos>24 & articulos<37
label var T2_expen_pers "Personal expenses 7 days (monthly)"


gen pers_expenses=expend*4 if articulos>24 & articulos<37 & articulos!=25 
label var pers_expenses "Personal expenses rather than smoking"

rename vr_compra pago 
rename vr_estimado prec_estim

collapse (sum) GastoCte T2_expen_pers pers_expenses, by(fex_2005 fex numero id_viv region localidad)
rename numero id_hogar
destring id_hogar, replace 
format id_hogar %20.0f

merge 1:1 id_hogar using "$dropbox\Tobacco-health-inequalities\data\ENCV2003\derived\ECV2003_expenditures_a.dta" , nogen

gen dif= totalExpenses-GastoCte if totalExpenses!=. & GastoCte!=.
replace GastoCte=totalExpenses if dif<-0.002
drop dif

gen curexpper=GastoCte/totalExpenses
gen alimExpenses1= alimExpenses

*saveold "$dropbox\tabaco\Tobacco-health-inequalities\data\ENCV2003\derived/ECV2003_expenditures.dta" ,replace

save "$dropbox\Tobacco-health-inequalities\data\ENCV2003\derived/ECV2003_expenditures1.dta" ,replace
