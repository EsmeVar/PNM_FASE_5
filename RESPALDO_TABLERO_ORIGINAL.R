---
  title: "MONITOREO DE LA CALIDAD DEL AGUA SUPERFICIAL (ETAPA I)"
output: 
  flexdashboard::flex_dashboard:
  orientation: rows
social: menu
source_code: embed
vertical_layout: fill    
---
  
  ```{r setup, include=FALSE}

#-------------------- Paquetes --------------------

library(flexdashboard)
library(plotly)
library(dplyr)
library(tidyr)
library(sf)
library(leaflet)

#-------------------- Colores ---------------------

color_positivos <- 'blue'
color_activos <- 'red'
color_recuperados <- 'green'
color_fallecidos <- 'purple'

color_nuevos_positivos <- 'pink'

color_hospitalizados <- 'pink'
color_salon <- 'pink'
color_uci <- 'pink'

#--------------------- Íconos ---------------------

icono_positivos <- 'fas fa-ambulance'
icono_activos <- 'fas fa-briefcase-medical'
icono_recuperados <- 'fas fa-file-medical'
icono_fallecidos <- 'fas fa-plus'
icono_nuevos_positivos <- 'fas fa-user-md'
icono_hospitalizados <- 'fas fa-hospital'
icono_salon <- 'fas fa-hospital-alt'
icono_uci <- 'fas fa-procedures'

#--------------- Otros parámetros -----------------

# Separador para lectura de datos CSV
caracter_separador <- ','
```


```{r, include=FALSE}
#--------------- Archivos de datos ----------------

archivo_general_pais <- 'https://raw.githubusercontent.com/pf0953-programaciongeoespacialr-2020/datos/master/covid19/ms/11_10_CSV_GENERAL.csv'

archivo_positivos_cantones <- 'https://raw.githubusercontent.com/pf0953-programaciongeoespacialr-2020/datos/master/covid19/ms/11_10_CSV_POSITIVOS.csv'
archivo_activos_cantones <- 'https://raw.githubusercontent.com/pf0953-programaciongeoespacialr-2020/datos/master/covid19/ms/11_10_CSV_ACTIVOS.csv'
archivo_recuperados_cantones <- 'https://raw.githubusercontent.com/pf0953-programaciongeoespacialr-2020/datos/master/covid19/ms/11_10_CSV_RECUP.csv'
archivo_fallecidos_cantones <- 'https://raw.githubusercontent.com/pf0953-programaciongeoespacialr-2020/datos/master/covid19/ms/11_10_CSV_FALLECIDOS.csv'
```

