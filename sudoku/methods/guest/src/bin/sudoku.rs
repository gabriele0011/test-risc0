//
// Copyright 2023 RISC Zero, Inc.
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

use std::io::Read;
use risc0_zkvm::guest::env;
use alloy_sol_types::SolValue;
//use alloy_primitives::hex;


//risolve un sudoku rappresentato in una matrice in flat mode (restituisce matrice in flat mode)
fn solve_sudoku(mut matrix: Vec<u8>, n: usize) -> Option<Vec<u8>> {
    fn is_valid(matrix: &[u8], n: usize, row: usize, col: usize, num: u8) -> bool {
        for c in 0..n {
            if matrix[row * n + c] == num {
                return false;
            }
        }
        for r in 0..n {
            if matrix[r * n + col] == num {
                return false;
            }
        }
        // Calcola la dimensione del quadrante basata su n
        let box_size = match n {
            4 => 2,    // 4x4 usa quadranti 2x2
            9 => 3,    // 9x9 usa quadranti 3x3
            16 => 4,   // 16x16 usa quadranti 4x4
            25 => 5,   // 25x25 usa quadranti 5x5
            36 => 6,   // 36x36 usa quadranti 6x6
            _ => 3,    // default per altre dimensioni
        };
        let start_row = (row / box_size) * box_size;
        let start_col = (col / box_size) * box_size;
        for r in start_row..start_row + box_size {
            for c in start_col..start_col + box_size {
                if matrix[r * n + c] == num {
                    return false;
                }
            }
        }
        true
    }
    fn solve(matrix: &mut [u8], n: usize) -> bool {
        let mut empty_pos = None;
        for i in 0..n * n {
            if matrix[i] == 0 {
                empty_pos = Some(i);
                break;
            }
        }
        if empty_pos.is_none() {
            return true;
        }
        let pos = empty_pos.unwrap();
        let row = pos / n;
        let col = pos % n;
        for num in 1..=(n as u8) {
            if is_valid(matrix, n, row, col, num) {
                matrix[pos] = num;
                if solve(matrix, n) {
                    return true;
                }

                matrix[pos] = 0;
            }
        }
        false
    }
    if solve(&mut matrix, n) {
        Some(matrix)
    } else {
        None
    }
}


// Funzione helper per verificare la validità di un posizionamento
fn is_valid_placement(matrix: &[u8], n: usize, row: usize, col: usize, num: u8) -> bool {
    // Verifica riga
    for c in 0..n {
        if matrix[row * n + c] == num {
            return false;
        }
    }
    // Verifica colonna
    for r in 0..n {
        if matrix[r * n + col] == num {
            return false;
        }
    }
    // Verifica quadrante
    let box_size = match n {
        4 => 2,
        9 => 3,
        16 => 4,
        25 => 5,
        _ => 3,
    };
    let start_row = (row / box_size) * box_size;
    let start_col = (col / box_size) * box_size;
    for r in start_row..start_row + box_size {
        for c in start_col..start_col + box_size {
            if matrix[r * n + c] == num {
                return false;
            }
        }
    }
    true
}

fn main() {
    
    /*  
    *   la funzione main legge un vettore di byte dall'ambiente che rappresenta 
    *   una matrice nella forma flat, ossia nel caso 3x3 risulterebbe del tipo [1 2 3 4 5 6 7 8 9]
    */

    // 1) lettura input da en

    // def di un vettore mutabile di bytes di tipo u8 (int senza segno a 8 bit/1 byte)
    let mut input_bytes = Vec::<u8>::new();
    // chiama stdin dal modulo env e ritorna un handle allo stdio da dove si leggono i dati con read 
    env::stdin().read_to_end(&mut input_bytes).expect("Failed to read initial input from env");


    // 2) decodifica ABI input_bytes e generazione matrice in flat_mode 

    //crea una stringa da input_bytes che rappresenta la flat_matrix usata per risolvere il sudoku
    let flat_matrix_string = String::abi_decode(&input_bytes)
        .expect("ABI decoding input bytes failed");
    
    // Converte la stringa in Vec<u8> per il solve_sudoku
    let flat_matrix: Vec<u8> = flat_matrix_string
        .split_whitespace()
        .map(|s| s.parse::<u8>().expect("Failed to parse number in matrix"))
        .collect();
      
    let n = (flat_matrix.len() as f64).sqrt() as usize;


    // 3) risoluzione sudoku 
    
    // risoluzione sudoku 
    let sudoku_solution = solve_sudoku(flat_matrix.clone(), n).expect("Sudoku non risolto");     
    
    
    // Converte la soluzione in una stringa separata da spazi
    let solution_string = sudoku_solution
        .iter()
        .map(|&x| x.to_string())
        .collect::<Vec<String>>()
        .join(" ");
    
    // committa la stringa della soluzione codificata ABI nell'ambiente per il publisher usando alloy
    env::commit_slice(&solution_string.abi_encode());    

    
    // DEBUG: test generale per la soluzione e la sua encode e decode ABI
    //println!("matrix {}x{}: {:?}", n, n, flat_matrix_string);
    //println!("solution: {}\n", solution_string);
    
    /* 
    //println!("ABI encoded matrice env: {:?}\n", input_bytes);
    //println!("ABI encoded hex matrice env: 0x{}\n", hex::encode_upper(&input_bytes));

    //println!("solution: {:?}\n", sudoku_solution);
    let encoded_solution = solution_string.abi_encode();
    println!("ABI encoded solution string length: {}\n", encoded_solution.len());
    println!("ABI encoded solution string hex: 0x{}\n", hex::encode_upper(&encoded_solution));
    
    let test_decode = String::abi_decode(&encoded_solution)
        .expect("Failed to decode solution");
    println!("Decode ABI solution string: {:?}", test_decode);
    
    // Stampa come array di byte (quello che vedrebbe Solidity)
    let encoded_bytes = sudoku_solution.abi_encode();
    println!("ABI encoded as byte array: {:?}", encoded_bytes);
    println!("ABI encoded as byte array (Solidity format): [{}]", 
    encoded_bytes.iter().map(|b| format!("{}", b)).collect::<Vec<_>>().join(", "))
    */
    
    
}


