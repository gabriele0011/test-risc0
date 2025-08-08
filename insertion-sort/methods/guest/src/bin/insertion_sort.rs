// Copyright 2023 RISC Zero, Inc.
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

use std::convert::TryFrom;
use std::io::Read;

use alloy_primitives::{I256};
use alloy_sol_types::SolValue;
use risc0_zkvm::guest::env;

/*
Insertion Sort
- Sorting by inserting at the appropriate position
- Starts from the second element, compares with preceding elements to find the correct position and inserts.
*/
fn insertion_sort(arr: &mut Vec<I256>) {
    
    // calculate arr len
    let n = arr.len();

    //
    for i in 1..n {
        let key = arr[i]; // The current integer to be inserted
        // println!("{}th element {}", i, key);
        // Inserts a[i] into the sorted array A[1:i-1]
        let mut j = (i - 1) as i32;

        // Ensure that the current comparison target does not go out of array bounds
        // Find A[j] > key in the sorted part, and end the while loop when j reaches 0

        // If the target comparison is out of bounds (less than the first element), stop
        // For descending order, change > key to < key
        while j >= 0 && arr[j as usize] > key {

            arr[(j + 1) as usize] = arr[j as usize];
            j -= 1; // Move left for the next comparison
        }
        // When the while loop ends, j is one position to the left of where key will be inserted
        arr[(j + 1) as usize] = key;
    }
}


fn main() {
 
    // read input bytes
    let mut input_bytes = Vec::<u8>::new();
    env::stdin().read_to_end(&mut input_bytes).expect("Failed to read initial input from env");
    
    // deserialized bytes to Vec<i32>
    let mut arr = Vec::<I256>::abi_decode(&input_bytes).expect("Failed to decode input");
    
    // sort arr
    insertion_sort(&mut arr);    

    // Converte Vec<i32> in Vec<I256> prima di committare
    let result: Vec<I256> = arr.iter().map(|&x| {
        I256::try_from(x).expect("La conversione da i32 a I256 non dovrebbe fallire")
    }).collect();

    // Committa il tipo corretto per la massima compatibilità con Solidity
    env::commit_slice(&result.abi_encode());

    // debug print

}
