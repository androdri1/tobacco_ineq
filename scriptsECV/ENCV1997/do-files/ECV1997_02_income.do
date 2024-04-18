* Author: Paul Rodriguez (paul.rodriguez@urosario.edu.co)
* Date: 2017.07.13
* Goal: produce total income of the HH for the ECV1997 (no imputation or outlier analysis here!)

glo project "C:\Users\paul.rodriguez\Dropbox\tabaco\Tobacco-health-inequalities"
glo project "C:\Users\PaulAndrÃ©s\Dropbox\tabaco\Tobacco-health-inequalities"
glo project "C:\Users\androdri\Dropbox\tabaco\Tobacco-health-inequalities"
glo project "C:\Users\susana.otalvaro\Dropbox\Tobacco-health-inequalities"
*glo project "C:\Users\Usuario\Dropbox\Tobacco-health-inequalities"
glo dropbox "C:\Users\\`c(username)'\\Google Drive\tabacoDrive" //NUEVA CARPETA EN DRIVE
glo project="$dropbox\Tobacco-health-inequalities"


use "$project\data\ENCV1997\originales\pet.dta" , clear

gen cero=0
egen id_hogar=concat(ident cero idehogar)


////////////////////////////////////////////////////////////////////////////////
// Clean variables
////////////////////////////////////////////////////////////////////////////////

foreach varDep in 	j2301 j2401 j2501 j2701 j2801 ///
					j4401 j4501 ///
					j2601   j3001 j3101 j3201 ///
					j5001 j4601 j4701 j5501 j5401 j5601 /// // others
					j4901 /// // transfers
					j5001 j5101 j4801 j5201 j5301 /// // capital
	{
	destring `varDep',  replace
	replace `varDep'=0 if `varDep'==2
	replace `varDep'=. if `varDep'==9 // Missings
}

