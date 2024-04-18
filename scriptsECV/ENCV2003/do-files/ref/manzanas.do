/*
COD: 5 01610 1 040 01 002 018
###: 1 23456 7 891 12 345 678
id_viv
 */
 
gen id_region = substr(id_viv,1,1)
gen id_consecutivo = substr(id_viv,2,5)
gen id_clase = substr(id_viv,7,1)
gen id_segmento = substr(id_viv,8,3)
gen id_manzana = substr(id_viv,11,2)
gen id_edificacion = substr(id_viv,13,3)
gen id_vivienda = substr(id_viv,16,13)

br  id_viv id_region id_consecutivo id_clase  localidad id_segmento id_manzana id_edificacion id_vivienda