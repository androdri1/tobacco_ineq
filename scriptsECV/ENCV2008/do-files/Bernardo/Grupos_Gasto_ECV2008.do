*******************************************
*******************************************
********Creación de Grupos de Gasto********
*******************************************
*******************************************

*use "C:\Documents and Settings\BAtuestaM\Mis documentos\Bernardo Atuesta\Darwin\Gasto ECV2008\StataFiles\VblesGasto_Imputadas_ECV2008.dta", clear 
use "$dropbox\Tobacco-health-inequalities\data\ENCV2008\derived\Bernardo\VblesGasto_Imputadas_ECV2008.dta", clear


foreach x in p8551 p6123 p8555 p6154s1a1 p6154s2a1 p6154s3a1 p6154s4a1 p6154s5a1 p6154s6a1 p6154s7a1 p6154s8a1 p6154s9a1 p6154s10a1 p8558s1a1 p8558s2a1  ///
 p6169s1 p8564s1 p8566s1 p8568s1 p8570s1 p8572s1 p8574s1 p8576s1 p8578s2 p8580s2 p6180s2 p8594s1 p8596s1 p8598s1 p8600s1 p8602s1 p8604s1 p8606s1 p8608s1  ///
 p8610s1 p8612s1 p5015 p8524 p5034 p5044 p5067 p8540 p5330 p5340 p5610 p8693 p5130 p5140 p5650 p8730s1 p8731s1 p8732s1 p8733s1 p8734s1 p8735s1 p8736s1 p8737s1 p8738s1 p8739s1 ///
 p8740s1 p8741s1 p8742s1 p8743s1 p8744s1 p8745s1 p8746s1 p8747s1 p8748s1 p8749s1 p8750s1 p8751s1 p8863s1 p8900s1a2 p8900s2a2 p8900s3a2 p8900s4a2 p8900s5a2 p8900s6a2 ///
 p8900s7a2 p8900s8a2 p8900s9a2 p8900s10a2 p8900s11a2 p8900s12a2 p8900s13a2 p8900s14a2 p8900s15a2 p8900s16a2 p8900s17a2 p8900s18a2 p8900s19a2 p8900s20a2 p8900s21a2 ///
 p8900s22a2 p8754s1 p8755s1 p8756s1 p8757s1 p8758s1 p8759s1 p8760s1 p8761s1 p8762s1 p8763s1 p8764s1 p8765s1 p8864s1 p8905s1a2 p8905s2a2 p8905s3a2 p8905s4a2 p8905s5a2 ///
 p8905s6a2 p8905s7a2 p8905s8a2 p8905s9a2 p8905s10a2 p8905s11a2 p8905s12a2 p8766s1 p8767s1 p8768s1 p8769s1 p8770s1 p8771s1 p8772s1 p8773s1 p8774s1 p8775s1 p8776s1 p8777s1 ///
 p8778s1 p8779s1 p8865s1 p8910s1a2 p8910s2a2 p8910s3a2 p8910s4a2 p8910s5a2 p8910s6a2 p8910s7a2 p8910s8a2 p8910s9a2 p8910s10a2 p8910s11a2 p8910s12a2 p8910s14a2 p8780s1 ///
 p8781s1 p8782s1 p8783s1 p8784s1 p8785s1 p8786s1 p8787s1 p8788s1 p8866s1 p8915s1a2 p8915s2a2 p8915s3a2 p8915s4a2 p8915s5a2 p8915s6a2 p8915s7a2 p8915s8a2 p8915s9a2 ///
 p8789s1 p8790s1 p8791s1 p8792s1 p8793s1 p8794s1 p8795s1 p8796s1 p8797s1 p8798s1 p8799s1 p8800s1 p8801s1 p8802s1 p8803s1 p8804s1 p8805s1 p8806s1 p8807s1 p8808s1 p8809s1 ///
 p8867s1 p8920s1a2 p8920s2a2 p8920s3a2 p8920s4a2 p8920s5a2 p8920s6a2 p8920s7a2 p8920s8a2 p8920s11a2 p8920s12a2 p8920s13a2 p8920s14a2 p8920s15a2 p8920s16a2 p8920s17a2 ///
 p8920s18a2 p8920s19a2 p8920s20a2 p8920s21a2 p6135{

replace `x'=0 if `x'==.

}



