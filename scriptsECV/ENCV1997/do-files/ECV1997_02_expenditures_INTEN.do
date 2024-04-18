* Author: Paul Rodriguez (paul.rodriguez@urosario.edu.co)
* Date: 2017.07.13
* Goal: produce total income of the HH for the ECV1997 (no imputation or outlier analysis here!)

glo dropbox "C:\Users\\`c(username)'\Google Drive\tabacoDrive"


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


use "$dropbox\Tobacco-health-inequalities\data\ENCV1997\original\vivienda.dta", clear
replace a05=0 if a05==.
tostring a05 a06 a07 , format(%02.0f) replace
tostring identificador_seg, replace
egen id_vivienda=concat(identificador_seg a05 a06 )
egen id_hogar=concat(identificador_seg a05 a06 a07)

*destring id_vivienda id_hogar, replace

duplicates tag id_vivienda, gen(dup)
*1. Para los que hay duplicados, mantener el idhogar
preserve
keep if dup>0
drop dup
tempfile multiHog
save `multiHog'
restore

keep if dup==0
drop dup

tempfile viviendas
save `viviendas'


// GASTOS INDIVIDUALES: SALUD Y EDUCACION 
* Members of the household ********************************************************
*if 1==0{
use "$dropbox\Tobacco-health-inequalities\data\ENCV1997\original\persona.dta", clear
replace a05=0 if a05==.
tostring a05 a06 a07 , format(%02.0f) replace
tostring identificador_seg, replace
rename e01 orden
egen id_vivienda=concat(identificador_seg a05 a06 )
egen id_hogar=concat(identificador_seg a05 a06 a07)
egen id_persona=concat(id_hogar orden)
*destring id_vivienda id_hogar id_persona, replace
/*
quietly destring 	g02 g06* g07* g08* g09* g10* g11* g12* g13* g14* g15* h14*  ///
					h15* h16* h17* h18* h19* h20* h21* h22* h26 h27* ///
					h23 h24* h31 h32* f01 f03 f06 f0801 f11 f13 f26 ///
					f30* f31* f32* f33* f34* f35* f36* f37*, replace
					
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
*/
duplicates drop id_hogar, force


*merge 1:1 id_hogar using `multiHog' , gen(matchViv1) 
merge n:1 id_vivienda using `viviendas' , gen(matchViv2) // replace update  
xx

destring orden b05* , replace
cleanvars 	"g0601 g0701 g0801 g0901 g1001 g1101 g1201 g1301 g1401 g1501 h1401 h1501 h1601 h1701 h1801 h1901 h2001 h2101 h2201 h23 h26 h31 f01 f03 f0801 f11 f3001 f3101 f3201 f3301 f3401 f3501 f3601 f3701"

replace b0503=8 if b0501==.
