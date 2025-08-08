// Copyright 2024 RISC Zero, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
    // Construct function call: Using the IInsertionSort interface, the application constructs
    // the ABI-encoded function call for the set function of the InsertionSort contract.
    // This call includes the verified number, the post-state digest, and the seal (proof).
    // may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// This application demonstrates how to send an off-chain proof request
// to the Bonsai proving service and publish the received proofs directly
// to your deployed app contract.

use alloy::{
    network::EthereumWallet, providers::ProviderBuilder, signers::local::PrivateKeySigner,
    sol_types::SolValue,
};
use alloy_primitives::{Address, I256}; 
use anyhow::{Context, Result};
use clap::Parser;
use methods::INSERTION_SORT_ELF;
use risc0_ethereum_contracts::encode_seal;
use risc0_zkvm::{default_prover, ExecutorEnv, ProverOpts, VerifierContext};
use url::Url;

// `IInsertionSort` interface automatically generated via the alloy `sol!` macro.
alloy::sol!(
    #[sol(rpc, all_derives)]
    "../contracts/IInsertionSort.sol"
);

/// Arguments of the publisher CLI.
#[derive(Parser, Debug)]
#[clap(author, version, about, long_about = None)]
struct Args {
    /// Ethereum chain ID
    #[clap(long)]
    chain_id: u64,

    /// Ethereum Node endpoint.
    #[clap(long, env)]
    eth_wallet_private_key: PrivateKeySigner,

    /// Ethereum Node endpoint.
    #[clap(long)]
    rpc_url: Url,

    /// Application's contract address on Ethereum
    #[clap(long)]
    contract: Address,

    // (!) DEVE PRENDERE IN INPUT UN VETTORE (!)
    /// The input to provide to the guest binary
    #[clap(short, long, value_delimiter = ',')]
    input: Vec<I256>,
}

fn main() -> Result<()> {
    
    env_logger::init();
    // Parse CLI Arguments: The application starts by parsing command-line arguments provided by the user.
    let args = Args::parse();

    // Create an alloy provider for that private key and URL.
    let wallet = EthereumWallet::from(args.eth_wallet_private_key);
    let provider = ProviderBuilder::new()
        .wallet(wallet)
        .connect_http(args.rpc_url);

    // ABI encode input: Before sending the proof request to the Bonsai proving service,
    // the input number is ABI-encoded to match the format expected by the guest code running in the zkVM.
    let input = args.input.abi_encode();


    let env = ExecutorEnv::builder().write_slice(&input).build()?;

    let receipt = default_prover()
        .prove_with_ctx(
            env,
            &VerifierContext::default(),
            INSERTION_SORT_ELF,
            &ProverOpts::groth16(),
        )?
        .receipt;

     // Serializza la ricevuta e stampa la dimensione
    let serialized_receipt = bincode::serialize(&receipt)?;
    println!("Receipt size: {} bytes", serialized_receipt.len());

    // Encode the seal with the selector.
    let seal = encode_seal(&receipt)?;

    // Extract the journal from the receipt.
    let journal = receipt.journal.bytes.clone();

    // 1. Decodifica il journal in un vettore di I256.
    let sorted_array = Vec::<I256>::abi_decode(&journal)
        .context("Errore durante la decodifica del journal in Vec<I256>")?;

    println!("journal: {:?}", sorted_array);

    // 2. Quando chiami il contratto, `alloy` gestirà la codifica corretta.
    let contract = IInsertionSort::new(args.contract, provider);
    // La funzione `set` nel tuo contratto dovrà accettare `int32[]` o `int256[]`.
    // `alloy` convertirà `Vec<I256>` nel formato corretto.
    let call_builder = contract.set(sorted_array, seal.into());

    // Initialize the async runtime environment to handle the transaction sending.
    let runtime = tokio::runtime::Runtime::new()?;

    // Send transaction: Finally, send the transaction to the Ethereum blockchain,
    // effectively calling the set function of the InsertionSort contract with the verified number and proof.
    let pending_tx = runtime.block_on(call_builder.send())?;
    runtime.block_on(pending_tx.get_receipt())?;

    Ok(())
}
