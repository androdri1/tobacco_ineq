* Author: Paul Rodriguez (paul.rodriguez@ur.edu.co)
* Date: 2017.06.30
* Goal: Moves ENCV data from SPSS into Stata

unicode encoding set Latin1

glo dropbox "C:\Users\paul.rodriguez\Dropbox"

cd "$dropbox\tabaco\Tobacco-health-inequalities\data\ENCV2011"


local files : dir . files "*.sav"
foreach filo in `files' {
	disp "`filo'"
	usespss `filo', clear
	saveold "`filo'.dta", replace
}
