
clear all
 cd "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T4\Nueva carpeta (2)"

import excel "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T4\Precio_Cobre.xls", sheet("FRED Graph") firstrow

 

replace Date = mofd(Date)
format Date %tm
tsset Date, monthly
 
 
 //1\\

pperron PrecioCobre // No stationa
arima  PrecioCobre, arima(12,0,0)
estat aroots,  plotregion(lcolor(black)) ///
	ytitle("Eje de Nros. Imaginarios") ///
	xtitle("Eje de Nros. Reales")
predict res_Cobre, residuals

pperron res_Cobre // Residuo Estacionario!!

tsline res_Cobre, legend(off) ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("Innovaciones del Precio del Cobre")  ytitle("Residuo") xtitle("Fecha") ///
	lcolor(midblue)

// graph export "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T4\g1.png", replace
//graph export "H:\Mi unidad\U\Macroeconometría Aplicada\2023 - 2\Evaluaciones\Tareas\Tarea 4\Recibo de Envíos Raúl\T4\T4\plots_png\g1.png", replace
 

 // 2 \\
 
 
preserve
import excel "IPC", sheet("Cuadro") firstrow clear 
replace Date = mofd(Date)

format Date %tm     
tsset  Date, monthly

tempfile REC
save `REC'
restore
merge 1:1 Date using `REC', nogenerate



preserve
import excel "Imacec", sheet("Cuadro") firstrow clear 
replace Date = mofd(Date)

format Date %tm     
tsset  Date, monthly

tempfile REC
save `REC'
restore
merge 1:1 Date using `REC', nogenerate



preserve
import excel "Imacec_Nominero", sheet("Cuadro") firstrow clear 
replace Date = mofd(Date)

format Date %tm     
tsset  Date, monthly

tempfile REC
save `REC'
restore
merge 1:1 Date using `REC', nogenerate


gen log_Imacec = log(Imacec)
gen log_Imacec_Nm = log(ImacecNoMinero)

tsline IPC, legend(off) ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("IPC") ///
	xtitle("Fecha") ///
	lcolor(midblue)

	
// 	graph export "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T4\g3.png", replace
	//graph export "H:\Mi unidad\U\Macroeconometría Aplicada\2023 - 2\Evaluaciones\Tareas\Tarea 4\Recibo de Envíos Raúl\T4\T4\plots_png\g3.png", replace
	
	
tsline log_Imacec, legend(off) ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("IMACEC Desestacionalizado") ///
	ytitle("log(Imacec)") ///
	xtitle("Fecha") ///
	lcolor(midblue)	
	
// 	graph export "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T4\g4.png", replace
	//graph export "H:\Mi unidad\U\Macroeconometría Aplicada\2023 - 2\Evaluaciones\Tareas\Tarea 4\Recibo de Envíos Raúl\T4\T4\plots_png\g4.png", replace

tsline log_Imacec_Nm, legend(off) ///
	plotregion(lcolor(black)) ///
	ylab(, nogrid) xlab(, nogrid) ///
	title("IMACEC No Minero Desestacionalizado") ///
	ytitle("log(Imacec No Minero)") ///
	xtitle("Fecha") ///
	lcolor(midblue)	
	
// 	graph export "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T4\g5.png", replace
//	graph export "H:\Mi unidad\U\Macroeconometría Aplicada\2023 - 2\Evaluaciones\Tareas\Tarea 4\Recibo de Envíos Raúl\T4\T4\plots_png\g5.png", replace




 // 3 \\
 

gen t=_n
gen h = t - 1



foreach var in log_Imacec log_Imacec_Nm  PrecioCobre{ 

  quietly gen b`var' = .
  quietly gen up90b`var' = .
  quietly gen lo90b`var' = .
  
} 



forvalues i = 0/18 { //horizonte


 foreach var in log_Imacec log_Imacec_Nm  PrecioCobre{

       qui newey F`i'.`var' res_Cobre L(1/12).log_Imacec L(1/12).log_Imacec_Nm L(1/12).IPC, lag(`=`i' + 1') 

      gen b`var'h`i' = _b[res_Cobre]
  
       gen se`var'h`i' = _se[res_Cobre]
  
     quietly replace b`var' = b`var'h`i' if h==`i' 
     quietly replace up90b`var' = b`var'h`i' + 1.68*se`var'h`i' if h==`i'
	 quietly replace lo90b`var' = b`var'h`i' - 1.68*se`var'h`i' if h==`i'
	
  }
  
}


set graphics off
foreach var in log_Imacec log_Imacec_Nm PrecioCobre { 
tw (rarea up90b`var' lo90b`var' h, bcolor(gs14) clw(medthin medthin)) ///
  (scatter b`var' h, c(l) clp(l) ms(i) clc(black) mc(black) clw(medthick))if h<=18, ///
  xtitle("") ytitle(`var') legend(off) name(vargk_`var',replace)
}

 set graphics on
