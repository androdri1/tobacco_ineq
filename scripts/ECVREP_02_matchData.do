* Author: Paul Rodriguez (paul.rodriguez@urosario.edu.co) & Susana Otálvaro-Ramírez (susana.otalvaro@urosario.edu.co)
* Date: 2020.07.01
* Goal:

if "`c(username)'"=="paul.rodriguez" {
	glo mainE="D:\Paul.Rodriguez\Dropbox\tabaco\tabacoDrive\tobacco-health-inequalities" //Paul
}
else {
	*glo mainE="C:\Users\\`c(username)'\Dropbox\tabacoDrive\Tobacco-health-inequalities" // Susana
	glo mainE="C:\Users\\`c(username)'\Dropbox\tabaco\tabacoDrive\tobacco-health-inequalities" // Paul	
}

glo mainF="$mainE\procesamiento"


////////////////////////////////////////////////////////////////////////////////
if 1==0 {
use "$mainF\IPC\ipc nacional1.dta", clear
tsset year, y

gen  ipctab2011=ipc_tabacoAd if year==2011
egen Ipctab2011=max(ipctab2011)
gen  cigprice=121*ipc_tabacoAd/Ipctab2011
keep if year>=1997 & year<=2012

tw (tsline ipc_tabacoAd , lwidth(thick)) ///
   (tsline ipc_total , lwidth(thick)) , tlabel(1997(2)2012)  legend(order(1 "CPI tobacco" 2 "CPI all goods index")) scheme(Plotplain) name(a1, replace)
graph export "$mainE\document\images\CigPrice.pdf", as(pdf) replace

gen  cigpriceR=cigprice*100/ipc_total
gen ficticia97= 0

tw (tsline cigprice , lwidth(thick) ) ///
   (tsline cigpriceR , lwidth(thick) ) ,  ///
   tlabel(1997(2)2012) legend(order(1 "Nominal cigarrete price" 2 "Real cigarrete prices (base 2008)") pos(6) r(1))
   *text(56 2012.5 " ---    Import tax" , place(se)) text(50 2012.5 " __    Cigarette tax" , place(se)) scheme(Plotplain) name(a2, replace)
graph export "$mainE\document\images\CigPriceTax.pdf", as(pdf) replace
graph export "$mainE\document\images\CigPriceTax.png", as(png) replace
}
*

* Paul 2017.10.3:  We cannot derive real prices from this information; at most, 
*                  we can reconstruct the current pric. See the example below
/*
     Año  PIB real	IPC	 (E)PIB nominal	(F)PIB nominal
27  2007	3000	100	    3000	    3000 =$F$29*E27/$E$29
28  2008	3090	104	    3213.6	    3213.6 =$F$29*E28/$E$29
29  2009	3167	107.1	3391.857	3391.857
*
*/

////////////////////////////////////////////////////////////////////////////////
use "$mainF\derived\ECVREP1.dta", clear

replace T1_expen_m1=0 if T1_expen_m1==.
replace alimExpenses=0 if alimExpenses==. 
/*
gen logexpe=log(totalExpenses)
tw (kdensity logexpe if year==1997)(kdensity logexpe if year==2003), name(a1, replace)
tw (kdensity logexpe if year==2008)(kdensity logexpe if year==2003), name(a2, replace)
tw (kdensity logexpe if year==2011)(kdensity logexpe if year==2003), name(a3, replace)
*/

*bys depto : egen REG=max(region) // !!!!!!!! Esta variable está mal, revisar!
*bys depto : sum region
la var numadu "Nro. adultos en el hogar"
la var numnin "Nro. niños en el hogar"
la var GastoCte "Current Expenditures"

recode edad (16/25=1 "16 to 25") (26/35=2 "26 to 35") (36/45=3 "36 to 45") (46/55=4 "46 to 55") (56/64=5 "56 to 64") (65/150=6 "65+"), g(edadg)
recode edad (10/19=1 "10 to 19") (20/29=2 "20 to 29") (30/39=3 "30 to 39") (40/49=4 "40 to 49") (50/59=5 "50 to 59") (60/150=6 "60+"), g(edadg1)
replace edadg=. if edad<16
replace edadg1=. if edad<10

svyset id [pw=fex], strata(depto)
*drop if depto==11 //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

gen currentExpenses=totalExpenses -(T2_expen_m3 + T2_expen_m5 + T2_expen_m8) if (totalExpenses!=. & T2_expen_m3!=. & T2_expen_m5!=. & T2_expen_m8!=.)
replace currentExpenses=. if currentExpenses<0

gen numcig=tabacoExpenses/cigprice if tabacoExpenses!=. & cigprice!=. & cigprice!=0

