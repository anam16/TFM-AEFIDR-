#!/bin/bash

# Para comprobar si se han introducido los nombres de los archivos 
if [ $# -ne 3 ]; then
    echo "No se han introducido los nombres de archivos necesarios."
    exit 
fi

# Establece los nombres de los archivos de entrada
prot_archv=$1
dna_archv=$2
result_prefix=$3


# Para dividr cada archivo fasta en archivos individuales, donde cada uno solo contiene una sola secuencia
awk '/^>/ {if(x>0) close(outname); x++; outname=sprintf("proteina_seq%d.fasta",x); print > outname;next;} {if(x>0) print >> outname;}' < "$prot_archv"
awk '/^>/ {if(y>0) close(outname); y++; outname=sprintf("dna_seq%d.fasta",y); print > outname;next;} {if(y>0) print >> outname;}' < "$dna_archv"

# Contar el número de archivos de secuencias generados
num_prots=$(ls proteina_seq*.fasta | wc -l)
num_dna=$(ls dna_seq*.fasta | wc -l)

# Para comprobar que ambos archivos tienen el mismo número de secuencias
if [ "$num_prots" -ne "$num_dna" ]; then
    echo "Los archivos de entrada tienen un número diferente de secuencias."
    exit 
fi

# Se ejecuta exonerate en los archivos correspondientes y se guardan los resultados
for i in $(seq 1 "$num_prots"); do
    exonerate --model protein2genome --query proteina_seq${i}.fasta --target dna_seq${i}.fasta --showtargetgff true  > ${3}resultados_${i}.txt
done

# Elimina los archivos temporales de secuencia dividida
rm proteina_seq*.fasta
rm dna_seq*.fasta

