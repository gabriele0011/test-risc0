#!/bin/bash
# Esce immediatamente se un comando fallisce.
set -e

# --- CONFIGURAZIONE ---

# Nome del file di output per i dati.
OUTPUT_FILE="insertion_sort_data.csv"

# Array contenente gli input da testare.
# Ogni elemento dell'array è una stringa che rappresenta un set di input.
INPUTS=(
    "23,7,41,15,8,34,2,19,46,12"
)

# Definizione del comando base da eseguire.
CMD_BASE="cargo run --bin publisher -- --chain-id=31337 --rpc-url=http://localhost:8545 --contract=0x0b306bf915c4d645ff596e518faf3f9669b97016"

# --- ESECUZIONE ---

# 1. Crea il file CSV con l'intestazione, sovrascrivendo versioni precedenti.
echo "Input,Perc_CPU,Total_Time_s,Max_RAM_kB,Media_RAM_kB,Media_Mem_Tot_kB" > "$OUTPUT_FILE"

echo "Script avviato. Verranno eseguiti ${#INPUTS[@]} test."
echo "-----------------------------------------------------"

# 2. Itera su ogni set di dati definito nell'array INPUTS.
for input_data in "${INPUTS[@]}"; do
    echo "Esecuzione test con input: $input_data"
    
    # Costruisce il comando completo aggiungendo l'input specifico.
    full_command="$CMD_BASE --input=$input_data"
    
    # Esegue il comando tramite /usr/bin/time.
    # I risultati vengono accodati al file di output.
    # L'input corrente viene aggiunto come prima colonna nel CSV per tracciabilità.
    /usr/bin/time -f "\"$input_data\",%P,%e,%M,%t,%K" -a -o "$OUTPUT_FILE" $full_command
done

echo "-----------------------------------------------------"
echo "Tutti i test sono stati completati. Dati salvati in $OUTPUT_FILE"