gen tabexpper = tabacoExpenses/totalExpenses if totalExpenses!=. & totalExpenses!=0
replace tabexpper=. if tabexpper>1 

gen tabexpper_c = tabacoExpenses/GastoCte if GastoCte!=. & GastoCte!=0
replace tabexpper_c = . if tabexpper_c>1

gen tabac01 =0
replace tabac01=1 if tabacoExpenses>0

gen lngast=ln(persgast)
drop curexpper
gen curexpper=GastoCte/totalExpenses

egen healthExpenses1 = rowtotal(T2_expen_m5a_afil T2_expen_m5a_comp T2_expen_m5a_hosp T2_expen_m5a_cons T2_expen_m5a_vacu T2_expen_m5a_medi T2_expen_m5a_labo T2_expen_m5a_tran T2_expen_m5a_tera T2_expen_m5a_inst) if year==1997 | year==2011
********************************************************************************
** Expenses Categories as a proportion of Total Expenses and Current Expenses **
********************************************************************************
// Total expenses net of tobacco 
gen totalExpenses_notob = totalExpenses-tabacoExpenses if tabacoExpenses!=. & totalExpenses!=.

// Current Expenses over Total 
gen currexpper=currentExpenses/totalExpenses if GastoCte!=. & totalExpenses!=. & totalExpenses!=0
replace currexpper=. if currexpper>1 & currexpper!=. 

// 1. Food Budget share
* Total Expenses
gen alimexpper = alimExpenses/totalExpenses
replace alimexpper=. if alimexpper>1 
gen alimexpperFUM=alimexpper if numcig>0
gen alimexpperNOFUM=alimexpper if numcig==0

rename alimExpenses1 alimExpensesa
* Total expenses (previous construction of food expenses)
gen alimexppera = alimExpensesa/totalExpenses
replace alimexppera=. if alimexppera>1 
gen alimexpperFUMa=alimexppera if numcig>0
gen alimexpperNOFUMa=alimexppera if numcig==0

* Current expenses
gen alimexpper_c = alimExpenses/GastoCte
replace alimexpper_c=. if alimexpper_c>1 
gen alimexpperFUM_c=alimexpper_c if numcig>0
gen alimexpperNOFUM_c=alimexpper_c if numcig==0

* Current expenses (previous construction of food expenses)
gen alimexppera_c = alimExpensesa/GastoCte
replace alimexppera_c=. if alimexppera_c>1 
gen alimexpperFUMa_c=alimexppera_c if numcig>0
gen alimexpperNOFUMa_c=alimexppera_c if numcig==0


// 1.a. Alcohol 
* Total Expenses
gen alcexpper = alcoholExpenses/totalExpenses
replace alcexpper=. if alcexpper>1 
gen alcexpperFUM=alcexpper if numcig>0
gen alcexpperNOFUM=alcexpper if numcig==0

* Current expenses
gen alcexpper_c = alcoholExpenses/GastoCte
replace alcexpper_c=. if alcexpper_c>1 
gen alcexpperFUM_c=alcexpper_c if numcig>0
gen alcexpperNOFUM_c=alcexpper_c if numcig==0

// Alcohol + Tobacco 
egen totalAlcTab= rowtotal(alcoholExpenses tabacoExpenses), missing
gen alctab = .
replace alctab = alcoholExpenses/totalAlcTab if alcoholExpenses!=. & totalAlcTab!=. 

// 2. Clothing and footwear BS 
* Total Expenses 
gen clothexpper = T2_expen_m2/totalExpenses
replace clothexpper=. if clothexpper>1

*Current Expenses
gen clothexpper_c = T2_expen_m2/GastoCte
replace clothexpper_c=. if clothexpper_c>1

// 3. Household services BS(Rent, home public services, domestic service) -Has no sense to do it with current expenditure-
* Total Expenses
gen houseexpper=T2_expen_m3/totalExpenses
replace houseexpper=. if houseexpper>1
gen houseexpperFUM=houseexpper if numcig>0
gen houseexpperNOFUM=houseexpper if numcig==0

// 4. Furniture BS 
* Total Expenses
gen furnexpper = T2_expen_m4/totalExpenses
replace furnexpper=. if furnexpper>1

* Current Expenses
gen furnexpper_c=T2_expen_m4/GastoCte
replace furnexpper_c=. if furnexpper_c>1

// 5. Health Budget share -Has no sense to do it with current expenditure-
* Total Expenses
gen healthexpper=T2_expen_m5/totalExpenses
replace healthexpper=. if healthexpper>1 
gen healthexpperFUM=healthexpper if numcig>0
gen healthexpperNOFUM=healthexpper if numcig==0

// 6. Transport and Communication
* Total Expenses 
gen transexpper=T2_expen_m6/totalExpenses
replace transexpper=. if transexpper>1
gen transexpperFUM=transexpper if numcig>0
gen transexpperNOFUM=transexpper if numcig==0

