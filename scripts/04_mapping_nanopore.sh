#!/bin/bash

# ================================
# Script: 04_mapping_nanopore.sh
# Proposito: Mapear lecturas de Nanopore a un genoma de referencia H5N1 clado 2.3.4.4b
# Plataforma: Nanopore
# ================================


# Detener el script si hay error en algún comando o si no encuentra alguna variable
set -eu



# ---------
# Definicion de rutas y variables iniciales
# ---------

REF="../references/H5N1_2344b_ref.mmi"
READS="../results/filtered/nanopore"
OUT="../results/mapping/nanopore"
LOGS="../logs"



# ---------
# Crear los directorios de salida si no existen
# ---------

mkdir -p "$OUT" "$LOGS"



# ---------
# Mapeo con Minimap2
# ---------

# Imprimir leyenda
echo "Mapeando lecturas Nanopore con Minimap2"




# Bucle for para reconocer archivos fastq

for FASTQ in $READS/*_filtered.fastq
do
	# Obtener el nombre de los archivos, para luego asignarlos a outputs 
    SAMPLE=$(basename "$FASTQ")

	# Quitar la extensión de la derecha 
    SAMPLE=${SAMPLE%%_filtered.fastq}


	# Imprimir leyenda
	echo "Procesando muestra: $SAMPLE"
   

# Correr Minimap2 en todo archivo .fastq y generar salida

    # Correr mapeador con salida SAM (-a), parámetro optimizado o preset Nanopore (-x map ont)y con 2 hilos
	# Archivos de referencia y fastq
	# El SAM generado pasa a samtools para ordenarlo y generar como salida BAM 
	# Guardar todos los errores 
	# Crear índice .bai (index)

	minimap2 -ax map-ont -t 2 "$REF" "$FASTQ" | \
        samtools sort -o "$OUT/${SAMPLE}.bam" \
        2>> "$LOGS/minimap2_errors.log"

    samtools index "$OUT/${SAMPLE}.bam"


done


	
# Imprimir leyenda de finalizacion
echo "Mapeo de lecturas Nanopore completado."


