# Inequality of the crowding-out effect of tobacco expenditure in Colombia

This repository includes the scripts required to replicate the main findings of the article "Inequality of the crowding-out effect of tobacco expenditure in Colombia" published in PLOSONE. We include a minimum dataset for the replicability of tables and figures, but the base datasets can be obtained from the ANDA repository: https://microdatos.dane.gov.co/catalog/MICRODATOS/about. If you need something more detailed on the construction of the data, please contact us.

## Contents
 0. Folder scriptsECV take base ECV files and generates standardized versions of them for this paper. For instance, health expenditures and income. Needs original datasets from DANE.
 1. ECVREP_01_compile.do and ECVREP_02_matchData.do generate the file. Needs outputs from the previous points. These files produce ["ECVrepeat_preMatch.dta"](https://www.dropbox.com/scl/fi/xsxqak1jgdccugqy2yvaq/ECVrepeat_preMatch.dta?rlkey=x9fqzhlq772xytbmvyl9x52fq&dl=0). This file can be downloaded here: 
 2. ECVREP_02b_matchData.r produces de genetic matching and generates  ["ECV_pesosAfterMatchingSmokers.dta"]([https://link-url-here.org](https://www.dropbox.com/scl/fi/hbrtje6b1o9qmum7xd5ld/ECV_pesosAfterMatchingSmokers.dta?rlkey=5cf55bmm0r8u89l3mqa1oau53&dl=0))
 3. ECVREP_03_SUREanalysis.do compiles the two datasets described above into ["$mainF\ECVrepeat_a8.dta"](https://www.dropbox.com/scl/fi/lhjhe4wj9kxkbje1cc2w3/ECVrepeat_a8.dta?rlkey=4y13254r7ocg30zys0vvomei8&dl=0). With this file is possible to run the SURE analyses.
