******************************************************************************************************
******************************************************************************************************
********Imputaci�n por medias a vbles de gasto y pegado archivos de personas y hogares ECV2008********
******************************************************************************************************
******************************************************************************************************

glo dropbox "C:\Users\\`c(username)'\\Google Drive\tabacoDrive"
***********************************
********Pegado de Archivos*********
***********************************
// Viviendas

use "$dropbox\Tobacco-health-inequalities\data\ENCV2008\original\viviendas.sav.dta", clear
*use  "C:\Documents and Settings\BAtuestaM\Mis documentos\Bernardo Atuesta\Encuestas\Calidad de vida\ECV2008\viviendas_municipios_ECV2008.dta", clear

egen id_vivienda = concat(DIRECTORIO SECUENCIA_P)
keep id_vivienda P1_DEPARTAMENTO  REGION P3 P8520S* DIRECTORIO SECUENCIA_P
destring P1_DEPARTAMENTO  REGION, replace
sort id_vivienda
destring id_vivienda, replace

*save "C:\Documents and Settings\BAtuestaM\Mis documentos\Bernardo Atuesta\Darwin\Gasto ECV2008\StataFiles\viviendas_apegar_ECV2008.dta", replace
save "$dropbox\Tobacco-health-inequalities\data\ENCV2008\derived\Bernardo\viviendas_apegar_ECV2008.dta", replace

********************************************************************************
// Hogares

*use "C:\Documents and Settings\BAtuestaM\Mis documentos\Bernardo Atuesta\Encuestas\Calidad de vida\ECV2008\hogares_ECV2008.dta", clear
use "$dropbox\Tobacco-health-inequalities\data\ENCV2008\original\hogares.sav.dta", clear

egen id_vivienda = concat( DIRECTORIO SECUENCIA_P)
egen id_hogar = concat (DIRECTORIO SECUENCIA_P SECUENCIA_ENCUESTA)
sort id_vivienda id_hogar
destring id_vivienda id_hogar, replace 

*save "C:\Documents and Settings\BAtuestaM\Mis documentos\Bernardo Atuesta\Darwin\Gasto ECV2008\StataFiles\hogares_apegar_ECV2008.dta", replace
save "$dropbox\Tobacco-health-inequalities\data\ENCV2008\derived\Bernardo\hogares_apegar_ECV2008.dta", replace

merge n:1 id_vivienda using "$dropbox\Tobacco-health-inequalities\data\ENCV2008\derived\Bernardo\viviendas_apegar_ECV2008.dta"
sort id_hogar
drop _merge

*save "C:\Documents and Settings\BAtuestaM\Mis documentos\Bernardo Atuesta\Darwin\Gasto ECV2008\StataFiles\vivienda_hogares_apegar_ECV2008.dta", replace
save "$dropbox\Tobacco-health-inequalities\data\ENCV2008\derived\Bernardo\vivienda_hogares_apegar_ECV2008.dta", replace

********************************************************************************
// Personas

*use "C:\Documents and Settings\BAtuestaM\Mis documentos\Bernardo Atuesta\Encuestas\Calidad de vida\ECV2008\personas_ECV2008.dta", clear
use "$dropbox\Tobacco-health-inequalities\data\ENCV2008\original\personas.sav.dta", clear

rename SECUENCIA_ENCUESTA SECUENCIA_ENCUESTAPER
rename SECUENCIA_P SECUENCIA_ENCUESTA
gen SECUENCIA_P=1
egen id_hogar = concat (DIRECTORIO SECUENCIA_P SECUENCIA_ENCUESTA)
destring id_hogar, replace 

merge n:1 id_hogar using "$dropbox\Tobacco-health-inequalities\data\ENCV2008\derived\Bernardo\vivienda_hogares_apegar_ECV2008.dta"
drop _merge

sort id_hogar

*save "C:\Documents and Settings\BAtuestaM\Mis documentos\Bernardo Atuesta\Darwin\Gasto ECV2008\StataFiles\BaseImputacion_ECV2008.dta", replace
save "$dropbox\Tobacco-health-inequalities\data\ENCV2008\derived\Bernardo\BaseImputacion_ECV2008.dta", replace 



