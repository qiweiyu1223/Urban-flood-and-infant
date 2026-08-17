		
keep if  strpos(parm, "occurred") |  strpos(parm, "ratio") | strpos(parm, "area") | strpos(parm, "days")


	
gen index = .
replace index =1 if strpos(parm, "occurred")
replace index =2 if strpos(parm, "ratio")
replace index =3  if strpos(parm, "area")
replace index =4 if strpos(parm, "days")
	
	
gen month = .
replace month = 3  if strpos(parm, "3m")
replace month = 6  if strpos(parm, "6m")
replace month = 9  if strpos(parm, "9m")
replace month = 12 if strpos(parm, "12m")