* Author: Paul Rodriguez (paul.rodriguez@urosario.edu.co)
* Date: 2017.07.05
* Goal: produce total income of the HH for the ENCV2011 (no imputation or outlier analysis here!)

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

glo dropbox "C:\Users\paul.rodriguez\Dropbox"
glo dropbox "C:\Users\PaulAndrés\Dropbox"


use "$dropbox\tabaco\Tobacco-health-inequalities\data\ENCV2011\original\dbfp_encv_552_6.sav.dta", clear

////////////////////////////////////////////////////////////////////////////////
// Clean variables
////////////////////////////////////////////////////////////////////////////////

foreach varDep in 	P6595 P6605 P6623 P6615 ///
	{
	replace `varDep'=0 if `varDep'==2
	replace `varDep'=. if `varDep'==9 // Missings
}

foreach varDep in 	P8624  ///
					P8626S1 P8628S1 P8630S1 P8631S1 ///
					P6630S1A1 P6630S2A1 P6630S3A1 P6630S5A1 P6630S6A1 ///
					P6750 P550 ///
					P6595S1 P6605S1 P6623S1 P6615S1 ///
					P8636S1 P8640S1 ///
					P8646S1 P8642S1 P8644S1 P8648S1 P8650S1 ///
					P8652S1 ///
	{
	replace `varDep'=. if `varDep'==98 |`varDep'==99 // Missings
}

////////////////////////////////////////////////////////////////////////////////
// Produce income categories, all will be monthly
////////////////////////////////////////////////////////////////////////////////

* Labour income ****************************************************************
gen il_monetary=P8624 											// main wage
replace il_monetary=il_monetary+P8626S1 if P8626==1 & P8626S1!=. // sub alimen (check if it was received, if was not already counted, and if there is a valid value)
replace il_monetary=il_monetary+P8628S1 if P8628==1 & P8628S1!=. // sub transp
replace il_monetary=il_monetary+P8630S1 if P8630==1 & P8630S1!=. // sub famil
*replace il_monetary=il_monetary+P168s1 if P168==1 & P168s1!=. // sub educ
replace il_monetary=il_monetary+P8631S1 if P8631==1 & P8631S1!=. // primas
*replace il_monetary=il_monetary+P170s1 if P170==1 & P170s1!=. // bonific men

replace il_monetary=il_monetary+P6630S1A1/12 if P6630S1==1 &  P6630S1A1!=. // prima servicios (yearly)
replace il_monetary=il_monetary+P6630S2A1/12 if P6630S2==1 &  P6630S2A1!=. // prima navidad (yearly)
replace il_monetary=il_monetary+P6630S3A1/12 if P6630S3==1 &  P6630S3A1!=. // prima vacaciones (yearly)
replace il_monetary=il_monetary+P6630S5A1/12 if P6630S5==1 &  P6630S5A1!=. // bonificaciones (yearly)
replace il_monetary=il_monetary+P6630S6A1/12 if P6630S6==1 &  P6630S6A1!=. // indemnizaciones (yearly)

replace il_monetary=il_monetary+P6750/12 if il_monetary!=. & P6750!=. // self-employed earnings
replace il_monetary=P6750/12 if il_monetary==. 									
replace il_monetary=il_monetary+P550/12  if il_monetary!=. & P550!=. 					// ganancia neta de la coseha
replace il_monetary=P550/12 if il_monetary==. 
replace il_monetary=il_monetary+P8636S1  if il_monetary!=. & P8636S1!=. 				// otros trabajos
replace il_monetary=P8636S1 if il_monetary==. 
replace il_monetary=il_monetary+P8640S1  if il_monetary!=. & P8640S1!=. 				// algun ingreso laboral
replace il_monetary=P8640S1 if il_monetary==. 

egen    il_inkindVal=rowtotal(P6595 P6605 P6623 P6615) 
egen il_inkind=rowtotal(P6595S1 P6605S1 P6623S1 P6615S1) if il_inkindVal>0 & il_inkindVal!=. , missing

gen     i_lab=il_monetary 
replace i_lab=i_lab+il_inkindVal if il_inkindVal!=. &  i_lab!=.
replace i_lab=il_inkindVal if i_lab==.

label var il_inkind "Labour income: In-kind"
label var il_monetary "Labour income: Monetary"
label var i_lab "Labour income: total"


* Others ***********************************************************************
gen i_other_st=.
replace i_other_st=            P8646S1    if P8646==1 & P8646S1!=. 				// arriendos
replace i_other_st=i_other_st+ P8642S1    if P8642==1 & P8642S1!=. & i_other_st!=. // pension por vejez o enfermedad
replace i_other_st=            P8642S1    if P8642==1 & P8642S1!=. & i_other_st==.
replace i_other_st=i_other_st+ P8644S1    if P8644==1 & P8644S1!=. & i_other_st!=. // pension por alimentos
replace i_other_st=            P8644S1    if P8644==1 & P8644S1!=. & i_other_st==.
replace i_other_st=i_other_st+ P8648S1/12 if P8648==1 & P8648S1!=. & i_other_st!=. // primas en la pensión (yearly report)
replace i_other_st=            P8648S1/12 if P8648==1 & P8648S1!=. & i_other_st==. 

replace i_other_st=i_other_st+ P8650S1/12 if P8650==1 & P8650S1!=. & i_other_st!=. //  Transf privadas
replace i_other_st=            P8650S1/12 if P8650==1 & P8650S1!=. & i_other_st==. 

gen i_capital=.
replace i_capital= P8654S1 if P8654==1 & P8654S1!=.							// otros conceptos
replace i_capital=i_capital+ P8652S1 if P8652==1 & P8652S1!=. & i_capital!=.	// venta de propiedades
replace i_capital=           P8652S1 if P8652==1 & P8652S1!=. & i_capital==.


label var i_capital "Capital income"
label var i_other_st "Private transfers"

* Total income ***********************************************************************

egen incomePer= rowtotal(i_lab i_capital i_other_st) , missing
label var incomePer "Total individual income (monthly)"

////////////////////////////////////////////////////////////////////////////////

keep DIRECTORIO SECUENCIA_ENCUESTA SECUENCIA_P NRO_ENCUESTA ORDEN FEX_C LLAVEHOG incomePer
saveold "$dropbox\tabaco\Tobacco-health-inequalities\data\ENCV2011\derived/ENCV2011_incomePersona.dta" ,replace

rename SECUENCIA_ENCUESTA SECUENCIA_ENCUESTAPER
rename SECUENCIA_P SECUENCIA_ENCUESTA

collapse (sum) incomeHH=incomePer, by(LLAVEHOG DIRECTORIO SECUENCIA_ENCUESTA)
label var incomeHH "Total household income (monthly)"

saveold "$dropbox\tabaco\Tobacco-health-inequalities\data\ENCV2011\derived/ENCV2011_incomeHogar.dta" ,replace
