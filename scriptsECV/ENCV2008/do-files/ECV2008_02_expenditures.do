* Author: Paul Rodriguez (paul.rodriguez@urosario.edu.co) 
* Date: 2017.07.05
* Goal: produce total income of the HH for the ECV2008 (no imputation or outlier analysis here!)


if "`c(username)'"=="paul.rodriguez" {
	glo dropbox="D:\Paul.Rodriguez\Drive\tabacoDrive" //Paul
}
else {
	glo dropbox="C:\Users\\`c(username)'\Dropbox\tabacoDrive" // Susana
}

********************************************************************************
********************************************************************************
		****************** BASE CON IMPUTACIONES ******************
********************************************************************************
********************************************************************************		


use "$dropbox\Tobacco-health-inequalities\data\ENCV2008\original\viviendas.sav.dta", clear
*use  "C:\Documents and Settings\BAtuestaM\Mis documentos\Bernardo Atuesta\Encuestas\Calidad de vida\ECV2008\viviendas_municipios_ECV2008.dta", clear

*egen id_vivienda = concat(DIRECTORIO SECUENCIA_P)
keep id_vivienda P1_DEPARTAMENTO  REGION P3 P8520S* DIRECTORIO SECUENCIA_P
destring P1_DEPARTAMENTO  REGION, replace
sort id_vivienda
destring id_vivienda, replace
la def P3 1 "Cabecera" 2 "Centros poblados" 3 "Area rural dispersa"
recode P3 (1=1 "Urbano") (2/3=0 "Rural"), g(zona)

tempfile viviendas
save `viviendas'

use "$dropbox\Tobacco-health-inequalities\data\ENCV2008\original\hogares.sav.dta", clear

egen id_vivienda = concat( DIRECTORIO SECUENCIA_P)
egen id_hogar = concat (DIRECTORIO SECUENCIA_P SECUENCIA_ENCUESTA)
sort id_vivienda id_hogar
destring id_vivienda id_hogar, replace 

merge n:1 id_vivienda using `viviendas'
sort id_hogar
drop _merge

tempfile viv_hogares
save `viv_hogares'

use "$dropbox\Tobacco-health-inequalities\data\ENCV2008\original\personas.sav.dta", clear

rename SECUENCIA_ENCUESTA SECUENCIA_ENCUESTAPER
rename SECUENCIA_P SECUENCIA_ENCUESTA
gen SECUENCIA_P=1
egen id_hogar = concat(DIRECTORIO SECUENCIA_P SECUENCIA_ENCUESTA)
egen id_persona = concat(id_hogar SECUENCIA_ENCUESTAPER)
destring id_hogar id_persona, replace 

merge n:1 id_hogar using `viv_hogares'
drop _merge

sort id_hogar
replace P8520S1A1=8 if P8520S1==2

save "$dropbox\Tobacco-health-inequalities\data\ENCV2008\derived\BaseImputacion_ECV2008.dta", replace 

********************************************************************************
// Subsidios y Becas a la Educacion mensualizados
foreach x in P8610S2 P8612S2{
replace `x'=6 if `x'==3
replace `x'=12 if `x'==4
}

foreach x in P8610 P8612{
replace `x'S1=(`x'S1/`x'S2) if (`x'S1!=. & `x'S1!=0 & `x'S2!=.)
}
********************************************************************************

sort id_hogar ORDEN
rename  FACTOR_EXPANSION fex
egen num_ind_hog=max(ORDEN), by (id_hogar)
gen fex_hogar = fex*num_ind_hog

keep if (P6051<=16 | P6051==21)	// No entiendo por que dejan el 21 (Otros no parientes)

egen numero=seq(), by (id_hogar)
egen personas_ug=max(numero), by (id_hogar)
drop numero
gen fex_ug = fex*personas_ug


////////////////////////////////////////////////////////////////////////////////
// Mean imputation for expenditures made individually
////////////////////////////////////////////////////////////////////////////////

cap program drop meanimput
program define meanimput , rclass
	args lista
	disp "Imputation of mean values at the individual level"
	foreach varDep in `lista' {
		cap gen nomiss_`varDep'=`varDep' if (`varDep'!=98 | `varDep'!=99 | `varDep'!=.)
		cap egen mean_`varDep'=mean(nomiss_`varDep'), by(P8520S1A1)
		cap replace `varDep'=mean_`varDep' if (`varDep'==98 | `varDep'==99)
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
		cap egen mean_`varDep'=mean(nomiss_`varDep'), by(P8520S1A1)
		cap replace `varDep'=mean_`varDep' if (`varDep'==98 | `varDep'==99)
		cap drop nomiss_`varDep' mean_`varDep'
	}
end 


******** IMPUTATION OF MEAN VALUES FOR EDUCATIONAL AND HEALTH EXPENSES ********

// Health
meanimput "P8551 P6123 P8555 P6154S1A1 P6154S2A1 P6154S3A1 P6154S4A1 P6154S5A1 P6154S6A1 P6154S7A1 P6154S8A1 P6154S9A1 P6154S10A1 P8558S1A1 P8558S2A1 P6135 P8779S1 P8910S14A2" 

