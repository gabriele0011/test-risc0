use std::io::Read;
use alloy_sol_types::SolValue;
use risc0_zkvm::guest::env;

/*
*   Counting Sort
*   Ordinamento stabile in tempo lineare per interi non negativi entro un range noto.
*/

/// Sorts a slice of non-negative i32 using the Counting Sort algorithm.
///
/// This function follows the implementation defined in the CLRS textbook.
///
/// # Arguments
///
/// * `a` - A slice of `i32` elements to be sorted. Values must be in the range `0..=k`.
/// * `k` - The maximum value present in the input slice `a` (non-negative).
///
/// # Returns
///
/// A new `Vec<i32>` containing the elements of `a` in sorted order.
///

fn counting_sort(a: &[i32], k: i32) -> Vec<i32> {
    assert!(k >= 0, "k must be non-negative");
    // The output array `B` from the pseudocode.
    // Initialized with zeros, it will be filled with sorted values.
    let mut b = vec![0i32; a.len()];

    // --- CLRS Steps 1 & 2 ---
    // Initialize the counting array `C` with zeros.
    // `C` will have a size of `k + 1` to hold counts for values from 0 to k.
    let mut c = vec![0usize; (k as usize) + 1];

    // --- CLRS Steps 3 & 4 ---
    // Count the occurrences of each element in the input array `a`.
    // After this loop, `c[i]` will contain the number of elements equal to `i`.
    for &value in a.iter() {
        assert!(value >= 0 && value <= k, "value {} out of range 0..={}", value, k);
        let idx = value as usize;
        c[idx] += 1;
    }
    // `c` now contains the number of elements equal to i.

    // --- CLRS Steps 6 & 7 ---
    // Modify `c` so that `c[i]` contains the number of elements less than or equal to `i`.
    // This is done by calculating a cumulative sum (prefix sum).
    for i in 1..=(k as usize) {
        c[i] += c[i - 1];
    }
    // `c` now contains the number of elements less than or equal to i.

    // --- CLRS Steps 9, 10, & 11 ---
    // Build the output array `b` by placing elements from `a` into their correct sorted positions.
    // We iterate backwards to make the sort "stable" (i.e., equal elements maintain
    // their original relative order).
    for &value in a.iter().rev() {
        // `c[value]` gives the position *after* the last `value`.
        // We subtract 1 to get the correct 0-based index for the output array `b`.
        let idx = value as usize;
        let output_index = c[idx] - 1;
        b[output_index] = value;

        // Decrement the count for this value to place the next identical element
        // in the position immediately before this one.
        c[idx] -= 1;
    }
    // Return the sorted array `b`.
    b
}



fn main() {
 
    // read input bytes
    let mut input_bytes = Vec::<u8>::new();
    env::stdin().read_to_end(&mut input_bytes).expect("Failed to read initial input from env");
    
    // deserialize bytes to Vec<i32>
    let arr = Vec::<i32>::abi_decode(&input_bytes).expect("Failed to decode input");

    // choose k explicitly (decidi tu il valore di k)
    let k: i32 = 10_000; // modifica questo valore se necessario

    // opzionale: verifica preliminare dell'intervallo [0, k]
    if let (Some(&min_v), Some(&max_v)) = (arr.iter().min(), arr.iter().max()) {
        assert!(min_v >= 0 && max_v <= k, "Input values out of range: min {} max {} k {}", min_v, max_v, k);
    }

    // sort array (ritorna un nuovo Vec<i32>)
    let sorted_array = counting_sort(&arr, k);

    // commit the result to env
    env::commit_slice(&sorted_array.abi_encode());
}