```{r, include=FALSE}
#---------------------- Datos ---------------------

# Data frame de datos generales por país
df_general_pais <- read.csv(archivo_general_pais, sep = caracter_separador)
df_general_pais$FECHA <- as.Date(df_general_pais$FECHA, "%d/%m/%Y")

# Data frame de datos generales por país en la última fecha
df_general_pais_ultima_fecha <- 
  df_general_pais %>%
  filter(FECHA == max(FECHA, na.rm = TRUE))

# Data frame de casos positivos por cantón
df_positivos_cantones_ancho <- read.csv(archivo_positivos_cantones, sep = caracter_separador)
df_positivos_cantones <-
  df_positivos_cantones_ancho %>%
  pivot_longer(cols = c(-cod_provin, -provincia, -cod_canton, -canton), names_to = "fecha", values_to = "positivos")
df_positivos_cantones$fecha <- as.Date(df_positivos_cantones$fecha, "X%d.%m.%Y")

# Data frame de casos positivos por cantón en la última fecha
df_positivos_cantones_ultima_fecha <- 
  df_positivos_cantones %>%
  filter(fecha == max(fecha, na.rm = TRUE)) %>%
  select(cod_canton, positivos)

# Data frame de casos activos por cantón
df_activos_cantones_ancho <- read.csv(archivo_activos_cantones, sep = caracter_separador)
df_activos_cantones <-
  df_activos_cantones_ancho %>%
  pivot_longer(cols = c(-cod_provin, -provincia, -cod_canton, -canton), names_to = "fecha", values_to = "activos")
df_activos_cantones$fecha <- as.Date(df_activos_cantones$fecha, "X%d.%m.%Y")

# Data frame de casos activos por cantón en la última fecha
df_activos_cantones_ultima_fecha <- 
  df_activos_cantones %>%
  filter(fecha == max(fecha, na.rm = TRUE)) %>%
  select(cod_canton, activos)

# Data frame de casos recuperados por cantón
df_recuperados_cantones_ancho <- read.csv(archivo_recuperados_cantones, sep = caracter_separador)
df_recuperados_cantones <-
  df_recuperados_cantones_ancho %>%
  pivot_longer(cols = c(-cod_provin, -provincia, -cod_canton, -canton), names_to = "fecha", values_to = "recuperados")
df_recuperados_cantones$fecha <- as.Date(df_recuperados_cantones$fecha, "X%d.%m.%Y")

# Data frame de casos recuperados por cantón en la última fecha
df_recuperados_cantones_ultima_fecha <- 
  df_recuperados_cantones %>%
  filter(fecha == max(fecha, na.rm = TRUE)) %>%
  select(cod_canton, recuperados)

# Data frame de casos fallecidos por cantón
df_fallecidos_cantones_ancho <- read.csv(archivo_fallecidos_cantones, sep = caracter_separador)
df_fallecidos_cantones <-
  df_fallecidos_cantones_ancho %>%
  pivot_longer(cols = c(-cod_provin, -provincia, -cod_canton, -canton), names_to = "fecha", values_to = "fallecidos")
df_fallecidos_cantones$fecha <- as.Date(df_fallecidos_cantones$fecha, "X%d.%m.%Y")

# Data frame de casos fallecidos por cantón en la última fecha
df_fallecidos_cantones_ultima_fecha <- 
  df_fallecidos_cantones %>%
  filter(fecha == max(fecha, na.rm = TRUE)) %>%
  select(cod_canton, fallecidos)

# Objeto sf de cantones
sf_cantones <- st_read('https://raw.githubusercontent.com/pf0953-programaciongeoespacialr-2020/datos/master/delimitacion-territorial-administrativa/cr/ign/cr_limite_cantonal_ign_wgs84.geojson')

# Objeto sf de casos positivos en cantones en la última fecha
sf_positivos_cantones_ultima_fecha <-
  left_join(sf_cantones, df_positivos_cantones_ultima_fecha, by = c('cod_canton')) %>%
  arrange(desc(positivos))

# Objeto sf de casos activos en cantones en la última fecha
sf_activos_cantones_ultima_fecha <-
  left_join(sf_cantones, df_activos_cantones_ultima_fecha, by = c('cod_canton')) %>%
  arrange(desc(activos))

# Objeto sf de casos recuperados en cantones en la última fecha
sf_recuperados_cantones_ultima_fecha <-
  left_join(sf_cantones, df_recuperados_cantones_ultima_fecha, by = c('cod_canton')) %>%
  arrange(desc(recuperados))

# Objeto sf de casos fallecidos en cantones en la última fecha
sf_fallecidos_cantones_ultima_fecha <-
  left_join(sf_cantones, df_fallecidos_cantones_ultima_fecha, by = c('cod_canton')) %>%
  arrange(desc(fallecidos))

```