* Current Expenses
gen transexpper_c=T2_expen_m6/GastoCte
replace transexpper_c=. if transexpper_c>1
gen transexpperFUM_c=transexpper_c if numcig>0
gen transexpperNOFUM_c=transexpper_c if numcig==0

// 7. Cultural Services BS
* Total Expenses 
gen cultexpper=T2_expen_m7/totalExpenses
replace cultexpper=. if cultexpper>1
gen cultexpperFUM=cultexpper if numcig>0
gen cultexpperNOFUM=cultexpper if numcig==0

// 8. Education BS(Enrollment fee, uniforms, equipment, etc) -Has no sense to do it with current expenditure-
* Total Expenses
gen educexpper=T2_expen_m8/totalExpenses
replace educexpper=. if educexpper>1
gen educexpperFUM=educexpper if numcig>0
gen educexpperNOFUM=educexpper if numcig==0

// 9. Personal services and other payments BS(Household durables) 
* Total Expenses
gen persserexpper=T2_expen_m9/totalExpenses
replace persserexpper=. if persserexpper>1
gen persserexpperFUM=persserexpper if numcig>0
gen persserexpperNOFUM=persserexpper if numcig==0



**********************************************
** SHARES NET OF TOBACCO 
**********************************************
// 1. Food Budget share
* Total Expenses
gen alimexpper_notob = alimExpenses/totalExpenses_notob
replace alimexpper_notob=. if alimexpper_notob>1 
gen alimexpper_notobFUM=alimexpper_notob if numcig>0
gen alimexpper_notobNOFUM=alimexpper_notob if numcig==0

* Total expenses (previous construction of food expenses)
gen alimexppera_notob = alimExpensesa/totalExpenses_notob
replace alimexppera_notob=. if alimexppera_notob>1 
gen alimexppera_notobFUM=alimexppera_notob if numcig>0
gen alimexppera_notobNOFUM=alimexppera_notob if numcig==0

// 1.a. Alcohol 
* Total Expenses
gen alcexpper_notob = alcoholExpenses/totalExpenses_notob
replace alcexpper_notob=. if alcexpper_notob>1 
gen alcexpper_notobFUM=alcexpper_notob if numcig>0
gen alcexpper_notobNOFUM=alcexpper_notob if numcig==0

// 2. Clothing and footwear BS 
* Total Expenses 
gen clothexpper_notob = T2_expen_m2/totalExpenses_notob
replace clothexpper_notob=. if clothexpper_notob>1

// 3. Household services BS(Rent, home public services, domestic service) -Has no sense to do it with current expenditure-
* Total Expenses
gen houseexpper_notob=T2_expen_m3/totalExpenses_notob
replace houseexpper_notob=. if houseexpper_notob>1
gen houseexpper_notobFUM=houseexpper_notob if numcig>0
gen houseexpper_notobNOFUM=houseexpper_notob if numcig==0

// 4. Furniture BS 
* Total Expenses
gen furnexpper_notob = T2_expen_m4/totalExpenses_notob
replace furnexpper_notob=. if furnexpper_notob>1

// 5. Health Budget share -Has no sense to do it with current expenditure-
* Total Expenses
gen healthexpper_notob=T2_expen_m5/totalExpenses_notob
replace healthexpper_notob=. if healthexpper_notob>1 
gen healthexpper_notobFUM=healthexpper_notob if numcig>0
gen healthexpper_notobNOFUM=healthexpper_notob if numcig==0

// 6. Transport and Communication
* Total Expenses 
gen transexpper_notob =T2_expen_m6/totalExpenses_notob
replace transexpper_notob =. if transexpper_notob>1
gen transexpper_notobFUM=transexpper_notob if numcig>0
gen transexpper_notobNOFUM=transexpper_notob if numcig==0

// 7. Cultural Services BS
* Total Expenses 
gen cultexpper_notob=T2_expen_m7/totalExpenses_notob
replace cultexpper_notob=. if cultexpper_notob>1
gen cultexpper_notobFUM=cultexpper_notob if numcig>0
gen cultexpper_notobNOFUM=cultexpper_notob if numcig==0

// 8. Education BS(Enrollment fee, uniforms, equipment, etc) -Has no sense to do it with current expenditure-
* Total Expenses
gen educexpper_notob=T2_expen_m8/totalExpenses_notob
replace educexpper_notob=. if educexpper_notob>1
gen educexpper_notobFUM=educexpper_notob if numcig>0
gen educexpper_notobNOFUM=educexpper_notob if numcig==0

