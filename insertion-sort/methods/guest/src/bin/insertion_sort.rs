use std::convert::TryFrom;
use std::io::Read;
use alloy_sol_types::SolValue;
use risc0_zkvm::guest::env;

/*
*   Insertion Sort
*   Sorting by inserting at the appropriate position
*   Starts from the second element, compares with preceding elements to find the correct position and inserts.
*/

fn insertion_sort(arr: &mut Vec<i32>) {
    
    // calculate arr len
    let n = arr.len();

    // iterates from the second elem onwards 
    for i in 1..n {
        
        // The current integer to be inserted
        let key = arr[i]; 
        
        // Inserts arr[i] into the sorted array A[1:i-1]
        let mut j = (i - 1) as i32;

        // Find A[j] > key in the sorted part, and end the while loop when j reaches 0

        // If the target comparison is out of bounds (less than the first element), stop
        // For descending order, change > key to < key
        while j >= 0 && arr[j as usize] > key {

            // copy the j th value to the j+1 th (move j one step to the left)
            arr[(j + 1) as usize] = arr[j as usize];
            // Move left for the next comparison
            j -= 1; 
        }
        // When the while loop ends, j is one position to the left of where key will be inserted
        // place the key
        arr[(j + 1) as usize] = key;
    }
}

fn main() {
 
    // read input bytes
    let mut input_bytes = Vec::<u8>::new();
    env::stdin().read_to_end(&mut input_bytes).expect("Failed to read initial input from env");
    
    // deserialized bytes to Vec<i32>
    let mut arr = Vec::<i32>::abi_decode(&input_bytes).expect("Failed to decode input");
    
    // sort array
    insertion_sort(&mut arr);    

    // Convert Vec<i32> to Vec<i32> before commit
    let sorted_array: Vec<i32> = arr.iter().map(|&x| {
        i32::try_from(x).expect("La conversione da i32 a i32 non dovrebbe fallire")
    }).collect();

    // commit the result to env
    env::commit_slice(&sorted_array.abi_encode());
}