*****************
****1. Alimentos

gen alimentos = (30/7)*(p8730s1 + p8731s1 + p8732s1 + p8733s1 + p8734s1 + p8735s1 + p8736s1 + p8737s1 + p8738s1 + p8739s1 + p8740s1 + p8741s1 + p8742s1 + p8743s1 + p8744s1 +  ///
 p8745s1 + p8746s1 + p8747s1 + p8748s1 + p8749s1 + p8750s1 + p8751s1 + p8900s1a2 + p8900s2a2 + p8900s3a2 + p8900s4a2 + p8900s5a2 + p8900s6a2 + p8900s7a2 + p8900s8a2 +  ///
 p8900s9a2 + p8900s10a2 + p8900s11a2 + p8900s12a2 + p8900s13a2 + p8900s14a2 + p8900s15a2 + p8900s16a2 + p8900s17a2 + p8900s18a2 + p8900s19a2 + p8900s20a2 + p8900s21a2 +  ///
 p8900s22a2 + p8763s1 +  p8905s10a2)


************************
****2. Bebidas y Tabaco

gen bebytab = (30/7)*(p8754s1 + p8905s1a2 + p8757s1 + p8905s4a2) 


***************************
****3. Vestuario y Calzado

gen vestycalz = ((30/7)*(p8760s1 +  p8905s7a2)) +  (p8769s1 + p8910s4a2) + ((1/3)*( p8780s1 + p8781s1 + p8782s1 + p8783s1 + p8915s1a2 + p8915s2a2 + p8915s3a2 + p8915s4a2))


********************************
****4. Servicios de la Vivienda

gen vivienda = (p5015 + p8524 + p5034 + p5044 + p5067 + p8540 + p5330 + p5130 + p5140 + p5650) + ((30/7)*(p8764s1 + p8905s11a2)) + (p8767s1 + p8910s2a2 + p8770s1 + p8910s5a2 + ///
 p8774s1 + p8910s9a2) + ((1/3)*(p8786s1 + p8915s7a2)) + ((1/12)*(p8790s1 + p8920s2a2)) 


*************************
****5. Muebles y Enseres

gen muebles = ((1/12)*(p8789s1 + p8791s1 + p8792s1 + p8793s1 + p8920s1a2 + p8920s3a2 + p8920s4a2 + p8920s5a2))


*************
****6. Salud

gen salud = (p8551 + p6123 + p8555 + p6154s1a1 + p6154s2a1 + p6154s3a1 + p6154s4a1 + p6154s5a1 + p6154s6a1 + p6154s7a1 + p6154s8a1 + p6154s9a1 + p6154s10a1) +  ///
 ((1/12)*(p8558s1a1 + p8558s2a1 + p6135)) + (p8768s1 + p8910s3a2 + p8779s1 + p8910s14a2)


***********************************
****7. Transporte y Comunicaciones

gen transycom = p5340 + ((30/7)*(p8756s1 + p8758s1 + p8759s1 + p8905s3a2 + p8905s5a2 + p8905s6a2 + p8765s1 + p8905s12a2)) + (p8775s1 + p8910s10a2) + ((1/3)*(p8784s1 + p8787s1  ///
 + p8915s5a2 + p8915s8a2)) + ((1/12)*(p8808s1 + p8920s20a2))


*****************************************
****8. Recreación y Servicios Culturales

gen recreacion = ((30/7)*(p8761s1 + p8905s8a2)) + (p8773s1 + p8777s1 + p8910s8a2 + p8910s12a2) + ((1/3)*(p8785s1 + p8788s1 + p8915s6a2 + p8915s9a2)) + ((1/12)*(p8794s1 +  ///
 p8795s1 + p8920s6a2 + p8920s7a2 + p8809s1 + p8920s21a2))


*****************
****9. Educación

gen educacion = ((1/12)*(p6169s1 + p8564s1 + p8566s1 + p8568s1)) + (p8570s1 + p8572s1 + p8574s1 + p8576s1) + (30*(p8578s2 + p8580s2 + p6180s2)) + ((1/12)*(p8594s1 +  ///
 p8596s1 + p8598s1)) + (p8600s1 + p8602s1 + p8604s1 + p8606s1 + p8608s1 + p8610s1 + p8612s1)


