#!/bin/bash
# Esce immediatamente se un comando fallisce.
set -e

# deploy locale
source deploy_local.sh

# --- CONFIGURAZIONE ---
OUTPUT_FILE="risultati_heapSort.csv"

# Definisci le dimensioni e i tipi di array da testare
# SIZES=(10 50 100 200 400) 
SIZES=(10 50 100 200 400) 
# ai fini della tesi serve solo "casuale"
#TYPES=("casuale" "quasi_ordinato" "inverso" "duplicati")
TYPES=("casuale")
CMD_BASE="cargo run --bin publisher -- --chain-id=31337 --rpc-url=http://localhost:8545 --contract=0x0b306bf915c4d645ff596e518faf3f9669b97016"

# --- ESECUZIONE ---
# Crea l'intestazione del file CSV
echo "Tipo_Array,Dimensione,Perc_CPU,Total_Time_s,Max_RAM_kB" > "$OUTPUT_FILE"
echo "Avvio"
echo "-----------------------------------------------------"

# intera su ogni dimensione e tipo di array
for size in "${SIZES[@]}"; do
    for type in "${TYPES[@]}"; do
        echo "Test in corso: Tipo=$type, Dimensione=$size"
        
        # 1. Genera l'array chiamando lo script Python
        input_data=$(python3 array_generator.py "$type" "$size")
        
        # 2. Controlla se l'input non è vuoto
        if [ -z "$input_data" ]; then
            echo "Errore: generazione dati fallita per Tipo=$type, Dimensione=$size"
            continue
        fi
        
        # 3. Costruisce ed esegue il comando
        full_command="$CMD_BASE --input=$input_data"
        /usr/bin/time -f "\"$type\",$size,%P,%e,%M" -a -o "$OUTPUT_FILE" $full_command
    done
done

echo "-----------------------------------------------------"
echo "Test completato. Dati salvati in $OUTPUT_FILE"