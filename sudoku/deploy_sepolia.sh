#!/bin/bash
set -e

# Inserisci qui le tue chiavi
echo export delle seguenti variabili:
echo ALCHEMY_API_KEY="INSERISCI_LA_TUA_ALCHEMY_API_KEY"
echo ETH_WALLET_PRIVATE_KEY="INSERISCI_LA_TUA_ETH_WALLET_PRIVATE_KEY"

# Controllo variabili obbligatorie
if [[ -z "$ALCHEMY_API_KEY" || -z "$ETH_WALLET_PRIVATE_KEY" ]]; then
  echo "Errore: devi inserire ALCHEMY_API_KEY e ETH_WALLET_PRIVATE_KEY all'inizio di questo script."
  exit 1
fi

# Build progetto
cargo build

# Deploy contratto
forge script script/Deploy.s.sol --rpc-url https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY} --broadcast

# Estrai indirizzo EvenNumber dal log di deploy
DEPLOY_LOG=./broadcast/Deploy.s.sol/11155111/run-latest.json
if [[ ! -f "$DEPLOY_LOG" ]]; then
  echo "Errore: file di log $DEPLOY_LOG non trovato."
  exit 1
fi

SUDOKU_ADDRESS=$(jq -re '.transactions[] | select(.contractName == "EvenNumber") | .contractAddress' "$DEPLOY_LOG")
if [[ -z "$SUDOKU_ADDRESS" ]]; then
  echo "Errore: indirizzo EvenNumber non trovato nei log."
  exit 1
fi

echo "Indirizzo EvenNumber deployato: $SUDOKU_ADDRESS"
export SUDOKU_ADDRESS

echo "Variabile d'ambiente SUDOKU_ADDRESS esportata."
