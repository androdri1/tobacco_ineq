* Author: Susana Otálvaro Ramírez (susana.otalvaro@urosario.edu.co) 
* Based on: Metodología de cálculo de la variable ingreso ECV 2015
* Date: 2017.07.22
* Goal: produce total income of the HH for the ENCV2011 (no imputation or outlier analysis here!)

/*
550_1	A Datos de identificacion y de vivienda 

551_1	C Datos de Servicios del hogar 
551_3	K Datos de tenencia y financiacion de la vivienda que ocupa el hogar 
551_4	L Datos condiciones de vida del hogar y tenencia 
551_5	  Variables sobre gastos semanales 
551_6	  Datos sobre gastos personales 
551_7	  Datos de gastos mensuales
551_8	  Datos de gastos trimestrales 
551_9	  Datos gastos anuales 
551_10	  Componente rural

552_1	D Datos sobre caracteristicas y composicion del hogar 
552_2	E Datos de salud 
552_3	F Datos de cuidado de los niños y niñas menores 
552_5	G Datos de educacion 
552_6	H Datos de fuerza de trabajo 

553_1	  Componente rural - Fincas 	
559_1	  Componente rural - Cultivos 			
565_1	  Componente rural - animales y productos 
*/

*glo dropbox "C:\Users\Usuario\Dropbox\Tobacco-health-inequalities\data" //Personal Susana
glo dropbox "C:\Users\susana.otalvaro\Dropbox\Tobacco-health-inequalities\data" //Universidad Susana
glo dropbox="C:\Users\paul.rodriguez\Dropbox\tabaco\Tobacco-health-inequalities\data" // Paul


////////////////////////////////////////////////////////////////////////////////
////// LABOUR FORCE INFORMATION 
////////////////////////////////////////////////////////////////////////////////

use "$dropbox\ENCV2011\original\dbfp_encv_552_6.sav.dta", clear

*********** Clean variables

