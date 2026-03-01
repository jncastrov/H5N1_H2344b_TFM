#!/bin/bash

# ================================
# Script: 13_genoflu.sh
# Proposito: Correr la herramienta Genoflu para definir el genotipo y determinar el origen de cada fragmenteo de AIV H5N1 HPAI
# ================================


# Detener el script si hay error en algún comando o si no encuentra alguna variable
set -eu



# ---------
# Definicion de rutas y variables iniciales
# ---------


SAMPLE_DIR="../results/genoflu/samples"
LOGS="../../../logs"
GENOFLU="/home/jcastrov1/H5N1_TFM/scripts/GenoFLU/bin/genoflu.py"



# ---------
# Genoflu	
# ---------

# Cambiar al directorio de los FASTA

cd "$SAMPLE_DIR"

# Bucle for para reconocer multifasta de cada muestra


for file in *.fasta
do
    # Obtener nombre de la muestra
    sample=$(basename "$file" .fasta)
	
	# Imprimir leyenda
    echo "Analizando $sample"



	# Correr Genoflu
    if python "$GENOFLU" \
        -f "$file" \
        2>> "$LOGS/genoflu.log" 
	then
		echo "$sample procesada correctamente."
	else
		echo "Error en $sample."

	fi


done


echo "Análisis por GenoFLU completado."




