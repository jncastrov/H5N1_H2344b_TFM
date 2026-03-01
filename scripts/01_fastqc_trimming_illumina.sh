#!/bin/bash

# ================================
# Script: 01_fastqc_trimming_illumina.sh
# Proposito: Control de calidad y Trimming para lecturas de Illumina
# Plataforma: Illumina
# ================================


# Detener el script si hay error en algún comando o si no encuentra alguna variable

set -eu



# ---------
# Definicion de rutas y variables iniciales
# ---------

RAW_READS=../data/raw/illumina
FASTQC_OUT=../results/fastqc/illumina
TRIMMED_OUT=../results/trimmed/illumina



# ---------
# Crear los directorios de salida si no existen
# ---------

mkdir -p $FASTQC_OUT
mkdir -p $TRIMMED_OUT



# ---------
# Paso 1: Control de calidad con fastqc
# ---------

# Imprimir leyenda
echo "Corriendo FastQC en lecturas Illumina..."

# Correr fastqc en todo archivo .fastq y generar salida
fastqc $RAW_READS/*.fastq.gz -o $FASTQC_OUT 2>> ../logs/fastqc_errors.log

# Imprimir leyenda
echo "FastQC completado."



# ---------
# Paso 2: Trimming y filtering con Trimmomatic
# ---------



# Bucle for para reconocer archivos R1 paired-end
for R1 in $RAW_READS/*_R1*.fastq*
do
	# Reemplazar en la variable R1 , R1 por R2
    R2=${R1/_R1/_R2}
	# Obtener el nombre de los archivos sin extensión, para luego asignarlos a outputs 
    SAMPLE=$(basename $R1 _R1.fastq.gz)

	# Imprimir leyenda
	echo "Procesando muestra: $SAMPLE"

	echo "Corriendo Trimmomatic..."

	# Correr trimmomatic para paired-end (PE)
	# Sistema de puntuacion de calidad
	# Archivos
	# Output de R1 que pasan calidad y conservan pareja R2
	# Output de R1 que pasan calidad pero pierden pareja R2
	# Output de R2 que pasan calidad y conservan pareja R1
	# Eliminación de adaptadores, archivo que tiene la seq de adaptadores, con número máx de desajustes 2, calidad 30, long min post recorte 10
	# Eliminación de bases con calidad menor a 20 al principio y al final
	# Criterio de calidad Q20 en ventana deslizante de 4 nt
	# Criterio de longitud minima de 50pb
	# Guardar todos los errores 
	    

	trimmomatic PE \
  		-phred33 \
  		$R1 $R2 \
  		$TRIMMED_OUT/${SAMPLE}_R1_paired.fastq.gz \
  		$TRIMMED_OUT/${SAMPLE}_R1_unpaired.fastq.gz \
  		$TRIMMED_OUT/${SAMPLE}_R2_paired.fastq.gz \
  		$TRIMMED_OUT/${SAMPLE}_R2_unpaired.fastq.gz \
		ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
 		LEADING:20 TRAILING:20\
  		SLIDINGWINDOW:4:20 \
  		MINLEN:50 \
  		2>> ../logs/trimmomatic_errors.log



done


# Imprimir leyenda
echo "Trimmomatic completado."

# Imprimir leyenda de finalizacion
echo "Illumina QC y trimming finalizados."

