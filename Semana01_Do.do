* Econometría Avanzada
* Clase Complementaria
* 2023-1
clear all
cap log close
set more off, perm
cls /7


*********************************************************************************
** CLASE 1-	INTRODUCCIÓN A STATA 											   **
*********************************************************************************

* 0. Carpeta de trabajo:


* -------------------------------------------------------------------------------

/* Antes de comenzar a utilizar Stata es importante organizar la carpeta sobre la 
	cual vamos a hacer el análisis estadístico. Al trabajar en Stata tipicamente:
	   
		(1) Abrimos bases de datos y do-files previamente trabajados.  
		(2) Guardamos los outputs de nuestro análisis (bases modificadas, 
			graficas, tablas, etc.). 											*/
				
*) Cree una carpeta llamada "Clase 01".
	
*) Dentro de esta carpeta, cree dos carpetas: (1) "raw_data" (2) "output". 
	
*) En la carpeta "Clase 01" guarde este Do-file.
	
*) En la carpeta "raw_data" debe guardar los archivos con datos de Bloque Neón.
	
*) En la carpeta "output" vamos a guardar todos los archivos modificados. 

* 1. ¿Cómo funciona Stata?
* -------------------------------------------------------------------------------

*) Cómo abrir Stata y el do-file de la clase 
	
*) Ventanas en Stata
		
	* Ventana de comandos
	* Ventana de resultados
	* Ventana de variables
	* Ventana de propiedades
	* Ventana de revisión
	
*) Dos tipos de archivos: do-files y log-files
	* Do-file
	* Log-files
		
	* Antes de iniciar defina manuelmente su directorio como la carpeta de 		
	* "Clase 01" (ya revisaremos cómo hacerlo de forma automática)
	
	*Fijar directorio de trabajo
	cd "C:\Users\andre\OneDrive\ANDRES CARRILLO\EDUCACIÓN\POSGRADO\MEcA\2023_10\ECON4301_ECONOMETRÍA AVANZADA\2.Clase complementaria\Clase 01"
	
	log using "output/Econometría_Avz_`c(current_date)'.log", replace

	display "Clase 1- Econometría Avanzada"
	di 2+2
	sysuse dir /* Bases de datos guardadas										*/

	log close 
	translate "output/Econometría_Avz_`c(current_date)'.log" 				    ///
		"output/Econometría_Avz_`c(current_date)'.pdf", replace 

*) ¿Cómo buscar ayuda? 
	
	* Helpfiles 
	help tabulate oneway
	search tabulate	/* Busca todos los help/otros files que mencionan 'tabulate'*/

		* 1ro: Nombre del comando.
		* 2do: Los argumentos obligatorios.
		* 3ro: Entre llaves "[]" los argumentos opcionales.
		* 4to: Después de la coma (,) las opciones (también en []).
		* 5to: Descripción de todas las opciones.
	
	* Internet: Googlear la pregunta (en inglés)
	* 		i.e. Stata list, stackoveflow
	
	* Revisar en los links de ayuda de stata o en do de Outputs (Bloque Neón).
	
	* Preguntarle a cualquier miembro del equipo
	
*) Búsqueda e instalación de paquetes
ssc install hprescott /* Official: Instalación de paquetes 						*/
ssc describe hprescott 
findit hodrick prescott /* User written: Busqueda de paquetes 					*/

*) Directorio
		
	* Definición del directorio: 
	* cd "directorio"	
	global dir "Econ. Av. - COMP/2022-2/2. Clase complementaria/Semana 01"
	
	if "`c(username)'"=="Dac12" {
	cd "C:\Users\Dac12\OneDrive - Universidad de los Andes/${dir}"
	}
	
	else if "`c(username)'"=="valentinacastillagutierrez"{
	cd "/Users/valentinacastillagutierrez/Library/CloudStorage/OneDrive-UniversidaddelosAndes/${dir}"
} 
	
	else if "`c(username)'"=="andre"{
	cd "C:\Users\andre\OneDrive - Universidad de los Andes/${dir}"
} 
	
	
	else //cd "ESTUDIANTE: COPIE AQUÍ LA RUTA DE SU DIRECTORIO"
	
	
	* En qué directorio estamos trabajando	
	pwd
		
	* Archivos en el directorio
	dir
	
* 2. Importación de datos
* -------------------------------------------------------------------------------
		
*) Excel
import excel "raw_data/CasosDengue.xlsx", firstrow clear 
	/* "firstrow" la primela fila del excel son los nombres de las variables	*/
	
	