*******************************************
****10. Servicios Personales y Otros Pagos

gen otros = ((1/12)*( p5610 + p8693)) + ((30/7)*(p8863s1 + p8755s1 + p8905s2a2 + p8762s1 + p8864s1 + p8905s9a2)) + (p8766s1 + p8771s1 + p8772s1 + p8776s1 + p8778s1 +  ///
 p8865s1 + p8910s1a2 + p8910s6a2 + p8910s7a2 + p8910s11a2) + ((1/3)*(p8866s1)) + ((1/12)*(p8796s1 + p8797s1 + p8798s1 + p8799s1 + p8800s1 + p8801s1 + p8802s1 + p8803s1 +  ///
 p8804s1 + p8805s1 + p8806s1 + p8807s1 + p8867s1 + p8920s8a2 + p8920s11a2 + p8920s12a2 + p8920s13a2 + p8920s14a2 + p8920s15a2 + p8920s16a2 + p8920s17a2 + p8920s18a2 +  ///
 p8920s19a2))



**********************
****TOTAL GASTO HOGAR

gen total_gasto_hog = alimentos + bebytab + vestycalz + vivienda + muebles + salud + transycom + recreacion + educacion + otros


********************************
****TOTAL GASTO HOGAR EXPANDIDO

gen total_gasto_hog_exp = total_gasto_hog*fex



save "C:\Documents and Settings\BAtuestaM\Mis documentos\Bernardo Atuesta\Darwin\Gasto ECV2008\StataFiles\Gasto_Hogares_ECV2008.dta", replace



**************************
****Gasto por regiones****
**************************

use "C:\Documents and Settings\BAtuestaM\Mis documentos\Bernardo Atuesta\Darwin\Gasto ECV2008\StataFiles\Gasto_Hogares_ECV2008.dta", clear

set more off

egen total_gasto_reg = total(total_gasto_hog), by (region)

egen total_gasto_reg_exp = total(total_gasto_hog_exp), by (region)

replace p3=2 if p3==3

egen total_gasto_reg_urb_rur = total(total_gasto_hog), by (region p3)

egen total_gasto_reg_urb_rur_exp = total(total_gasto_hog_exp), by (region p3)


egen total_gasto = total(total_gasto_hog)

egen total_gasto_exp =  total(total_gasto_hog_exp)

egen total_gasto_urb_rur = total(total_gasto_hog), by (p3)

egen total_gasto_urb_rur_exp =  total(total_gasto_hog_exp), by (p3)

************************************
****Personas y Hogares por regiones

egen total_pers_reg = total(fex_ug), by (region)

egen total_hogs_reg = total(fex), by (region)

egen total_pers_reg_urb_rur = total(fex_ug), by (region p3)

egen total_hogs_reg_urb_rur = total(fex), by (region p3)

egen total_pers = total(fex_ug)

egen total_hogs = total (fex)

egen total_pers_urb_rur = total(fex_ug), by (p3)

egen total_hogs_urb_rur = total(fex), by(p3)


sort region p3

egen numero=seq(), by (region p3)

keep if numero==1

gen porc_gasto_reg = (total_gasto_reg_exp/total_gasto_exp)*100

gen porc_gasto_reg_urb_rur = (total_gasto_reg_urb_rur_exp/total_gasto_urb_rur_exp)*100

gen gasto_percap_reg = (total_gasto_reg_exp/total_pers_reg)*100

gen gasto_percap_reg_urb_rur = (total_gasto_reg_urb_rur_exp/total_pers_reg_urb_rur)*100

gen gasto_percap_total = (total_gasto_exp/total_pers)*100

gen gasto_percap_total_urb_rur = (total_gasto_urb_rur_exp /total_pers_urb_rur)*100

save "C:\Documents and Settings\BAtuestaM\Mis documentos\Bernardo Atuesta\Darwin\Gasto ECV2008\StataFiles\Gasto_percapita_Regiones_ECV2008.dta", replace














