```{r, include=FALSE}
#---------------------- Datos de distritos ---------------------
archivo_general_distritos_old <- 'https://raw.githubusercontent.com/geoprocesamiento-2020i/datos/master/covid19/ms/07_02_CSV_GENERAL_DISTRITOS.csv'
archivo_general_distritos <- 'https://raw.githubusercontent.com/pf0953-programaciongeoespacialr-2020/datos/master/covid19/ms/11_17_CSV_DISTRITOS.csv'
# Carga del archivo CSV en un data frame
df_general_distritos_sucio_old <- read.csv(archivo_general_distritos_old)
df_general_distritos_sucio <- read.csv(archivo_general_distritos)
# Eliminación de filas y columnas que corresponden a encabezados, totales, etc.
df_general_distritos_ultima_fecha_old <- df_general_distritos_sucio_old[-c(1:5), -c(1, 3, 10, 11)]
df_general_distritos_ultima_fecha <- df_general_distritos_sucio[-c(1:7), -c(1, 2, 4)]
# Cambio de nombre de las columnas
df_general_distritos_ultima_fecha <- 
  df_general_distritos_ultima_fecha %>%
  rename(provincia = X.2,
         canton = X.4,
         distrito = X.5,
         positivos = X.6,
         recuperados = X.7,
         fallecidos = X.8,
         activos = X.9
  ) %>%  
  mutate_all(funs(sub("^\\s*$", NA, .))) %>% # Se llenan con NA las celdas con espacios vacíos
  mutate(distrito = if_else(distrito == "El Carmen", "Carmen", distrito)) %>%
  mutate(distrito = if_else(distrito == "Valle de La Estrella", "Valle La Estrella", distrito)) %>%
  mutate(distrito = if_else(distrito == "La Amistad", "La  Amistad", distrito)) %>%
  fill(c(1,2)) # Se rellenan "hacia abajo" las columnas de provincia y cantón con valor NA
# Borrado de las filas con valor de NA o de "Sin información de distrito" en la columna de distrito
df_general_distritos_ultima_fecha <- df_general_distritos_ultima_fecha[!is.na(df_general_distritos_ultima_fecha$distrito), ]
df_general_distritos_ultima_fecha <- df_general_distritos_ultima_fecha[df_general_distritos_ultima_fecha$distrito != 'Sin información de distrito', ]
# Conversión a integer de los tipos de datos de las columnas con cifras
df_general_distritos_ultima_fecha$positivos <- as.integer(df_general_distritos_ultima_fecha$positivos)
df_general_distritos_ultima_fecha$recuperados <- as.integer(df_general_distritos_ultima_fecha$recuperados)
df_general_distritos_ultima_fecha$fallecidos <- as.integer(df_general_distritos_ultima_fecha$fallecidos)
df_general_distritos_ultima_fecha$activos <- as.integer(df_general_distritos_ultima_fecha$activos)
# Objeto sf de distritos
# Capa simplificada
sf_distritos <- st_read('https://raw.githubusercontent.com/pf0953-programaciongeoespacialr-2020/datos/master/delimitacion-territorial-administrativa/cr/ign/cr_limite_distrital_ign_wgs84.geojson')
# Capa detallada
# sf_distritos <- st_read('https://raw.githubusercontent.com/pf0953-programaciongeoespacialr-2020/datos/master/delimitacion-territorial-administrativa/cr/ign/cr_distritos_ign_wgs84.geojson')
# Objeto sf de casos general en distritos en la última fecha
sf_general_distritos_ultima_fecha <-
  left_join(sf_distritos, df_general_distritos_ultima_fecha, by = c('provincia', 'canton', 'distrito'))

# Datos positivos distrito para gráfico pastel
df_distritos_positivos_top10 <- (df_general_distritos_ultima_fecha) %>%
  mutate(distritos= factor (positivos, levels = sort(unique(df_general_distritos_ultima_fecha$positivos)))) %>%
  select(distrito, positivos) %>%
  top_n(n = 10, wt = positivos)

df_distritos_positivos_otros <- (df_general_distritos_ultima_fecha) %>%
  mutate(distritos= factor (positivos, levels = sort(unique(df_general_distritos_ultima_fecha$positivos)))) %>%
  select(distrito, positivos) %>%
  slice(11:487)%>%
  summarize(distrito="otros", positivos = sum(positivos))

df_distritos_pastel_positivos <- rbind(df_distritos_positivos_top10,df_distritos_positivos_otros)

# Datos activos distrito para gráfico pastel

df_distritos_activos_top10 <- (df_general_distritos_ultima_fecha) %>%
  mutate(distritos= factor (activos, levels = sort(unique(df_general_distritos_ultima_fecha$activos)))) %>%
  select(distrito, activos) %>%
  top_n(n = 10, wt = activos)

df_distritos_activos_otros <- (df_general_distritos_ultima_fecha) %>%
  mutate(distritos= factor (activos, levels = sort(unique(df_general_distritos_ultima_fecha$activos)))) %>%
  select(distrito, activos) %>%
  slice(11:487)%>%
  summarize(distrito="otros", activos = sum(activos))

df_distritos_pastel_activos <- rbind(df_distritos_activos_top10,df_distritos_activos_otros)

# Datos recuperados distrito para gráfico pastel
df_distritos_recuperados_top10 <- (df_general_distritos_ultima_fecha) %>%
  mutate(distritos= factor (recuperados, levels = sort(unique(df_general_distritos_ultima_fecha$recuperados)))) %>%
  select(distrito, recuperados) %>%
  top_n(n = 10, wt = recuperados)

df_distritos_recuperados_otros <- (df_general_distritos_ultima_fecha) %>%
  mutate(distritos= factor (recuperados, levels = sort(unique(df_general_distritos_ultima_fecha$recuperados)))) %>%
  select(distrito, recuperados) %>%
  slice(11:487)%>%
  summarize(distrito="otros", recuperados = sum(recuperados))

df_distritos_pastel_recuperados <- rbind(df_distritos_recuperados_top10,df_distritos_recuperados_otros)

# Datos fallecidos distrito para gráfico pastel
df_distritos_fallecidos_top10 <- (df_general_distritos_ultima_fecha) %>%
  mutate(distritos= factor (fallecidos, levels = sort(unique(df_general_distritos_ultima_fecha$fallecidos)))) %>%
  select(distrito, fallecidos) %>%
  top_n(n = 10, wt = fallecidos)

df_distritos_fallecidos_otros <- (df_general_distritos_ultima_fecha) %>%
  mutate(distritos= factor (fallecidos, levels = sort(unique(df_general_distritos_ultima_fecha$fallecidos)))) %>%
  select(distrito, fallecidos) %>%
  slice(11:487)%>%
  summarize(distrito="otros", fallecidos = sum(fallecidos))

df_distritos_pastel_fallecidos <- rbind(df_distritos_fallecidos_top10,df_distritos_fallecidos_otros)

```

