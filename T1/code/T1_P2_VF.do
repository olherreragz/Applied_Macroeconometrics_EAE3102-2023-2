clear all
cd "C:\Users\theen\OneDrive\Escritorio\MacroEconometria\T1"

import excel "Datos_Tarea1_BC", sheet("Hoja1") firstrow

format Periodo %tm
replace Periodo = mofd(Periodo)

tsset Periodo

gen t = _n



//1
rename Imacec Yt 
rename ActivosdeReserva Rt

twoway (scatter M2 Yt, mcolor(edekblue) msize(medium) msymbol(circle_hollow)) (lfit M2 Yt, lcolor(red))
twoway (scatter M2 Rt, mcolor(edekblue) msize(medium) msymbol(circle_hollow)) (lfit M2 Rt, lcolor(red))

// Teoría Cuanto P*Y = M*V/
// Se aprecia una correlación positiva entre M2 y Yt, si tomamos como proxy Imacec al % de crecimiento del PIB, vemos que según la Tería Cuantitativa Yt Sube- M Sube, todo lo demás cte.
// Podemos tomar al M2 como proxy de la Base Monetaria, ??? si es así M  M = C + R, M sube, R sube


//2
newey M2 L.M2 L2.M2, lag(7)

reg M2 L.M2 L2.M2, r // Estamos subestimando los errores al sólo corregir por Robust y no
// con matriz HAC. Aún así, obtenemos los mismo resultados

pperron M2 // p-value < 0.05, por tanto, rechazo Ho --> La serie no tiene raíces unitarias --> ergo la serie es ergódica 


//3
// Para esta parte el desarrollo algebraico irá en el informe
newey M2 L.M2 L2.M2, lag(7)
predict residuos1, residuals
gen c_LM2 = _b[L.M2] // guardamos coeficientes los beta's y constante
gen c_L2_M2 = _b[L2.M2] 
gen constante = _b[_cons]
summarize residuos1, detail
local varianza_residuos = r(var)
gen var_r = 1.86


// Construimos la Esperanza Incondicional y la Varianza 
// Por otro lado tenemos que la Media condicional al set de información, es la serie en cada momento
gen Media_M2 = constante/(1-c_LM2-c_L2_M2)
gen Varianza_M2 = (1-c_L2_M2)*var_r / ((1+c_L2_M2)*[(1-c_L2_M2)^2-c_LM2^2])
tsline M2 Media_M2


//4 
//Generamos la variable covid,  y le damos valor 1 y 0, según lo pedido.
gen covid =.
replace covid = 0 if  t < 279 | t > 303
replace covid = 1 if covid ==.

gen covid_L = covid*L.M2
gen covid_L2 = covid*L2.M2
newey M2 L.M2 L2.M2 covid covid_L covid_L2, lag(7)
// Tenemos que casit todos los coeficientes son significativos  al 5%, 
// lo que no es significativo es la variable L2.Covid
//Interpretacion ?



//5
//Covid_L2 sigue siendo no significativo, Covid tampoco lo es, Como tampoco lo son las variables Yt y su rezago. Las demás son significativos.
//Intepretacion?

newey M2 L.M2 L2.M2 covid covid_L covid_L2 Yt L.Yt Rt L.Rt, lag(7)

//6 

//7 Ho el residuo es de ruido blanco
predict residuos3, residuals
wntestq residuos3, lags(10)


//8
twoway (scatter M2 TPM, mcolor(edekblue) msize(medium) msymbol(circle_hollow)) (lfit M2 TPM)
xaxis(min(0.5) max(13))
yaxis(min(-3) max(24)

drop if t <14
newey M2 L.M2 L2.M2 covid covid_L covid_L2 Yt L.Yt Rt L.Rt TPM_2, lag(7)