* Similarmente:	

	* Para .csv usar el comando "import delimited"
	* Para bases de Stata (.dta) usar el comando "use" 	
	
	
* 3. Comandos iniciales		
* -------------------------------------------------------------------------------
		
*) compress+save: guardar base de datos
import excel "raw_data/CasosDengue.xlsx", firstrow clear
	
	* Guardar base optimizando espacio
	compress

	* opción "replace" para sobreescribir
	save "output/base.dta", replace
		
*) browse and desribe: Exploración de los datos
		
	* Descripción del contenido
	describe
	
	* Ver de la base de datos
	br
	

*) Organización de datos	
use "output/base.dta", clear // abrir bases en el formato nativo de stata
	
	* Renombrar variables
	rename area zona
	ren (population week) (poblacion semana)
		
	* Poner etiquetas a variables, datos y valores
	label var semana "Semana Epidemiologica"
	label data "Bases de datos sobre casos de Dengue en 2011"
	label define unoatres 1 "Uno" 2 "Dos" 3 "Tres", modify
	label values semana unoatres
	tab semana

	* Ordenar VARIABLES en la base.
	order semana departamento casos	  
	des
	
	* Ordenar OBSERVACIONES. Menor a Mayor
	sort semana						  
	list semana in 1/4
	
	* Ordenar OBSERVACIONES. Mayor a Menor
	gsort - semana 	
	
	list semana in 1/4
	sort departamento zona semana
	  				
* 4. Creación de variables
* -------------------------------------------------------------------------------

*) Creación básica
gen incidencia = casos/poblacion * 100000 /* por cada 100,000 habitantes 		*/
gen casos2 = casos^2
gen log_incidencia = log(incidencia)
	
*) Variables con condiciones
gen casos_brote = (casos >= 50 & casos != .)
tab casos_brote
cap drop casos_brote
gen casos_brote = cond(casos >= 50 & casos != .,1,cond(casos == .,.,0))

*) Reemplazos y recodificaciones
*replace casos_brote = 0 if casos_brote == .
recode casos_brote (. = 0)

*) egen 
egen promedio_casos = mean(casos)		
bysort departamento: egen prome_dpto_casos = mean(casos)



* 5. Condicionales
* -------------------------------------------------------------------------------

*) if 
if 2==2 {
	di "Hola"
}

*) else if y else
scalar a=3
if a==1 {
	di "a es 1"	
}
else if a==2 {
	di "a es 2"
}
else {
	di "a no es 1 ni 2"
}

* 6. Macros y Loops
* -------------------------------------------------------------------------------


*) global
global prueba "Antioquia Santander Meta Tolima Vichada" 	
di "$prueba"

macro list

*) local
local controles casos incidencia 
di "`controles'"

macro list

*) Loop

*En Stata hay tres tipos de Loops:

	*forvalues: recorre elementos de una lista de números enteros que siguen
	*un patrón definido.
	
	*foreach: recorre elementos de una lista arbitraria
	
	*while: ejecuta un comando hasta que se cumpla una condición lógica


	* Ejemplo 1
	foreach persona in Manuel David Valentina Andrea Camilo Daniel {
		di "`persona'"
	}

	* Ejemplo 2
	local n=0
	foreach persona in $prueba {
		local ++n
		di "`n'. `persona'"
	}
	
	* Ejemplo 3
	foreach dep of global prueba{
		di "*********`dep'*********"
		forvalues j = 1(1)5{
			dis "`j'"
		}
	}
	
	
	*Ejemplo 4
	local j=0
	forvalues i=1(1)5 {
		local j=`j'+`i'
		di `j'
	}
	
	
	*Ejemplo 5
	local i=0
	while `i'<5 {
		local ++i
		di `i'
	}
	

* 7. Figuras y Tablas
* -------------------------------------------------------------------------------
* Este tema lo iremos aprendiendo sobre la marcha.
* Sin embargo, les dejamos un do-file tutuorial de cómo hacer figuras y gráficas
* en Bloque Neón:

	*Links y documentos de ayuda -> Outputs de Stata -> DoFile Outputs.

*********************************************************************************
**  Ejercicio: haga un loop que muestre en la ventana de resultados cada uno   **
** 	de los números del 1 al 10 seguido del texto "es par"/"es impar", según    **
** 	corresponda. Pista: Explore los condicionales if y else. 				   **
*********************************************************************************