Resumen
=======================================================================
  Row {data-height=10}
-----------------------------------------------------------------------
  ### **Última actualización de datos realizada el `r  df_general_pais_ultima_fecha$FECHA` con base en los [datos publicados por el Ministerio de Salud de Costa Rica](http://geovision.uned.ac.cr/oges/)**.
  
  
  Row
-----------------------------------------------------------------------
  
  ### Casos positivos {.value-box}
  ```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$positivos, big.mark = ","), "", sep = " "), 
         caption = "Total de casos positivos", 
         icon = icono_positivos, 
         color = color_positivos
)
```

### Casos activos {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$activos, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$activos / df_general_pais_ultima_fecha$positivos, 1), 
                       "%)", sep = ""), 
         caption = "Total de casos activos",
         icon = icono_activos, 
         color = color_activos
)
```

### Casos recuperados {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$RECUPERADOS, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$RECUPERADOS / df_general_pais_ultima_fecha$positivos, 1), 
                       "%)", sep = ""), 
         caption = "Total de casos recuperados",
         icon = icono_recuperados, 
         color = color_recuperados
)
```

### Casos fallecidos {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$fallecidos, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$fallecidos / df_general_pais_ultima_fecha$positivos, 1), 
                       "%)", sep = ""), 
         caption = "Total de casos fallecidos",
         icon = icono_fallecidos, 
         color = color_fallecidos
)
```

Row
-----------------------------------------------------------------------
  
  ### Hospitalizados {.value-box}
  ```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$hospital, big.mark = ","), "", sep = " "), 
         caption = "Total de hospitalizados", 
         icon = icono_hospitalizados,
         color = color_hospitalizados
)
```

### En salón {.value-box}
```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$salon, big.mark = ","), " (",
                       round(100 * df_general_pais_ultima_fecha$salon / df_general_pais_ultima_fecha$hospital, 1), 
                       "%)", sep = ""), 
         caption = "Hospitalizados en salón",
         icon = icono_salon, 
         color = color_salon
)
```

### **Hospitalizados en UCI. Capacidad total: 359 camas** {.gauge}
```{r}
UCI <- round(100 * df_general_pais_ultima_fecha$UCI / df_general_pais_ultima_fecha$hospital) 
gauge(UCI, min = 0, max = 100, gaugeSectors(
  success = c(0, 33), warning = c(34, 70), danger = c(71, 100)
), symbol = "%", label = "Ocupación en UCI")
```

Row {data-width=400}
-----------------------------------------------------------------------
  
  ### Gráfico de variación de las cantidades de casos en el tiempo
  ```{r}
