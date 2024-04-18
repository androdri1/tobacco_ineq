* Author: Paul Rodriguez (paul.rodriguez@urosario.edu.co)
* Date: 2017.07.06
* Goal: produce total income of the HH for the ECV2003 (no imputation or outlier analysis here!)

*glo dropbox "C:\Users\Usuario\Dropbox"
*glo dropbox "C:\Users\paul.rodriguez\Dropbox"
*glo dropbox "C:\Users\PaulAndrés\Dropbox"
*glo dropbox "C:\Users\androdri\Dropbox"
glo dropbox "C:\Users\\`c(username)'\\Google Drive\tabacoDrive" //NUEVA CARPETA EN DRIVE


*use "$dropbox\tabaco\Tobacco-health-inequalities\data\ENCV2003\original\trabajoL.dta", clear
use "$dropbox\Tobacco-health-inequalities\data\ENCV2003\original\trabajoL.dta", clear

////////////////////////////////////////////////////////////////////////////////
// Clean variables
////////////////////////////////////////////////////////////////////////////////

foreach varDep in 	l2401 l2501 l2601 l2701 l2801 ///
					l2901 l3001 l3101 l3201 ///
	{
	replace `varDep'=0 if `varDep'==2
	replace `varDep'=. if `varDep'==9 // Missings
}

foreach varDep in 	l23  ///
					l2402 l2502 l2602 l2702 l2802 ///
					l2902 l3002 l3102 l3202 ///
					l33 l4302 ///
					l5102 l4902 l5002 l5302 l5503 l5602 l5402 ///
	{
	replace `varDep'=. if `varDep'==98 |`varDep'==99 // Missings
}

////////////////////////////////////////////////////////////////////////////////
// Produce income categories, all will be monthly
////////////////////////////////////////////////////////////////////////////////

* Labour income ****************************************************************
gen il_monetary=l23 											// main wage
replace il_monetary=il_monetary+l2902 if l2901==1 & l2902!=. // sub alimen (check if it was received, if was not already counted, and if there is a valid value)
replace il_monetary=il_monetary+l3002 if l3001==1 & l3002!=. // sub transp
replace il_monetary=il_monetary+l3102 if l3101==1 & l3102!=. // sub famil
*replace il_monetary=il_monetary+P168s1 if P168==1 & P168s1!=. // sub educ
replace il_monetary=il_monetary+l3202 if l3201==1 & l3202!=. // primas
*replace il_monetary=il_monetary+P170s1 if P170==1 & P170s1!=. // bonific men

/*
replace il_monetary=il_monetary+P6630S1A1/12 if P6630S1==1 &  P6630S1A1!=. // prima servicios (yearly)
replace il_monetary=il_monetary+P6630S2A1/12 if P6630S2==1 &  P6630S2A1!=. // prima navidad (yearly)
replace il_monetary=il_monetary+P6630S3A1/12 if P6630S3==1 &  P6630S3A1!=. // prima vacaciones (yearly)
replace il_monetary=il_monetary+P6630S5A1/12 if P6630S5==1 &  P6630S5A1!=. // bonificaciones (yearly)
replace il_monetary=il_monetary+P6630S6A1/12 if P6630S6==1 &  P6630S6A1!=. // indemnizaciones (yearly)
*/
replace il_monetary=il_monetary+l33 if il_monetary!=. & l33!=. // self-employed earnings
replace il_monetary=            l33 if il_monetary==. 			

///////////////////////////
//Corregí aquí porqué la pregunta ya estaba formulada de forma mensual
///////////////////////////
					


*replace il_monetary=il_monetary+P550/12  if il_monetary!=. & P550!=. 					// ganancia neta de la coseha
*replace il_monetary=P550/12 if il_monetary==. 
replace il_monetary=il_monetary+l4302 if il_monetary!=. & l4302!=. 				// otros trabajos
replace il_monetary=            l4302 if il_monetary==. 
*replace il_monetary=il_monetary+P8640S1  if il_monetary!=. & P8640S1!=. 				// algun ingreso laboral
*replace il_monetary=P8640S1 if il_monetary==. 

egen    il_inkindVal=rowtotal(l2401 l2501 l2601 l2701 l2801) 
egen 	il_inkind=rowtotal(l2402 l2502 l2602 l2702 l2802) if il_inkindVal>0 & il_inkindVal!=. , missing

gen     i_lab=il_monetary 
replace i_lab=i_lab+il_inkindVal if il_inkindVal!=. &  i_lab!=.
replace i_lab=il_inkindVal if i_lab==.

label var il_inkind "Labour income: In-kind"
label var il_monetary "Labour income: Monetary"
label var i_lab "Labour income: total"


* Others ***********************************************************************
gen i_other_st=.
replace i_other_st=            l5102    if l5101==1 & l5102!=. 				// arriendos
replace i_other_st=i_other_st+ l4902    if l4901==1 & l4902!=. & i_other_st!=. // pension por vejez o enfermedad
replace i_other_st=            l4902    if l4901==1 & l4902!=. & i_other_st==.
replace i_other_st=i_other_st+ l5002    if l5001==1 & l5002!=. & i_other_st!=. // pension por alimentos
replace i_other_st=            l5002    if l5001==1 & l5002!=. & i_other_st==.
replace i_other_st=i_other_st+ l5302/12 if l5301==1 & l5302!=. & i_other_st!=. // primas en la pensión (yearly report)
replace i_other_st=            l5302/12 if l5301==1 & l5302!=. & i_other_st==. 

replace i_other_st=i_other_st+ l5503/12 if l5501==1 & l5503!=. & i_other_st!=. //  Transf privadas
replace i_other_st=            l5503/12 if l5501==1 & l5503!=. & i_other_st==. 

gen i_capital=.
replace i_capital= l5202 if l5201==1 & l5202!=.							// cesantias
replace i_capital=i_capital+ l5602 if l5601==1 & l5602!=. & i_capital!=.	// venta de propiedades
replace i_capital=           l5602 if l5601==1 & l5602!=. & i_capital==.
replace i_capital=i_capital+ l5402 if l5401==1 & l5402!=. & i_capital!=.	// intereses prestamo
replace i_capital=           l5402 if l5401==1 & l5402!=. & i_capital==.

label var i_capital "Capital income"
label var i_other_st "Private transfers"

* Total income ***********************************************************************

egen incomePer= rowtotal(i_lab i_capital i_other_st) , missing
label var incomePer "Total individual income (monthly)"

////////////////////////////////////////////////////////////////////////////////

keep numero e01 fex incomePer
*saveold "$dropbox\tabaco\Tobacco-health-inequalities\data\ENCV2003\derived/ECV2003_incomePersona.dta" ,replace
saveold "$dropbox\Tobacco-health-inequalities\data\ENCV2003\derived/ECV2003_incomePersona.dta" ,replace
collapse (sum) incomeHH=incomePer, by(numero)
label var incomeHH "Total household income (monthly)"
rename numero id_hogar 

*saveold "$dropbox\tabaco\Tobacco-health-inequalities\data\ENCV2003\derived/ECV2003_incomeHogar.dta" ,replace
saveold "$dropbox\Tobacco-health-inequalities\data\ENCV2003\derived/ECV2003_incomeHogar.dta" ,replace
