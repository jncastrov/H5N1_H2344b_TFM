#!/bin/bash

# ================================
# Script: 03_mapping_illumina.sh
# Proposito: Mapear lecturas de Illumina a un genoma de referencia H5N1 clado 2.3.4.4b
# Plataforma: Illumina
# ================================


# Detener el script si hay error en algún comando o si no encuentra alguna variable
set -eu



# ---------
# Definicion de rutas y variables iniciales
# ---------

REF="../references/H5N1_2344b_ref.fasta"
READS="../results/trimmed/illumina"
OUT="../results/mapping/illumina"
LOGS="../logs"



# ---------
# Crear los directorios de salida si no existen
# ---------

mkdir -p "$OUT" "$LOGS"



# ---------
# Mapeo con BWA-MEM
# ---------

# Imprimir leyenda
echo "Mapeando lecturas Illumina con BWA-MEM"



# Bucle for para reconocer archivos R1 paired-end

for R1 in $READS/*_R1_paired.fastq.gz
do
	# Reemplazar en la variable R1 , R1 por R2
    R2=${R1/_R1_paired/_R2_paired}
	# Obtener el nombre de los archivos, para luego asignarlos a outputs 
    SAMPLE=$(basename "$R1")
	# Quitar la extensión de la derecha 
    SAMPLE=${SAMPLE%%_R1*}

# Imprimir leyenda
echo "Procesando muestra: $SAMPLE"


# Correr BWA-MEM en todo archivo .fastq y generar salida

    # Correr mapeador BWA algoritmo MEM (Maximal exact matches) con 2 hilos
	# Archivos de referencia, read1 y read2 
	# El SAM generado pasa a samtools para ordenarlo y generar como salida BAM 
	# Guardar todos los errores 
	# Crear índice .bai (index)

 	bwa mem -t 2 "$REF" "$R1" "$R2" | \
        samtools sort -o "$OUT/${SAMPLE}.bam" \
        2>> "$LOGS/bwa_errors.log"

    samtools index "$OUT/${SAMPLE}.bam"
done


	
# Imprimir leyenda de finalizacion
echo "Mapeo de lecturas Illumina completado."


