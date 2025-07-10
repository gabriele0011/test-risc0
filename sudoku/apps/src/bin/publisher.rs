// Copyright 2024 RISC Zero, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
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
use anyhow::{Result};
use clap::Parser;
use methods::SUDOKU_ELF;
use risc0_ethereum_contracts::encode_seal;
use risc0_zkvm::{default_prover, ExecutorEnv, ProverOpts, VerifierContext};
use url::Url;
use alloy_primitives::Address;

use std::fs::OpenOptions;
use std::io::Write;


//MODIFICA (!)
// ISudoku interface automatically generated via the alloy `sol!` macro
alloy::sol!(
    #[sol(rpc, all_derives)]
    "../contracts/ISudoku.sol"
);


// Arguments of the publisher CLI
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

    /// Matrix values in row-major order as a string, e.g. "1 2 3 2 3 4 2 4 0"
    /// Must contain matrix_size * matrix_size integers between 0 and 9 separated by spaces
    #[clap(long)]
    matrix: String,
}


fn main() -> Result<()> {
    
    // parsing CLI arguments
    env_logger::init();
    let args = Args::parse();

    // Create an alloy provider for that private key and URL.
    let wallet = EthereumWallet::from(args.eth_wallet_private_key);
    let provider = ProviderBuilder::new()
        .wallet(wallet)
        .connect_http(args.rpc_url);
    
    
    // matrice che rappresenta l'input del guest code come stringa
    // Non è più necessario parsare in Vec<u8> dato che passiamo la stringa direttamente
    
    // codifica ABI della stringa della matrice usando alloy
    let encoded = args.matrix.abi_encode();


    // definizione ambiente 
    let env = ExecutorEnv::builder().write_slice(&encoded).build()?;


    //ricevuta 
    let receipt = default_prover()
        .prove_with_ctx(
            env,
            &VerifierContext::default(),
            SUDOKU_ELF,
            &ProverOpts::groth16(),
        )?
        .receipt;

    // Serializza la ricevuta e stampa la dimensione
    let serialized_receipt = bincode::serialize(&receipt)?;
    println!("Receipt size: {} bytes", serialized_receipt.len());

    // Encode the seal with the selector.
    let seal = encode_seal(&receipt)?;

    // Extract the journal from the receipt che contiene al soluzione del sudoku calcolata dal guest
    let journal = receipt.journal.bytes.clone();

    // Decodifica del Journal come stringa usando alloy
    let solution_string = String::abi_decode(&journal)
        .expect("ABI decoding journal as string failed");
    
    // Converti la stringa in Vec<u8> per il contratto (se necessario)
    let vec: Vec<u8> = solution_string.as_bytes().to_vec();

    // Construct function call: Using the IEvenNumber interface, the application constructs
    // the ABI-encoded function call for the set function of the EvenNumber contract.
    // This call includes the verified number, the post-state digest, and the seal (proof).
    let contract = ISudoku::new(args.contract, provider);
    
    // il contratto viene settato memorizzando al suo interno la ricevuta (journal + seal)
    let call_builder = contract.set(vec.into(), seal.into());
    
    // Initialize the async runtime environment to handle the transaction sending.
    let runtime = tokio::runtime::Runtime::new()?;

    // Send transaction: Finally, send the transaction to the Ethereum blockchain,
    // effectively calling the set function of the EvenNumber contract with the verified number and proof.
    let pending_tx = runtime.block_on(call_builder.send())?;
    runtime.block_on(pending_tx.get_receipt())?;


    


    Ok(())
}
