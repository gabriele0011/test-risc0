use std::convert::TryFrom;
use std::io::Read;
use alloy_primitives::{I256};
use alloy_sol_types::SolValue;
use risc0_zkvm::guest::env;

/*
*/

fn merge(a: &mut Vec<I256>, p: usize, q: usize, r: usize) {
    let n1 = q - p + 1;
    let n2 = r - q;

    // Copia delle sottoliste
    let mut left: Vec<I256> = a[p..=q].to_vec();
    let mut right: Vec<I256> = a[q+1..=r].to_vec();

    // Aggiunta delle sentinelle
    left.push(I256::MAX);
    right.push(I256::MAX);

    let mut i = 0;
    let mut j = 0;

    for k in p..=r {
        if left[i] <= right[j] {
            a[k] = left[i];
            i += 1;
        } else {
            a[k] = right[j];
            j += 1;
        }
    }
}

fn merge_sort(a: &mut Vec<I256>, p: usize, r: usize) {
    if p < r {
        let q = p + (r - p) / 2;
        merge_sort(a, p, q);
        merge_sort(a, q + 1, r);
        merge(a, p, q, r);
    }
}


fn main() {
 
    // read input bytes
    let mut input_bytes = Vec::<u8>::new();
    env::stdin().read_to_end(&mut input_bytes).expect("Failed to read initial input from env");
    
    // deserialized bytes to Vec<i32>
    let mut arr = Vec::<I256>::abi_decode(&input_bytes).expect("Failed to decode input");
    
    let len = arr.len();

    // sort array
    merge_sort(&mut arr, 0, len-1);    

    // Convert Vec<i32> to Vec<I256> before commit
    let sorted_array: Vec<I256> = arr.iter().map(|&x| {
        I256::try_from(x).expect("La conversione da i32 a I256 non dovrebbe fallire")
    }).collect();

    // commit the result to env
    env::commit_slice(&sorted_array.abi_encode());
}
