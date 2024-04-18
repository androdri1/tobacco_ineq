STILL TO BE DONE!


* Author: Paul Rodriguez (paul.rodriguez@ur.edu.co)
* Date: 2017.06.30
* Goal: Derive individual health variables from ELPS

glo dropbox "C:\Users\paul.rodriguez\Dropbox"
glo dropbox "C:\Users\susana.otalvaro\Dropbox"

*cd "$dropbox\tabaco\Tobacco-health-inequalities\data\ELPS"
cd "$dropbox\Tobacco-health-inequalities\data\ELPS"

use "original/F. SALUD.dta", clear

////////////////////////////////////////////////////////////////////////////////
// Diagnostics
////////////////////////////////////////////////////////////////////////////////

egen countSick_all=rowtotal(P128s1 P128s2 P128s3 P128s4 P128s5 P128s6 P128s7 P128s8 P128s10 P128s11)
label var countSick_all "Total chornic diseases"

egen countSick_cig=rowtotal(P128s1 P128s3 P128s4 P128s5 P128s6) // Asthama, COP, Diabetes, HBP, CVDs, Cancer
label var countSick_cig "Total chornic smoking-related diseases"

egen countDisa=rowtotal(P129s1 P129s2 P129s3 P129s4 P129s5 P129s6 P129s7 P129s8 P129s9 P129s10)
label var countDisa "Total disabilities"

* Indicator vars per diseases, conditional on having answered the diagnositics inventory quest
gen dg_cancer= P128s6==1 if countSick_all>0 | P128s12==1
label var dg_cancer "Diagnosed with Cancer"

gen dg_cvd= P128s5==1 if countSick_all>0 | P128s12==1
label var dg_cvd "Diagnosed with a CVD"

gen dg_hbp= P128s4==1 if countSick_all>0 | P128s12==1
label var dg_hbp "Diagnosed with HBP"

gen dg_dm= P128s3==1 if countSick_all>0 | P128s12==1
label var dg_dm "Diagnosed with diabetes"

gen dg_resp= P128s1==1 if countSick_all>0 | P128s12==1
label var dg_resp "Diagnosed with Asthma, Efisema or EPOC"

////////////////////////////////////////////////////////////////////////////////
// Health Behaviours
////////////////////////////////////////////////////////////////////////////////
gen smoke_ev= P137==1 if P137!=.
label var smoke_ev "Ever smoked"

gen smoken = P138==1 if P138!=.
label var smoken "Current smoker"

gen smokeIntC= P139
label var smokeIntC "Cigs per day | smoker"

gen smokeIntA= P139
replace smokeIntA=0 if smoken==0
label var smokeIntA "Cigs per day (everyone)"

////////////////////////////////////////////////////////////////////////////////

saveold "derived/ELPS2012_health.dta" ,replace
