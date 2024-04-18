macro drop _all
clear all
* glo carpetaMadre "C:\Documents and Settings\paul rodriguez\Mis documentos\Trabajos"
 glo carpetaMadre "E:\Documents and Settings\Paul Andres\Mis documentos\Trabajos"
glo carpetaDatos "$carpetaMadre\Comedores\Old Version (PE)"
glo carpetaResul "$carpetaMadre\Comedores\Paper\Procesamiento\Bases Intermedias"
glo carpetaPCA "$carpetaMadre\Comedores\Thesis Version\Procesamiento\prinqual"

cd "$carpetaResul"
/* ************************************************************************************************************
**************************************************************************************************************
************************* ELABORACIÓN DE LA BASE DE DATOS AGREGADA A NIVEL DE HOGAR **************************
**************************************************************************************************************
************************************************************************************************************ */
use "comedores2003.dta", clear

# delim ;		
collapse  (count) tamhogar=e01
		  (sum) il_especie il_monetario il_subsidios i_capital i_capital_SD i_otros t_almts_ie t_becas_sub
				ingreso ingreso_st i_transfmon i_otros_st transferencias transferencias_conm
				ed0 ed12 ed34 ed56 ed611 ed1215 ed1617 eh0 eh12 eh34 eh56 eh611 eh1215 eh1617
				tamfamilia=es_familia tamnucleof=es_nucleo_f es_ocp es_des es_pei es_nopea informal informalf
				m5_jardi m5_papasc m5_papast m5_remc m5_otro 
		  (min) edadmenorf=e02_familia edadmenorn=e02_nucleo
		  (max) localidad_1 localidad_2 localidad_3 localidad_4 localidad_5 localidad_6 localidad_7 localidad_8 localidad_9 localidad_10 localidad_11 localidad_12 localidad_13 localidad_14 localidad_15 localidad_16 localidad_17 localidad_18 localidad_19
				sisben12 servdom
			, by(numero);

	label var localidad_1 "Usaquén";
    label var localidad_2 "Chapinero";
    label var localidad_3 "Santafé";
    label var localidad_4 "San Cristóbal";
    label var localidad_5 "Usme";
    label var localidad_6 "Tunjuelito";
    label var localidad_7 "Bosa";
    label var localidad_8 "Kennedy";
    label var localidad_9 "Fontibón";
    label var localidad_10 "Engativá";
    label var localidad_11 "Suba";
    label var localidad_12 "Barrios Unidos";
    label var localidad_13 "Teusaquillo";
    label var localidad_14 "Los Martires";
    label var localidad_15 "Antonio Nariño";
    label var localidad_16 "Puente Aranda";
    label var localidad_17 "La Candelaria";
    label var localidad_18 "Rafael Uribe Uribe";
    label var localidad_19 "Ciudad Bolívar";

	label var ed0 "Parientes Jfe menores a 1 año";
	label var ed12 "Parientes Jfe con 1 o 2 años";
	label var ed34 "Parientes Jfe con 3 o 4 años";
	label var ed56 "Parientes Jfe con 5 o 6 años (e.pree)";
	label var ed611 "Parientes Jfe entre 6 y 11 años (e.bprim)";
	label var ed1215 "Parientes Jfe entre 12 y 15 años (e.bsec)";
	label var ed1617 "Parientes Jfe con 16 o 17 años (e.media)";
	label var eh0 "Hijos Jfe menores a 1 año";
	label var eh12 "Hijos Jfe con 1 o 2 años";
	label var eh34 "Hijos Jfe con 3 o 4 años";
	label var eh56 "Hijos Jfe con 5 o 6 años (e.pree)";
	label var eh611 "Hijos Jfe entre 6 y 11 años (e.bprim)";
	label var eh1215 "Hijos Jfe entre 12 y 15 años (e.bsec)";
	label var eh1617 "Hijos Jfe con 16 o 17 años (e.media)";
	label var es_ocp "Trabaja";
	label var es_des "Desempleado";
	label var es_pei "Pobl Econ. Inactiva";
	label var es_nopea "No PET";
	label var informal "Def SI DANE";
	label var informalf "Def SI DANE -{Los que sean empleados casa}";
	label var servdom "Tiene servicio doméstico hogar";			
						
/* A esta base le pegamos hogar */
cd "$carpetaDatos"; 
merge numero using "ECV2003\hogarL.dta", unique sort;
drop if _merge==2;
drop _merge;
merge numero using "ECV2003\condicL.dta", unique sort;
drop if _merge==2;
drop _merge;
cd "$carpetaResul";
merge numero using "$carpetaPCA\hogar_icv2003.dta", unique sort;
drop if _merge==2;
drop _merge;



xi i.b04012, noomit;

rename b04012 estrato;
rename  _Ib04012_0 estratoPir;
rename  _Ib04012_1 estrato1;
rename  _Ib04012_2 estrato2;
rename  _Ib04012_3 estrato3;
rename  _Ib04012_4 estrato4;
rename  _Ib04012_5 estrato5;
rename  _Ib04012_6 estrato6;
/* rename  _Ib04012_9 estratona;
replace estratona=0 if estratoPir==.; */
/* Drop if estratona==1??? */
    
destring m080*, replace;
gen calamidad=cond(m0801==1 | m0802==1 | m0803==1 | m0804==1 | m0805==1,1,0);
label var calamidad "Alguna calamidad en año anterior";

rename b01 tipoviv;
rename m12 considerapobre;
rename  m20 fincomida_sempas;
rename  d01 tenenciahogar;

xtile dec_ingreso_hogar=ingreso,  nquantiles(10);
/* Para los Per Cápita */
gen ingreso_pc=ingreso/ tamfamilia;
xtile dec_ingreso_pc=ingreso_pc,  nquantiles(10);
xi i.dec_ingreso_pc, noomit;
renpfix _I "";

xi i.tipoviv, noomit;
label var _Itipoviv_1 "1. Casa";
label var _Itipoviv_2 "2. Apartamento";
label var _Itipoviv_3 "3. Cuarto (s) Inquilinato";
label var _Itipoviv_4 "4. Cuarto(s) en otro tipo de estructura";
/* label var _Itipoviv_5 "5. Vivienda indígena";     NO había ninguna*/
label var _Itipoviv_5 "6. Otro tipo de vivienda (carpa, tienda, vagón, embarcación, refugio natural, puente, etc.)";
renpfix _I "";

# delim cr;

* Tenencia Hogar


xi i.tenenciahogar , noomit
label var _Itenenciah_1 "1. Propia totalmente paga"
label var _Itenenciah_2 "2. Propia la están pagando"
label var _Itenenciah_3 "3. En arriendo o subarriendo"
label var _Itenenciah_4 "4. En usufructo"
label var _Itenenciah_5 "6. Ocupante de hecho"
renpfix _I ""

# delim ;

rename localidad id_loc;

keep  id_loc numero-tipoviv tenenciahogar tenenciah_* estrato considerapobre fincomida_sempas tipoviv_* estratoPir-calamidad dec_* ingreso_pc tamhogar icv;
save "comedoresHogar2003.dta", replace;

