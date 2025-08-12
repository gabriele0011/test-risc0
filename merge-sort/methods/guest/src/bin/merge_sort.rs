use std::convert::TryFrom;
use std::io::Read;
use alloy_sol_types::SolValue;
use risc0_zkvm::guest::env;

/*
*/

fn merge(a: &mut Vec<i32>, p: usize, q: usize, r: usize) {
    let n1 = q - p + 1;
    let n2 = r - q;

    // Copia delle sottoliste
    let mut left: Vec<i32> = a[p..=q].to_vec();
    let mut right: Vec<i32> = a[q+1..=r].to_vec();

    // Aggiunta delle sentinelle
    left.push(i32::MAX);
    right.push(i32::MAX);

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

fn merge_sort(a: &mut Vec<i32>, p: usize, r: usize) {
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
    let mut arr = Vec::<i32>::abi_decode(&input_bytes).expect("Failed to decode input");
    
    let len = arr.len();

    // sort array
    merge_sort(&mut arr, 0, len-1);    

    // Convert Vec<i32> to Vec<i32> before commit
    let sorted_array: Vec<i32> = arr.iter().map(|&x| {
        i32::try_from(x).expect("La conversione da i32 a i32 non dovrebbe fallire")
    }).collect();

    // commit the result to env
    env::commit_slice(&sorted_array.abi_encode());
}
