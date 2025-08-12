use std::io::Read;
use alloy_sol_types::SolValue;
use risc0_zkvm::guest::env;

/*
*   Insertion Sort
*   Sorting by inserting at the appropriate position
*   Starts from the second element, compares with preceding elements to find the correct position and inserts.
*/

// Ordina uno slice mutabile di i32 in-place usando l'algoritmo Heap Sort.
pub fn heapsort(arr: &mut [i32]) {
    if arr.len() <= 1 {
        return; // Già ordinato o vuoto
    }
    
    // 1. Costruisce il Max Heap
    build_max_heap(arr);

    // 2. Ciclo for per estrarre gli elementi dall'heap
    for i in (1..arr.len()).rev() {
        // Scambia la radice (elemento più grande) con l'ultimo elemento dell'heap
        arr.swap(0, i);
        
        // La dimensione dell'heap è ora `i`. Ripristina la proprietà dell'heap.
        max_heapify(arr, i, 0);
    }
}

/// Riordina il sotto-albero con radice al nodo `i` per mantenere la proprietà del Max Heap.
fn max_heapify(arr: &mut [i32], heap_size: usize, i: usize) {
    let left = 2 * i + 1;
    let right = 2 * i + 2;

    let mut largest = i;
    if left < heap_size && arr[left] > arr[largest] {
        largest = left;
    }
    if right < heap_size && arr[right] > arr[largest] {
        largest = right;
    }

    if largest != i {
        arr.swap(i, largest);
        // Continua a "heapificare" verso il basso
        max_heapify(arr, heap_size, largest);
    }
}

/// Costruisce un Max Heap a partire da uno slice non ordinato di i32.
fn build_max_heap(arr: &mut [i32]) {
    let n = arr.len();
    // Itera su tutti i nodi che non sono foglie, dal basso verso l'alto.
    for i in (0..n / 2).rev() {
        max_heapify(arr, n, i);
    }
}


fn main() {
 
    // read input bytes
    let mut input_bytes = Vec::<u8>::new();
    env::stdin().read_to_end(&mut input_bytes).expect("Failed to read initial input from env");
    
    // deserialized bytes to Vec<i32>
    //let mut arr = Vec::<i32>::abi_decode(&input_bytes).expect("Failed to decode input");
    let mut arr: Vec<i32> = Vec::<i32>::abi_decode(&input_bytes).expect("Failed to decode input");
    
    // sort array
    heapsort(&mut arr);    

    // commit the result to env
    env::commit_slice(&arr.abi_encode());
}