foreach varDep in 	j2902 j2901 ///
					j2302 j2402 j2502 j2702 j2802 j33 j4402 j4502 ///
					j2602 j3002 j3102 j3202 ///
					j5002 j4602 j4702 j5502 j5402 j5602 j4903 ///
					j5102 j4802 j5202 j5302 ///
	{
	destring `varDep', force replace
	replace `varDep'=. if `varDep'==98 |`varDep'==99 // Missings
}

////////////////////////////////////////////////////////////////////////////////
// Produce income categories, all will be monthly
////////////////////////////////////////////////////////////////////////////////

// INCOME CATEGORIES (monthly)
* Labour income ****************************************************************
gen il_monetary=. 															// main wage (monthly)
replace il_monetary=j2901 if j2902==1 & j2901!=.
replace il_monetary=j2901*2 if j2902==2 & j2901!=.
replace il_monetary=j2901*3 if j2902==3 & j2901!=.
replace il_monetary=j2901*4.2857 if j2902==4 & j2901!=.
replace il_monetary=j2901*23.5714286 if j2902==5 & j2901!=.
	 
replace il_monetary=il_monetary-j2702 if j2701==1 & j2702!=. 					// descuento por prestamos
replace il_monetary=il_monetary+j2802/12 if j2801==1 & j2802!=. 				// primas

replace il_monetary=il_monetary+j33/3 if il_monetary!=. & j33!=. 				// self-employed earnings
replace il_monetary=            j33/3 if il_monetary==. & j33!=.									
replace il_monetary=il_monetary+j4402 if il_monetary!=. & j4401==1 & j4402!=. 	// otros trabajos
replace il_monetary=            j4402 if il_monetary==. & j4401==1 
replace il_monetary=il_monetary+j4502  if il_monetary!=. & j4501==1 & j4502!=. 	// algun ingreso laboral (no trabajo pero le pagaron)
replace il_monetary=j4502              if il_monetary==. & j4501==1 & j4502!=.

* Labour income (in-kind)*******************************************************

egen    il_inkindVal=rowtotal(j2601 j3001 j3101 j3201) 							// subsidio familiar en especie, alimentos, vivienda, transporte como parte de pago 
egen 	il_inkind=rowtotal(j2602 j3002 j3102 j3202) if il_inkindVal>0 & il_inkindVal!=. , missing


* Labour income (subsides)******************************************************
gen il_sub=.
replace il_sub=j2302 if j2301==1 & j2302!=.										// sub alimentacion			
replace il_sub=il_sub+j2402 if j2401==1 & j2402!=. 								// sub transp
replace il_sub=j2402 if j2401==1 & j2402!=. & il_sub==. 
replace il_sub=il_sub+j2502 if j2501==1 & j2502!=. 								// sub famil
replace il_sub=j2502 if j2501==1 & j2502!=. & il_sub==. 				
replace il_sub=il_sub+j2602 if j2601==1 & j2602!=.
replace il_sub=j2602 if j2601==1 & j2602!=. & il_sub==.


* Labour income (total)******************************************************
gen     i_lab=il_monetary 
replace i_lab=i_lab+il_inkind if il_inkind!=. &  i_lab!=.
replace i_lab=il_inkind if i_lab==.
replace i_lab=i_lab+il_sub if il_sub!=. & i_lab!=.
replace i_lab=il_sub if il_sub!=. & i_lab==.


label var il_inkind "Labour income: In-kind"
label var il_monetary "Labour income: Monetary"
label var il_sub "Labour income: Subsides"
label var i_lab "Labour income: total"


* Capital income ***************************************************************
gen i_capital=.
replace i_capital=           j5102 if j5101==1 & j5102!=. & i_capital==.
replace i_capital=i_capital+ j4802/3 if j4801==1 & j4802!=. & i_capital!=.		// intereses de cdts
replace i_capital=           j4802/3 if j4801==1 & j4802!=. & i_capital==.
replace i_capital=i_capital+ j5202/12 if j5201==1 & j5202!=. & i_capital!=.		// prestamos
replace i_capital=           j5202/12 if j5201==1 & j5202!=. & i_capital==.
replace i_capital=i_capital+ j5302/12 if j5301==1 & j5302!=. & i_capital!=.		// le devolvieron dinero prestado
replace i_capital=           j5302/12 if j5301==1 & j5302!=. & i_capital==.
replace i_capital=i_capital+ j5002    if j5001==1 & j5002!=. & i_capital!=.		// arriendos
replace i_capital= 			 j5002	  if j5001==1 & j5002!=. & i_capital==.	
replace i_capital=i_capital+ j5502/12 if j5501==1 & j5502!=. & i_capital!=. 	// cesantias
replace i_capital=            j5502/12 if j5501==1 & j5502!=. & i_capital==. 


* Real State Sales' income *****************************************************
gen i_rs=.
replace i_rs=j5102 if j5101==1 & j5102!=. & i_rs!=.								// venta de propiedades


* Pension income or similars ***************************************************
gen i_pens=.
replace i_pens=i_pens+ j4602    if j4601==1 & j4602!=. & i_pens!=. 				// pension por vejez o enfermedad
replace i_pens=            j4602    if j4601==1 & j4602!=. & i_pens==.
replace i_pens=i_pens+ j4702    if j4701==1 & j4702!=. & i_pens!=. 				// pension por alimentos
replace i_pens=            j4702    if j4701==1 & j4702!=. & i_pens==.



* Others ***********************************************************************
gen i_other_st=.
replace i_other_st=i_other_st+ j5402/12 if j5401==1 & j5402!=. & i_other_st!=.	// indemnizaciones
replace i_other_st=            j5402/12 if j5401==1 & j5402!=. & i_other_st==.
replace i_other_st=i_other_st+ j5602/12 if j5601==1 & j5602!=. & i_other_st!=.	// loterias
replace i_other_st=            j5602/12 if j5601==1 & j5602!=. & i_other_st==.
replace i_other_st=i_other_st+ j4903/12 if j4901==1 & j4903!=. & i_other_st!=. 	//  Transf privadas
replace i_other_st=            j4903/12 if j4901==1 & j4903!=. & i_other_st==. 


label var i_capital "Capital income"
label var i_pens "Pension income"
label var i_rs "Real State Sales' income"
label var i_other_st "Private transfers"


* Total income ***********************************************************************

egen incomePer1= rowtotal(i_lab i_capital i_rs i_pens i_other_st) , missing
label var incomePer1 "Total individual labour income (monthly)"

////////////////////////////////////////////////////////////////////////////////

keep id_hogar incomePer1 j5501
saveold "$project\data\ENCV1997\derived/ECV1997_incomePersona.dta" ,replace

collapse (sum) incomeHH1=incomePer1, by(id_hogar)
label var incomeHH1 "Total HH Labour Income(monthly)"

save "$project\data\ENCV1997\derived/ENCV1997_incomePers1.dta" ,replace

////////////////////////////////////////////////////////////////////////////////
////// CHILDREN CARE INFORMATION
////////////////////////////////////////////////////////////////////////////////

use "$project\data\ENCV1997\originales\persona.dta", clear

gen cero=0
egen id_hogar=concat(ident cero idehogar)

destring g1401 g1501 , replace

foreach varDep in g1401 g1501 ///
	{
	replace `varDep'=0 if `varDep'==2
	replace `varDep'=. if `varDep'==9
	}