***************************************************************************
*******Imputacion por media de variables que responden las personas********
***************************************************************************

use "$dropbox\Tobacco-health-inequalities\data\ENCV2008\derived\Bernardo\BaseImputacion_ECV2008.dta", clear

replace P8520S1A1=. if P8520S1A1==9


* Descuento en SS, planes o seguros de salud, ultima atencion en salud, bonos o cuotas moderadoras
* copagos, consulta medica, odontologo, vacunas, medicamentos o remedios
* examenes, transporte, rehabilitacion o terapias, terapias alternativas
* lentes u audifonos, cirugias ambulatorias, hospitalizacion

* matricula, uniformes, utiles, libros, pension, transporte, alimentacion
* otro concepto escolar, almuerzo gratuito, algo gratuito, alimentos gratuitos
* matricula ano escolar, uniformes, utiles, pension, transporte, alimentacion 
* material escolar, cultural escolar, beca escolar, subsidio 


////////////////////////////////////////////////////////////////////////////////
// Clean the data
////////////////////////////////////////////////////////////////////////////////
/*cap program drop cleanvars
program define cleanvars , rclass
	args lista
	disp "Cleaning! `lista'"
	foreach varDep in `lista'{
		cap replace `varDep'=0 if `varDep'==2
		cap replace `varDep'=. if `varDep'==98 | `varDep'==99 // Missings
		* Shall I do an outlier analysis??
		
		noisily cap replace `varDep'S1=. if `varDep'S1==98 |`varDep'S1==99 // Missings for all
		noisily cap replace `varDep'A2=. if `varDep'A2==98 |`varDep'A2==99 // Missings for the home produ
	}
end
*/


foreach x in P8551 P6123 P8555 P6154S1A1 P6154S2A1 P6154S3A1 P6154S4A1 P6154S5A1 P6154S6A1 P6154S7A1 P6154S8A1 P6154S9A1 P6154S10A1 P8558S1A1 P8558S2A1 P6135 ///
P6169S1 P8564S1 P8566S1 P8568S1 P8570S1 P8572S1 P8574S1 P8576S1 P8578S2 P8580S2 P6180S2 P8594S1 P8596S1 P8598S1 P8600S1 P8602S1 P8604S1 P8606S1 P8608S1 ///
P8610S1 P8612S1 ///
P5015 P8524 P5034 P5044 P5067 P5330 P5610{
replace `x'=. if (`x'==98 | `x'==99) 
}
*

***Mensualizo las preguntas p8610s1 y p8612s1

foreach x in P8610S2 P8612S2{
replace `x'=6 if `x'==3
replace `x'=12 if `x'==4
}

foreach x in P8610 P8612{
replace `x'S1=(`x'S1/`x'S2) if (`x'S1!=. & `x'S1!=0)
}

sort id_hogar ORDEN
rename  FACTOR_EXPANSION fex
egen num_ind_hog=max(ORDEN), by (id_hogar)
gen fex_hogar = fex*num_ind_hog

keep if (P6051<=16 | P6051==21)

egen numero=seq(), by (id_hogar)
egen personas_ug=max(numero), by (id_hogar)
drop numero
gen fex_ug = fex*personas_ug


***Imputo por media

foreach x in P8551 P6123 P8555 P6154S1A1 P6154S2A1 P6154S3A1 P6154S4A1 P6154S5A1 P6154S6A1 P6154S7A1 P6154S8A1 P6154S9A1 P6154S10A1 P8558S1A1 P8558S2A1 P6135 ///
P6169S1 P8564S1 P8566S1 P8568S1 P8570S1 P8572S1 P8574S1 P8576S1 P8578S2 P8580S2 P6180S2 P8594S1 P8596S1 P8598S1 P8600S1 P8602S1 P8604S1 P8606S1 P8608S1 ///
P8610S1 P8612S1{

gen nomiss_`x'=`x' if (`x'!=.) 
egen mean_`x'=mean(nomiss_`x'), by(P8520S1A1)
replace `x'=mean_`x' if (`x'==.)
egen hogar_`x'=total(`x'), by (id_hogar)

