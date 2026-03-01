#!/bin/bash

# ================================
# Script: 05_mapping_illumina.sh
# Proposito: Generar concenso a partir de referencia y del archivo .bam generado en el proceso de Mapping de lecturas Illumina
# Plataforma: Illumina
# ================================


# Detener el script si hay error en algún comando o si no encuentra alguna variable
set -eu



# ---------
# Definicion de rutas y variables iniciales
# ---------

REF="../references/H5N1_2344b_ref.fasta"
BAM_DIR="../results/mapping/illumina"
OUT_DIR="../results/consensus/illumina"
LOGS="../logs"



# ---------
# Crear los directorios de salida si no existen
# ---------

mkdir -p "$OUT_DIR"



# ---------
# Concenso total con bcftools
# ---------

# Imprimir leyenda
echo "Generando concensos Illumina con bcftools"




# Bucle for para reconocer archivos BAM

for BAM in $BAM_DIR/*.bam
do
	# Obtener el nombre de los archivos, para luego asignarlos a outputs 
    SAMPLE=$(basename "$BAM")

	# Quitar la extensión de la derecha 
    SAMPLE=${SAMPLE%%.bam}


	# Imprimir leyenda
	echo "Procesando muestra: $SAMPLE"
   



# Correr bcftools en todo archivo .bam y generar salida

    # Correr bcftools con salida BAM, para que cuente el nt de cada lectura en cada posición
    # Parámetros: referencia (-f), archivo BAM, salida binaria sin comprimir (-Ou), tener en cuenta depth - cuantas lecturas de cada posición (-a), ignorar calidad -20 (-q)	
	# Correr bcftools para detectar las variantes 
	# Parámetros: modelo multialélico moderno (-m), reportar solo variantes (-v), salida vcf.gz (-Oz), muestras haploides (--ploidy), salida(-o), guardar errores



 bcftools mpileup \
        -f "$REF" \
        "$BAM" \
        -Ou \
        -a FORMAT/DP \
        -Q 20 \
 		2>> "$LOGS/mpileup_errors.log" | \

    bcftools call \
        -mv \
        -Oz \
		--ploidy 1 \
        -o "$OUT_DIR/${SAMPLE}.vcf.gz"\
 		2>> "$LOGS/call_errors.log"





	# Indexar VCF para acceder a cada posición eficientemente
    bcftools index "$OUT_DIR/${SAMPLE}.vcf.gz"



	# Correr bcftools para filtrar cobertura posiciones con baja profundidad (-e), archivo de entrada, salida vcf.gz (-Oz), salida(-o)

	bcftools filter \
    	-e 'INFO/DP<10' \
    	"$OUT_DIR/${SAMPLE}.vcf.gz" \
    	-Oz \
    	-o "$OUT_DIR/${SAMPLE}.filtered.vcf.gz" \
    	2>> "$LOGS/filter_errors.log"

	# Indexar VCF filtradopara acceder a cada posición eficientemente
	bcftools index "$OUT_DIR/${SAMPLE}.filtered.vcf.gz"


	# Aplicar variantes al FASTA de la referencia
	# Entrada VCF comprimido
	# Salida en formato FASTA
    bcftools consensus \
        -f "$REF" \
        "$OUT_DIR/${SAMPLE}.filtered.vcf.gz" \
        > "$OUT_DIR/${SAMPLE}.consensus.fasta"



	
# Imprimir leyenda de finalizacion
echo "Concensos totales de Illumina completados."


done


# ---------
# Concenso por segmento 
# ---------


# Imprimir leyenda 
echo "Generando concensos por cada segmento Illumina."



	# Indexar el FASTA consenso para tener nombres y longitudes de cada segmento
	samtools faidx "$OUT_DIR/${SAMPLE}.consensus.fasta"

	# Extraer segmentos individuales
	# Extraer primera columna - nombre del concenso indexado
	SEGMENTS=$(cut -f1 "$OUT_DIR/${SAMPLE}.consensus.fasta.fai")

	# Extraer cada segmento con bucle for primera columna - nombre del concenso indexado
	# Extraer FASTA del segmento
	# Guardarlo con nombre, segmento. fasta
	for SEG in $SEGMENTS
	do
    	samtools faidx \
    	    "$OUT_DIR/${SAMPLE}.consensus.fasta" \
    	    "$SEG" \
    	    > "$OUT_DIR/${SAMPLE}.${SEG}.fasta"
done



# Imprimir leyenda de finalizacion
echo "Concensos por cada segmento Illumina completados."