foreach varDep in 	g1403 g1402 ///
					g1503 g1502 ///
	{
	replace `varDep'=. if `varDep'==98 |`varDep'==99 
}

gen i_alim=.
replace i_alim=(g1402-g1403)*15 if g1401==1 & g1402!=. & g1403!=.  						//Children care food subs (Breakfast or lunch)
replace i_alim=i_alim+ ((g1502-g1503)*15) if g1501==1 & g1502!=. & g1503!=. & i_alim!=. //Children care food subs (Other) refrigerios
replace i_alim=((g1502-g1503)*15) if g1501==1 & g1502!=. & g1503!=. & i_alim==. 

egen incomePer2= rowtotal(i_alim) , missing
label var incomePer2 "Total individual children care income (monthly)"

keep id_hogar incomePer2

collapse (sum) incomeHH2=incomePer2, by(id_hogar)
label var incomeHH2 "Total HH Children Care Income(monthly)"

save "$project\data\ENCV1997\derived/ENCV1997_incomePers2.dta" ,replace


////////////////////////////////////////////////////////////////////////////////
////// EDUCATION INFORMATION
////////////////////////////////////////////////////////////////////////////////

use "$project\data\ENCV1997\originales\persona.dta", clear

gen cero=0
egen id_hogar=concat(ident cero idehogar)

destring h1001 h26 h23 h2402 h2702, replace

*********** Clean variables

foreach varDep in h1001 h26 h23  ///
	{
	replace `varDep'=0 if `varDep'==2
	replace `varDep'=. if `varDep'==9 // Missings
	replace `varDep'=. if `varDep'==3 
}

foreach varDep in 	h1002 h1003  ///
					h2401 h2701 ///
	{
	replace `varDep'=. if `varDep'==98 |`varDep'==99 // Missings
}

gen i_educ=.
replace i_educ=(h1002-h1003)*15 		if h1001==1 & h1003!=. & h1002!=.  			//School food service 
replace i_educ=i_educ+(h2401/12) 		if h2402==4 & h2401!=. & i_educ!=.			//Scholarship in money or in-kind (yearly) 
replace i_educ=(h2401/12) 				if h2402==4 & h2401!=. & i_educ==.
replace i_educ=i_educ+(h2401/6) 		if h2402==3 & h2401!=. & i_educ!=.			//Scholarship in money or in-kind (semester)
replace i_educ=(h2401/6) 				if h2402==3 & h2401!=. & i_educ==.
replace i_educ=i_educ+(h2401/2) 		if h2402==2 & h2401!=. & i_educ!=.			//Scholarship in money or in-kind (every two months)
replace i_educ=(h2401/2) 				if h2402==2 & h2401!=. & i_educ==.
replace i_educ=i_educ+h2401 			if h2402==1 & h2401!=. & i_educ!=.			//Scholarship in money or in-kind (monthly)
replace i_educ=h2401 					if h2402==1 & h2401!=. & i_educ==.
replace i_educ=i_educ+(h2701/12)     	if h2702==4 & h2701!=. & i_educ!=. 			//Education subsides in money or in-kind (yearly)
replace i_educ=(h2701/12)     			if h2702==4 & h2701!=. & i_educ==. 		
replace i_educ=i_educ+(h2701/6)     	if h2702==3 & h2701!=. & i_educ!=. 			//Education subsides in money or in-kind (semester)
replace i_educ=(h2701/6)     			if h2702==3 & h2701!=. & i_educ==. 		
replace i_educ=i_educ+(h2701/2)     	if h2702==2 & h2701!=. & i_educ!=. 			//Education subsides in money or in-kind (every two months)
replace i_educ=(h2701/2)     			if h2702==2 & h2701!=. & i_educ==. 		
replace i_educ=i_educ+h2701     		if h2702==1 & h2701!=. & i_educ!=. 			//Education subsides in money or in-kind (monthly)
replace i_educ=h2701	     			if h2702==1 & h2701!=. & i_educ==. 		

egen incomePer3= rowtotal(i_educ) , missing
label var incomePer3 "Total individual education income (monthly)"

