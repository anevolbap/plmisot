* COMENTARIOS DE CADA ARCHIVO

1) simular.R admite initial y fLoss:
   initial : 'cl', 'rb', 'ay', 'mmiso'
   fLoss   : 'cl', 'hb', 'l1, 'tk',

2) simularAY.R:
   'ay'     :	estimador de nucleos y Alv-Yoh (tiene una salida distinta al anterior)

3) generar.R: 	genera muestras contaminadas (o no) 

   Hay tres modelos:
   a) ay:   como el paper de Alvarez-Yohai
   b) du:   como el paper de Du
   c) sosa: como la tesis de Sosa con algunos escenarios nuevos de contaminacion
   
4) La minimizacion es un tema...
   
   - minimizar.R:	estima minimizando (clasico y MM)
   - mpl.R: 		estima con Alv-Yoh
   - procesar: 		rutinas para elegir la cantidad de splines por
     BIC y medidas de resumen
