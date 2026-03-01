#!/bin/bash

# ================================
# Script: 08_consensus_nanopore.sh
# Proposito: Generar concenso a partir de referencia y del archivo .bam generado en el proceso de Mapping de lecturas Nanopore
# Plataforma: Nanopore
# ================================


# Detener el script si hay error en algún comando o si no encuentra alguna variable
set -eu



# ---------
# Definicion de rutas y variables iniciales
# ---------

BAM_DIR="../results/mapping/nanopore"
OUT="../results/consensus/nanopore"
LOGS="../logs"
REF="../references/H5N1_2344b_ref.fasta"



# ---------
# Crear los directorios de salida si no existen
# ---------

mkdir -p "$OUT" "$LOGS"



# ---------
# Concensos con ivar
# ---------

# Imprimir leyenda
echo "Generando concensos Nanopore con ivar"





# Bucle for para reconocer archivos BAM

for BAM in $BAM_DIR/*.bam
do
	# Obtener el nombre de los archivos, para luego asignarlos a outputs 
    SAMPLE=$(basename "$BAM")

	# Quitar la extensión de la derecha 
    SAMPLE=${SAMPLE%%.bam}


	# Imprimir leyenda
	echo "Procesando muestra: $SAMPLE"


 	# Obtener segmentos desde el BAM
 	# Solo se visualiza el header (-h), primera columna con @SQ , segunda columna reemplazar SN por nada e imprimir, para solo tener el fragmento
    SEGMENTS=$(samtools view -H "$BAM" | awk '$1=="@SQ"{sub("SN:","",$2); print $2}')

 	# Realizar bucle para tener cada segmento y posterior análisis por mpileup
    for SEG in $SEGMENTS
    do
        echo "  → Segmento $SEG"





    # Correr mpileup de samtools para tener tabla de cada posición para contar nt 
    # Parámetros: incluir todas las bases (-a), incluir lecturas anómalas (-A),  límite de profundidad para aumentar velocidad(-d), sin filtro de calidad por ahora (-Q),  archivo BAM, guardar errores, referencia (-f), análisis de segmento específico (-r)
	# Correr ivar para detectar las variantes 
	# Parámetros: salida archivo FASTA colocando segmento(-p), rcalidad mínima de la base (-q), frecuencia mínima (-t), profundidad mínima (m), colocar N sino cumple criterios previos(-N), guardar errores
	samtools mpileup \
    	-aa -A -d 10000 -Q 0 \
		-f "$REF" \
		-r "$SEG" \
       	"$BAM" \
    	2>> "$LOGS/ivar_mpileup.log" | \

  	ivar consensus \
    	-p "$OUT/${SAMPLE}.${SEG}" \
    	-q 10 \
    	-t 0.6 \
    	-m 10 \
    	-n N \
    	2>> "$LOGS/ivar_consensus.log"

   

	done
done



# Imprimir leyenda de finalizacion
echo "Concensos por cada segmento Nanopore completados."