plot_ly(data = df_general_pais,
        x = ~ FECHA,
        y = ~ positivos, 
        name = 'Positivos', 
        type = 'scatter',
        mode = 'lines',
        line = list(color = color_positivos)) %>%
  add_trace(y = ~ activos,
            name = 'Activos',
            mode = 'lines',
            line = list(color = color_activos)) %>%
  add_trace(y = ~ RECUPERADOS,
            name = 'Recuperados',
            mode = 'lines',
            line = list(color = color_recuperados)) %>%
  add_trace(y = ~ fallecidos,
            name = 'Fallecidos',
            mode = 'lines',
            line = list(color = color_fallecidos)) %>%  
  layout(title = "",
         yaxis = list(title = "Cantidad de casos"),
         xaxis = list(title = "Fecha"),
         legend = list(x = 0.1, y = 0.9),
         hovermode = "compare")
```

### **Tabla de cantidades de casos en distritos**
```{r}
st_drop_geometry(sf_general_distritos_ultima_fecha) %>% 
  select(Provincia = provincia, Canton = canton, Distrito = distrito, Positivos = positivos, Activos = activos, Recuperados = recuperados, Fallecidos = fallecidos) %>%
  DT::datatable(rownames = FALSE,
                options = list(searchHighlight = TRUE, 
                               language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json')
                )
  )
```

Casos positivos
=======================================================================
  Row {data-height=1}
-----------------------------------------------------------------------
  ### **Última actualización de datos: `r  df_general_pais_ultima_fecha$FECHA`**
  
  
  Row
-----------------------------------------------------------------------
  
  ### Casos positivos {.value-box}
  ```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$positivos, big.mark = ","), "", sep = " "), 
         caption = "Total de casos positivos", 
         icon = icono_positivos, 
         color = color_positivos
)
```

Row {data-width=400}
-----------------------------------------------------------------------
  
  ### Mapa de casos positivos en distritos
  ```{r}

paleta_azul <- colorBin(palette = "Blues", 
                        domain = sf_general_distritos_ultima_fecha$positivos,
                        bins = 10
)

leaflet_distritos <- leaflet(sf_general_distritos_ultima_fecha) %>% 
  fitBounds(lng1 = -86, lng2 = -82, lat1 = 8, lat2 = 11) %>%
  addProviderTiles(providers$OpenStreetMap.Mapnik, group = "OpenStreetMap") %>%
  addPolygons(fillColor = ~paleta_azul(positivos), stroke=T, fillOpacity = 1,
              color="black", weight=0.2, opacity= 0.5,
              group = "Distritos",
              popup = paste("Provincia: ", sf_general_distritos_ultima_fecha$provincia, "<br>",
                            "Distritos: ", sf_general_distritos_ultima_fecha$distrito, "<br>",
                            "Positivos: ", sf_general_distritos_ultima_fecha$positivos
              )
  ) %>%
  addLegend("bottomright", pal = paleta_azul, values = ~positivos,
            title = "Casos positivos", group = "Distritos",
            opacity = 1
  ) %>%
  addLayersControl(
    baseGroups = c("OpenStreetMap"),
    overlayGroups = c("Distritos"),
    options = layersControlOptions(collapsed = TRUE)
  ) %>%
  addScaleBar(
  ) %>%
  addMiniMap(
    toggleDisplay = TRUE,
    position = "bottomleft",
    tiles = providers$OpenStreetMap.Mapnik
  )

# Despliegue del mapa
leaflet_distritos
```

### **Gráfico de distritos con mayor cantidad de casos positivos**
```{r}
pastelpositivos <- plot_ly(df_distritos_pastel_positivos,labels = ~ distrito, 
                           values = ~ positivos, 
                           type = "pie", 
                           textposition = 'inside',
                           marker = list(color = color_positivos)
) %>%
  layout(title = "Cantidad de casos positivos por distrito", 
         yaxis = list(title = ""),
         xaxis = list(title = ""),
         margin = list(l = 50,
                       r = 50,
                       b = 50,
                       t = 50,
                       pad = 5
         )
  )
