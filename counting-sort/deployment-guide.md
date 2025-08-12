# RISC Zero Ethereum Deployment Guide

Welcome to the [RISC Zero] Ethereum Deployment guide!

Once you've written your [contracts] and your [methods], and [tested] your program, you're ready to deploy your contract.

You can either:

- [Deploy your project to a local network][section-local]
- [Deploy to a testnet][section-testnet]
- [Deploy to Ethereum Mainnet][section-mainnet]



## Deploy your project on a local network

You can deploy your contracts and run an end-to-end test or demo as follows:

1. Start a local testnet with `anvil` by running:

    ```bash
    anvil
    ```

    Once anvil is started, keep it running in the terminal, and switch to a new terminal.

2. Set your environment variables:
    > ***Note:*** *This requires having access to a Bonsai API Key. To request an API key [complete the form here](https://bonsai.xyz/apply).*
    > Alternatively you can generate your proofs locally, assuming you have a machine with an x86 architecture and [Docker] installed. In this case do not export Bonsai related env variables.

    ```bash
    # Anvil sets up a number of default wallets, and this private key is one of them.
    export ETH_WALLET_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
    export BONSAI_API_KEY="YOUR_API_KEY" # see form linked in the previous section
    export BONSAI_API_URL="BONSAI_API_URL" # provided with your api key
    ```

3. Build your project:

    ```bash
    cargo build
    ```

4. Deploy your contract by running:

    ```bash
    forge script --rpc-url http://localhost:8545 --broadcast script/Deploy.s.sol
    ```

    This command should output something similar to:

    ```bash
    ...
    == Logs ==
    You are deploying on ChainID 31337
    Deployed RiscZeroGroth16Verifier to 0x5FbDB2315678afecb367f032d93F642f64180aa3
    Deployed InsertionSort to 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
    ...
    ```

    Save the `InsertionSort` contract address to an env variable:

    ```bash
    export COUNTING_SORT_ADDRESS=#COPY EVEN NUMBER ADDRESS FROM DEPLOY LOGS
    ```

    > You can also use the following command to set the contract address if you have [`jq`][jq] installed:
    >
    > ```bash
    > export COUNTING_SORT_ADDRESS=$(jq -re '.transactions[] | select(.contractName == "InsertionSort") | .contractAddress' ./broadcast/Deploy.s.sol/31337/run-latest.json)
    > ```

### Interact with your local deployment

1. Query the state:

    ```bash
    cast call --rpc-url http://localhost:8545 ${COUNTING_SORT_ADDRESS:?} 'get()(int256[])'
    ```

2. Publish a new state

    ```bash
    cargo run --bin publisher -- \
        --chain-id=31337 \
        --rpc-url=http://localhost:8545 \
        --contract=${COUNTING_SORT_ADDRESS:?} \
        --input=2,7,8,12,15,19,23,34,41,46
    ```

3. Query the state again to see the change:

    ```bash
    cast call --rpc-url http://localhost:8545 ${COUNTING_SORT_ADDRESS:?} 'get()(int256[])'
    ```







## S E P O L I A ________________________________________________________________________________________________________________________________

## Deploy your project on Sepolia testnet

You can deploy your contracts on the `Sepolia` testnet and run an end-to-end test or demo as follows:

1. Get access to Bonsai and an Ethereum node running on Sepolia testnet (in this example, we will be using [Alchemy](https://www.alchemy.com/) as our Ethereum node provider) and export the following environment variables:
    > ***Note:*** *This requires having access to a Bonsai API Key. To request an API key [complete the form here](https://bonsai.xyz/apply).*
    > Alternatively you can generate your proofs locally, assuming you have a machine with an x86 architecture and [Docker] installed. In this case do not export Bonsai related env variables.

    ```bash
    export ETH_WALLET_PRIVATE_KEY="YOUR_WALLET_PRIVATE_KEY" # the private hex-encoded key of your Sepolia testnet wallet
    ```

2. Build your project:

    ```bash
    cargo build
    ```

3. Deploy your contract by running:

    ```bash
    forge script script/Deploy.s.sol --rpc-url https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY:?} --broadcast
    ```

    This command uses the `sepolia` profile defined in the [config][config] file, and should output something similar to:

    ```bash
    ...
    == Logs ==
    You are deploying on ChainID 11155111
    Deploying using config profile: sepolia
    Using IRiscZeroVerifier contract deployed at 0x925d8331ddc0a1F0d96E68CF073DFE1d92b69187
    Deployed InsertionSort to 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
    ...
    ```

    Save the `InsertionSort` contract address to an env variable:

    ```bash
    export COUNTING_SORT_ADDRESS=#COPY EVEN NUMBER ADDRESS FROM DEPLOY LOGS
    ```

    > You can also use the following command to set the contract address if you have [`jq`][jq] installed:
    >
    > ```bash
    > export COUNTING_SORT_ADDRESS=$(jq -re '.transactions[] | select(.contractName == "InsertionSort") | .contractAddress' ./broadcast/Deploy.s.sol/11155111/run-latest.json)
    > ```

### Interact with your Sepolia testnet deployment

1. Query the state:

    ```bash
    cast call --rpc-url https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY:?} ${COUNTING_SORT_ADDRESS:?} 'get()(int256[])'
    ```

2. Publish a new state

    ```bash
    cargo run --bin publisher -- \
        --chain-id=11155111 \
        --rpc-url=https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY:?} \
        --contract=${COUNTING_SORT_ADDRESS:?} \
        --input=23,7,41,15,8,34,2,19,46,12
    ```

3. Query the state again to see the change:

    ```bash
    cast call --rpc-url https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY:?} ${COUNTING_SORT_ADDRESS:?} 'get()(int256[])'
    ```