drop nomiss_`x' mean_`x' `x'
rename hogar_`x' `x'

}
*

keep if ORDEN==1

*save "C:\Documents and Settings\BAtuestaM\Mis documentos\Bernardo Atuesta\Darwin\Gasto ECV2008\StataFiles\BaseImputacion_pgtasHogares_ECV2008.dta", replace
save "$dropbox\Tobacco-health-inequalities\data\ENCV2008\derived\Bernardo\BaseImputacion_pgtasHogares_ECV2008.dta", replace

***Mensualizo las preguntas p5015 p8524 p5034 p5044 p5067 p5330 p5610:
* pago por electricidad último
* pago gas natural
* pago alcantarillado
* pago recoleccion de basuras
* pago acueducto
* pago servicio telefonico
* pago predial

foreach x in P5015 P8524 P5034 P5044 P5067 P5330 P5610{

replace `x'=`x'/`x'S1 if (`x'!=. & `x'!=0) 

}

* pago por electricidad último
* pago gas natural
* pago alcantarillado
* pago recoleccion de basuras
* pago acueducto
* pago servicio telefonico
* pago predial (p5610)
* celular (p5340)
* valorizacion (p8693)
* arriendo -imputado- (p5130)
* arriendo (p5140)
* administracion (p5650)
* alimentos (p8730 - P8900S23)
* personales (p8754 - p8)

foreach x in P5015 P8524 P5034 P5044 P5067 P8540 P5330 P5340 P5610 P8693 P5130 P5140 P5650 ///
P8730S1 P8731S1 P8732S1 P8733S1 P8734S1 P8735S1 P8736S1 P8737S1 P8738S1 P8739S1 ///
P8740S1 P8741S1 P8742S1 P8743S1 P8744S1 P8745S1 P8746S1 P8747S1 P8748S1 P8749S1 P8750S1 P8751S1 P8863S1 P8900S1A2 P8900S2A2 P8900S3A2 P8900S4A2 P8900S5A2 P8900S6A2 ///
P8900S7A2 P8900S8A2 P8900S9A2 P8900S10A2 P8900S11A2 P8900S12A2 P8900S13A2 P8900S14A2 P8900S15A2 P8900S16A2 P8900S17A2 P8900S18A2 P8900S19A2 P8900S20A2 P8900S21A2 ///
P8900S22A2 P8754S1 P8755S1 P8756S1 P8757S1 P8758S1 P8759S1 P8760S1 P8761S1 P8762S1 P8763S1 P8764S1 P8765S1 P8864S1 P8905S1A2 P8905S2A2 P8905S3A2 P8905S4A2 P8905S5A2 ///
P8905S6A2 P8905S7A2 P8905S8A2 P8905S9A2 P8905S10A2 P8905S11A2 P8905S12A2 P8766S1 P8767S1 P8768S1 P8769S1 P8770S1 P8771S1 P8772S1 P8773S1 P8774S1 P8775S1 P8776S1 P8777S1 ///
P8778S1 P8779S1 P8865S1 P8910S1A2 P8910S2A2 P8910S3A2 P8910S4A2 P8910S5A2 P8910S6A2 P8910S7A2 P8910S8A2 P8910S9A2 P8910S10A2 P8910S11A2 P8910S12A2 P8910S14A2 P8780S1 ///
P8781S1 P8782S1 P8783S1 P8784S1 P8785S1 P8786S1 P8787S1 P8788S1 P8866S1 P8915S1A2 P8915S2A2 P8915S3A2 P8915S4A2 P8915S5A2 P8915S6A2 P8915S7A2 P8915S8A2 P8915S9A2 ///
P8789S1 P8790S1 P8791S1 P8792S1 P8793S1 P8794S1 P8795S1 P8796S1 P8797S1 P8798S1 P8799S1 P8800S1 P8801S1 P8802S1 P8803S1 P8804S1 P8805S1 P8806S1 P8807S1 P8808S1 P8809S1 ///
P8867S1 P8920S1A2 P8920S2A2 P8920S3A2 P8920S4A2 P8920S5A2 P8920S6A2 P8920S7A2 P8920S8A2 P8920S11A2 P8920S12A2 P8920S13A2 P8920S14A2 P8920S15A2 P8920S16A2 P8920S17A2 ///
P8920S18A2 P8920S19A2 P8920S20A2 P8920S21A2{

replace `x'=.  if (`x'==98 | `x'==99) 
}
*



