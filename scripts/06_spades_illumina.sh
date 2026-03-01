#!/bin/bash

# ================================
# Script: 06_spades_illumina.sh
# Proposito: Ensamblar de novo lecturas Illumina 
# Plataforma: Illumina
# ================================


# Detener el script si hay error en algún comando o si no encuentra alguna variable
set -eu



# ---------
# Definicion de rutas y variables iniciales
# ---------

READS="../results/trimmed/illumina"
OUT="../results/spades/illumina"
LOGS="../logs"



# ---------
# Crear los directorios de salida si no existen
# ---------

mkdir -p "$OUT" "$LOGS"



# ---------
# Ensamblar de novo con SPAdes
# ---------

# Imprimir leyenda
echo "Ensamblando de novo lecturas Illumina con SPAdes."



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


# Correr SPAdes en todo archivo .fastq y generar salida

    # Correr SPAdes
	# Archivos de referencia, read1 y read2 
	# Archivo de salida
	# Reducir errores en el ensamblaje
	# Número de hilos
	# Guardar todos los errores 


    spades.py \
        -1 "$R1" \
        -2 "$R2" \
        -o "$OUT/$SAMPLE" \
        --careful \
        -t 2 \
        2>> "$LOGS/spades_errors.log"

done


	
# Imprimir leyenda de finalizacion
echo "Ensamblaje con SPAdes completado."


