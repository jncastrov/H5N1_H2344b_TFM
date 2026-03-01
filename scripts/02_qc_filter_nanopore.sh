#!/bin/bash

# ================================
# Script: 02_qc_filter_nanopore.sh
# Proposito: Control de calidad y filtering para lecturas de Nanopore
# Plataforma: Nanopore
# ================================


# Detener el script si hay error en algún comando o si no encuentra alguna variable
set -eu



# ---------
# Definicion de rutas y variables iniciales
# ---------

RAW_READS="../data/raw/nanopore"
FILTERED_OUT="../results/filtered/nanopore"
QC_OUT="../results/qc/nanopore"
LOGS="../logs"



# ---------
# Crear los directorios de salida si no existen
# ---------

mkdir -p "$FILTERED_OUT" "$QC_OUT" "$LOGS"



# ---------
# Paso 1: Control de calidad con NanoPlot
# ---------





# Bucle for para reconocer archivos fastq
for FASTQ in $RAW_READS/*.fastq*
do
	# Obtener el nombre de los archivos, para luego asignarlos a outputs 
    SAMPLE=$(basename "$FASTQ")

	# Quitar la extensión de la derecha 
    SAMPLE=${SAMPLE%%.fastq*}


	# Imprimir leyenda
	echo "Procesando muestra: $SAMPLE"

	# Imprimir leyenda
    echo "Corriendo QC en lecturas Nanopore con NanoPlot..."

    # Correr Nanoplot en todo archivo .fastq y generar salida
	# Archivo fastq
	# Salida 
	# Gráfico de longitud en escala log
	# Número de hilos
	# Guardar todos los errores 

    NanoPlot \
        --fastq "$FASTQ" \
        --outdir "$QC_OUT/${SAMPLE}_nanoplot" \
        --loglength \
        --threads 2 \
        2>> "$LOGS/nanoplot_errors.log"


	# Imprimir leyenda
	echo "QC completado."



# ---------
# Paso 2: Filtering con NanoFilt
# ---------

# Imprimir leyenda
echo "Corriendo Filtering con Nanofilt..."

	# Descomprimir archivo fast.gz para trabajar con fastq y pasarlo por pipe a NanoFilt
	zcat "$FASTQ" | \


	# Correr NanoFilt
	# Criterio de calidad de 10
	# Archivos
	# Output tomando nombre de fastq
	# Guardar todos los errores 
	    
    NanoFilt \
        -q 10 \
        > "$FILTERED_OUT/${SAMPLE}_filtered.fastq" \
        2>> "$LOGS/nanofilt_errors.log"

	# Imprimir leyenda
    echo "Filtrado completado"


done



# Imprimir leyenda de finalizacion
echo "Nanopore QC y filtering finalizados."