pastelpositivos 
```


Casos activos
=======================================================================
  Row {data-height=10}
-----------------------------------------------------------------------
  ### **Última actualización de datos realizada el `r  df_general_pais_ultima_fecha$FECHA` con base en los [datos publicados por el Ministerio de Salud de Costa Rica](http://geovision.uned.ac.cr/oges/)**.
  
  Row
-----------------------------------------------------------------------
  
  ### Casos activos {.value-box}
  ```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$activos, big.mark = ","), "", sep = " "), 
         caption = "Total de casos activos", 
         icon = icono_activos, 
         color = color_activos
)
```

Row {data-width=400}
-----------------------------------------------------------------------
  
  ### **Mapa de casos activos en distritos**
  ```{r}

paleta_activos <- colorBin(palette = "Reds", 
                           domain = sf_general_distritos_ultima_fecha$activos,
                           bins = 10
)

leaflet_distritos <- leaflet(sf_general_distritos_ultima_fecha) %>% 
  fitBounds(lng1 = -86, lng2 = -82, lat1 = 8, lat2 = 11) %>%
  addProviderTiles(providers$OpenStreetMap.Mapnik, group = "OpenStreetMap") %>%
  addPolygons(fillColor = ~paleta_activos(activos), stroke=T, fillOpacity = 1,
              color="black", weight=0.2, opacity= 0.5,
              group = "Distritos",
              popup = paste("Provincia: ", sf_general_distritos_ultima_fecha$provincia, "<br>",
                            "Distritos: ", sf_general_distritos_ultima_fecha$distrito, "<br>",
                            "activos: ", sf_general_distritos_ultima_fecha$activos
              )
  ) %>%
  addLegend("bottomright", pal = paleta_activos, values = ~activos,
            title = "Casos activos", group = "Distritos",
            opacity = 1
  ) %>%
  addLayersControl(
    baseGroups = c("OpenStreetMap"),
    overlayGroups = c("Distritos"),
    options = layersControlOptions(collapsed = TRUE)
  ) %>%
  addScaleBar(
  ) %>%
  addMiniMap(
    toggleDisplay = TRUE,
    position = "bottomleft",
    tiles = providers$OpenStreetMap.Mapnik
  )

# Despliegue del mapa
leaflet_distritos
```

### **Gráfico de distritos con mayor cantidad de casos activos**
```{r}
pastelactivos <- plot_ly(df_distritos_pastel_activos,labels = ~ distrito, 
                         values = ~ activos, 
                         type = "pie", 
                         textposition = 'inside',
                         marker = list(color = color_activos)
) %>%
  layout(title = "Cantidad de casos activos por distrito", 
         yaxis = list(title = ""),
         xaxis = list(title = ""),
         margin = list(l = 50,
                       r = 50,
                       b = 50,
                       t = 50,
                       pad = 5
         )
  )
pastelactivos
```

Casos recuperados
=======================================================================
  Row {data-height=10}
-----------------------------------------------------------------------
  ### **Última actualización de datos realizada el `r  df_general_pais_ultima_fecha$FECHA` con base en los [datos publicados por el Ministerio de Salud de Costa Rica](http://geovision.uned.ac.cr/oges/)**.
  
  Row
-----------------------------------------------------------------------
  
  ### Casos recuperados {.value-box}
  ```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$RECUPERADOS, big.mark = ","), "", sep = " "), 
         caption = "Total de casos recuperados", 
         icon = icono_recuperados, 
         color = color_recuperados
)
```

Row {data-width=400}
-----------------------------------------------------------------------
  
  ### Mapa de casos recuperados en distritos
  ```{r}

paleta_recuperados <- colorBin(palette = "Greens", 
                               domain = sf_general_distritos_ultima_fecha$recuperados,
                               bins = 10
)

leaflet_distritos <- leaflet(sf_general_distritos_ultima_fecha) %>% 
  fitBounds(lng1 = -86, lng2 = -82, lat1 = 8, lat2 = 11) %>%
  addProviderTiles(providers$OpenStreetMap.Mapnik, group = "OpenStreetMap") %>%
  addPolygons(fillColor = ~paleta_recuperados(recuperados), stroke=T, fillOpacity = 1,
              color="black", weight=0.2, opacity= 0.5,
              group = "Distritos",
              popup = paste("Provincia: ", sf_general_distritos_ultima_fecha$provincia, "<br>",
                            "Distritos: ", sf_general_distritos_ultima_fecha$distrito, "<br>",
                            "recuperados: ", sf_general_distritos_ultima_fecha$recuperados
              )
  ) %>%
  addLegend("bottomright", pal = paleta_recuperados, values = ~recuperados,
            title = "Casos recuperados", group = "Distritos",
            opacity = 1
  ) %>%
  addLayersControl(
    baseGroups = c("OpenStreetMap"),
    overlayGroups = c("Distritos"),
    options = layersControlOptions(collapsed = TRUE)
  ) %>%
  addScaleBar(
  ) %>%
  addMiniMap(
    toggleDisplay = TRUE,
    position = "bottomleft",
    tiles = providers$OpenStreetMap.Mapnik
  )