// 9. Personal services and other payments BS(Household durables) 
* Total Expenses
gen persserexpper_notob=T2_expen_m9/totalExpenses_notob
replace persserexpper_notob=. if persserexpper_notob>1
gen persserexpper_notobFUM=persserexpper_notob if numcig>0
gen persserexpper_notobNOFUM=persserexpper_notob if numcig==0


********************************************************************************
* Subcategorias de Salud

* Version 1: Como proporcion del gasto en salud 
gen 	afiliacion_h = T2_expen_m5a_afil/healthExpenses1 if T2_expen_m5a_afil!=. & T2_expen_m5!=0 & T2_expen_m5!=. 
replace afiliacion_h =. if afiliacion_h>1 

gen 	complementario_h = T2_expen_m5a_comp/healthExpenses1 if T2_expen_m5a_comp!=. & T2_expen_m5!=0 & T2_expen_m5!=. 
replace complementario_h =. if complementario_h>1 

gen 	hospitalizacion_h = T2_expen_m5a_hosp/healthExpenses1 if T2_expen_m5a_hosp!=. & T2_expen_m5!=0 & T2_expen_m5!=. 
replace hospitalizacion_h =. if hospitalizacion_h>1 

gen 	consulta_h = T2_expen_m5a_cons/healthExpenses1 if T2_expen_m5a_cons!=. & T2_expen_m5!=0 & T2_expen_m5!=. 
replace consulta_h =. if consulta_h>1 

gen 	vacunas_h = T2_expen_m5a_vacu/healthExpenses1 if T2_expen_m5a_vacu!=. & T2_expen_m5!=0 & T2_expen_m5!=. 
replace vacunas_h =. if vacunas_h>1 

gen 	medicinas_h = T2_expen_m5a_medi/healthExpenses1 if T2_expen_m5a_medi!=. & T2_expen_m5!=0 & T2_expen_m5!=. 
replace medicinas_h =. if medicinas_h>1 

gen 	examenes_h = T2_expen_m5a_labo/healthExpenses1 if T2_expen_m5a_labo!=. & T2_expen_m5!=0 & T2_expen_m5!=. 
replace examenes_h =. if examenes_h>1 

gen 	transporte_h = T2_expen_m5a_tran/healthExpenses1 if T2_expen_m5a_tran!=. & T2_expen_m5!=0 & T2_expen_m5!=. 
replace transporte_h =. if transporte_h>1 

gen 	terapias_h = T2_expen_m5a_tera/healthExpenses1 if T2_expen_m5a_tera!=. & T2_expen_m5!=0 & T2_expen_m5!=. 
replace terapias_h =. if terapias_h>1 

gen 	instrum_h = T2_expen_m5a_inst/healthExpenses1 if T2_expen_m5a_inst!=. & T2_expen_m5!=0 & T2_expen_m5!=. 
replace instrum_h =. if instrum_h>1 


*Version 2: Como proporcion del gasto total 

gen 	afiliacion_T = T2_expen_m5a_afil/totalExpenses if T2_expen_m5a_afil!=. & T2_expen_m5!=0 & T2_expen_m5!=. 
replace afiliacion_T =. if afiliacion_T>1 

gen 	complementario_T = T2_expen_m5a_comp/totalExpenses if T2_expen_m5a_comp!=. & T2_expen_m5!=0 & T2_expen_m5!=. 
replace complementario_T =. if complementario_T>1 

gen 	hospitalizacion_T = T2_expen_m5a_hosp/totalExpenses if T2_expen_m5a_hosp!=. & T2_expen_m5!=0 & T2_expen_m5!=. 
replace hospitalizacion_T =. if hospitalizacion_T>1 

gen 	consulta_T = T2_expen_m5a_cons/totalExpenses if T2_expen_m5a_cons!=. & T2_expen_m5!=0 & T2_expen_m5!=. 
replace consulta_T =. if consulta_T>1 

gen 	vacunas_T = T2_expen_m5a_vacu/totalExpenses if T2_expen_m5a_vacu!=. & T2_expen_m5!=0 & T2_expen_m5!=. 
replace vacunas_T =. if vacunas_T>1 

gen 	medicinas_T = T2_expen_m5a_medi/totalExpenses if T2_expen_m5a_medi!=. & T2_expen_m5!=0 & T2_expen_m5!=. 
replace medicinas_T =. if medicinas_T>1 

gen 	examenes_T = T2_expen_m5a_labo/totalExpenses if T2_expen_m5a_labo!=. & T2_expen_m5!=0 & T2_expen_m5!=. 
replace examenes_T =. if examenes_T>1 

gen 	transporte_T = T2_expen_m5a_tran/totalExpenses if T2_expen_m5a_tran!=. & T2_expen_m5!=0 & T2_expen_m5!=. 
replace transporte_T =. if transporte_T>1 

