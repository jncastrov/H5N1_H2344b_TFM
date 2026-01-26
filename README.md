# Implementación de un flujo de trabajo bioinformático basado en NGS para el determinar el origen filogenético del virus Influenza Tipo A subtipo H5N1 clado 2.3.4.4b en Colombia

## Descripción general

Este repositorio contiene el pipeline desarrollado en el marco de un Trabajo Fin de Máster (TFM) en Bioinformática, para realizar el análisis filogenético del virus de Influenza Tipo A subtipo H5N1 clado 2.3.4.4b.

El pipeline integra el análisis de datos de secuenciación de nueva generación (NGS) obtenidos a partir de plataformas Illumina y Oxford Nanopore, y está diseñado para ser reproducible al aplicable a datos crudos de secuenciación.

---

## Objetivo del proyecto

Determinar el origen filogenético de las de secuencias colombianas del virus de Influenza Tipo A subtipo H5N1 clado 2.3.4.4b, implementando un flujo de trabajo bioinformático NGS aplicable a datos crudos de secuenciación obtenidos a partir de las tecnologías Illumina y Oxford Nanopore.

---

## Datos utilizados

Este estudio utiliza:

- Lecturas crudas Illumina disponibles públicamente en el BioProject PRJNA1186741 (NCBI), número de experimento SRX26969643 
- Lecturas crudas Oxford Nanopore disponibles públicamente en el BioProject PRJNA1312032 (NCBI), número de experimento SRX30290909 
- Secuencias consenso de aislados colombianos depositadas en GenBank, números de acceso: OQ683479 - OQ683486, OQ683455 - OQ683462, OQ683495 - OQ683502, OQ683463 - OQ683470, OQ683487 - OQ683494, OQ683471 - OQ683478
- Secuencias de referencia del subtipo H5N1 clado 2.3.4.4b obtenidas del NCBI Influenza Virus Database o EPiFLu GISAID

Las secuencias crudas y archivos intermedios de gran tamaño no se incluyen en este repositorio.

---

## Flujo de trabajo bioinformático

El pipeline se organiza en scripts secuenciales que corresponden a las principales etapas metodológicas:

1. Control de calidad de lecturas (FastQC) y filtrado, recorte de lecturas Illumina (Trimmomatic).
2. Evaluación y filtrado de lecturas Oxford Nanopore (NanoPlot, NanoFilt).
3. Mapeo de lecturas a genoma de referencia:
   - Illumina: BWA-MEM
   - Oxford Nanopore: minimap2
4. Procesamiento de archivos BAM y marcado de duplicados (SAMtools, Picard).
5. Generación de secuencias consenso:
   - Illumina: BCFtools
   - Oxford Nanopore: iVar
6. Submuestreo estratificado de secuencias de referencia (metadata).
7. Alineamiento múltiple y análisis filogenético (MAFFT, IQ-TREE).

Cada etapa se implementa mediante scripts independientes almacenados en el directorio `scripts/`.

---

## Estructura del repositorio

```text
H5N1_TFM/
├── data/        # Metadata y referencias (no datos crudos)
├── env/         # Archivo de entorno conda
├── scripts/     # Scripts del pipeline bioinformático
├── docs/        # Documentación adicional
├── results/     # Resultados 
└── README.md

