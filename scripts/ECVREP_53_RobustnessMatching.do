* Author: Paul Rodriguez (paul.rodriguez@urosario.edu.co)
* Date: 2024.03.26
* Goal: En esta version realizamos un OLS y un PSM tradicional, para comparar
*       con el genetic matching

if "`c(username)'"=="paul.rodriguez" {
	glo mainE="D:\Paul.Rodriguez\Dropbox\tabaco\tabacoDrive\tobacco-health-inequalities" //Paul
}
else {
	*glo mainE="C:\Users\\`c(username)'\Dropbox\tabacoDrive\Tobacco-health-inequalities" // Susana
	glo mainE="C:\Users\\`c(username)'\Dropbox\tabaco\tabacoDrive\tobacco-health-inequalities" // Paul	
}

glo mainF="$mainE\procesamiento\derived" // Susana

////////////////////////////////////////////////////////////////////////////////


*------------------------------------------------------------------------------*
						** ORDENAR LA BASE DE DATOS **
*------------------------------------------------------------------------------*
if 1==0 {

	
	* **************************************************************************
	* Kernel matching
	use "$mainF\ECVrepeat_preMatch.dta", clear	
	rename quint quin
	gen treat = year==2011 & smokers==1
	gen kernelweight=1 if treat==1
	
	foreach anio in 1997 2003 2008 2011 {
		foreach qui in 1 2 3 4 5 {
			foreach sm in 0 1 {
				if !(`sm'==1 & `anio'==2011){  // No se hace matching de los fumadores de 2011 con ellos mismos
				
				*loc anio=1997
				*loc qui=1
				*loc sm=0
				
				psmatch2 treat total_indiv zona edad female kids_adults ed_1 ed_2  	///
					if quin==`qui' & ( treat==1 | (year==`anio' & smokers==`sm') )	///
					, kernel common
				replace kernelweight= _weight if kernelweight==.
				
				}
			}
		}		
	}
	

	cap drop matching_*
	keep if (T1_expen_m1!=. & T2_expen_m3!=. & T2_expen_m5!=. & T2_expen_m9!=.) // & T2_expen_m6!=. & T2_expen_m7!=. & T2_expen_m8!=. ; estos no necesiramente los resportan todos los hogares

	* Fix ......................
	drop I_time
	gen  I_time=.
	replace I_time  = (year==2011) & !mi(year) if year==1997 |  year==2011 // Por alguna razon, no estaba bien definido antes
	drop qi_1- qi_5
	cap drop quint
	rename quin quint
	tab quint, g(qi_)
	* ........................

	gen nonsmokers=1-smokers
	rename zona urban
	gen rural=1-urban
	gen male=1-female

	recode auto_health (0/1=0 "Bad")(2/3=1 "Good"), g(good_health)
	gen bad_health=1-good_health

	cap drop othersH*
	egen affiliationComp = rowtotal(T2_expen_m5a_afil T2_expen_m5a_comp), missing
	gen affiliationComp_T=affiliationComp/totalExpenses if affiliationComp!=. 
	egen othersH = rowtotal(T2_expen_m5a_hosp T2_expen_m5a_cons T2_expen_m5a_vacu T2_expen_m5a_medi T2_expen_m5a_labo T2_expen_m5a_tran T2_expen_m5a_tera T2_expen_m5a_inst), missing
	gen othersH_T= othersH/totalExpenses  if othersH!=. 


	la var urban "Zone (Urban=1)"
	la var kids_adults "Ratio children-under-5/adults"

	la var edad "Age"
	la var educ_uptoPrim "Primary School" 
	la var educ_uptoSec "Secondary School" 
	la var educ_tert "Tertiary education"
	
	label var ed_1 "Primary school"
	label var ed_2 "Secondary school"
	label var ed_3 "Tertiary school"	
	
	forval i=1(1)5{
		la var qi_`i' "Quintile `i'"
	}
	la var total_indiv "Total individuals"
	la var logincome "ln(Income)"

	* Versión con gastos de tabaco .........

		gen share_alimentos_tot	= alimExpenses/totalExpenses if totalExpenses!=. & alimExpenses!=. 
		gen share_tabaco_tot	= tabacoExpenses/totalExpenses if totalExpenses!=. & tabacoExpenses!=. 
		gen share_alcoh_tot		= alcoholExpenses/totalExpenses if totalExpenses!=. & alcoholExpenses!=. 
		gen share_ropa_tot		= T2_expen_m2/totalExpenses if totalExpenses!=. 
		gen share_vivienda_tot	= T2_expen_m3/totalExpenses if totalExpenses!=. & T2_expen_m3!=.
		gen share_muebles_tot	= T2_expen_m4/totalExpenses if totalExpenses!=. & T2_expen_m4!=.
		gen share_salud_tot		= T2_expen_m5/totalExpenses if totalExpenses!=. & T2_expen_m5!=.
		gen share_affil_tot		= affiliationComp/totalExpenses if totalExpenses!=. & affiliationComp!=.
		gen share_othersH_tot	= othersH/totalExpenses if totalExpenses!=. & othersH!=.
		gen share_transporte_tot= T2_expen_m6/totalExpenses if totalExpenses!=. & T2_expen_m6!=.
		gen share_cultura_tot	= T2_expen_m7/totalExpenses if totalExpenses!=. & T2_expen_m7!=.
		gen share_educac_tot	= T2_expen_m8/totalExpenses if totalExpenses!=. & T2_expen_m8!=.
		gen share_otros			= T2_expen_m9/totalExpenses if totalExpenses!=. & T2_expen_m9!=.

	* Versión neta de gastos de tabaco .........
		gen Gasto_tot_neto=totalExpenses-tabacoExpenses if totalExpenses!=. & tabacoExpenses!=. 

		gen Porcent_alimentos_tot	= alimExpenses/Gasto_tot_neto if Gasto_tot_neto!=. & alimExpenses!=. 
		gen Porcent_tabaco_tot		= tabacoExpenses/Gasto_tot_neto if Gasto_tot_neto!=. & tabacoExpenses!=. 
		gen Porcent_alcoh_tot		= alcoholExpenses/Gasto_tot_neto if Gasto_tot_neto!=. & alcoholExpenses!=. 
		gen Porcent_ropa_tot		= T2_expen_m2/Gasto_tot_neto if Gasto_tot_neto!=. 
		gen Porcent_vivienda_tot	= T2_expen_m3/Gasto_tot_neto if Gasto_tot_neto!=. & T2_expen_m3!=.
		gen Porcent_muebles_tot		= T2_expen_m4/Gasto_tot_neto if Gasto_tot_neto!=. & T2_expen_m4!=.
		gen Porcent_salud_tot		= T2_expen_m5/Gasto_tot_neto if Gasto_tot_neto!=. & T2_expen_m5!=.
		gen Porcent_affil_tot		= affiliationComp/Gasto_tot_neto if Gasto_tot_neto !=. & affiliationComp!=.
		gen Porcent_othersH_tot		= othersH/Gasto_tot_neto if Gasto_tot_neto !=. & othersH!=.
		gen Porcent_transporte_tot	= T2_expen_m6/Gasto_tot_neto if Gasto_tot_neto!=. & T2_expen_m6!=.
		gen Porcent_cultura_tot		= T2_expen_m7/Gasto_tot_neto if Gasto_tot_neto!=. & T2_expen_m7!=.
		gen Porcent_educac_tot		= T2_expen_m8/Gasto_tot_neto if Gasto_tot_neto!=. & T2_expen_m8!=.
		gen Porcent_otros			= T2_expen_m9/Gasto_tot_neto if Gasto_tot_neto!=. & T2_expen_m9!=.

		
		rename female SEXO
		la var SEXO "Gender (Female=1)"

		gen GASTO2 = totalExpenses^2
		gen lnGASTO2 = ln(totalExpenses)^2
		gen lnGASTO = ln(totalExpenses)

		*expand FE
		gen EDAD2 = edad^2
		gen lnEDAD =ln(edad)
		egen PromEdad = mean(edad) // No se que sera esto en el codigo de Guillermo 

		*gen lnEDUE = ln(EDUE) // No se que sera esto en el codigo de Guillermo, tal vez se refiera a anos de escolaridad, nosotros tenemos niveles
		gen lnNPERSONA = ln(total_indiv) 


		qui tab educacion, g(educacion)
		glo het lnNPERSONA SEXO edad EDAD2 educacion1 educacion2 educacion3

		foreach var in $het{
			su `var'
			gen het_`var'=(`var' - r(mean))*tabac01
			}
			
	glo demo 	"tabac01 lnGASTO lnGASTO2 lnNPERSONA SEXO edad EDAD2 educacion1 educacion2"
	glo demo2 	"tabac01 lnGASTO lnGASTO2 lnNPERSONA SEXO lnEDAD"

	save "$mainF\ECVrepeat_robustness.dta", replace
		
}
*

