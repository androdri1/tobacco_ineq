* Author: Paul Rodriguez (paul.rodriguez@urosario.edu.co)
* Date: 2017.07.05
* Goal: Moves ENCV2008 data from SPSS into Stata

*unicode encoding set Latin1

glo dropbox "C:\Users\paul.rodriguez\Dropbox"

cd "$dropbox\tabaco\Tobacco-health-inequalities\data\ENCV2008"


local files : dir . files "*.sav"
foreach filo in `files' {
	disp "`filo'"
	usespss `filo', clear
	saveold "`filo'.dta", replace
}