gen 	terapias_T = T2_expen_m5a_tera/totalExpenses if T2_expen_m5a_tera!=. & T2_expen_m5!=0 & T2_expen_m5!=. 
replace terapias_T =. if terapias_T>1 

gen 	instrum_T = T2_expen_m5a_inst/totalExpenses if T2_expen_m5a_inst!=. & T2_expen_m5!=0 & T2_expen_m5!=. 
replace instrum_T =. if instrum_T>1 


egen othersH = rowtotal(T2_expen_m5a_comp T2_expen_m5a_hosp T2_expen_m5a_cons T2_expen_m5a_vacu T2_expen_m5a_medi T2_expen_m5a_labo T2_expen_m5a_tera T2_expen_m5a_tran T2_expen_m5a_inst), missing
gen othersH_T= othersH/totalExpenses if othersH!=. 
replace othersH_T =. if othersH_T>1 


 
********************************************************************************

rename educacion educacionOLD
rename logincome logincomeOLD
rename kids_adults kids_adultsOLD
rename total_indiv total_indivOLD

gen     educacion=1 if educ_uptoSec==0 & educ_tert==0
replace educacion=2 if educ_uptoSec==1
replace educacion=3 if educ_tert==1

replace numcig=numcig/numadu
replace numcig=5000 if numcig>5000 & numcig<30000

gen numcigFUM=numcig if numcig>0
gen tabexpperFUM=tabexpper if numcig>0
gen tabexpperFUM_c=tabexpper_c if numcig>0
gen anycig=numcig>0
gen logincome=ln(persingr) if persingr>1000

recode zona 1=1 2=0
label def zona1 1 "Urbano" 0 "Rural"
label val zona zona1

la def female 1 "Female" 0 "Male"
la val female female
replace female=0 if female==1 & year==2017
replace female=1 if female==2 & year==2017

gen 	kids_adults=0
replace kids_adults=numnin/numadu if (numnin!=0 & numadu!=0)

egen 	total_indiv=rowtotal(numnin numadu)
*replace total_indiv=. if (numnin==. & numadu==.)

*gen 	kids_total=numnin/total_indiv if numnin!=.
gen 	adul_total=numadu/total_indiv if numadu!=.

recode sr_health (1/2=0 "Bueno/Muy bueno") (3/4=1 "Malo/Muy malo"), g(salud)
*drop mala_salud


replace educacion   = educacionOLD   if year==2017
replace logincome   = logincomeOLD   if year==2017
replace kids_adults = kids_adultsOLD if year==2017
replace total_indiv = total_indivOLD if year==2017
drop educacionOLD logincomeOLD kids_adultsOLD total_indivOLD

la var female "Gender (Female==1)"
la var educ_uptoPrim "Educ. Level (Primary)"
la var educ_uptoSec "Educ. Level (Secondary)"
la var educ_tert "Educ. Level (Tertiary)"
la var salud "Health Status (Bad/Very bad==1)"
la var zona "Zone (Urban==1)"
la var kids_adults "Ratio Kids/Adults"

xtile quint97=persgast if year==1997 & persgast!=. & (T1_expen_m1!=. & T2_expen_m3!=. & T2_expen_m5!=. & T2_expen_m6!=. & T2_expen_m7!=. & T2_expen_m8!=. & T2_expen_m9!=.), n(5)
xtile quint03=persgast if year==2003 & persgast!=. & (T1_expen_m1!=. & T2_expen_m3!=. & T2_expen_m5!=. & T2_expen_m6!=. & T2_expen_m7!=. & T2_expen_m8!=. & T2_expen_m9!=.), n(5)
xtile quint08=persgast if year==2008 & persgast!=. & (T1_expen_m1!=. & T2_expen_m3!=. & T2_expen_m5!=. & T2_expen_m6!=. & T2_expen_m7!=. & T2_expen_m8!=. & T2_expen_m9!=.), n(5)
xtile quint11=persgast if year==2011 & persgast!=. & (T1_expen_m1!=. & T2_expen_m3!=. & T2_expen_m5!=. & T2_expen_m6!=. & T2_expen_m7!=. & T2_expen_m8!=. & T2_expen_m9!=.), n(5)

gen 	quint = quint97 if year==1997
replace quint = quint03 if year==2003
replace quint = quint08 if year==2008
replace quint = quint11 if year==2011
replace quint = quint17 if year==2017
tab quint, g(qi_)