********************************************************************************				
// Balance del Matching
********************************************************************************
if 1==0 {
	

	use "$mainF/ECVrepeat_robustness.dta", clear
	
	gen yearB= year==2011 & smokers==1
	

	glo matchvar "edad SEXO ed_1 ed_2 ed_3 urban kids_adults total_indiv"
	glo annios 1997 2003 2008 2011
	glo nY : word count $annios
	glo nY1= $nY*2+2

	cd 
	cap texdoc close
	texdoc init "Sample_balance_kernel", replace force
	
	tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}		
	tex \begin{table}[H]
	tex \centering
	tex \scriptsize		
	tex \caption{Matching Sample Balance \label{tab:sample_balance_kernel}}
	
	tex \begin{adjustbox}{max width=1.03\textwidth}
	
	loc cols="l"
	foreach i in $annios {
		loc cols="`cols'll"
	}
	
	tex \begin{tabular}{l`cols'}			
	tex \toprule		
	
	tex & 
	foreach yeo in $annios {
		tex & \multicolumn{2}{c}{`yeo'} 
	}		
	tex \\
	
	tex Variable & Sample 
	foreach yeo in $annios {
		tex & Smoker & Non-Smoker
	}		
	tex 		
	tex \\
	
	tex \cmidrule(l){1-2}
	loc i1=3
	foreach yeo in $annios {
		loc i2 = `i1'+1
		tex \cmidrule(l){`i1'-`i2'}
		loc i1 = `i2'+1
	}		
		
	foreach varDep in  $matchvar {
		local labelo : variable label `varDep'		
		loc line1 =""
		loc line2 =""
		foreach yeo in $annios {
			qui {
				
				* No matching ..................................................
				* Smokers ...................
				cap reg `varDep' yearB qi_2 qi_3 qi_4 qi_5 if  ((smokers==1) & year==`yeo') | (smokers==1 & year==2011)  ,r 
				if _rc==0 {
					local difnm : di %7.3f _b[yearB]
					local difsenm : di %7.3f _se[yearB]			
					local tbefnm = _b[yearB]/_se[yearB]
					local pbefnm = 2*ttail(e(df_r),abs(`tbefnm'))	
					
					local starunm = ""
					if ((`pbefnm' < 0.1) )  local starunm = "*" 
					if ((`pbefnm' < 0.05) ) local starunm = "**" 
					if ((`pbefnm' < 0.01) ) local starunm = "***" 
					
					mean `varDep'  if (smokers==1 & year==`yeo')
					mat A=r(table)
					loc v1nm : di %7.3f A[1,1]				
					
					loc line1 = " `line1' & `v1nm'`starunm' "		
				}
				else {
					loc line1 = " `line1' & "		
				}
				* Non Smokers ...................
				cap reg `varDep' yearB qi_2 qi_3 qi_4 qi_5 if  ((smokers==0) & year==`yeo') | (smokers==1 & year==2011)  ,r 
				if _rc==0 {
					local difnm : di %7.3f _b[yearB]
					local difsenm : di %7.3f _se[yearB]			
					local tbefnm = _b[yearB]/_se[yearB]
					local pbefnm = 2*ttail(e(df_r),abs(`tbefnm'))	
					
					local starunm = ""
					if ((`pbefnm' < 0.1) )  local starunm = "*" 
					if ((`pbefnm' < 0.05) ) local starunm = "**" 
					if ((`pbefnm' < 0.01) ) local starunm = "***" 

					
					mean `varDep'  if (smokers==0 & year==`yeo')
					mat A=r(table)
					loc v0nm : di %7.3f A[1,1]		
					
					loc line1 = " `line1' & `v0nm'`starunm' "		
				}
				else {
					loc line1 = " `line1' & "		
				}				
				

				* With matching ..................................................
				* Smokers............................
				cap reg `varDep' yearB qi_2 qi_3 qi_4 qi_5 [aw=kernelweight] if  ((smokers==1) & year==`yeo') | (smokers==1 & year==2011)  ,r 
				if (_rc==0 & `yeo'!=2011 ) {
					local difm : di %7.3f _b[yearB]
					local difsem : di %7.3f _se[yearB]			
					local tbefm = _b[yearB]/_se[yearB]
					local pbefm = 2*ttail(e(df_r),abs(`tbefm'))					
					
					local starum = ""
					if ((`pbefm' < 0.1) )  local starum = "*" 
					if ((`pbefm' < 0.05) ) local starum = "**" 
					if ((`pbefm' < 0.01) ) local starum = "***" 
					
					mean `varDep' [aw=kernelweight] if (smokers==1 & year==`yeo')
					mat A=r(table)
					loc v1m : di %7.3f A[1,1]				
					
					loc line2 = " `line2' & `v1m'`starum' "					
				}
				else {
					loc line2 = " `line2' & "		
				}
				* Non-Smokers............................
				cap reg `varDep' yearB qi_2 qi_3 qi_4 qi_5 [aw=kernelweight] if  (( smokers==0) & year==`yeo') | ( smokers==1 & year==2011)  ,r 
				if (_rc==0) {
					local difm : di %7.3f _b[yearB]
					local difsem : di %7.3f _se[yearB]			
					local tbefm = _b[yearB]/_se[yearB]
					local pbefm = 2*ttail(e(df_r),abs(`tbefm'))					
					
					local starum = ""
					if ((`pbefm' < 0.1) )  local starum = "*" 
					if ((`pbefm' < 0.05) ) local starum = "**" 
					if ((`pbefm' < 0.01) ) local starum = "***" 
					
					mean `varDep' [aw=kernelweight] if ( smokers==0 & year==`yeo')
					mat A=r(table)
					loc v0m : di %7.3f A[1,1]					
					
					loc line2 = " `line2' & `v0m'`starum' "					
				}
				else {
					loc line2 = " `line2' & "		
				}				

			}
		}
		disp "tex \parbox[l]{3cm}{`labelo'} & Non-matched `line1' \\"
		disp "tex                           & Matched     `line2' \\"
		
		tex \parbox[l]{3cm}{`labelo'} & NM `line1' \\
		tex                           & M     `line2' \\
	}	
		
	tex \bottomrule
	tex \addlinespace	
	tex \multicolumn{$nY1}{l}{\parbox[l]{19cm}{ \textit{Notes:} Per variable, the first 
	    tex row corresponds to the sample without matching (NM), and the second
		tex to the matched sample (M). Genetic matching with the propensity score, with one neighbor,
		tex population size of the optimizer of 1000, and a caliper of 0.26.
		tex Significance of t-test between smokers of each year, and smokers of 2011: * 10\%, ** 5\%, *** 1\%.  }} \\
	tex \end{tabular}
	tex \end{adjustbox}
	tex \end{table}	
	texdoc close	
		
}

////////////////////////////////////////////////////////////////////////////////
// Resultados con el kernel matching
////////////////////////////////////////////////////////////////////////////////
if 1==1{
	
	cd "$mainE\document\tables\SEM"

	use "$mainF\ECVrepeat_robustness.dta", clear
	glo controles5 "lnGASTO lnGASTO2 lnEDAD SEXO ed_2 ed_3 urban kids_adults total_indiv logincome"

/* Con los gastos netos de tabaco
	rename Porcent_alimentos_tot 	Food1
	rename Porcent_tabaco_tot 		Tobacco
	rename Porcent_alcoh_tot 		Alcohol
	rename Porcent_ropa_tot 		Clothing
	rename Porcent_vivienda_tot		Housing
	rename Porcent_salud_tot 		Health
	rename Porcent_affil_tot		Affiliation
	rename Porcent_othersH_tot		HealthO
	rename Porcent_educac_tot  		Education
	rename Porcent_transporte_tot 	Transport
	rename Porcent_otros			Others
*/	
	rename share_alimentos_tot 	Food
	rename share_tabaco_tot 	Tobacco
	rename share_alcoh_tot 		Alcohol
	rename share_ropa_tot 		Clothing
	rename share_vivienda_tot	Housing
	rename share_salud_tot 		Health
	rename share_affil_tot		Affiliation
	rename share_othersH_tot	HealthO
	rename share_educac_tot  	Education
	rename share_transporte_tot Transport
	rename share_otros			Others


	global list1  	Alcohol		Others  // Tobacco1 Affiliation1
	global list2  	Transport 	Housing 
	global list3 	Food  		Clothing 
	global list4 	Health 		Education
	
	glo annios 1997 2003 2008 2011
	glo nY : word count $annios
	glo nY1= $nY*4+1
	glo nYc= $nY*4
	
	
	foreach ver in NC C { // No controls, controls
		foreach y in $annios {
			forval ll=1(1)4 {		
				global listo`ll'`ver'_`y' =""
				foreach varDep in ${list`ll'} {
					global listo`ll'`ver'_`y' =" ${listo`ll'`ver'_`y'} `varDep'`ver'_`y' "
				}
			}
		}
	}
	
	* An example ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	reg Tobacco c.qi_2#c.smokers 		c.qi_3#c.smokers 		c.qi_4#c.smokers  	 c.qi_5#c.smokers		 ///
				 c.qi_2#c.nonsmokers 	c.qi_3#c.nonsmokers 	c.qi_4#c.nonsmokers  c.qi_5#c.nonsmokers	 ///
				 nonsmokers smokers $controles5 [aw=kernelweight] if year==1997 , nocons
				
	* ~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	foreach y in $annios {
		forval ll=1(1)4 { // Which list of variables
			foreach varDep in ${list`ll'} {
				qui	reg `varDep' c.qi_2#c.smokers 		c.qi_3#c.smokers 		c.qi_4#c.smokers  	 c.qi_5#c.smokers		 ///
								 c.qi_2#c.nonsmokers 	c.qi_3#c.nonsmokers 	c.qi_4#c.nonsmokers  c.qi_5#c.nonsmokers	 ///
								 nonsmokers smokers $controles5 [aw=kernelweight] if year==`y' , nocons	
				est store `varDep'C_`y'
			}
		}
	}
	
	// Now, get the main results for the table
	cap mat drop bigResults
	loc vl=1
	foreach ver in C  { // controls , No controls
		foreach y in $annios {
			qui suest ${listo1`ver'_`y'}  ${listo2`ver'_`y'} ${listo3`ver'_`y'} ${listo4`ver'_`y'} //, vce(r)
			forval ll=1(1)4 { // Which list of variables
				loc wl=1
				foreach varDep in ${listo`ll'`ver'_`y'}  { // Which dependent variable
					forval qq=5(1)5 { // which quintile
					
						local beta_smok :di %7.3f  _b[`varDep'_mean:c.qi_`qq'#c.smoker]
						local beta_nsmo :di %7.3f  _b[`varDep'_mean:c.qi_`qq'#c.nonsmoker]
						local difse_smok:di %7.3f _se[`varDep'_mean:c.qi_`qq'#c.smoker]
						local difse_nsmo:di %7.3f _se[`varDep'_mean:c.qi_`qq'#c.nonsmoker]

						local tbef_smok = _b[`varDep'_mean:c.qi_`qq'#c.smoker]   /_se[`varDep'_mean:c.qi_`qq'#c.smoker]
						local tbef_nsmo = _b[`varDep'_mean:c.qi_`qq'#c.nonsmoker]/_se[`varDep'_mean:c.qi_`qq'#c.nonsmoker]
						local df_smok	= e(N)-e(rank)
						local pbef_smok = 2*ttail(`df_smok',abs(`tbef_smok'))	
						local pbef_nsmo = 2*ttail(`df_smok',abs(`tbef_nsmo'))	
						
						qui test [`varDep'_mean]c.qi_`qq'#c.smokers=[`varDep'_mean]c.qi_`qq'#c.nonsmokers
						local dif :di %7.4f [`varDep'_mean]c.qi_`qq'#c.smokers - [`varDep'_mean]c.qi_`qq'#c.nonsmokers
						local chi :di %7.3f r(chi2)
						local pval:di %7.3f r(p)			
						
						mat resu = [`vl',`y',`ll',`wl',`qq',`beta_smok',`difse_smok',`pbef_smok',`beta_nsmo',`difse_nsmo',`pbef_nsmo',`dif',`pval' ]
						mat bigResults =nullmat(bigResults) \ resu
						
					}
					// Constants (mean quintile 1)
					local beta_smok :di %7.3f  _b[`varDep'_mean:smoker]
					local beta_nsmo :di %7.3f  _b[`varDep'_mean:nonsmoker]
					local difse_smok:di %7.3f _se[`varDep'_mean:smoker]
					local difse_nsmo:di %7.3f _se[`varDep'_mean:nonsmoker]

					local tbef_smok = _b[`varDep'_mean:c.smoker]   /_se[`varDep'_mean:c.smoker]
					local tbef_nsmo = _b[`varDep'_mean:c.nonsmoker]/_se[`varDep'_mean:c.nonsmoker]
					local df_smok	= e(N)-e(rank)
					local pbef_smok = 2*ttail(`df_smok',abs(`tbef_smok'))	
					local pbef_nsmo = 2*ttail(`df_smok',abs(`tbef_nsmo'))	
					
					qui test [`varDep'_mean]c.smokers=[`varDep'_mean]c.nonsmokers
					local dif :di %7.4f [`varDep'_mean]c.smokers - [`varDep'_mean]c.nonsmokers
					local chi :di %7.3f r(chi2)
					local pval:di %7.3f r(p)			
					
					mat resu = [`vl',`y',`ll',`wl',0,`beta_smok',`difse_smok',`pbef_smok',`beta_nsmo',`difse_nsmo',`pbef_nsmo',`dif',`pval' ]
					mat bigResults =nullmat(bigResults) \ resu					
									
					loc wl=`wl'+1  // variable counter
				}
			}
		}
		loc vl=`vl'+1
	}
	mat colname bigResults = Version Year List Variable Quintile beta_smok difse_smok pbef_smok beta_nsmo difse_nsmo pbef_nsmo dif pval
	mat list bigResults
	svmat bigResults, names(col)

	// Resultados - Coeficientes y pruebas de hipotesis 
	if 1==1 {
		cap texdoc close
		texdoc init Table3X_kernel, replace force
		tex {
		tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}		
		tex \begin{table}[H]
		tex \centering
		tex \scriptsize		
		tex \caption{ SUR Estimates for variation on shares between smokers and non-smokers \label{tab:SUR_kernel}}
		tex \begin{adjustbox}{max totalheight=1.1\textheight, max width=1\textwidth,keepaspectratio}
		tex \begin{tabular}{l*{$nYc}{c}}			
		tex \toprule	
						
		forval ll=1(1)4 { // Which list
			glo linea0a=""
			glo linea0b=""
			glo linea0c=""
			forval io=1(1)$nYc {
				glo linea`io'=""
			}
		
			loc wl=1
			
			loc c=2 // For the columns counter
			foreach varDep in ${list`ll'}  { // Which dependent variable
				disp "`varDep'"
				loc vl=1 // Only the "C" version
				
				loc qq=5 // Only Quintile 5
				glo linea0a="$linea0a & \multicolumn{$nY}{c}{`varDep'}"
				
				loc c1=`c'+$nY-1
				glo linea0c="$linea0c \cmidrule(l){`c'-`c1'} "
				
				foreach y in $annios {
					loc ver = "`y'"				

					glo linea0b="$linea0b & `ver' "
					
					// Constant for smokers
										
					qui reg `varDep' smokers nonsmoker [aw=kernelweight] if year==`y' & qi_1==1, nocon
					local beta_smok :di %7.3f  _b[smoker]
					local beta_nsmo :di %7.3f  _b[nonsmoker]
					local difse_smok:di %7.3f _se[smoker]
					local difse_nsmo:di %7.3f _se[nonsmoker]

					loc valo :di %7.3f `beta_smok'
					glo linea1="$linea1 & `valo'"

					loc valo :di %7.3f `difse_smok'
					glo linea2="$linea2 & (`valo') "						
					
					loc valo :di %7.3f `beta_nsmo'
					glo linea5="$linea5 & `valo'"

					loc valo :di %7.3f `difse_nsmo'
					glo linea6="$linea6 & (`valo') "					
					
					/*
					qui sum pbef_smok if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==0 & Year==`y'
					loc valo=r(mean)
					local staru = ""
					if ((`valo' < 0.1) )  local staru_s = "*" 
					if ((`valo' < 0.05) )  local staru_s = "**" 
					if ((`valo' < 0.01) )  local staru_s = "***" 					
					
					qui sum beta_smok if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==0 & Year==`y'
					loc valo :di %7.3f r(mean)
					glo linea1="$linea1 & `valo'" //`staru_s' "

					qui sum difse_smok if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==0 & Year==`y'
					loc valo :di %7.3f r(mean)
					glo linea2="$linea2 & (`valo') "					
					*/
					
					// Coefficients Q1 vs Q5 for smokers ................................
					qui sum pbef_smok if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==`qq' & Year==`y'
					loc valo=r(mean)
					local staru = ""
					if ((`valo' < 0.1) )  local staru_s = "*" 
					if ((`valo' < 0.05) )  local staru_s = "**" 
					if ((`valo' < 0.01) )  local staru_s = "***" 					
					
					qui sum beta_smok if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==`qq' & Year==`y'
					loc valo :di %7.3f r(mean)
					glo linea3="$linea3 & `valo'" //`staru_s' "

					qui sum difse_smok if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==`qq' & Year==`y'
					loc valo :di %7.3f r(mean)
					glo linea4="$linea4 & (`valo') "	
				
					// Coefficients Q1 vs Q5 for non-smokers ............................
					qui sum pbef_nsmo if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==`qq' & Year==`y'
					loc valo=r(mean)
					local staru = ""
					if ((`valo' < 0.1) )  local staru_s = "*" 
					if ((`valo' < 0.05) )  local staru_s = "**" 
					if ((`valo' < 0.01) )  local staru_s = "***" 					
					
					qui sum beta_nsmo if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==`qq' & Year==`y'
					loc valo :di %7.3f r(mean)
					glo linea7="$linea7 & `valo'" //`staru_s' "

					qui sum difse_nsmo if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==`qq' & Year==`y'
					loc valo :di %7.3f r(mean)
					glo linea8="$linea8 & (`valo') "						
					
					// Test 1 lines (means) ............................................
					qui sum dif if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==0 & Year==`y'
					loc valo :di %7.3f r(mean)
					glo linea9="$linea9 & `valo'"

					qui sum pval if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==0 & Year==`y'
					loc valo :di %7.3f r(mean)
					glo linea10="$linea10 & `valo' "			
					
					// Test 2 lines (gradient) ............................................
					qui sum dif if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==`qq' & Year==`y'
					loc valo :di %7.3f r(mean)
					glo linea11 ="$linea11 & `valo' "
					
					qui sum pval if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==`qq' & Year==`y'
					loc valo :di %7.3f r(mean)
					glo linea12="$linea12 & `valo' "						
					// .........................................................
					
				
					loc c=`c1'+1 // For the columns counter
				}	
				loc wl=`wl'+1 // Variable counter		
				
			}
			
			tex \textbf{Variable}   $linea0a \\
			tex  					$linea0b \\
			tex   					$linea0c 
			tex \parbox[l]{5.5cm}{A: Q1 Smokers Share } 	$linea1 \\ 
			tex                           						$linea2 \\			
			tex \parbox[l]{5.5cm}{B: Q5 vs Q1 smokers share: Q_{`qq'}^{(l)} \cdot s_{it}} 	$linea3 \\ 
			tex                           						$linea4 \\
			tex \parbox[l]{5.5cm}{C: Q1 Non-smokers Share } $linea5 \\
			tex                           		  			    $linea6 \\
			tex \parbox[l]{5.5cm}{D: Q5 vs Q1 non-smokers share: Q_{`qq'}^{(l)} \cdot ns_{it} } $linea7 \\
			tex                           		  			    $linea8 \\
			tex \addlinespace[2pt]
			tex   					$linea0c 
			tex E: Share difference smok. vs non-smok. Q1  $linea9 \\
			tex $ \quad$ p-val     $linea10 \\			
			tex F: Gradient difference smok. vs non-smok. Q1  $linea11 \\
			tex $ \quad$ p-val     $linea12 \\
			tex \midrule
		}
			
		tex \multicolumn{$nY1}{l}{\parbox[l]{17.5cm}{\textit{Notes:} Robust standard errors in parentheses. This table summarises the main results  with total expenditure net of expenditure on tobacco. ///
			Each set of columns correspond to a category of spending per year. In each year, the unconditional shares for smokers ///
			and non-smokers from quintile 1 are presented (rows A and C), as well as the difference of these shares for quintile 5 ///
			which correspond to equation 1 estimated coefficients conditional on controls (rows B and D). Below them, there are two ///
			tests that compare the previous numbers between smokers and non-smokers (A - C, B - D), both of them computed with the ///
			estimates of equation 1. ///
			Controls include log-expenditures, squared log-expenditures, log-age, female dummy, education level, living in a urban area, ratio dis under 5 per adult, household size, and log-income.  /// //  
			/// // Controls include:  lnGASTO lnGASTO2 lnEDAD SEXO educacion2 educacion3 urban kidsadults totalindiv logincome.
			}} \\
		tex \end{tabular}
		tex \end{adjustbox}
		tex \end{table}
		tex }
		texdoc close	

	}					
}

////////////////////////////////////////////////////////////////////////////////
// Resultados sin matching
////////////////////////////////////////////////////////////////////////////////
if 1==1{
	
	cd "$mainE\document\tables\SEM"

	use "$mainF\ECVrepeat_robustness.dta", clear
	glo controles5 "lnGASTO lnGASTO2 lnEDAD SEXO ed_2 ed_3 urban kids_adults total_indiv logincome"

/* Con los gastos netos de tabaco
	rename Porcent_alimentos_tot 	Food1
	rename Porcent_tabaco_tot 		Tobacco
	rename Porcent_alcoh_tot 		Alcohol
	rename Porcent_ropa_tot 		Clothing
	rename Porcent_vivienda_tot		Housing
	rename Porcent_salud_tot 		Health
	rename Porcent_affil_tot		Affiliation
	rename Porcent_othersH_tot		HealthO
	rename Porcent_educac_tot  		Education
	rename Porcent_transporte_tot 	Transport
	rename Porcent_otros			Others
*/	
	rename share_alimentos_tot 	Food
	rename share_tabaco_tot 	Tobacco
	rename share_alcoh_tot 		Alcohol
	rename share_ropa_tot 		Clothing
	rename share_vivienda_tot	Housing
	rename share_salud_tot 		Health
	rename share_affil_tot		Affiliation
	rename share_othersH_tot	HealthO
	rename share_educac_tot  	Education
	rename share_transporte_tot Transport
	rename share_otros			Others


	global list1  	Alcohol		Others  // Tobacco1 Affiliation1
	global list2  	Transport 	Housing 
	global list3 	Food  		Clothing 
	global list4 	Health 		Education
	
	glo annios 1997 2003 2008 2011
	glo nY : word count $annios
	glo nY1= $nY*4+1
	glo nYc= $nY*4
	
	
	foreach ver in NC C { // No controls, controls
		foreach y in $annios {
			forval ll=1(1)4 {		
				global listo`ll'`ver'_`y' =""
				foreach varDep in ${list`ll'} {
					global listo`ll'`ver'_`y' =" ${listo`ll'`ver'_`y'} `varDep'`ver'_`y' "
				}
			}
		}
	}
	
	* An example ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	reg Tobacco c.qi_2#c.smokers 		c.qi_3#c.smokers 		c.qi_4#c.smokers  	 c.qi_5#c.smokers		 ///
				 c.qi_2#c.nonsmokers 	c.qi_3#c.nonsmokers 	c.qi_4#c.nonsmokers  c.qi_5#c.nonsmokers	 ///
				 nonsmokers smokers $controles5  if year==1997 , nocons
				
	* ~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	foreach y in $annios {
		forval ll=1(1)4 { // Which list of variables
			foreach varDep in ${list`ll'} {
				qui	reg `varDep' c.qi_2#c.smokers 		c.qi_3#c.smokers 		c.qi_4#c.smokers  	 c.qi_5#c.smokers		 ///
								 c.qi_2#c.nonsmokers 	c.qi_3#c.nonsmokers 	c.qi_4#c.nonsmokers  c.qi_5#c.nonsmokers	 ///
								 nonsmokers smokers $controles5  if year==`y' , nocons	
				est store `varDep'C_`y'
			}
		}
	}
	
	// Now, get the main results for the table
	cap mat drop bigResults
	loc vl=1
	foreach ver in C  { // controls , No controls
		foreach y in $annios {
			qui suest ${listo1`ver'_`y'}  ${listo2`ver'_`y'} ${listo3`ver'_`y'} ${listo4`ver'_`y'} //, vce(r)
			forval ll=1(1)4 { // Which list of variables
				loc wl=1
				foreach varDep in ${listo`ll'`ver'_`y'}  { // Which dependent variable
					forval qq=5(1)5 { // which quintile
					
						local beta_smok :di %7.3f  _b[`varDep'_mean:c.qi_`qq'#c.smoker]
						local beta_nsmo :di %7.3f  _b[`varDep'_mean:c.qi_`qq'#c.nonsmoker]
						local difse_smok:di %7.3f _se[`varDep'_mean:c.qi_`qq'#c.smoker]
						local difse_nsmo:di %7.3f _se[`varDep'_mean:c.qi_`qq'#c.nonsmoker]

						local tbef_smok = _b[`varDep'_mean:c.qi_`qq'#c.smoker]   /_se[`varDep'_mean:c.qi_`qq'#c.smoker]
						local tbef_nsmo = _b[`varDep'_mean:c.qi_`qq'#c.nonsmoker]/_se[`varDep'_mean:c.qi_`qq'#c.nonsmoker]
						local df_smok	= e(N)-e(rank)
						local pbef_smok = 2*ttail(`df_smok',abs(`tbef_smok'))	
						local pbef_nsmo = 2*ttail(`df_smok',abs(`tbef_nsmo'))	
						
						qui test [`varDep'_mean]c.qi_`qq'#c.smokers=[`varDep'_mean]c.qi_`qq'#c.nonsmokers
						local dif :di %7.4f [`varDep'_mean]c.qi_`qq'#c.smokers - [`varDep'_mean]c.qi_`qq'#c.nonsmokers
						local chi :di %7.3f r(chi2)
						local pval:di %7.3f r(p)			
						
						mat resu = [`vl',`y',`ll',`wl',`qq',`beta_smok',`difse_smok',`pbef_smok',`beta_nsmo',`difse_nsmo',`pbef_nsmo',`dif',`pval' ]
						mat bigResults =nullmat(bigResults) \ resu
						
					}
					// Constants (mean quintile 1)
					local beta_smok :di %7.3f  _b[`varDep'_mean:smoker]
					local beta_nsmo :di %7.3f  _b[`varDep'_mean:nonsmoker]
					local difse_smok:di %7.3f _se[`varDep'_mean:smoker]
					local difse_nsmo:di %7.3f _se[`varDep'_mean:nonsmoker]

					local tbef_smok = _b[`varDep'_mean:c.smoker]   /_se[`varDep'_mean:c.smoker]
					local tbef_nsmo = _b[`varDep'_mean:c.nonsmoker]/_se[`varDep'_mean:c.nonsmoker]
					local df_smok	= e(N)-e(rank)
					local pbef_smok = 2*ttail(`df_smok',abs(`tbef_smok'))	
					local pbef_nsmo = 2*ttail(`df_smok',abs(`tbef_nsmo'))	
					
					qui test [`varDep'_mean]c.smokers=[`varDep'_mean]c.nonsmokers
					local dif :di %7.4f [`varDep'_mean]c.smokers - [`varDep'_mean]c.nonsmokers
					local chi :di %7.3f r(chi2)
					local pval:di %7.3f r(p)			
					
					mat resu = [`vl',`y',`ll',`wl',0,`beta_smok',`difse_smok',`pbef_smok',`beta_nsmo',`difse_nsmo',`pbef_nsmo',`dif',`pval' ]
					mat bigResults =nullmat(bigResults) \ resu					
									
					loc wl=`wl'+1  // variable counter
				}
			}
		}
		loc vl=`vl'+1
	}
	mat colname bigResults = Version Year List Variable Quintile beta_smok difse_smok pbef_smok beta_nsmo difse_nsmo pbef_nsmo dif pval
	mat list bigResults
	svmat bigResults, names(col)

	// Resultados - Coeficientes y pruebas de hipotesis 
	if 1==1 {
		cap texdoc close
		texdoc init Table3X_nomatching, replace force
		tex {
		tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}		
		tex \begin{table}[H]
		tex \centering
		tex \scriptsize		
		tex \caption{ SUR Estimates for variation on shares between smokers and non-smokers \label{tab:SUR_nomatching}}
		tex \begin{adjustbox}{max totalheight=1.1\textheight, max width=1\textwidth,keepaspectratio}
		tex \begin{tabular}{l*{$nYc}{c}}			
		tex \toprule	
						
		forval ll=1(1)4 { // Which list
			glo linea0a=""
			glo linea0b=""
			glo linea0c=""
			forval io=1(1)$nYc {
				glo linea`io'=""
			}
		
			loc wl=1
			
			loc c=2 // For the columns counter
			foreach varDep in ${list`ll'}  { // Which dependent variable
				disp "`varDep'"
				loc vl=1 // Only the "C" version
				
				loc qq=5 // Only Quintile 5
				glo linea0a="$linea0a & \multicolumn{$nY}{c}{`varDep'}"
				
				loc c1=`c'+$nY-1
				glo linea0c="$linea0c \cmidrule(l){`c'-`c1'} "
				
				foreach y in $annios {
					loc ver = "`y'"				

					glo linea0b="$linea0b & `ver' "
					
					// Constant for smokers
										
					qui reg `varDep' smokers nonsmoker if year==`y' & qi_1==1, nocon
					local beta_smok :di %7.3f  _b[smoker]
					local beta_nsmo :di %7.3f  _b[nonsmoker]
					local difse_smok:di %7.3f _se[smoker]
					local difse_nsmo:di %7.3f _se[nonsmoker]

					loc valo :di %7.3f `beta_smok'
					glo linea1="$linea1 & `valo'"

					loc valo :di %7.3f `difse_smok'
					glo linea2="$linea2 & (`valo') "						
					
					loc valo :di %7.3f `beta_nsmo'
					glo linea5="$linea5 & `valo'"

					loc valo :di %7.3f `difse_nsmo'
					glo linea6="$linea6 & (`valo') "					
					
					/*
					qui sum pbef_smok if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==0 & Year==`y'
					loc valo=r(mean)
					local staru = ""
					if ((`valo' < 0.1) )  local staru_s = "*" 
					if ((`valo' < 0.05) )  local staru_s = "**" 
					if ((`valo' < 0.01) )  local staru_s = "***" 					
					
					qui sum beta_smok if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==0 & Year==`y'
					loc valo :di %7.3f r(mean)
					glo linea1="$linea1 & `valo'" //`staru_s' "

					qui sum difse_smok if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==0 & Year==`y'
					loc valo :di %7.3f r(mean)
					glo linea2="$linea2 & (`valo') "					
					*/
					
					// Coefficients Q1 vs Q5 for smokers ................................
					qui sum pbef_smok if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==`qq' & Year==`y'
					loc valo=r(mean)
					local staru = ""
					if ((`valo' < 0.1) )  local staru_s = "*" 
					if ((`valo' < 0.05) )  local staru_s = "**" 
					if ((`valo' < 0.01) )  local staru_s = "***" 					
					
					qui sum beta_smok if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==`qq' & Year==`y'
					loc valo :di %7.3f r(mean)
					glo linea3="$linea3 & `valo'" //`staru_s' "

					qui sum difse_smok if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==`qq' & Year==`y'
					loc valo :di %7.3f r(mean)
					glo linea4="$linea4 & (`valo') "	
				
					// Coefficients Q1 vs Q5 for non-smokers ............................
					qui sum pbef_nsmo if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==`qq' & Year==`y'
					loc valo=r(mean)
					local staru = ""
					if ((`valo' < 0.1) )  local staru_s = "*" 
					if ((`valo' < 0.05) )  local staru_s = "**" 
					if ((`valo' < 0.01) )  local staru_s = "***" 					
					
					qui sum beta_nsmo if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==`qq' & Year==`y'
					loc valo :di %7.3f r(mean)
					glo linea7="$linea7 & `valo'" //`staru_s' "

					qui sum difse_nsmo if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==`qq' & Year==`y'
					loc valo :di %7.3f r(mean)
					glo linea8="$linea8 & (`valo') "						
					
					// Test 1 lines (means) ............................................
					qui sum dif if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==0 & Year==`y'
					loc valo :di %7.3f r(mean)
					glo linea9="$linea9 & `valo'"

					qui sum pval if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==0 & Year==`y'
					loc valo :di %7.3f r(mean)
					glo linea10="$linea10 & `valo' "			
					
					// Test 2 lines (gradient) ............................................
					qui sum dif if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==`qq' & Year==`y'
					loc valo :di %7.3f r(mean)
					glo linea11 ="$linea11 & `valo' "
					
					qui sum pval if Version==`vl' & List==`ll' & Variable==`wl' & Quintile==`qq' & Year==`y'
					loc valo :di %7.3f r(mean)
					glo linea12="$linea12 & `valo' "						
					// .........................................................
					
				
					loc c=`c1'+1 // For the columns counter
				}	
				loc wl=`wl'+1 // Variable counter		
				
			}
			
			tex \textbf{Variable}   $linea0a \\
			tex  					$linea0b \\
			tex   					$linea0c 
			tex \parbox[l]{5.5cm}{A: Q1 Smokers Share } 	$linea1 \\ 
			tex                           						$linea2 \\			
			tex \parbox[l]{5.5cm}{B: Q5 vs Q1 smokers share: Q_{`qq'}^{(l)} \cdot s_{it}} 	$linea3 \\ 
			tex                           						$linea4 \\
			tex \parbox[l]{5.5cm}{C: Q1 Non-smokers Share } $linea5 \\
			tex                           		  			    $linea6 \\
			tex \parbox[l]{5.5cm}{D: Q5 vs Q1 non-smokers share: Q_{`qq'}^{(l)} \cdot ns_{it} } $linea7 \\
			tex                           		  			    $linea8 \\
			tex \addlinespace[2pt]
			tex   					$linea0c 
			tex E: Share difference smok. vs non-smok. Q1  $linea9 \\
			tex $ \quad$ p-val     $linea10 \\			
			tex F: Gradient difference smok. vs non-smok. Q1  $linea11 \\
			tex $ \quad$ p-val     $linea12 \\
			tex \midrule
		}
			
		tex \multicolumn{$nY1}{l}{\parbox[l]{17.5cm}{\textit{Notes:} Robust standard errors in parentheses. This table summarises the main results  with total expenditure net of expenditure on tobacco. ///
			Each set of columns correspond to a category of spending per year. In each year, the unconditional shares for smokers ///
			and non-smokers from quintile 1 are presented (rows A and C), as well as the difference of these shares for quintile 5 ///
			which correspond to equation 1 estimated coefficients conditional on controls (rows B and D). Below them, there are two ///
			tests that compare the previous numbers between smokers and non-smokers (A - C, B - D), both of them computed with the ///
			estimates of equation 1. ///
			Controls include log-expenditures, squared log-expenditures, log-age, female dummy, education level, living in a urban area, ratio dis under 5 per adult, household size, and log-income.  /// //  
			/// // Controls include:  lnGASTO lnGASTO2 lnEDAD SEXO educacion2 educacion3 urban kidsadults totalindiv logincome.
			}} \\
		tex \end{tabular}
		tex \end{adjustbox}
		tex \end{table}
		tex }
		texdoc close	

	}					
}

