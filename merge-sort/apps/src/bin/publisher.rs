/* 
The program generates a proof based on the execution of the guest code, which implements 
the Insertion Sort algorithm to sort the elements of an array in ascending order. 
This proof, certifying the validity of the computation, is published on-chain via 
the InsertionSort smart contract and is publicly verifiable.
The programme inputs are described in Struct Args (line 30).
*/

use alloy::{
    network::EthereumWallet, providers::ProviderBuilder, signers::local::PrivateKeySigner,
    sol_types::SolValue,
};
use alloy_primitives::{Address}; 
use anyhow::{Context, Result};
use clap::Parser;
use methods::MERGE_SORT_ELF;
use risc0_ethereum_contracts::encode_seal;
use risc0_zkvm::{default_prover, ExecutorEnv, ProverOpts, VerifierContext};
use url::Url;

// `IInsertionSort` interface automatically generated via the alloy `sol!` macro.
alloy::sol!(
    #[sol(rpc, all_derives)]
    "../contracts/IMergeSort.sol"
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

    /// The input to provide to the guest binary
    #[clap(short, long, value_delimiter = ',')]
    input: Vec<i32>,
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

    // receipt genereted by the execution of guest code
    let receipt = default_prover()
        .prove_with_ctx(
            env,
            &VerifierContext::default(),
            MERGE_SORT_ELF,
            &ProverOpts::groth16(),
        )?
        .receipt;

    // Serialise the receipt and print the size
    // (!) you could write to a file in the future
    let serialized_receipt = bincode::serialize(&receipt)?;
    println!("Receipt size: {} bytes", serialized_receipt.len());

    // Encode the seal with the selector.
    let seal = encode_seal(&receipt)?;
    
    // Extract the journal from the receipt.
    let journal = receipt.journal.bytes.clone();

    // decode journal
    let sorted_array = Vec::<i32>::abi_decode(&journal)
        .context("Errore durante la decodifica del journal in Vec<i32>")?;

    // print journal
    // println!("journal: {:?}", sorted_array);

    // When you call the contract, `alloy` will handle the correct encoding.
    let contract = IMergeSort::new(args.contract, provider);
    let call_builder = contract.set(sorted_array, seal.into());

    // Initialize the async runtime environment to handle the transaction sending.
    let runtime = tokio::runtime::Runtime::new()?;

    // Send transaction: Finally, send the transaction to the Ethereum blockchain,
    // effectively calling the set function of the InsertionSort contract with the verified number and proof.
    let pending_tx = runtime.block_on(call_builder.send())?;
    runtime.block_on(pending_tx.get_receipt())?;

    Ok(())
}
