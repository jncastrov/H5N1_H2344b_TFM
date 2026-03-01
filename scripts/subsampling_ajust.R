# --------------------------------------------------

# Subsampling secuencias de referencia in R

# Date: 2026-01-31

# Authors: Jennifer Castro

# --------------------------------------------------



# Descripción:

# Este script permite realiza sub muestreo de secuencias de referencia descargadas , 

# de GISAID para posterior filogenia


# --------------------------------------------------


# Librerias

library(dplyr)
library(readxl)
library(stringr)
library(writexl)
library(lubridate)

# Directorio de trabajo

setwd(dir="/home/jcastrov1/H5N1_TFM/")
        


# Leer todos los archivos metadata

list.files("phylogeny/metadata")


files <- list.files(
  path = "phylogeny/metadata",
  pattern = "\\.xls$",
  full.names = TRUE
)

# Leer y unir los archivos de metadata


meta_list <- lapply(files, read_excel)
meta_all <- bind_rows(meta_list)
colnames(meta_all)

# Filtrar columnas de interés

meta_clean <- meta_all %>%
  select(
    Isolate_Id,
    Isolate_Name,
    Subtype,
    Clade,
    Genotype,
    Host,
    Location,
    Collection_Date
  )


# Extraer año a través de fecha de collección

meta_clean <- meta_clean %>%
  mutate(
    Year = as.numeric(substr(Collection_Date, 1, 4))
  )

# Extraer región de la locación

meta_clean <- meta_clean %>%
  mutate(
    Region = str_extract(Location, "^[^/]+")
  )
head(meta_clean$Region)

# Guardar nueva tabla con la metadata filtrada y limpia

write_xlsx(
  meta_clean,
  "phylogeny/metadata/metadata_all_clean_ajust_b.xlsx"
)


# Cargar metadata limpia

meta <- read_excel("phylogeny/metadata/metadata_all_clean_ajust_b.xlsx")

head(meta)
colnames(meta)
dim(meta)


meta %>% count(Region)


# Generar columnas Country y Year

head(meta$Collection_Date)

meta <- meta %>%
  mutate(
    Date_parsed = parse_date_time(Collection_Date,
    orders = c("ymd", "ym", "y")), # ymd convierte texto en fecha. year extrae año
    Year = year(Date_parsed), 
    Country = word(Location, 2, sep = "/"))

sum(is.na(meta$Year))


# Extraer año

meta <- meta %>%
  filter(Year >= 2021, Year <= 2026)

head(meta$Year)


# ---------------
# Subsampling
# ---------------


# Reproducibilidad
set.seed(123)  

# Agregar todas secuencias de Colombia
meta_colombia <- meta %>%
  filter(Country == "Colombia")   

# Tomar países diferentes a Colombia
meta_world <- meta %>%
  filter(Country != "Colombia")

# Realizar submuestreo estratificado simple en países diferentes a Colombia
meta_sub_world <- meta_world %>%
  group_by(Region) %>%   
  slice_sample(n = 25, replace = FALSE) %>%  # 25 por región
  ungroup()

# Unir secuencias colombianas y mundiales
meta_sub <- bind_rows(meta_sub_world, meta_colombia) %>%
  distinct()


# Corroborar cuántas secuencias quedan
nrow(meta_sub)




# Guardar subsampling

write_xlsx(
  meta_sub,
  "phylogeny/metadata/metadata_subsampled_ajust.xlsx")   


# Extraer Ids para filtrar secuencias .fasta

ids_sub_ajust <- meta_sub$Isolate_Id


name_sub_ajust <-meta_sub$Isolate_Name

head(ids_sub_ajust)

# Hacer lista con Ids para filtrar secuencias .fasta

write.table(
  ids_sub_ajust,
  "phylogeny/metadata/ids_sub_ajust.txt",
  row.names = FALSE,
  col.names = FALSE,
  quote = FALSE
)


write.table(
  name_sub_ajust,
  "phylogeny/metadata/name_sub_ajust.txt",
  row.names = FALSE,
  col.names = FALSE,
  quote = FALSE
)

# Crear columna con los IDs ajustados a las seq fasta 

meta_sub$Tree_ID <- gsub("EPI_ISL_", "EPI", meta_sub$Isolate_Id)
nrow(meta_sub)
colnames(meta_sub)
head(meta_sub$Tree_ID)

head(meta_sub$Isolate_Id)


write_xlsx(
  meta_sub,
  "phylogeny/metadata/metadata_subsampled_ajust.xlsx") 