graph combine  vargk_log_Imacec vargk_log_Imacec_Nm vargk_PrecioCobre,title("Shock del Precio del Cobre")  name(LP, replace)

// Parámetros estéticos

set graphics off
tw (rarea up90blog_Imacec lo90blog_Imacec h, plotregion(lcolor(black)) bcolor(gs14) clw(medthin medthin)) ///
  (scatter blog_Imacec h, c(l) clp(l) ms(i) clc(black) mc(black) clw(medthick))if h<=18, ///
  xtitle("") ytitle("ln(Imacec)") legend(off) name(vargk_log_Imacec ,replace)

tw (rarea up90blog_Imacec_Nm lo90blog_Imacec_Nm h, plotregion(lcolor(black)) bcolor(gs14) clw(medthin medthin)) ///
  (scatter blog_Imacec_Nm h, c(l) clp(l) ms(i) clc(black) mc(black) clw(medthick))if h<=18, ///
  xtitle("") ytitle("ln(Imacec No Minero)") legend(off) name(vargk_log_Imacec_Nm ,replace)

tw (rarea up90bPrecioCobre lo90bPrecioCobre h, plotregion(lcolor(black)) bcolor(gs14) clw(medthin medthin)) ///
  (scatter bPrecioCobre h, c(l) clp(l) ms(i) clc(black) mc(black) clw(medthick))if h<=18, ///
  xtitle("") ytitle("ln(Precio del Cobre)") legend(off) name(vargk_PrecioCobre ,replace)
  
 set graphics on
graph combine  vargk_log_Imacec vargk_log_Imacec_Nm vargk_PrecioCobre,title("Shock del Precio del Cobre")  name(LP, replace)


//  graph export "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T4\g6.png", replace
// graph export "H:\Mi unidad\U\Macroeconometría Aplicada\2023 - 2\Evaluaciones\Tareas\Tarea 4\Recibo de Envíos Raúl\T4\T4\plots_png\g6.png", replace




// 4 \\


//gen t=_n
//gen h = t - 1




gen PrecioCobre_n =.
replace PrecioCobre_n = res_Cobre

foreach var in IPC PrecioCobre_n { 

  quietly gen b`var' = .  
  quietly gen up90b`var' = .
  quietly gen lo90b`var' = .
  
} 



forvalues i = 0/18 { //horizonte


 foreach var in IPC PrecioCobre_n {

       qui newey F`i'.`var' res_Cobre  L(1/12).log_Imacec L(1/12).log_Imacec_Nm L(1/12).IPC, lag(`=`i' + 1') //ecuación de local proyections

       gen b`var'h`i' = _b[res_Cobre]
  
       gen se`var'h`i' = _se[res_Cobre]
  
     quietly replace b`var' = b`var'h`i' if h==`i' 
     quietly replace up90b`var' = b`var'h`i' + 1.68*se`var'h`i' if h==`i'
	 quietly replace lo90b`var' = b`var'h`i' - 1.68*se`var'h`i' if h==`i'
	
  }
  
}



// set graphics off
// foreach var in IPC PrecioCobre_n { 
// tw (rarea up90b`var' lo90b`var' h, bcolor(gs14) clw(medthin medthin)) ///
//   (scatter b`var' h, c(l) clp(l) ms(i) clc(black) mc(black) clw(medthick))if h<=18, ///
//   xtitle("") ytitle(`var') legend(off) name(vargk_`var',replace)
// }

set graphics off
foreach var in IPC { 
tw (rarea up90b`var' lo90b`var' h, plotregion(lcolor(black)) bcolor(gs14) clw(medthin medthin)) ///
  (scatter b`var' h, c(l) clp(l) ms(i) clc(black) mc(black) clw(medthick))if h<=18, ///
  xtitle("") ytitle("Inflación") legend(off) name(vargk_`var',replace)
}

set graphics on
graph combine  vargk_IPC vargk_PrecioCobre ,title("Shock del Precio del Cobre")  name(LP, replace)

//  graph export "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T4\g7.png", replace
//  graph export "H:\Mi unidad\U\Macroeconometría Aplicada\2023 - 2\Evaluaciones\Tareas\Tarea 4\Recibo de Envíos Raúl\T4\T4\plots_png\g7.png", replace

  

