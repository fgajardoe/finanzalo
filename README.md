# finanzalo
Un script en R para visualizar tus finanzas.

Mas concretamente, genera reportes en `PDF` y visualizaciones interactivas en `html` utiles para visualizar en que y cuando gastas tu dinero. Como nació como un proyecto personal, hasta ahora solo reconoce el formato `xls` que se descarga del Banco de Chile, pero adaptarlo a otros bancos es totalmente posible.


# Installation

Install `R` y todos estos paquetes:

```
install.packages("tidyverse")
install.packages("ggrepel")
install.packages("readxl")
install.packages("reshape2")
install.packages("plotly")
install.packages("htmlwidgets")
install.packages("rmarkdown")
```

# Usage

En general:

```
Rscript finanzalo.R CARTOLAS.lst
```

Producirá los plots en el directorio donde se encuentra `CARTOLAS.lst`, el cual es un archivo de texto plano con una lista de archivos `xls` que cubren el periodo a graficar. Por ejemplo:

`CARTOLAS_2024.lst`:

```
cartola_01-01-2024_10-02-2024.xls
cartola_10-02-2024_26-03-2024.xls
#cartola_27-03-2024_28-03-2024.xls
cartola_12-02-2024_28-03-2024.xls
cartola_14-02-2024_30-03-2024.xls
```

Aqui podemos destacar varias cosas. Primero, que el script soporta fechas sobrelapadas, por lo que no tendras que preocuparte por transacciones duplicadas. Segundo, puedes comentar archivos `xls` para que sean ignorados del análisis. 

Finalmente, es buena idea tener un archivo de cartolas (`.lst`) por año, porque sino el eje x crece mucho y no se nota, pero ustedes hagan lo que quieran.
