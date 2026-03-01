#!/bin/bash

# ================================
# Script: 12_phylogeny.sh
# Proposito: Generar árboles filogenéticos
# ================================


# Detener el script si hay error en algún comando o si no encuentra alguna variable
set -eu



# ---------
# Definicion de rutas y variables iniciales
# ---------

SEGMENTS="../phylogeny/segments_prepared"
ALIGN="../phylogeny/alignments"
TREES="../phylogeny/trees"
LOGS="../phylogeny/logs"
TRIM="../phylogeny/trimmed"



# ---------
# Crear los directorios de salida si no existen
# ---------

mkdir -p "$ALIGN" "$TREES" "$LOGS" "$TRIM"



# ---------
# Alineamiento con Mafft
# ---------

# Imprimir leyenda
echo "Generando filogenias"


# Bucle for para realizar alineamiento para cada segmento
# Elegir automaticamente algoritmo segun divergencia (--auto)
# Archivo de entrada
# Archivo de salida alineado
# Guardar errores

for SEG in PB2 HA NA
do
    echo "Alineando $SEG..."

    mafft \
        --auto \
        "$SEGMENTS/${SEG}.fasta" \
        > "$ALIGN/${SEG}.aligned.fasta" \
        2>> "$LOGS/mafft_errors.log"


    echo "Recortando extremos $SEG..."
 

	# Recortar extremos del alineamiento

	trimal \
    	-in "$ALIGN/${SEG}.aligned.fasta" \
    	-out "$TRIM/${SEG}.trimmed.fasta" \
    	-automated1



# ---------
# Alineamiento con Mafft
# ---------


	# Realizar árbol con iqtree2 
	# Parámetros: archivo de entrada (-s), model finder plus (-m), ultrafast bootstrap (-bb), evidencia estadìstica de cada raman(-alrt),  buscar nucleos disponibles (-nt), prefijo de archivos de salida(-pre)
	# Guardar errores


    echo "Construyendo árbol ML para $SEG..."

    iqtree \
        -s "$TRIM/${SEG}.trimmed.fasta" \
        -m MFP \
        -bb 1000 \
        -alrt 1000 \
        -nt AUTO \
        -pre "$TREES/${SEG}" \
        2>> "$LOGS/iqtree_errors.log"


done

# Imprimir leyenda de finalizacion
echo "Filogenias completadas."