# Despliegue del mapa
leaflet_distritos
```

### **Gráfico de distritos con mayor cantidad de casos recuperados**
```{r}
pastelrecuperados <- plot_ly(df_distritos_pastel_recuperados,labels = ~ distrito, 
                             values = ~ recuperados, 
                             type = "pie", 
                             textposition = 'inside',
                             marker = list(color = color_recuperados)
) %>%
  layout(title = "Cantidad de casos recuperados por distrito", 
         yaxis = list(title = ""),
         xaxis = list(title = ""),
         margin = list(l = 50,
                       r = 50,
                       b = 50,
                       t = 50,
                       pad = 5
         )
  )
pastelrecuperados 
```

Casos fallecidos
=======================================================================
  Row {data-height=10}
-----------------------------------------------------------------------
  ### **Última actualización de datos realizada el `r  df_general_pais_ultima_fecha$FECHA` con base en los [datos publicados por el Ministerio de Salud de Costa Rica](http://geovision.uned.ac.cr/oges/)**.
  
  
  Row
-----------------------------------------------------------------------
  
  ### Casos fallecidos {.value-box}
  ```{r}
valueBox(value = paste(format(df_general_pais_ultima_fecha$fallecidos, big.mark = ","), "", sep = " "), 
         caption = "Total de casos fallecidos", 
         icon = icono_fallecidos, 
         color = color_fallecidos
)
```

Row {data-width=400}
-----------------------------------------------------------------------
  
  ### Mapa de casos fallecidos en distritos
  ```{r}

paleta_fallecidos <- colorBin(palette = "Purples", 
                              domain = sf_general_distritos_ultima_fecha$fallecidos,
                              bins = 10
)

leaflet_distritos <- leaflet(sf_general_distritos_ultima_fecha) %>% 
  fitBounds(lng1 = -86, lng2 = -82, lat1 = 8, lat2 = 11) %>%
  addProviderTiles(providers$OpenStreetMap.Mapnik, group = "OpenStreetMap") %>%
  addPolygons(fillColor = ~paleta_fallecidos(fallecidos), stroke=T, fillOpacity = 1,
              color="black", weight=0.2, opacity= 0.5,
              group = "Distritos",
              popup = paste("Provincia: ", sf_general_distritos_ultima_fecha$provincia, "<br>",
                            "Distritos: ", sf_general_distritos_ultima_fecha$distrito, "<br>",
                            "fallecidos: ", sf_general_distritos_ultima_fecha$fallecidos
              )
  ) %>%
  addLegend("bottomright", pal = paleta_fallecidos, values = ~fallecidos,
            title = "Casos fallecidos", group = "Distritos",
            opacity = 1
  ) %>%
  addLayersControl(
    baseGroups = c("OpenStreetMap"),
    overlayGroups = c("Distritos"),
    options = layersControlOptions(collapsed = TRUE)
  ) %>%
  addScaleBar(
  ) %>%
  addMiniMap(
    toggleDisplay = TRUE,
    position = "bottomleft",
    tiles = providers$OpenStreetMap.Mapnik
  )

# Despliegue del mapa
leaflet_distritos
```

### **Gráfico de distritos con mayor cantidad de casos fallecidos**
```{r}
pastelfallecidos <- plot_ly(df_distritos_pastel_fallecidos,labels = ~ distrito, 
                            values = ~ fallecidos, 
                            type = "pie", 
                            textposition = 'inside',
                            marker = list(color = color_fallecidos)
) %>%
  layout(title = "Cantidad de casos fallecidos por distrito", 
         yaxis = list(title = ""),
         xaxis = list(title = ""),
         margin = list(l = 50,
                       r = 50,
                       b = 50,
                       t = 50,
                       pad = 5
         )
  )
pastelfallecidos 
```