keep id_hogar incomePer3

collapse (sum) incomeHH3=incomePer3, by(id_hogar)
label var incomeHH3 "Total HH Education Income(monthly)"

save "$project\data\ENCV1997\derived/ENCV1997_incomePers3.dta" ,replace


////////////////////////////////////////////////////////////////////////////////
////// HOUSING CONDITIONS AND LIVING
////////////////////////////////////////////////////////////////////////////////
/*
gen cero=0
egen id_hogar=concat(ident cero idehogar)

*/
////////////////////////////////////////////////////////////////////////////////
////// HOUSE FINANCING
////////////////////////////////////////////////////////////////////////////////

********************************************************************************
*Rural House financing incomeÂ¨
********************************************************************************
/*
use "$project\data\ENCV1997\originales\agrop1.dta", clear

gen cero=0
egen idhogar=concat(ident cero idehogar)

replace m06=. if m06==99 | m06==98 | m06==0 | m06==3

gen i_hous=. 
replace i_hous=m06/12 if m06!=. 

egen incomeHouse1= rowtotal(i_hous) , missing
label var incomeHouse1 "Total HH financing income (monthly)"

keep idhogar incomeHouse1

collapse (sum) incomeHHouse=incomeHouse1, by(idhogar)
label var incomeHHouse "Rural HH House financing Income(monthly)"

save "$project\data\ENCV1997\derived/ENCV1997_incomeHouse1.dta" ,replace
********************************************************************************

********************************************************************************
*Housing subsides
********************************************************************************
  No dice su valor en ninguna variable
use "$project\data\ENCV1997\originales\hogar.dta", clear
k1801 //Subsidio de vivienda del gobierno (si o no)
k19 //Subsidio vivienda (11)

gen cero=0
egen idhogar=concat(ident cero idehogar)

*/
********************************************************************************


********************************************************************************
*House financing or subsides
********************************************************************************

use "$project\data\ENCV1997\originales\97hogares.dta", clear
gen subs=.
replace subs=1 if d06=="1"
replace subs=0 if d06=="2"
drop d06
rename subs d06

gen prop=.
replace prop=1 if d01=="1"
replace prop=2 if d01=="2"
replace prop=3 if d01=="3"
replace prop=4 if d01=="4"
replace prop=5 if d01=="5"
drop d01
rename prop d01

destring d1701 d1702 d1703 d1704 d1705 d1706 d1707 d1708 d1709 d1710 d1711 , replace


gen sub1=. 
replace sub1=1 if d1001=="1"
replace sub1=0 if d1001=="2"
drop d1001
rename sub1 d1001