foreach x in P5015 P8524 P5034 P5044 P5067 P8540 P5330 P5340 P5610 P8693 P5130 P5140 P5650 ///
P8730S1 P8731S1 P8732S1 P8733S1 P8734S1 P8735S1 P8736S1 P8737S1 P8738S1 P8739S1 ///
P8740S1 P8741S1 P8742S1 P8743S1 P8744S1 P8745S1 P8746S1 P8747S1 P8748S1 P8749S1 P8750S1 P8751S1 P8863S1 P8900S1A2 P8900S2A2 P8900S3A2 P8900S4A2 P8900S5A2 P8900S6A2 ///
P8900S7A2 P8900S8A2 P8900S9A2 P8900S10A2 P8900S11A2 P8900S12A2 P8900S13A2 P8900S14A2 P8900S15A2 P8900S16A2 P8900S17A2 P8900S18A2 P8900S19A2 P8900S20A2 P8900S21A2 ///
P8900S22A2 P8754S1 P8755S1 P8756S1 P8757S1 P8758S1 P8759S1 P8760S1 P8761S1 P8762S1 P8763S1 P8764S1 P8765S1 P8864S1 P8905S1A2 P8905S2A2 P8905S3A2 P8905S4A2 P8905S5A2 ///
P8905S6A2 P8905S7A2 P8905S8A2 P8905S9A2 P8905S10A2 P8905S11A2 P8905S12A2 P8766S1 P8767S1 P8768S1 P8769S1 P8770S1 P8771S1 P8772S1 P8773S1 P8774S1 P8775S1 P8776S1 P8777S1 ///
P8778S1 P8779S1 P8865S1 P8910S1A2 P8910S2A2 P8910S3A2 P8910S4A2 P8910S5A2 P8910S6A2 P8910S7A2 P8910S8A2 P8910S9A2 P8910S10A2 P8910S11A2 P8910S12A2 P8910S14A2 P8780S1 ///
P8781S1 P8782S1 P8783S1 P8784S1 P8785S1 P8786S1 P8787S1 P8788S1 P8866S1 P8915S1A2 P8915S2A2 P8915S3A2 P8915S4A2 P8915S5A2 P8915S6A2 P8915S7A2 P8915S8A2 P8915S9A2 ///
P8789S1 P8790S1 P8791S1 P8792S1 P8793S1 P8794S1 P8795S1 P8796S1 P8797S1 P8798S1 P8799S1 P8800S1 P8801S1 P8802S1 P8803S1 P8804S1 P8805S1 P8806S1 P8807S1 P8808S1 P8809S1 ///
P8867S1 P8920S1A2 P8920S2A2 P8920S3A2 P8920S4A2 P8920S5A2 P8920S6A2 P8920S7A2 P8920S8A2 P8920S11A2 P8920S12A2 P8920S13A2 P8920S14A2 P8920S15A2 P8920S16A2 P8920S17A2 ///
P8920S18A2 P8920S19A2 P8920S20A2 P8920S21A2{

gen nomiss_`x'=`x' if (`x'!=.) 
egen mean_`x'=mean(nomiss_`x'), by(P8520S1A1)
replace `x'=mean_`x' if (`x'==.)
drop nomiss_`x' mean_`x'
}
*


*save "C:\Documents and Settings\BAtuestaM\Mis documentos\Bernardo Atuesta\Darwin\Gasto ECV2008\StataFiles\VblesGasto_Imputadas_ECV2008.dta", replace
save "$dropbox\Tobacco-health-inequalities\data\ENCV2008\derived\Bernardo\VblesGasto_Imputadas_ECV2008.dta", replace
