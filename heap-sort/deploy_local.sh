#!/bin/bash
set -e

# 1. Avvia anvil in background (se non già avviato)
if ! pgrep -f anvil > /dev/null; then
  echo "[INFO] Avvio anvil..."
  nohup anvil > anvil.log 2>&1 &
  sleep 2
else
  echo "[INFO] anvil già in esecuzione."
fi
# 2. Esporta variabili d'ambiente
export ETH_WALLET_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# Crea file per esportare variabili nel terminale principale
echo "export ETH_WALLET_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80" > .env_vars

# 3. Build progetto
cargo build

# 4. Deploy contratto
forge script --rpc-url http://localhost:8545 --broadcast script/Deploy.s.sol

# 5. Estrai indirizzo InsertionSort dal log di deploy
export HEAP_SORT_ADDRESS=$(jq -re '.transactions[] | select(.contractName == "HeapSort") | .contractAddress' ./broadcast/Deploy.s.sol/31337/run-latest.json)

# Aggiorna il file delle variabili d'ambiente
echo "export ETH_WALLET_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80" > .env_vars
echo "export HEAP_SORT_ADDRESS=$HEAP_SORT_ADDRESS" >> .env_vars

# 6. Query stato iniziale
cast call --rpc-url http://localhost:8545 $HEAP_SORT_ADDRESS 'get()(int32[])'
echo "[INFO] Deploy e query completati. Ora puoi usare il publisher."

# 7. Mostra comando per pubblicare un nuovo stato
echo ""
echo "[INFO] Per pubblicare un nuovo stato, usare il seguente comando (è possibile cambiare l'input):"
echo ""
echo "cargo run --bin publisher -- \\"
echo "    --chain-id=31337 \\"
echo "    --rpc-url=http://localhost:8545 \\"
echo "    --contract=\"$HEAP_SORT_ADDRESS\" \\"
echo "    --input=2,7,8,12,15,19,23,34,41,46"

echo "[INFO] Deploy, query e comando publisher pronti."
echo ""
echo "[INFO] Per esportare le variabili nel tuo terminale, esegui:"
echo "source .env_vars"
echo ""
echo "[INFO] Oppure la prossima volta esegui lo script con:"
echo "source deploy_local.sh"