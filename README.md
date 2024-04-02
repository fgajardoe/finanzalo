# finanzalo
Un script en R para visualizar tus finanzas.

Mas concretamente, genera reportes en `PDF` y visualizaciones interactivas en `html` utiles para visualizar en que y cuando gastas tu dinero. Como nació como un proyecto personal, hasta ahora solo reconoce el formato `xls` que se descarga del Banco de Chile, pero adaptarlo a otros bancos es totalmente posible.

# Usage

En general:

```
Rscript finanzalo.R CARTOLAS.lst
```

Producirá los plots.

Aqui, el archivo `CARTOLAS.lst` es un archivo de texto plano con una lista de archivos `xls` que cubren el periodo a graficar. Por ejemplo:

`CARTOLAS_2024.lst`

```
cartola_01-01-2024_10-02-2024.xls
cartola_10-02-2024_26-03-2024.xls
#cartola_27-03-2024_28-03-2024.xls
cartola_12-02-2024_28-03-2024.xls
cartola_14-02-2024_30-03-2024.xls
```

Aqui podemos destacar varias cosas. Primero, que el script soporta fechas sobrelapadas, por lo que no tendras que preocuparte por transacciones duplicadas. Segundo, puedes comentar archivos `xls` para que sean ignorados del análisis. 

Finalmente, yo creo que es conveniente tener un archivo de cartolas (`.lst`) por año`, porque si se juntan dos el eje x crece mucho y no se nota, pero ustedes hagan lo que quieran.