// Education
meanimput "P6169S1 P8564S1 P8566S1 P8568S1 P8570S1 P8572S1 P8574S1 P8576S1 P8578S2 P8580S2 P6180S2 P8594S1 P8596S1 P8598S1 P8600S1 P8602S1 P8604S1 P8606S1 P8608S1 P8610S1 P8612S1"


******** IMPUTATION OF MEAN VALUES AT THE HOUSEHOLD LEVEL ********

// Servicios publicos y pagos del hogar mensualizados
* pago por electricidad último
* pago gas natural
* pago alcantarillado
* pago recoleccion de basuras
* pago acueducto
* pago servicio telefonico
* pago predial

foreach x in P5015 P8524 P5034 P5044 P5067 P8540 P5330 P5340 P5610 P8693 P5130 P5140 P5650{

count if (`x'==98 | `x'==99) 
}

foreach x in P5015 P8524 P5034 P5044 P5067 P5330 P5610{
replace `x'=`x'/`x'S1 if (`x'!=98 & `x'!=99 & `x'!=. & `x'!=0 & `x'S1!=.) 
}

meanimput_h "P5015 P8524 P5034 P5044 P5067 P8540 P5330 P5340 P5610 P8693 P5130 P5140 P5650"


// Food 7-days X
meanimput_h "P8730S1 P8731S1 P8732S1 P8733S1 P8734S1 P8735S1 P8736S1 P8737S1 P8738S1 P8739S1 P8740S1 P8741S1 P8742S1 P8743S1 P8744S1 P8745S1 P8746S1 P8747S1 P8748S1 P8749S1 P8750S1 P8751S1 P8900S1A2 P8900S2A2 P8900S3A2 P8900S4A2 P8900S5A2 P8900S6A2 P8900S7A2 P8900S8A2 P8900S9A2 P8900S10A2 P8900S11A2 P8900S12A2 P8900S13A2 P8900S14A2 P8900S15A2 P8900S16A2 P8900S17A2 P8900S18A2 P8900S19A2 P8900S20A2 P8900S21A2 P8900S22A2"

// Alc-Tob 7-days
meanimput_h "P8754S1 P8905S1A2 P8757S1 P8905S4A2"

// Clothing and Footwear 7-days / monthly / 3-months / 
meanimput_h "P8760S1 P8905S7A2 P8769S1 P8910S4A2 P8780S1 P8781S1 P8782S1 P8783S1 P8915S1A2 P8915S2A2 P8915S3A2 P8915S4A2"

// Transport & Comm 
meanimput_h "P8756S1 P8758S1 P8759S1 P8905S3A2 P8905S5A2 P8905S6A2 P8765S1 P8905S12A2 P8775S1 P8910S10A2 P8784S1 P8787S1 P8915S5A2 P8915S8A2 P8808S1 P8920S20A2"

// Cultural services
meanimput_h "P8761S1 P8905S8A2 P8773S1 P8777S1 P8910S8A2 P8910S12A2 P8785S1 P8788S1 P8915S6A2 P8915S9A2 P8794S1 P8795S1 P8920S6A2 P8920S7A2 P8809S1 P8920S21A2"

// Household needs 7-days / month
meanimput_h "P8764S1 P8905S11A2 P8767S1 P8768S1 P8770S1 P8774S1 P8910S2A2 P8910S3A2 P8910S5A2 P8910S9A2 P8786S1 P8915S7A2 P8790S1 P8920S2A2"

//Muebles y enseres
meanimput_h "P8789S1 P8791S1 P8792S1 P8793S1 P8920S1A2 P8920S3A2 P8920S4A2 P8920S5A2"

// Others
meanimput_h "P8863S1 P8755S1 P8905S2A2 P8762S1 P8864S1 P8905S9A2 P8766S1 P8771S1 P8772S1 P8776S1 P8778S1 P8865S1 P8910S1A2 P8910S6A2 P8910S7A2 P8910S11A2 P8866S1 P8796S1 P8797S1 P8798S1 P8799S1 P8800S1 P8801S1 P8802S1 P8803S1 P8804S1 P8805S1 P8806S1 P8807S1 P8867S1 P8920S8A2 P8920S11A2 P8920S12A2 P8920S13A2 P8920S14A2 P8920S15A2 P8920S16A2 P8920S17A2 P8920S18A2 P8920S19A2 P8905S10A2 P8763S1"


********************************************************************************
********************************************************************************
		****************** CONSOLIDADO DEL GASTO ******************
********************************************************************************
********************************************************************************

// Clean the data
cap program drop cleanvars
program define cleanvars , rclass
	args lista
	disp "Cleaning! `lista'"
	foreach varDep in `lista'	{
		cap replace `varDep'=0 if `varDep'==2
		cap replace `varDep'=. if `varDep'==98 | `varDep'==99 | `varDep'>2 // Missings
		* Shall I do an outlier analysis??		
	}
end

/*
noisily cap replace `varDep'S1=. if `varDep'S1==98 |`varDep'S1==99 // Missings for all
noisily cap replace `varDep'A2=. if `varDep'A2==98 |`varDep'A2==99 // Missings for the home produ
*/

////////////////////////////////////////////////////////////////////////////////

* 1. Alimentos *****************************************************************
cleanvars 	"P8730 P8731 P8732 P8733 P8734 P8735 P8736 P8737 P8738 P8739 P8740 P8741 P8742 P8743 P8744 P8745 P8746 P8747 P8748 P8749 P8750 P8751 P8900S1 P8900S2 P8900S3 P8900S4 P8900S5 P8900S6 P8900S7 P8900S8 P8900S9 P8900S10 P8900S11 P8900S12 P8900S13 P8900S14 P8900S15 P8900S16 P8900S17 P8900S18 P8900S19 P8900S20 P8900S21 P8900S22"

egen T1_infoav=rowtotal(P8730 P8731 P8732 P8733 P8734 P8735 P8736 P8737 P8738 P8739 P8740 P8741 P8742 P8743 P8744 P8745 P8746 P8747 P8748 P8749 P8750 P8751) 
egen T1_expen_7d=rowtotal(P8730S1 P8731S1 P8732S1 P8733S1 P8734S1 P8735S1 P8736S1 P8737S1 P8738S1 P8739S1 P8740S1 P8741S1 P8742S1 P8743S1 P8744S1 P8745S1 P8746S1 P8747S1 P8748S1 P8749S1 P8750S1 P8751S1 ///
						  P8900S1A2 P8900S10A2 P8900S11A2 P8900S12A2 P8900S13A2 P8900S14A2 P8900S15A2 P8900S16A2 P8900S17A2 P8900S18A2 P8900S19A2 P8900S2A2 P8900S20A2 P8900S21A2 P8900S22A2 P8900S3A2 P8900S4A2 P8900S5A2 P8900S6A2 P8900S7A2 P8900S8A2 P8900S9A2) if T1_infoav>0 & T1_infoav!=.  , missing
replace T1_expen_7d=T1_expen_7d*(30/7) if T1_expen_7d!=.
gen alimExpenses=T1_expen_7d
*egen expend=rowtotal(P8730S1 P8731S1 P8732S1 P8733S1 P8734S1 P8735S1 P8736S1 P8737S1 P8738S1 P8739S1 P8740S1 P8741S1 P8742S1 P8743S1 P8744S1 P8745S1 P8746S1 P8747S1 P8748S1 P8749S1 P8750S1 P8751S1 ) if T1_infoav>0 & T1_infoav!=.  , missing
*replace expend= expend*(30/7)
sum alimExpenses, d
scalar a=r(p99)
dis a
replace alimExpenses = a if alimExpenses>a

*if P8730==1 | P8731==1 | P8732==1 | P8733==1 | P8734==1 | P8735==1 | P8736==1 | P8737==1 | P8738==1 | P8739==1 | P8740==1 | P8741==1 | P8742==1 | P8743==1 | P8744==1 | P8745==1 | P8746==1 | P8747==1 | P8748==1 | P8749==1 | P8750==1 | P8751==1
label var T1_expen_7d "Food expenses 7days (monthly)"
rename T1_expen_7d T1_expen_m1

* 2. Alcohol and Tobacco *******************************************************
cleanvars "P8754 P8757 P8905S1 P8905S4"

egen T2_infoav1=rowtotal(P8754 P8757 P8905S1 P8905S4)
egen T2_expen_7d1=rowtotal(P8754S1 P8905S1A2 P8757S1 P8905S4A2) if T2_infoav1>0 & T2_infoav1!=.  , missing
replace T2_expen_7d1=T2_expen_7d1*(30/7) if T2_expen_7d1!=.
label var T2_expen_7d1 "Tob-Alc 7 days (monthly)"
rename T2_expen_7d1 T2_expen_m1

egen tabacoExpenses=rowtotal(P8754S1 P8905S1A2) , missing
replace  tabacoExpenses=tabacoExpenses*(30/7) if tabacoExpenses!=.
label var tabacoExpenses "Tabaco expenses (monthly)"

egen T2_infoav1alc=rowtotal(P8757 P8905S4), missing
egen alcoholExpenses=rowtotal(P8757S1 P8905S4A2) if (T2_infoav1alc>0 & T2_infoav1alc!=.), missing 
replace alcoholExpenses=alcoholExpenses*(30/7) if alcoholExpenses!=.
label var alcoholExpenses "Alcohol Expenses (monthly)"

* 3. Clothing and footwear *****************************************************
cleanvars "P8760 P8769 P8780 P8781 P8782 P8783 P8905S7 P8910S4 P8915S1 P8915S2 P8915S3 P8915S4"

egen T2_infoav2=rowtotal(P8760 P8769 P8780 P8781 P8782 P8783 P8905S7 P8910S4 P8915S1 P8915S2 P8915S3 P8915S4)
egen T2_expen_7d2=rowtotal(P8760S1 P8905S7A2) if T2_infoav2>0 & T2_infoav2!=.  , missing
replace T2_expen_7d2=T2_expen_7d2*(30/7) if T2_expen_7d2!=.

egen T2_expen_mon2=rowtotal(P8769S1 P8910S4A2) if T2_infoav2>0 & T2_infoav2!=. , missing

egen T2_expen_q2=rowtotal(P8780S1 P8781S1 P8782S1 P8783S1 P8915S1A2 P8915S2A2 P8915S3A2 P8915S4A2) if T2_infoav2>0 & T2_infoav2!=.  , missing
replace T2_expen_q2=T2_expen_q2*(1/3) if T2_expen_q2!=.

egen T2_expen_m2=rowtotal(T2_expen_7d2 T2_expen_mon2 T2_expen_q2) if T2_infoav2>0 & T2_infoav2!=.  , missing

label var T2_expen_m2 "Clothing and footwear (monthly)"

* 4. Household services ********************************************************
cleanvars "P5014 P8522 P5032 P5042 P5066 P5320 P8764 P8767 P8770 P8774 P8786 P8790 P8905S11 P8910S2 P8910S5 P8910S9 P8915S7 P8920S2"

egen T2_infoav3=rowtotal(P5014 P8522 P5032 P5066 P5320 P8764 P8767 P8770 P8774 P8786 P8790 P8905S11 P8910S2 P8910S5 P8910S9 P8915S7 P8920S2)
egen T2_expen_7d3=rowtotal(P8764S1 P8905S11A2) if T2_infoav3>0 & T2_infoav3!=. , missing
replace T2_expen_7d3=T2_expen_7d3*(30/7) if T2_expen_7d3!=. 

egen T2_expen_mon3=rowtotal(P5015 P8524 P5034 P5044 P5067 P8540 P5330 P5130 P5140 P5650 ///
					P8767S1 P8910S2A2 P8770S1 P8910S5A2 P8774S1 P8910S9A2), missing

egen T2_expen_q3=rowtotal(P8786S1 P8915S7A2) if T2_infoav3>0 & T2_infoav3!=. , missing
replace T2_expen_q3=T2_expen_q3*(1/3) if T2_expen_q3!=.

egen T2_expen_y3=rowtotal(P8790S1 P8920S2A2) if T2_infoav3>0 & T2_infoav3!=. , missing
replace T2_expen_y3=T2_expen_y3*(1/12) if T2_expen_y3!=.

egen T2_expen_m3=rowtotal(T2_expen_7d3 T2_expen_mon3 T2_expen_q3 T2_expen_y3) if T2_infoav3>0 & T2_infoav3!=., missing

label var T2_expen_m3 "Household services (monthly)"

* 5. Furniture *****************************************************************
cleanvars "P8789 P8791 P8792 P8793 P8920S1 P8920S3 P8920S4 P8920S5"

egen T2_infoav4=rowtotal(P8789 P8791 P8792 P8793 P8920S1 P8920S3 P8920S4 P8920S5)
egen T2_expen_y4=rowtotal(P8789S1 P8791S1 P8792S1 P8793S1 P8920S1A2 P8920S3A2 P8920S4A2 P8920S5A2) if T2_infoav4>0 & T2_infoav4!=. , missing
replace T2_expen_y4=T2_expen_y4*(1/12) if T2_expen_y4!=.

rename T2_expen_y4 T2_expen_m4
label var T2_expen_m4 "Furniture expenses (monthly)"

* 6. Healht ********************************************************************
cleanvars "P6154S1 P6154S2 P6154S3 P6154S4 P6154S5 P6154S6 P6154S7 P6154S8 P6154S9 P6154S10 P8558S1 P8558S2 P6133 P8768 P8779 P8910S3 P8910S14"

egen T2_infoav5=rowtotal(P6154S1 P6154S2 P6154S3 P6154S4 P6154S5 P6154S6 P6154S7 P6154S8 P6154S9 P6154S10 P8558S1 P8558S2 P6133 P8768 P8779 P8910S3 P8910S14  )
egen T2_expen_mon5_a=rowtotal(P6154S1A1 P6154S2A1 P6154S3A1 P6154S4A1 P6154S5A1 P6154S6A1 P6154S7A1 P6154S8A1 P6154S9A1 P6154S10A1 P8768S1 P8910S3A2 P8779S1 P8910S14A2) if T2_infoav5>0 & T2_infoav5!=. , missing
egen T2_expen_mon5_b=rowtotal(P8551 P6123 P8555), missing
egen T2_expen_mon5=rowtotal(T2_expen_mon5_a T2_expen_mon5_b), missing

egen T2_expen_y5=rowtotal(P8558S1A1 P8558S2A1 P6135) if T2_infoav5>0 & T2_infoav5!=. , missing
replace T2_expen_y5=T2_expen_y5*(1/12) if T2_expen_y5!=.

egen T2_expen_m5=rowtotal(T2_expen_mon5 T2_expen_y5), missing
label var T2_expen_m5 "Expenses on Health (monthly)"

* 7. Transport and comunication ************************************************
cleanvars "P8544 P8756 P8758 P8759 P8765 P8775 P8784 P8787 P8808 P8905S3 P8905S5 P8905S6 P8905S12 P8910S10 P8915S5 P8915S8 P8920S20" 

egen T2_infoav6=rowtotal(P8544 P8756 P8758 P8759 P8765 P8775 P8784 P8787 P8808 P8905S3 P8905S5 P8905S6 P8905S12 P8910S10 P8915S5 P8915S8 P8920S20)
egen T2_expen_7d6=rowtotal(P8756S1 P8758S1 P8759S1 P8905S3A2 P8905S5A2 P8905S6A2 P8765S1 P8905S12A2) if T2_infoav6>0 & T2_infoav6!=. , missing
replace T2_expen_7d6=T2_expen_7d6*(30/7) if T2_expen_7d6!=.

egen T2_expen_mon6=rowtotal(P5340 P8775S1 P8910S10A2) if T2_infoav6>0 & T2_infoav6!=. , missing

egen T2_expen_q6=rowtotal(P8784S1 P8787S1 P8915S5A2 P8915S8A2) if T2_infoav6>0 & T2_infoav6!=. , missing
replace T2_expen_q6=T2_expen_q6*(1/3) if T2_expen_q6!=.

egen T2_expen_y6=rowtotal(P8808S1 P8920S20A2) if T2_infoav6>0 & T2_infoav6!=. , missing
replace T2_expen_y6=T2_expen_y6*(1/12) if T2_expen_y6!=. 

egen T2_expen_m6=rowtotal(T2_expen_7d6 T2_expen_mon6 T2_expen_q6 T2_expen_y6), missing
label var T2_expen_m6 "Transport and comunication expenses (monthly)"
replace T2_expen_m6=0 if T2_expen_m6==. & T2_infoav6==0 //9.4% de la muestra.

* 8. Cultural Services *********************************************************
cleanvars "P8761 P8773 P8777 P8785 P8788 P8794 P8795 P8905S8 P8910S8 P8910S12 P8915S6 P8915S9 P8920S6 P8920S7 P8809 P8920S21"

egen T2_infoav7=rowtotal(P8761 P8773 P8777 P8785 P8788 P8794 P8795 P8905S8 P8910S8 P8910S12 P8915S6 P8915S9 P8920S6 P8920S7 P8809 P8920S21)
egen T2_expen_7d7=rowtotal(P8761S1 P8905S8A2) if T2_infoav7>0 & T2_infoav7!=. , missing
replace T2_expen_7d7=T2_expen_7d7*(30/7) if T2_expen_7d7!=.

egen T2_expen_mon7=rowtotal(P8773S1 P8777S1 P8910S8A2 P8910S12A2) if T2_infoav7>0 & T2_infoav7!=. , missing

egen T2_expen_q7=rowtotal(P8785S1 P8788S1 P8915S6A2 P8915S9A2) if T2_infoav7>0 & T2_infoav7!=. , missing
replace T2_expen_q7=T2_expen_q7*(1/3) if T2_expen_q7!=.

egen T2_expen_y7=rowtotal(P8794S1 P8795S1 P8920S6A2 P8920S7A2 P8809S1 P8920S21A2)  if T2_infoav7>0 & T2_infoav7!=. , missing
replace T2_expen_y7=T2_expen_y7*(1/12) if T2_expen_y7!=.

egen T2_expen_m7=rowtotal(T2_expen_7d7 T2_expen_mon7 T2_expen_q7 T2_expen_y7), missing
label var T2_expen_m7 "Cultural Services and entertainment expenses(monthly)"
replace T2_expen_m7=0 if T2_expen_m7==. & T2_infoav7==0 //56.4% de la muestra

* 9. Education *****************************************************************
cleanvars "P6169 P8564 P8566 P8568 P8570 P8572 P8574 P8576 P8578 P8580 P6180 P8594 P8596 P8598 P8600 P8602 P8604 P8606 P8608 P8610 P8612"

egen T2_infoav8=rowtotal(P6169 P8564 P8566 P8568 P8570 P8572 P8574 P8576 P8578 P8580 P6180 P8594 P8596 P8598 P8600 P8602 P8604 P8606 P8608 P8610 P8612)
egen T2_expen_7d8=rowtotal(P8578S2 P8580S2 P6180S2) if T2_infoav8>0 & T2_infoav8!=. , missing
replace T2_expen_7d8=T2_expen_7d8*(30) if T2_expen_7d8!=.

egen T2_expen_mon8=rowtotal(P8570S1 P8572S1 P8574S1 P8576S1 P8600S1 P8602S1 P8604S1 P8606S1 P8608S1 P8610S1 P8612S1) if T2_infoav8>0 & T2_infoav8!=. , missing

egen T2_expen_y8=rowtotal(P6169S1 P8564S1 P8566S1 P8568S1 P8594S1 P8596S1 P8598S1)  if T2_infoav8>0 & T2_infoav8!=. , missing
replace T2_expen_y8=T2_expen_y8*(1/12) if T2_expen_y8!=.

egen T2_expen_m8=rowtotal(T2_expen_7d8 T2_expen_mon8 T2_expen_y8), missing
replace T2_expen_m8=. if T2_infoav8==0
replace T2_expen_m8=0 if P6169==. & P8564==. & P8566==. & P8568==. & P8570==. & P8572==. & P8574==. & P8576==. & P8578==. & P8580==. & P6180==. & P8594==. & P8596==. & P8598==. & P8600==. & P8602==. & P8604==. & P8606==. & P8608==. & P8610==. & P8612==.

label var T2_expen_m8 "Expenses on Education(monthly)"

* 10. Personal Services and other payments *************************************
cleanvars "P8863 P8755 P8905S2 P8762 P8864 P8905S9 P8766 P8771 P8772 P8776 P8778 P8865 P8910S1 P8910S6 P8910S7 P8910S11 P8866 P8796 P8797 P8798 P8799 P8800 P8801 P8802 P8803 P8804 P8805 P8806 P8807 P8867 P8920S8 P8920S11 P8920S12 P8920S13 P8920S14 P8920S15 P8920S16 P8920S17 P8920S18 P8920S19  P8905S10 P8763"

egen T2_infoav9=rowtotal(P8863 P8755 P8905S2 P8762 P8864 P8905S9 P8766 P8771 P8772 P8776 P8778 P8865 P8910S1 P8910S6 P8910S7 P8910S11 P8866 P8796 P8797 P8798 P8799 P8800 P8801 P8802 P8803 P8804 P8805 P8806 P8807 P8867 P8920S8 P8920S11 P8920S12 P8920S13 P8920S14 P8920S15 P8920S16 P8920S17 P8920S18 P8920S19  P8905S10 P8763)
egen T2_expen_7d9=rowtotal(P8863S1 P8755S1 P8905S2A2 P8762S1 P8864S1 P8905S9A2  P8905S10A2 P8763S1) if T2_infoav9>0 & T2_infoav9!=. , missing
replace T2_expen_7d9=T2_expen_7d9*(30/7) if T2_expen_7d9!=.

egen T2_expen_mon9=rowtotal(P8766S1 P8771S1 P8772S1 P8776S1 P8778S1 P8865S1 P8910S1A2 P8910S6A2 P8910S7A2 P8910S11A2) if T2_infoav9>0 & T2_infoav9!=. , missing

egen T2_expen_q9=rowtotal(P8866S1) if T2_infoav9>0 & T2_infoav9!=. , missing
replace T2_expen_q9=T2_expen_q9*(1/3) if T2_expen_q9!=.

egen T2_expen_y9_a=rowtotal(P5610 P8693), missing //Anual predial y valorizacion
egen T2_expen_y9_b=rowtotal(P8796S1 P8797S1 P8798S1 P8799S1 P8800S1 P8801S1 P8802S1 P8803S1 P8804S1 P8805S1 P8806S1 P8807S1 P8867S1 P8920S8A2 P8920S11A2 P8920S12A2 P8920S13A2 P8920S14A2 P8920S15A2 P8920S16A2 P8920S17A2 P8920S18A2 P8920S19A2) if T2_infoav9>0 & T2_infoav9!=. , missing

egen T2_expen_y9=rowtotal(T2_expen_y9_a T2_expen_y9_b), missing

egen T2_expen_m9=rowtotal(T2_expen_7d9 T2_expen_mon9 T2_expen_q9 T2_expen_y9), missing

label var T2_expen_m9 "Personal services and other payments(monthly)"

* TOTAL EXPENSES HOUSEHOLD *****************************************************
*egen totalExpenses= rowtotal(T1_expen_m1 T2_expen_m1 T2_expen_m2 T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 T2_expen_m8 T2_expen_m9) if missing(T1_infoav,T2_infoav1,T2_infoav2,T2_infoav3,T2_infoav4,T2_infoav5,T2_infoav6,T2_infoav7,T2_infoav8,T2_infoav9)==0 & (T1_infoav>0 | T2_infoav1>0 | T2_infoav2>0 | T2_infoav3>0 | T2_infoav4>0 | T2_infoav5>0 | T2_infoav6>0 | T2_infoav7>0 | T2_infoav7>0 | T2_infoav8>0 | T2_infoav9>0)  , missing
egen totalExpenses= rowtotal(T1_expen_m1 T2_expen_m1 T2_expen_m2 T2_expen_m3 T2_expen_m4 T2_expen_m5 T2_expen_m6 T2_expen_m7 T2_expen_m8 T2_expen_m9), missing
label var totalExpenses "Total expenses (monthly)"

bys id_hogar: egen respondio=min(ORDEN) if T1_expen_m1!=. | T2_expen_m1!=. | T2_expen_m2!=. | T2_expen_m3!=. | T2_expen_m4!=. | T2_expen_m5!=. | T2_expen_m6!=. | T2_expen_m7!=. | T2_expen_m8!=. | T2_expen_m9!=.
keep if ORDEN==1

drop T2_expen_mon* 

keep DIRECTORIO NRO_ENCUESTA SECUENCIA_ENCUESTA SECUENCIA_P id_hogar id_persona ORDEN zona totalExpenses tabacoExpenses alcoholExpenses alimExpenses T2_expen_m* T1_expen_m1 

saveold "$dropbox\Tobacco-health-inequalities\data\ENCV2008\derived/ENCV2008_expenditures_a.dta" ,replace

/// COMO ESTABA ANTES 

* 7-days HH expenses **************************************************************
use "$dropbox\Tobacco-health-inequalities\data\ENCV2008\original\hogares.sav.dta", clear

cleanvars 	"P8730 P8731 P8732 P8733 P8734 P8735 P8736 P8737 P8738 P8739 P8740 P8741 P8742 P8743 P8744 P8745 P8746 P8747 P8748 P8749 P8750 P8751 P8863 P8900S1 P8900S10 P8900S11 P8900S12 P8900S13 P8900S14 P8900S15 P8900S16 P8900S17 P8900S18 P8900S19 P8900S2 P8900S20 P8900S21 P8900S22 P8900S3 P8900S4 P8900S5 P8900S6 P8900S7 P8900S8 P8900S9"

egen T1_infoav=rowtotal(P8730 P8731 P8732 P8733 P8734 P8735 P8736 P8737 P8738 P8739 P8740 P8741 P8742 P8743 P8744 P8745 P8746 P8747 P8748 P8749 P8750 P8751 P8863 P8900S1 P8900S10 P8900S11 P8900S12 P8900S13 P8900S14 P8900S15 P8900S16 P8900S17 P8900S18 P8900S19 P8900S2 P8900S20 P8900S21 P8900S22 P8900S3 P8900S4 P8900S5 P8900S6 P8900S7 P8900S8 P8900S9) 
egen T1_expen_7d=rowtotal(P8730S1 P8731S1 P8732S1 P8733S1 P8734S1 P8735S1 P8736S1 P8737S1 P8738S1 P8739S1 P8740S1 P8741S1 P8742S1 P8743S1 P8744S1 P8745S1 P8746S1 P8747S1 P8748S1 P8749S1 P8750S1 P8751S1 ///
						  P8900S1A2 P8900S10A2 P8900S11A2 P8900S12A2 P8900S13A2 P8900S14A2 P8900S15A2 P8900S16A2 P8900S17A2 P8900S18A2 P8900S19A2 P8900S2A2 P8900S20A2 P8900S21A2 P8900S22A2 P8900S3A2 P8900S4A2 P8900S5A2 P8900S6A2 P8900S7A2 P8900S8A2 P8900S9A2) if T1_infoav>0 & T1_infoav!=.  , missing
replace T1_expen_7d=T1_expen_7d*(30/7)
egen expend=rowtotal(P8730S1 P8731S1 P8732S1 P8733S1 P8734S1 P8735S1 P8736S1 P8737S1 P8738S1 P8739S1 P8740S1 P8741S1 P8742S1 P8743S1 P8744S1 P8745S1 P8746S1 P8747S1 P8748S1 ) if T1_infoav>0 & T1_infoav!=.  , missing
replace expend= expend*4
sum expend, d
scalar a=r(p99)
dis a
gen alimExpenses1=expend if P8730==1 | P8731==1 | P8732==1 | P8733==1 | P8734==1 | P8735==1 | P8736==1 | P8737==1 | P8738==1 | P8739==1 | P8740==1 | P8741==1 | P8742==1 | P8743==1 | P8744==1 | P8745==1 | P8746==1 | P8747==1 | P8748==1 | P8749==1 | P8750==1 | P8751==1
replace alimExpenses1 = a if expend>a
label var T1_expen_7d "Expenses 7days (monthly)"


* Utilities HH and other monthly reported expeneses *******************************
cleanvars 	"P8754 P8757 P8766 P8767 P8768 P8769 P8770 P8771 P8772 P8773 P8774 P8775 P8776 P8777 P8778 P8779 P8765 P8865 P8905S1 P8905S4 P8910S1 P8910S10 P8910S11 P8910S12 P8910S14 P8910S2 P8910S3 P8910S4 P8910S5 P8910S6 P8910S7 P8910S8 P8910S9"

egen T3_infoav=rowtotal(P8766 P8767 P8768 P8769 P8770 P8771 P8772 P8773 P8774 P8775 P8776 P8777 P8778 P8779 P8765 P8865)  
egen T3_expen_month=rowtotal(P8766S1 P8767S1 P8768S1 P8769S1 P8770S1 P8771S1 P8772S1 P8773S1 P8774S1 P8775S1 P8776S1 P8777S1 P8778S1 P8779S1 P8765S1 P8865S1 ///
							 P8910S1A2 P8910S10A2 P8910S11A2 P8910S12A2 P8910S14A2 P8910S2A2 P8910S3A2 P8910S4A2 P8910S5A2 P8910S6A2 P8910S7A2 P8910S8A2 P8910S9A2) if T3_infoav>0 & T3_infoav!=.  , missing
label var T3_expen_month "Utilities-sec2 and other monthly expenses (monthly)"

* Quarterly HH expenses ***********************************************************

cleanvars 	"P8780 P8781 P8782 P8783 P8784 P8785 P8786 P8787 P8788 P8866    P8915S1 P8915S2 P8915S3 P8915S4 P8915S5 P8915S6 P8915S7 P8915S8 P8915S9"

egen T4_infoav=rowtotal(P8780 P8781 P8782 P8783 P8784 P8785 P8786 P8787 P8788 P8866)  
egen T4_expen_quart=rowtotal(P8780S1 P8781S1 P8782S1 P8783S1 P8784S1 P8785S1 P8786S1 P8787S1 P8788S1 P8866S1 ///
							 P8915S1A2 P8915S2A2 P8915S3A2 P8915S4A2 P8915S5A2 P8915S6A2 P8915S7A2 P8915S8A2 P8915S9A2 ) if T4_infoav>0 & T4_infoav!=.  , missing
replace T4_expen_quart=T4_expen_quart/3
label var T4_expen_quart "Quarterly expenses (monthly)"


* Yearly HH expenses **************************************************************

cleanvars 	"P8789 P8790 P8791 P8792 P8793 P8794 P8795 P8796 P8797 P8798 P8799 P8800 P8801 P8802 P8803 P8804 P8805 P8806 P8807 P8808 P8809 P8867   P8920S1 P8920S11 P8920S12 P8920S13 P8920S14 P8920S15 P8920S16 P8920S17 P8920S18 P8920S19 P8920S2 P8920S20 P8920S21 P8920S3 P8920S4 P8920S5 P8920S6 P8920S7 P8920S8"

egen T5_infoav=rowtotal(P8789 P8790 P8791 P8792 P8793 P8794 P8795 P8796 P8797 P8798 P8799 P8800 P8801 P8802 P8803 P8804 P8805 P8806 P8807 P8808 P8809 P8867 ///
						)
egen T5_expen_year=rowtotal(P8789S1 P8790S1 P8791S1 P8792S1 P8793S1 P8794S1 P8795S1 P8796S1 P8797S1 P8798S1 P8799S1 P8800S1 P8801S1 P8802S1 P8803S1 P8804S1 P8805S1 P8806S1 P8807S1 P8808S1 P8809S1 P8867S1 ///
							P8920S1A2 P8920S11A2 P8920S12A2 P8920S13A2 P8920S14A2 P8920S15A2 P8920S16A2 P8920S17A2 P8920S18A2 P8920S19A2 P8920S2A2 P8920S20A2 P8920S21A2 P8920S3A2 P8920S4A2 P8920S5A2 P8920S6A2 P8920S7A2 P8920S8A2) if T5_infoav>0 & T5_infoav!=.  , missing
replace T5_expen_year=T5_expen_year/12
label var T5_expen_year "Yearly expenses (monthly)"

////////////////////////////////////////////////////////////////////////////////
* Gastos personales ************************************************************
cleanvars 	"P8754 P8755 P8756 P8757 P8758 P8759 P8760 P8761 P8762 P8763 P8764 P8864 P8905S1 P8905S10 P8905S11 P8905S12 P8905S2 P8905S3 P8905S4 P8905S5 P8905S6 P8905S7 P8905S8 P8905S9"

egen T2_infoav=rowtotal(P8754 P8755 P8756 P8757 P8758 P8759 P8760 P8761 P8762 P8763 P8764 P8864)  
egen T2_expen_pers=rowtotal(P8754S1 P8755S1 P8756S1 P8757S1 P8758S1 P8759S1 P8760S1 P8761S1 P8762S1 P8763S1 P8764S1 P8864S1 ///
							P8905S10A2 P8905S11A2 P8905S12A2 P8905S2A2 P8905S3A2 P8905S4A2 P8905S5A2 P8905S6A2 P8905S7A2 P8905S8A2 P8905S9A2 ) if T2_infoav>0 & T2_infoav!=.  , missing
							
label var T2_expen_pers "Personal expenses 7 days (monthly)"

gen 	pers_expenses=T2_expen_pers 

egen GastoCte= rowtotal(T1_expen_7d T2_expen_pers T3_expen_month T4_expen_quart T5_expen_year) , missing
label var GastoCte "Total expenses (monthly)"
egen id_hogar = concat (DIRECTORIO SECUENCIA_P SECUENCIA_ENCUESTA)
destring id_hogar, replace 
format id_hogar %20.0f
////////////////////////////////////////////////////////////////////////////////

keep DIRECTORIO NRO_ENCUESTA SECUENCIA_ENCUESTA SECUENCIA_P ORDEN id_hogar GastoCte pers_expenses alimExpenses1

merge 1:1 id_hogar using "$dropbox\Tobacco-health-inequalities\data\ENCV2008\derived/ENCV2008_expenditures_a.dta" , nogen

replace pers_expenses=pers_expenses-tabacoExpenses if tabacoExpenses!=.

gen dif= totalExpenses-GastoCte if totalExpenses!=. & GastoCte!=.
replace GastoCte=totalExpenses if dif<-0.002
drop dif

gen curexpper=GastoCte/totalExpenses

////////////////////////////////////////////////////////////////////////////////
save "$dropbox\Tobacco-health-inequalities\data\ENCV2008\derived/ENCV2008_expenditures1.dta" ,replace

