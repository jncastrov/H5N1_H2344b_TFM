#!/bin/bash

# ================================
# Script: 09_flye_nanopore.sh
# Proposito: Ensamblar de novo lecturas Nanopore 
# Plataforma: Nanopore
# ================================


# Detener el script si hay error en algún comando o si no encuentra alguna variable
set -eu



# ---------
# Definicion de rutas y variables iniciales
# ---------


READS="../results/filtered/nanopore"
OUT="../results/flye/nanopore"
LOGS="../logs"



# ---------
# Crear los directorios de salida si no existen
# ---------

mkdir -p "$OUT" "$LOGS"



# ---------
# Ensamblar de novo con Flye
# ---------

# Imprimir leyenda
echo "Ensamblando de novo lecturas Nanopore con Flye."



# Bucle for para reconocer archivos fastq


for FASTQ in $READS/*_filtered.fastq
do
	# Obtener el nombre de los archivos, para luego asignarlos a outputs 
    SAMPLE=$(basename "$FASTQ")

	# Quitar la extensión de la derecha 
    SAMPLE=${SAMPLE%%_filtered.fastq}


	# Imprimir leyenda
	echo "Procesando muestra: $SAMPLE"





	# Correr Flye en todo archivo .fastq y generar salida

    # Correr Flye
	# Archivo de entrada
	# Archivo de salida
	# Tamaño de genoma
	# Número de hilos
	# Disminuir ruido
	# Guardar todos los errores 



    flye \
        --nano-raw "$FASTQ" \
        --out-dir "$OUT/$SAMPLE" \
        --genome-size 14k \
        --threads 2 \
		--meta \
        2>> "$LOGS/flye_errors.log"


done


	
# Imprimir leyenda de finalizacion
echo "Ensamblaje con Flye completado."


