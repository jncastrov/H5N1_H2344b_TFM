#!/bin/bash

# ================================
# Script: 11_prepare_fastas.sh
# Proposito: Preparar las secuencias FASTA HA, NA, PB2 junto a las referencias previo a la filogenia
# ================================


# Detener el script si hay error en algún comando o si no encuentra alguna variable
set -eu



# ---------
# Definicion de rutas y variables iniciales
# ---------

SAMPLES="../phylogeny/samples"
REFS="../phylogeny/references"
OUT="../phylogeny/segments_prepared"
STATS="../phylogeny/stats"
LOGS="../phylogeny/logs"


# ---------
# Crear los directorios de salida si no existen
# ---------

mkdir -p "$OUT" "$STATS" "$LOGS"

echo "Preparando FASTAs para filogenia..."

# ------------------------
# Bucle para procesar cada segmento
# ------------------------

for SEG in HA NA PB2
do
    echo "Procesando segmento $SEG..."
    
    # Generar archivo intermedio
    TMP="$OUT/${SEG}.tmp.fasta"
    > "$TMP"

    # Illumina
    # Tomar todo lo del header
    # Reemplazar por origen/segmento y lo capturado en el header
    # Añadir al archivo temporal
    for F in "$SAMPLES"/illumina/*.${SEG}.fasta
    do
        seqkit replace \
          -p "^(.+)$" \
          -r 'Illumina|$SEG|$1' \
          "$F" >> "$TMP"
    done

    # Nanopore
    for F in "$SAMPLES"/nanopore/*.${SEG}.fa
    do
        seqkit replace \
          -p "^(.+)$" \
          -r 'Nanopore|$SEG|$1' \
          "$F" >> "$TMP"
    done

    # Colombia NCBI 
    for F in "$SAMPLES"/colombia_ncbi/*.${SEG}.fa
    do
        seqkit replace \
          -p "^(.+)$" \
          -r 'NCBI_Colombia|$SEG|$1' \
          "$F" >> "$TMP"
    done

    # GISAID subsample
    # Buscar en el archivo de referencias
    # Tomar todo lo del header
    # Reemplazar por origen/segmento y lo capturado en el header
    # Añadir al archivo temporal 
    seqkit grep -r -p "$SEG" "$REFS"/gisaid_subsample.fasta | \
    seqkit replace \
      -p "^(.+)$" \
      -r 'GISAID|$SEG|$1' \
      >> "$TMP"

    # Filtrar por longitud mínima dependiendo del segmento

    if [ "$SEG" = "HA" ]; then
        MINLEN=1400
    elif [ "$SEG" = "NA" ]; then
        MINLEN=1100
    else
        MINLEN=1800
    fi

    # Buscar en el archivo intermedio las secuencias que cumplan longitud mínima, eliminando gaps (-g), y generar un multifasta
    seqkit seq -g -m $MINLEN "$TMP" > "$OUT/${SEG}.fasta"

    # Generar estadísticas
    seqkit stats "$OUT/${SEG}.fasta" > "$STATS/${SEG}.stats.txt"

    # Eliminar archivo intermedio
    rm "$TMP"

    echo "Segmento $SEG listo."
done

echo "Secuencias FASTAs preparadas correctamente."