********************************************************************************
* DESCRIPTIVES
********************************************************************************				
if 1==0{
la def educ_uptoSec 0 "Below secondary" 1 "Up to secondary"
la val educ_uptoSec educ_uptoSec 
tab sr_health, gen(sr_health)
gen mala_salud=0 if sr_health!=.
replace mala_salud=1 if sr_health3==1 | sr_health4==1


* Characterization of the All HH
preserve
keep if year==1997 | year==2011
bys year: count 

table year , contents(mean edad) // Age
table year if edadg>1, contents(mean female) // Gender
table year , contents(mean educ_uptoPrim) // Education
table year , contents(mean educ_uptoSec) // Education
table year , contents(mean educ_tert) // Education
forval i=1(1)5{
table year , contents(mean q_`i') // Quintiles
}
table year  if edadg>1, contents(mean zona)  // Zone
table year  , contents(mean kids_adults)  // Ratio Kids_Adults
table year  , contents(mean total_indiv)  // Individuos
table year  , contents(mean logincome)  // Individuos

restore

* Descriptives of All HH with expenses info available
preserve 
keep if year==1997 | year==2011
keep if (T1_expen_m1!=. & T2_expen_m2!=. & T2_expen_m3!=. & T2_expen_m5!=. & T2_expen_m6!=. & T2_expen_m8!=. & T2_expen_m9!=.)
bys year: count 

table year , contents(mean edad) // Age
table year  if edadg>1, contents(mean female) // Gender
table year , contents(mean educ_uptoPrim) // Education
table year , contents(mean educ_uptoSec) // Education
table year , contents(mean educ_tert) // Education
forval i=1(1)5{
table year , contents(mean q_`i') // Quintiles
}
table year  if edadg>1, contents(mean zona)  // Zone
table year  , contents(mean kids_adults)  // Ratio Kids_Adults
table year  , contents(mean total_indiv)  // Individuos
table year  , contents(mean logincome)  // Individuos

restore

* Descriptives of All HH with expenses info available (Smokers - Non Smokers)
preserve
keep if year==1997 | year==2011
keep if (T1_expen_m1!=. & T2_expen_m2!=. & T2_expen_m3!=. & T2_expen_m5!=. & T2_expen_m6!=. & T2_expen_m8!=. & T2_expen_m9!=.)

rename smokers smokersOLD
 
gen smokers= (numcig>0)
bys year: count if smokers==1
bys year: count if smokers==0
gen nonsmokers=1-smokers

replace smokers=smokersOLD if year==2017
drop smokersOLD 

** Smokers
table year  if smokers==1, contents(mean edad) // Age
table year  if edadg>1 & smokers==1, contents(mean female) // Gender
table year  if smokers==1, contents(mean educ_uptoPrim) // Education
table year  if smokers==1, contents(mean educ_uptoSec) // Education
table year  if smokers==1, contents(mean educ_tert) // Education
forval i=1(1)5{
table year  if smokers==1, contents(mean q_`i') // Quintiles
}
table year  if edadg>1 & smokers==1, contents(mean zona)  // Zone
table year  if smokers==1, contents(mean kids_adults)  // Ratio Kids_Adults
table year  if smokers==1, contents(mean total_indiv)  // Individuos
table year  if smokers==1, contents(mean logincome)  // Individuos

** Non-smokers
table year  if smokers==0, contents(mean edad) // Age
table year  if edadg>1 & smokers==0, contents(mean female) // Gender
table year  if smokers==0, contents(mean educ_uptoPrim) // Education
table year  if smokers==0, contents(mean educ_uptoSec) // Education
table year  if smokers==0, contents(mean educ_tert) // Education
forval i=1(1)5{
table year  if smokers==0, contents(mean q_`i') // Quintiles
}
table year  if edadg>1 & smokers==0, contents(mean zona)  // Zone
table year  if smokers==0, contents(mean kids_adults)  // Ratio Kids_Adults
table year  if smokers==0, contents(mean total_indiv)  // Individuos
table year  if smokers==0, contents(mean logincome)  // Individuos

foreach i of num 1997 2011{
foreach varDep in edad female educ_uptoPrim educ_uptoSec educ_tert q_1 q_2 q_3 q_4 q_5 zona kids_adults total_indiv logincome {
disp in red "Este es `varDep' en `i'"
reg `varDep' smokers if year==`i'
}
}
restore

preserve
keep if (T1_expen_m1!=. & T2_expen_m2!=. & T2_expen_m3!=. & T2_expen_m5!=. & T2_expen_m6!=. & T2_expen_m8!=. & T2_expen_m9!=.)
gen All=1 
tempfile All
save `All'

use "$mainF\ECVrepeat\derived\ECVrepeat_BASE.dta", clear
append using `All' 
replace All=0 if All==.

foreach i of num 1997 2011{
foreach varDep in edad female educ_uptoPrim educ_uptoSec educ_tert q_1 q_2 q_3 q_4 q_5 zona kids_adults total_indiv logincome {
disp in red "Este es `varDep' en `i'"
reg `varDep' All if year==`i'
}
}

save "$mainF\ECVrepeat\derived\ECVrepeat_BASEComparacion.dta", replace
restore


if 1==0{
* Characterization of the smokers
table year [pw = fex] if numcig>0, contents(mean edad ) // Age
table year [pw = fex] if (edadg>1 & numcig>0), contents(mean female) // Gender
table year [pw = fex] if (edadg>1 & numcig>0), contents(mean zona)  // Zone
table year [pw = fex] if numcig>0, contents(mean educ_uptoSec) // Education
table year [pw = fex] if numcig>0, contents(mean educ_uptoPrim) // Education
table year [pw = fex] if numcig>0, contents(mean educ_tert) 
table year [pw = fex] if numcig>0, contents(mean mala_salud) 

* Prevalence by characteristic
table edadg year [pw = fex], contents(mean anycig )  //Prevalence by age group 
table female year [pw = fex] if edadg>1, contents(mean anycig) 
table zona year [pw = fex] if edadg>1, contents(mean anycig) 
table educ_uptoSec year [pw = fex], contents(mean anycig) 
*table year educ_tert [pw = fex], contents(mean anycig) 



* Characterization by quintile (all sample)
table year quintile [pw = fex], contents(mean edad) 
table year quintile [pw = fex] if edadg>1, contents(mean female) 
table year quintile [pw = fex] if edadg>1, contents(mean zona)
table year quintile [pw = fex] if edadg>1, contents(mean educ_uptoSec)
*table year quintile [pw = fex] if edadg>1, contents(mean educ_tert)
table year quintile [pw = fex] if edadg>1, contents(mean mala_salud)

* Characterization by quintile (smokers)
table year quintile [pw = fex] if numcig>0, contents(mean edad) 
table year quintile [pw = fex] if edadg>1 & numcig>0, contents(mean female) 
table year quintile [pw = fex] if edadg>1 & numcig>0, contents(mean zona)
table year quintile [pw = fex] if edadg>1 & numcig>0, contents(mean educ_uptoSec)
table year quintile [pw = fex] if edadg>1 & numcig>0 & year==1997, contents(mean educ_tert)
table year quintile [pw = fex] if edadg>1 & numcig>0, contents(mean educ_tert)
table year quintile [pw = fex] if edadg>1 & numcig>0, contents(mean educ_uptoPrim)
table year quintile [pw = fex] if edadg>1 & numcig>0 & year==2011, contents(mean educ_uptoPrim)
table year quintile [pw = fex] if edadg>1 & numcig>0, contents(mean mala_salud)


* Prevalence by characteristic
table edadg quintile [pw = fex], contents(mean anycig)  //Prevalence by age group and quintile 
table female quintile [pw = fex], contents(mean anycig)  //Prevalence by gender and quintile 
table zona quintile [pw = fex], contents(mean anycig)  //Prevalence by zone and quintile 
table educ_uptoSec quintile [pw = fex], contents(mean anycig)  //Prevalence by terciary education and quintile 
*table educ_tert quintile [pw = fex], contents(mean anycig)  //Prevalence by terciary education and quintile 
table mala_salud quintile [pw = fex], contents(mean anycig)  //Prevalence by health status and quintile 


* Prevalence by characteristic and year
table edadg quintile [pw = fex] if year==1997, contents(mean anycig )  //Prevalence by age group and quintile - 1997 
table edadg quintile [pw = fex] if year==2011, contents(mean anycig )  //Prevalence by age group and quintile - 2011

table female quintile [pw = fex] if year==1997, contents(mean anycig)  //Prevalence by gender and quintile 
table female quintile [pw = fex] if year==2011, contents(mean anycig)  //Prevalence by gender and quintile 

table zona quintile [pw = fex] if year==1997, contents(mean anycig)  //Prevalence by zone and quintile 
table zona quintile [pw = fex] if year==2011, contents(mean anycig)  //Prevalence by zone and quintile 

table educ_uptoSec quintile [pw = fex] if year==1997, contents(mean anycig)  //Prevalence by terciary education and quintile 
table educ_uptoSec quintile [pw = fex] if year==2011, contents(mean anycig)  //Prevalence by terciary education and quintile 

table educ_tert quintile [pw = fex] if edadg>1 & numcig>0 & year==1997, contents(mean anycig)
table educ_tert quintile [pw = fex] if edadg>1 & numcig>0 & year==2011, contents(mean anycig)
table educ_uptoPrim quintile [pw = fex] if edadg>1 & numcig>0 & year==1997, contents(mean anycig)
table educ_uptoPrim quintile [pw = fex] if edadg>1 & numcig>0 & year==2011, contents(mean anycig)

table mala_salud quintile [pw = fex] if year==1997, contents(mean anycig)  //Prevalence by health status and quintile 
table mala_salud quintile [pw = fex] if year==2011, contents(mean anycig)  //Prevalence by health status and quintile 

forvalues i=1/9 {
*table year region_`i' [pweight = fex], contents(mean anycig )
table year quintile [pw = fex] if region_`i'==1, contents(mean anycig )
}
*

foreach i in 1 2 3 4 ///
{
table year [pweight = fex], contents(mean sr_health`i') 
table year [pweight = fex] if numcig>0, contents(mean sr_health`i') 
table year quintile [pweight = fex] if sr_health`i'==1, contents(mean anycig )
}
*

*Smokers and Non-Smokers
table quintile year [pw = fex] if anycig!=0, contents(mean edad ) // Age Smokers
table quintile year [pw = fex] if anycig==0, contents(mean edad ) // Age Non-Smokers

table quintile year [pw = fex] if (edadg1>1 & anycig!=0), contents(mean female) // Gender Smokers
table quintile year [pw = fex] if (edadg1>1 & anycig==0), contents(mean female) // Gender Non-Smokers

table quintile year [pw = fex] if (edadg1>1 & anycig!=0), contents(mean zona)  // Zone
table quintile year [pw = fex] if (edadg1>1 & anycig==0), contents(mean zona)  // Zone

table quintile year [pw = fex] if anycig!=0, contents(mean educ_uptoSec) // Education
table quintile year [pw = fex] if anycig==0, contents(mean educ_uptoSec) // Education

table quintile year [pw = fex] if anycig!=0, contents(mean educ_tert) // Education
table quintile year [pw = fex] if anycig==0, contents(mean educ_tert) // Education

*table year [pw = fex], contents(mean educ_tert) 
table year [pw = fex], contents(mean mala_salud) 
}


********************************************************************************	
label var numcigFUM "Cig. consumed"
*label var LnumcigFUM "Cig. consumed (precio bajo)"
*label var UnumcigFUM "Cig. consumed (precio alto)"
label var persgast "HH Consumption"
	
	loc i=1
	foreach y in 1997 2008 2011 2017 {
		qui conindex numcigFUM if year==`y' [pw=fex], rankvar(persgast)  truezero graph
		loc CI   : disp %3.2f r(CI)
		loc CIse : disp %3.2f r(CIse)
		graph rename a`i', replace
		gr_edit .title.text.Arrpush "`y'"
		gr_edit .subtitle.text.Arrpush "CI: `CI' (`CIse')"
		loc i=1+`i'
	}
	graph combine a1 a2 a3, scheme(plotplain) cols(2) rows(2)
graph export "$mainE\document\images\Tobacco_CI.pdf", as(pdf) replace
graph export "$mainE\document\images\Tobacco_CI.png", as(png) replace
									
table year quintile [pweight = fex], contents(mean numcigFUM ) // Pero los que queda son los que mas fuman
						

}

********************************************************************************
* CREAR LOS PESOS DEL MATCHING
********************************************************************************

rename smokers smokersOLD
 gen smokers= (numcig>0)
replace smokers=smokersOLD if year==2017
drop smokersOLD	
		
tabstat T1_expen_m1 T2_expen_m3 T2_expen_m5 T2_expen_m6 T2_expen_m7 T2_expen_m8 T2_expen_m9 if smokers==1, by(year)
tabstat T1_expen_m1 T2_expen_m3 T2_expen_m5 T2_expen_m6 T2_expen_m7 T2_expen_m8 T2_expen_m9 if smokers==0, by(year)
tabstat edad female educacion quint zona kids_adults total_indiv if smokers==1 , by(year)
tabstat edad female educacion quint zona kids_adults total_indiv if smokers==0, by(year)



	keep if (T1_expen_m1!=. & T2_expen_m3!=. & T2_expen_m5!=. & T2_expen_m9!=.) 
	svyset id [pw=fex], strata(depto)
	gen I_time  = (year==2011) & !mi(year)
	*tab quintile, gen(d_quintile)
	*glo controls=" c.edad female i.educacion i.quint zona c.numnin c.numadu logincome" // 
	*glo controls1=" c.edad female i.educacion i.quint zona adul_total logincome" //
	glo controls2=" c.edad female i.educacion i.quint zona kids_adults total_indiv" //
	tab educacion, g(ed_)
	
	*ssc install psmatch2
	gen I_fum2011= (numcig>0 & year==2011)
	
	

	reg smokers $controls2 i.year
	keep if e(sample)==1
	*sample 5 , by(year smokers)
	
	drop if year==2017 // No vamos a usar finalmente esta encuesta; demasiados problemas de comparabilidad 09/07/2021
	
save "$mainF\derived\ECVrepeat_preMatch.dta", replace	

