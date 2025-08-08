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
# (BONSAI_API_KEY e BONSAI_API_URL opzionali per prove locali)

# 3. Build progetto
cargo build

# 4. Deploy contratto
forge script --rpc-url http://localhost:8545 --broadcast script/Deploy.s.sol

# 5. Estrai indirizzo Sudoku dal log di deploy
export SUDOKU_ADDRESS=$(jq -re '.transactions[] | select(.contractName == "Sudoku") | .contractAddress' ./broadcast/Deploy.s.sol/31337/run-latest.json)

# 6. Query stato iniziale
cast call --rpc-url http://localhost:8545 $SUDOKU_ADDRESS 'matrix()(bytes memory)'

echo "[INFO] Deploy e query completati. Ora puoi usare il publisher."

# 7. Mostra comando per pubblicare un nuovo stato
echo ""
echo "[INFO] Per pubblicare un nuovo stato, usa il comando seguente (puoi cambiare l'input):"
echo "cargo run --bin publisher -- \\"
echo "    --chain-id=31337 \\"
echo "    --rpc-url=http://localhost:8545 \\"
echo "    --contract=\"$SUDOKU_ADDRESS\" \\"
echo "    --matrix='1 0 0 4 0 0 0 0 0 0 0 0 4 0 0 1'"

echo "[INFO] Deploy, query e comando publisher pronti."

echo "[INFO]" Per completare la procedura: 
echo export ETH_WALLET_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80