foreach varDep in P8631 P6630S1 P6630S2 P6630S3 P6630S5 P6630S6 P6595 P6605 P6623 P6615 P8646 P8654  ///
	{
	replace `varDep'=0 if `varDep'==2
	replace `varDep'=. if `varDep'==9 // Missings
	replace `varDep'=. if `varDep'==3 
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


// INCOME CATEGORIES (monthly)
* Labour monetary income *******************************************************
gen gan=.
replace gan=P550/12 if P550!=. 														//monthly self-employed earnings

gen il_mon=P8624																	//main wage
replace il_mon=il_mon+P8631S1 if P8631==1 & P8631S1!=. 								//prim tecnica o de antiguedad
replace il_mon=il_mon+P6630S1A1/12 if  P6630S1==1 & P6630S1A1!=. 					//prim servicioss (yearly)
replace il_mon=il_mon+P6630S2A1/12 if  P6630S2==1 & P6630S2A1!=. 					//prim navidad (yearly)
replace il_mon=il_mon+P6630S3A1/12 if  P6630S3==1 & P6630S3A1!=. 					//prim vacaciones(yearly)
replace il_mon=il_mon+P6630S5A1/12 if  P6630S5==1 & P6630S5A1!=. 					//bonif(yearly)
replace il_mon=il_mon+P6630S6A1/12 if  P6630S6==1 & P6630S6A1!=. 					//indemn(yearly)

replace il_mon=il_mon+gan if P6750!=. & P550!=. & il_mon!=. & gan>P6750				//ganancia neta de un negocio o cosecha (yearly)
replace il_mon=gan if gan>P6750 & il_mon==. & P6750!=. & P550!=.
replace il_mon=gan if il_mon==. & P6750==. & P550!=.

replace il_mon=P6750 if il_mon==. & P6750>gan & P550!=.	& P6750!=.					//ganancia negocio o cosecha (monthly)
replace il_mon=P6750 if il_mon==. & P550==. & P6750!=. 								//self_employed earnings

replace il_mon=il_mon+P8636S1 if P8636S1!=. & il_mon!=.								//other jobs
replace il_mon=P8636S1 if il_mon==. 
replace il_mon=il_mon+P8640S1 if P8640S1!=. & il_mon!=.								//other labour income
replace il_mon=P8640S1 if il_mon==. 

* Labour income (in-kind)********************************************************
gen il_ink=.
replace il_ink=P6595S1 if P6595==1 & P6595S1!=.  									//Food
replace il_ink=il_ink+P6605S1 if P6605==1 & P6605S1!=. & il_ink!=. 					//Housing
replace il_ink=P6605S1 if il_ink==. & P6605S1!=.
replace il_ink=il_ink+P6623S1 if P6623==1 & P6623S1!=.								//Other in-kind income
replace il_ink=P6623S1 if il_ink==. & P6623S1!=.
replace il_ink=il_ink+P6615S1 if P6615==1 & P6615S1!=. 								//Transport
replace il_ink=P6615S1 if il_ink==. & P6615S1!=.

* Labour income (subsides)******************************************************
gen il_sub=.
replace il_sub=P8626S1 if P8626==1 & P8626S1!=.  									//Food subsides in money
replace il_sub=il_sub+P8628S1 if P8628==1 & P8628S1!=. 								//Transport subs in money 
replace il_sub=P8628S1 if il_sub==. & P8628S1!=. 
replace il_sub=il_sub+P8630S1 if P8630==1 & P8630S1!=. 								//Family subs in money
replace il_sub=P8630S1 if il_sub==. & P8630S1!=. 	


* Labour income (total)******************************************************
gen     i_lab=il_mon
replace i_lab=i_lab+il_ink if il_ink!=. & i_lab!=.
replace i_lab=il_ink if i_lab==. & il_ink!=.
replace i_lab=i_lab+il_sub if il_sub!=. & i_lab!=.
replace i_lab=il_sub if i_lab==. &il_sub!=.

label var il_ink "Labour income: In-kind"
label var il_mon "Labour income: Monetary"
label var il_sub "Labour income: Subsides"

label var i_lab "Labour income: total"

* Capital income ***************************************************************
gen i_cap=P8646S1 if P8646==1 & P8646S1!=.   										//Arriendos
replace i_cap=i_cap+P8654S1 if P8654==1 & P8654S1!=. 								//Cesantías, préstamos, CDT, intereses, rifas
replace i_cap=P8654S1 if i_cap==. & P8654S1!=.

* Real State Sales' income *****************************************************
gen i_rs=.
replace i_rs=P8652S1/12 if P8652==1 & P8652S1!=.									//Real state sales income

* Pension income or similars ***************************************************
gen i_pens=.
replace i_pens=			P8642S1 		if P8642==1 & P8642S1!=.  					//pension o jubilacion
replace i_pens=i_pens+	P8644S1 		if P8644==1 & P8644S1!=. & i_pens!=. 
replace i_pens=			P8644S1 		if i_pens==. & P8644==1 & P8644S1!=.  		//pension de alimentos o sostenimiento (hijos)
replace i_pens=i_pens+	(P8648S1/12) 	if P8648==1 & P8648S1!=. & i_pens!=.		//prima pension(yearly)
replace i_pens= 		(P8648S1/12) 	if i_pens==. & P8648==1 & P8648S1!=.
replace i_pens=i_pens+	(P8650S1/12) 	if P8650==1 & P8650S1!=. & i_pens!=.		//Private transfers (yearly)
replace i_pens=			(P8650S1/12) 	if i_pens==. & P8650==1 & P8650S1!=.

label var i_cap "Capital income"
label var i_pens "Pension income"
label var i_rs "Real State Sales' income"

keep DIRECTORIO SECUENCIA_ENCUESTA SECUENCIA_P NRO_ENCUESTA ORDEN FEX_C LLAVEHOG  i_lab i_cap i_pens i_rs P8654S1
rename NRO_ENCUESTA NRO_ENCUESTAPER
rename SECUENCIA_ENCUESTA SECUENCIA_ENCUESTAPER
rename SECUENCIA_P SECUENCIA_ENCUESTA

egen incomePer1= rowtotal(i_lab i_cap i_pens i_rs) , missing
replace incomePer1=incomePer1-P8654S1 if P8654S1!=. 
label var incomePer1 "Total individual income -LF info-(monthly)"

collapse(sum) incomeHH1=incomePer1, by(LLAVEHOG DIRECTORIO SECUENCIA_ENCUESTA FEX_C)
label var incomeHH1 "Total HH income -Labour force info-"

save "$dropbox\ENCV2011\derived/ENCV2011_incomePers1.dta" ,replace


////////////////////////////////////////////////////////////////////////////////
////// CHILDREN CARE INFORMATION
////////////////////////////////////////////////////////////////////////////////

use "$dropbox\ENCV2011\original\dbfp_encv_552_3.sav.dta", clear

*********** Clean variables

foreach varDep in P8578 P8580  ///
	{
	replace `varDep'=0 if `varDep'==2
	replace `varDep'=. if `varDep'==9 // Missings
	replace `varDep'=. if `varDep'==3 
}

foreach varDep in 	P8578S1 P8578S2  ///
					P8580S1 P8580S2  ///
	{
	replace `varDep'=. if `varDep'==98 |`varDep'==99 // Missings
}

gen i_alim=.
replace i_alim=(P8578S2-P8578S1)*15 if P8578==1 & P8578S2!=. & P8578S1!=.  						//Children care food subs (Breakfast or lunch)
replace i_alim=i_alim+ ((P8580S2-P8580S1)*15) if P8580==1 & P8580S2!=. & P8580S1!=. & i_alim!=. //Children care food subs (Other) refrigerios
replace i_alim=((P8580S2-P8580S1)*15) if P8580==1 & P8580S2!=. & P8580S1!=. & i_alim==. 

keep DIRECTORIO SECUENCIA_ENCUESTA SECUENCIA_P NRO_ENCUESTA ORDEN FEX_C LLAVEHOG  i_alim
rename NRO_ENCUESTA NRO_ENCUESTAPER
rename SECUENCIA_ENCUESTA SECUENCIA_ENCUESTAPER
rename SECUENCIA_P SECUENCIA_ENCUESTA

egen incomePer2= rowtotal(i_alim) , missing
label var incomePer2 "Total individual income -CC info-(monthly)"

collapse(sum) incomeHH2=incomePer2, by(LLAVEHOG DIRECTORIO SECUENCIA_ENCUESTA FEX_C)
label var incomeHH2 "Total HH income -Children care info-"

save "$dropbox\ENCV2011\derived/ENCV2011_incomePers2.dta" ,replace


////////////////////////////////////////////////////////////////////////////////
////// EDUCATION INFORMATION
////////////////////////////////////////////////////////////////////////////////

use "$dropbox\ENCV2011\original\dbfp_encv_552_5.sav.dta", clear

*********** Clean variables

foreach varDep in P6180 P8612 P8610  ///
	{
	replace `varDep'=0 if `varDep'==2
	replace `varDep'=. if `varDep'==9 // Missings
	replace `varDep'=. if `varDep'==3 
}

foreach varDep in 	P6180S2 P6180S1  ///
					P8610S1 P8612S1 ///
	{
	replace `varDep'=. if `varDep'==98 |`varDep'==99 // Missings
}



gen i_educ=.
replace i_educ=(P6180S2-P6180S1)*15 	if P6180==1 & P6180S1!=. & P6180S2!=.  			//School food service 
replace i_educ=i_educ+(P8610S1/12) 		if P8610S2==4 & P8610S1!=. & i_educ!=.			//Scholarship in money or in-kind (yearly) 
replace i_educ=(P8610S1/12) 			if P8610S2==4 & P8610S1!=. & i_educ==.
replace i_educ=i_educ+(P8610S1/6) 		if P8610S2==3 & P8610S1!=. & i_educ!=.			//Scholarship in money or in-kind (semester)
replace i_educ=(P8610S1/6) 				if P8610S2==3 & P8610S1!=. & i_educ==.
replace i_educ=i_educ+(P8610S1/2) 		if P8610S2==2 & P8610S1!=. & i_educ!=.			//Scholarship in money or in-kind (every two months)
replace i_educ=(P8610S1/2) 				if P8610S2==2 & P8610S1!=. & i_educ==.
replace i_educ=i_educ+P8610S1 			if P8610S2==1 & P8610S1!=. & i_educ!=.			//Scholarship in money or in-kind (monthly)
replace i_educ=P8610S1 					if P8610S2==1 & P8610S1!=. & i_educ==.
replace i_educ=i_educ+(P8612S1/12)     	if P8612S2==4 & P8612S1!=. & i_educ!=. 			//Education subsides in money or in-kind (yearly)
replace i_educ=(P8612S1/12)     		if P8612S2==4 & P8612S1!=. & i_educ==. 		
replace i_educ=i_educ+(P8612S1/6)     	if P8612S2==3 & P8612S1!=. & i_educ!=. 			//Education subsides in money or in-kind (semester)
replace i_educ=(P8612S1/6)     			if P8612S2==3 & P8612S1!=. & i_educ==. 		
replace i_educ=i_educ+(P8612S1/2)     	if P8612S2==2 & P8612S1!=. & i_educ!=. 			//Education subsides in money or in-kind (every two months)
replace i_educ=(P8612S1/2)     			if P8612S2==2 & P8612S1!=. & i_educ==. 		
replace i_educ=i_educ+P8612S1     		if P8612S2==1 & P8612S1!=. & i_educ!=. 			//Education subsides in money or in-kind (monthly)
replace i_educ=P8612S1	     			if P8612S2==1 & P8612S1!=. & i_educ==. 		

keep DIRECTORIO SECUENCIA_ENCUESTA SECUENCIA_P NRO_ENCUESTA ORDEN FEX_C LLAVEHOG  i_educ
rename NRO_ENCUESTA NRO_ENCUESTAPER
rename SECUENCIA_ENCUESTA SECUENCIA_ENCUESTAPER
rename SECUENCIA_P SECUENCIA_ENCUESTA

egen incomePer3= rowtotal(i_educ) , missing
label var incomePer3 "Total individual income -Ed info-(monthly)"

collapse(sum) incomeHH3=incomePer3, by(LLAVEHOG DIRECTORIO SECUENCIA_ENCUESTA FEX_C)
label var incomeHH3 "Total HH income -Education subsides and scholarships-"

save "$dropbox\ENCV2011\derived/ENCV2011_incomePers3.dta" ,replace


////////////////////////////////////////////////////////////////////////////////
////// HOUSING CONDITIONS AND LIVING
////////////////////////////////////////////////////////////////////////////////

use "$dropbox\ENCV2011\original\dbfp_encv_551_4.sav.dta", clear

*********** Clean variables

foreach varDep in P5191S1 P5191S2 ///
	{
	replace `varDep'=0 if `varDep'==2
	replace `varDep'=. if `varDep'==9 // Missings
	replace `varDep'=. if `varDep'==3 
}

replace P5191S1A1=. if P5191S1A1==98 | P5191S1A1==99
replace P5191S2A1=. if P5191S2A1==98 | P5191S2A1==99

// Produce Housing conditions and living income
gen i_other=.
replace  i_other=P5191S1A1 			if P5191S1==1 & P5191S1A1!=.   						//Housing subsides in money
replace i_other=i_other+P5191S2A1 	if P5191S2==1 & P5191S2A1!=.						//Housing subsides in-kind
replace i_other= P5191S2A1 			if P5191S2==1 & P5191S2A1!=. & i_other==.

keep DIRECTORIO SECUENCIA_ENCUESTA SECUENCIA_P NRO_ENCUESTA ORDEN FEX_C LLAVEHOG  i_other
rename NRO_ENCUESTA NRO_ENCUESTAHOG
rename SECUENCIA_ENCUESTA SECUENCIA_ENCUESTAHOG
rename SECUENCIA_P SECUENCIA_ENCUESTA

egen incomeHog1= rowtotal(i_other) , missing
label var incomeHog1 "Total individual income -HC & L info-(monthly)"

collapse(sum) incomeHH4=incomeHog1, by(LLAVEHOG DIRECTORIO SECUENCIA_ENCUESTA FEX_C)
label var incomeHH4 "Total HH income -Housing conditions and living-"

save "$dropbox\ENCV2011\derived/ENCV2011_incomeHog1.dta" ,replace


////////////////////////////////////////////////////////////////////////////////
////// HOUSE FINANCING
////////////////////////////////////////////////////////////////////////////////

use "$dropbox\ENCV2011\original\dbfp_encv_551_3.sav.dta", clear

*********** Clean variables

foreach varDep in P5160S1 P5160S2 ///
	{
	replace `varDep'=0 if `varDep'==2
	replace `varDep'=. if `varDep'==9 // Missings
	replace `varDep'=. if `varDep'==3 
}

foreach varDep in 	P5130 P5100 		///
					P5160S1A1 P5160S2A1 ///
	{
	replace `varDep'=. if `varDep'==98 |`varDep'==99 // Missings
}

gen i_hous=.
replace i_hous=P5130 if (P5095==1 & P5130!=.) |  (P5095==4 & P5130!=.) | (P5095==5 & P5130!=.)  //They own the house or don't pay for living in it
replace i_hous=0 if P5095==2 & ((P5130-P5100)<0) & P5130!=. & P5100!=.    						//They have a credit to pay the house
replace i_hous=0 if (P5095==2 & P5100==.) | (P5095==2 & P5130==.)  
replace i_hous=(P5130-P5100) if  P5095==2 & P5130!=.  & P5100!=.  & ((P5130-P5100)>0) 

gen i_gob=.
replace i_gob=P5160S1A1 if P5160S1==1 & P5160S1A1!=.											//Government subs in money for housing
replace i_gob=i_gob+P5160S2A1 if P5160S2==1 & P5160S2A1!=. & i_gob!=. 							//Government subs for housing in kind
replace i_gob=P5160S2A1 if P5160S2==1 & P5160S2A1!=. & i_gob==.

keep DIRECTORIO SECUENCIA_ENCUESTA SECUENCIA_P NRO_ENCUESTA ORDEN FEX_C LLAVEHOG  i_hous i_gob
rename NRO_ENCUESTA NRO_ENCUESTAHOG
rename SECUENCIA_ENCUESTA SECUENCIA_ENCUESTAHOG
rename SECUENCIA_P SECUENCIA_ENCUESTA

egen incomeHog2= rowtotal(i_hous i_gob) , missing
label var incomeHog2 "Total individual income -HF info-(monthly)"

collapse(sum) incomeHH5=incomeHog2, by(LLAVEHOG DIRECTORIO SECUENCIA_ENCUESTA FEX_C)
label var incomeHH5 "Total HH income -House financing info-"

save "$dropbox\ENCV2011\derived/ENCV2011_incomeHog2.dta" ,replace


//Merge all the information you have constructed in the last steps of the do file
use "$dropbox\ENCV2011\derived/ENCV2011_incomeHog2.dta" , clear

merge m:1 LLAVEHOG using "$dropbox\ENCV2011\derived\ENCV2011_incomeHog1.dta"
drop _merge

merge m:1 LLAVEHOG using "$dropbox\ENCV2011\derived\ENCV2011_incomePers3.dta"
drop _merge

merge m:1 LLAVEHOG using "$dropbox\ENCV2011\derived\ENCV2011_incomePers2.dta"
drop _merge

merge m:1 LLAVEHOG using "$dropbox\ENCV2011\derived\ENCV2011_incomePers1.dta"
drop _merge

egen incomeHH=rowtotal(incomeHH1 incomeHH2 incomeHH3 incomeHH4 incomeHH5)
label var incomeHH "Total Household Income"

saveold "$dropbox\ENCV2011\derived/ENCV2011_incomeHH.dta", replace 

/////////////
//Análisis de desigualdad 
svyset DIRECTORIO [pw=FEX_C]
conindex incomeHH, rankvar(incomeHH) svy truezero graph

/*

---------------------------------------------------------------------------------------------------------
Index:                  | No. of obs.  | Index value            | Std. error             | p-value      |
---------------------------------------------------------------------------------------------------------
Gini                    | 25364        | .55654759              |.01646607               |  0.0000      |
---------------------------------------------------------------------------------------------------------
 

*/