foreach VarDep in 	d0801 d0802 d0803 d0804 d0805 d0805 d1801 d1802 d1803 d1804 d1805 d1806 d1807 d1808 d1809 d1810 d1811 ///
{ 
replace `VarDep'=. if `VarDep'==99 | `VarDep'==98 | `VarDep'==3
}

gen i_hous=.
replace i_hous=d21 if (d01==1 & d21!=.) |  (d01==4 & d21!=.) | (d01==5 & d21!=.)  																						//They own the house or don't pay for living in it
replace i_hous=0 if (d01==2 & ((d21-(d1801/d1701))<0) & d21!=. & d1801!=.) | (d01==2 & ((d21-(d1802/d1702))<0) & d21!=. & d1802!=.) | (d01==2 & ((d21-(d1803/d1703))<0) & d21!=. & d1803!=.) | ///
					(d01==2 & ((d21-(d1804/d1704))<0) & d21!=. & d1804!=.) | (d01==2 & ((d21-(d1805/d1705))<0) & d21!=. & d1805!=.) | (d01==2 & ((d21-(d1806/d1706))<0) & d21!=. & d1806!=.) | ///
					(d01==2 & ((d21-(d1807/d1707))<0) & d21!=. & d1807!=.) | (d01==2 & ((d21-(d1808/d1708))<0) & d21!=. & d1808!=.) | (d01==2 & ((d21-(d1809/d1709))<0) & d21!=. & d1809!=.) | ///
					(d01==2 & ((d21-(d1810/d1710))<0) & d21!=. & d1810!=.) | (d01==2 & ((d21-(d1811/d1711))<0) & d21!=. & d1811!=.) 													//They have a credit to pay the house
replace i_hous=0 if (d01==2 & d1801==.) | (d01==2 & d1802==.) | (d01==2 & d1803==.) | (d01==2 & d1804==.) | (d01==2 & d1805==.) | (d01==2 & d1806==.) | (d01==2 & d1807==.) | ///
					(d01==2 & d1808==.) | (d01==2 & d1809==.) | (d01==2 & d1810==.) | (d01==2 & d1811==.) | (d01==2 & d21==.)  
replace i_hous=(d21-(d1801/d1701)) if  d21!=.  & d1801!=.  & ((d21-(d1801/d1701))>0) 
replace i_hous=(d21-(d1802/d1702)) if  d21!=.  & d1802!=.  & ((d21-(d1802/d1702))>0) 
replace i_hous=(d21-(d1803/d1703)) if  d21!=.  & d1803!=.  & ((d21-(d1803/d1703))>0) 
replace i_hous=(d21-(d1804/d1704)) if  d21!=.  & d1804!=.  & ((d21-(d1804/d1704))>0) 
replace i_hous=(d21-(d1805/d1705)) if  d21!=.  & d1805!=.  & ((d21-(d1805/d1705))>0) 
replace i_hous=(d21-(d1806/d1706)) if  d21!=.  & d1806!=.  & ((d21-(d1806/d1706))>0) 
replace i_hous=(d21-(d1807/d1707)) if  d21!=.  & d1807!=.  & ((d21-(d1807/d1707))>0) 
replace i_hous=(d21-(d1808/d1708)) if  d21!=.  & d1808!=.  & ((d21-(d1808/d1708))>0) 
replace i_hous=(d21-(d1809/d1709)) if  d21!=.  & d1809!=.  & ((d21-(d1809/d1709))>0) 
replace i_hous=(d21-(d1810/d1710)) if  d21!=.  & d1810!=.  & ((d21-(d1810/d1710))>0) 
replace i_hous=(d21-(d1811/d1711)) if  d21!=.  & d1811!=.  & ((d21-(d1811/d1711))>0) 
replace i_hous=(d21-d22) if d01==2 & d21!=. & d22!=. 

egen incomeHog2= rowtotal(i_hous) , missing
label var incomeHog2 "HH House financing income (monthly)"

rename idhogar id_hogar
keep id_hogar incomeHog2 fex

collapse (sum) incomeHH4=incomeHog2, by(id_hogar fex)
label var incomeHH4 "HH House financing Income(monthly)"

save "$project\data\ENCV1997\derived/ENCV1997_incomeHog2.dta" ,replace

//Merge all the information you have constructed in the last steps of the do file
use "$project\data\ENCV1997\derived/ENCV1997_incomeHog2.dta" , clear
merge m:1 id_hogar using "$project\data\ENCV1997\derived\ENCV1997_incomePers3.dta"
drop _merge

merge m:1 id_hogar using "$project\data\ENCV1997\derived\ENCV1997_incomePers2.dta"
drop _merge

merge m:1 id_hogar using "$project\data\ENCV1997\derived\ENCV1997_incomePers1.dta"
drop _merge

egen incomeHH=rowtotal(incomeHH1 incomeHH2 incomeHH3 incomeHH4)
label var incomeHH "Total Household Income"

saveold "$project\data\ENCV1997\derived/ECV1997_incomeHH.dta" ,replace

svyset id_hogar [pw=fex]
conindex incomeHH, rankvar(incomeHH) svy truezero graph







///////////////////////////////////////////////////////////////////////////
// Original version from someone else...
/*

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

////////////////////////////////////////////////////////////////////////////////
// Income

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



* *******************************************************************************
* INGRESOS TOTALES (RIQUEZA)
egen income=rowtotal(wformal winformal wagricola wservag wservicios wcomercial wotras wsecundario pension transf wcapital wloterias)
label var income "Ingresos totales"

sort id_hogar idpersona

* INGRESO DEL HOGAR
egen incomeh=total(income), by(id_hogar)
label var incomeh "Ingresos totales del hogar"

* INGRESO PER CAPITA DEL HOGAR
gen incomepc=incomeh/c35
label var incomepc "Ingreso per cápia del hogar"

* Cantidad de individuos que reportan ingresos por hogar

gen ind=.
replace ind=1 if income~=. & income~=0
egen reportan=total(ind), by(id_hogar)
drop ind
label var reportan "Individuos que reportan ingreso en el hogar"

* Porcentaje de individuos que reportan ingresos por hogar

gen razonreporte=reportan/c35
label var razonreporte "Porcentaje de individuos que reportan ingresos por hogar"

*/
