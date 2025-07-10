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
//
// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.20;
import "forge-std/console.sol";
import {RiscZeroCheats} from "risc0/test/RiscZeroCheats.sol";
import {console2} from "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";
import {IRiscZeroVerifier} from "risc0/IRiscZeroVerifier.sol";
import {Sudoku} from "../contracts/Sudoku.sol";
import {Elf} from "./Elf.sol"; // auto-generated contract after running `cargo build`.

/*
*   si tratta di uno script di test scritto in solidity che serve per verificare il corretto funzionamento
*   del contratto Sudoku
*/

contract SudokuTest is RiscZeroCheats, Test {
    
    Sudoku public sudoku;

    function setUp() public {

        // deploya un mock/verificatore zk per i test 
        IRiscZeroVerifier verifier = deployRiscZeroVerifier();
        
        // nuova istanza del contratto sudoku
        sudoku = new Sudoku(verifier);
    }

    function test_Sudoku4x4() public {

        // matrice di input 4x4 come stringa
        string memory matrix_string = "1 0 0 4 0 0 0 0 0 0 0 0 4 0 0 1";

        // DEBUG: stampa input inviato al guest
        console.log("Input matrix string to guest:");
        console.log(matrix_string);
        // encoding info
        //bytes memory encoded_input = abi.encode(matrix_string);
        //console.log("Encoded input length:", encoded_input.length);
        //console.log("Encoded input hex:");
        //console.logBytes(encoded_input);
 

        // Returns the journal, and seal, resulting from running the
        // guest with elf_path using input on the RISC Zero zkVM
        (bytes memory journal, bytes memory seal) = prove(Elf.SUDOKU_PATH, abi.encode(matrix_string));
    
       
        // decodifica journal viene committato nel publisher come stringa in codifica ABI
        string memory solution_string = abi.decode(journal, (string));
        
        // Converti la stringa in bytes per il contratto
        bytes memory decode_journal = bytes(solution_string);

        // DEBUG: info soluzione e receipt
        console.log("Solution string from guest:");
        console.log(solution_string);
        console.log("Solution string length:", bytes(solution_string).length);

        console.log("Seal size:", seal.length);
        console.log("Journal size:", journal.length);  


        // setta nel contratto la ricevuta
        sudoku.set(decode_journal, seal);
        
        // Verifica che la soluzione nel journal sia corretta
        // soluzione attesa (corretta per un Sudoku 4x4 valido)
        string memory expected_solution = "1 2 3 4 3 4 1 2 2 1 4 3 4 3 2 1";
        
        // confronto sol attesa vs effettiva
        assertEq(keccak256(bytes(solution_string)), keccak256(bytes(expected_solution)));
            
    }
/*


    function test_Sudoku9x9() public {

        // matrice di input 9x9 come stringa
        string memory matrix_string = "5 3 0 0 7 0 0 0 0 6 0 0 1 9 5 0 0 0 0 9 8 0 0 0 0 6 0 8 0 0 0 6 0 0 0 3 "
            "4 0 0 8 0 3 0 0 1 7 0 0 0 2 0 0 0 6 0 6 0 0 0 0 2 8 0 0 0 0 4 1 9 0 0 5 0 0 0 0 8 0 0 7 9";

        // DEBUG: stampa input inviato al guest
        console.log("Input matrix string to guest:");
        console.log(matrix_string);
        // encoding info
        //bytes memory encoded_input = abi.encode(matrix_string);
        //console.log("Encoded input length:", encoded_input.length);
        //console.log("Encoded input hex:");
        //console.logBytes(encoded_input);
 

        // Returns the journal, and seal, resulting from running the
        // guest with elf_path using input on the RISC Zero zkVM
        (bytes memory journal, bytes memory seal) = prove(Elf.SUDOKU_PATH, abi.encode(matrix_string));
    
       
        // decodifica journal viene committato nel publisher come stringa in codifica ABI
        string memory solution_string = abi.decode(journal, (string));
        
        // Converti la stringa in bytes per il contratto
        bytes memory decode_journal = bytes(solution_string);

        // DEBUG: info soluzione e receipt
        console.log("Solution string from guest:");
        console.log(solution_string);
        console.log("Solution string length:", bytes(solution_string).length);

        console.log("Seal size:", seal.length);
        console.log("Journal size:", journal.length);  


        // setta nel contratto la ricevuta
        sudoku.set(decode_journal, seal);
        // Verifica che la soluzione nel journal sia corretta
    
        // soluzione attesa
        string memory expected_solution = "5 3 4 6 7 8 9 1 2 6 7 2 1 9 5 3 4 8 1 9 8 3 4 2 5 6 7 8 5 9 7 6 1 4 2 3 "
            "4 2 6 8 5 3 7 9 1 7 1 3 9 2 4 8 5 6 9 6 1 5 3 7 2 8 4 2 8 7 4 1 9 6 3 5 3 4 5 2 8 6 1 7 9";
        
        // confronto sol attesa vs effettiva
        assertEq(keccak256(bytes(solution_string)), keccak256(bytes(expected_solution)));
               
    }
/*
    function test_Sudoku16x16() public {

        // matrice di input 9x9 come stringa
        string memory matrix_string = "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 5 6 7 8 9 10 11 12 13 14 15 16 1 2 3 4 9 10 11 12 13 14 15 16 1 2 3 4 5 6 7 8 13 14 15 16 1 2 3 4 5 6 7 8 9 10 11 12 2 1 4 3 6 5 8 7 10 9 12 11 14 13 16 15 6 5 8 7 10 9 12 11 14 13 16 15 2 1 4 3 10 9 12 11 14 13 16 15 2 1 4 3 6 5 8 7 14 13 16 15 2 1 4 3 6 5 8 7 10 9 12 11 3 4 1 2 7 8 5 6 11 12 9 10 15 16 13 14 7 8 5 6 11 12 9 10 15 16 13 14 3 4 1 2 11 12 9 10 15 16 13 14 3 4 1 2 7 8 5 6 15 16 13 14 3 4 1 2 7 8 5 6 11 12 9 10 4 3 2 1 8 7 6 5 12 11 10 9 16 15 14 13 8 7 6 5 12 11 10 9 16 15 14 13 4 3 2 1 12 11 10 9 16 15 14 13 4 3 2 1 8 7 6 5 16 15 14 13 4 3 2 1 8 7 6 5 12 11 10 9";

        // DEBUG: stampa input inviato al guest
        console.log("Input matrix string to guest:");
        console.log(matrix_string);
        // encoding info
        //bytes memory encoded_input = abi.encode(matrix_string);
        //console.log("Encoded input length:", encoded_input.length);
        //console.log("Encoded input hex:");
        //console.logBytes(encoded_input);
 

        // Returns the journal, and seal, resulting from running the
        // guest with elf_path using input on the RISC Zero zkVM
        (bytes memory journal, bytes memory seal) = prove(Elf.SUDOKU_PATH, abi.encode(matrix_string));
    
       
        // decodifica journal viene committato nel publisher come stringa in codifica ABI
        string memory solution_string = abi.decode(journal, (string));
        
        // Converti la stringa in bytes per il contratto
        bytes memory decode_journal = bytes(solution_string);

        // DEBUG: info soluzione e receipt
        console.log("Solution string from guest:");
        console.log(solution_string);
        console.log("Solution string length:", bytes(solution_string).length);

        console.log("Seal size:", seal.length);
        console.log("Journal size:", journal.length);  


        // setta nel contratto la ricevuta
        sudoku.set(decode_journal, seal);
        // Verifica che la soluzione nel journal sia corretta
    
        // soluzione attesa
        string memory expected_solution = "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 5 6 7 8 9 10 11 12 13 14 15 16 1 2 3 4 9 10 11 12 13 14 15 16 1 2 3 4 5 6 7 8 13 14 15 16 1 2 3 4 5 6 7 8 9 10 11 12 2 1 4 3 6 5 8 7 10 9 12 11 14 13 16 15 6 5 8 7 10 9 12 11 14 13 16 15 2 1 4 3 10 9 12 11 14 13 16 15 2 1 4 3 6 5 8 7 14 13 16 15 2 1 4 3 6 5 8 7 10 9 12 11 3 4 1 2 7 8 5 6 11 12 9 10 15 16 13 14 7 8 5 6 11 12 9 10 15 16 13 14 3 4 1 2 11 12 9 10 15 16 13 14 3 4 1 2 7 8 5 6 15 16 13 14 3 4 1 2 7 8 5 6 11 12 9 10 4 3 2 1 8 7 6 5 12 11 10 9 16 15 14 13 8 7 6 5 12 11 10 9 16 15 14 13 4 3 2 1 12 11 10 9 16 15 14 13 4 3 2 1 8 7 6 5 16 15 14 13 4 3 2 1 8 7 6 5 12 11 10 9";
            
        
        // confronto sol attesa vs effettiva
        assertEq(keccak256(bytes(solution_string)), keccak256(bytes(expected_solution)));
               
    }


    function test_Sudoku25x25() public {

        // matrice di input 9x9 come stringa
        string memory matrix_string = string.concat(
            "0 2 3 0 5 6 7 8 9 10 11 12 13 14 15 16 0 18 19 20 21 22 23 24 25 ",
            "6 7 8 9 10 11 12 13 14 15 16 17 0 19 20 21 22 23 24 25 1 2 3 4 0 ",
            "11 12 13 14 15 16 0 18 19 0 21 22 23 24 0 1 2 3 4 5 6 7 8 9 10 ",
            "16 17 18 19 20 21 22 23 24 25 1 2 3 4 5 6 7 8 9 0 11 12 13 14 15 ",
            "21 22 23 24 25 1 0 3 4 5 6 7 8 9 0 11 12 13 14 15 16 0 18 19 20 ",
            "2 3 4 5 1 7 8 9 10 6 12 13 14 15 11 17 18 19 20 16 22 23 24 25 21 ",
            "7 8 9 10 6 12 13 14 15 11 17 18 19 20 16 22 23 24 25 21 2 0 4 0 1 ",
            "12 13 14 15 11 17 0 19 20 16 22 23 24 0 21 2 3 4 0 1 7 8 9 10 6 ",
            "17 18 19 20 16 22 23 24 25 21 2 3 4 5 1 7 8 9 10 6 12 13 14 15 11 ",
            "0 23 24 25 21 2 3 4 5 0 7 8 9 10 0 12 13 14 15 11 17 18 19 20 16 ",
            "3 4 5 1 2 8 9 10 6 7 13 14 15 11 12 0 19 20 0 17 23 24 25 21 22 ",
            "8 9 10 6 7 13 14 15 11 12 18 19 20 16 17 23 24 25 21 22 3 4 5 1 2 ",
            "13 0 15 11 12 18 19 20 16 17 23 24 25 21 22 3 4 5 1 2 8 9 10 0 7 ",
            "18 19 20 0 17 23 24 25 21 22 3 4 0 1 2 8 9 0 6 7 13 14 0 11 12 ",
            "23 24 25 21 22 3 4 5 0 0 8 9 10 6 7 13 14 15 11 12 18 19 20 16 17 ",
            "4 5 1 2 3 9 10 6 7 8 14 15 11 12 13 19 20 0 17 18 24 0 21 22 23 ",
            "9 10 6 7 8 14 15 11 12 13 19 20 16 17 0 24 25 21 22 23 4 5 1 2 3 ",
            "14 15 11 12 13 19 20 16 17 18 24 25 21 22 23 4 5 1 2 3 9 10 6 7 8 ",
            "19 20 16 17 18 24 25 21 22 23 4 5 1 2 3 9 10 6 7 8 14 15 11 12 13 ",
            "24 25 21 22 23 4 5 1 2 3 9 10 6 7 8 14 15 11 12 13 19 0 16 17 18 ",
            "5 1 2 3 4 10 6 7 8 9 15 11 12 13 14 20 0 17 18 19 25 21 22 23 0 ",
            "10 6 7 8 9 15 11 12 0 14 20 16 17 18 19 25 21 22 23 0 5 1 2 3 4 ",
            "15 11 12 13 14 20 16 17 18 19 25 21 22 0 24 5 1 2 3 4 10 6 7 8 9 ",
            "20 16 17 18 19 25 21 0 23 24 5 1 2 3 4 10 6 7 8 9 15 11 12 13 14 ",
            "0 21 22 0 24 5 1 2 3 4 10 6 7 8 9 15 11 12 0 14 0 16 17 18 0"
        );

        // DEBUG: stampa input inviato al guest
        console.log("Input matrix string to guest:");
        console.log(matrix_string);
        // encoding info
        //bytes memory encoded_input = abi.encode(matrix_string);
        //console.log("Encoded input length:", encoded_input.length);
        //console.log("Encoded input hex:");
        //console.logBytes(encoded_input);
 

        // Returns the journal, and seal, resulting from running the
        // guest with elf_path using input on the RISC Zero zkVM
        (bytes memory journal, bytes memory seal) = prove(Elf.SUDOKU_PATH, abi.encode(matrix_string));
    
       
        // decodifica journal viene committato nel publisher come stringa in codifica ABI
        string memory solution_string = abi.decode(journal, (string));
        
        // Converti la stringa in bytes per il contratto
        bytes memory decode_journal = bytes(solution_string);

        // DEBUG: info soluzione e receipt
        console.log("Solution string from guest:");
        console.log(solution_string);
        console.log("Solution string length:", bytes(solution_string).length);

        console.log("Seal size:", seal.length);
        console.log("Journal size:", journal.length);  


        // setta nel contratto la ricevuta
        sudoku.set(decode_journal, seal);
        // Verifica che la soluzione nel journal sia corretta
    
    string memory expected_solution = string.concat(
        "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 ",
        "6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 1 2 3 4 5 ",
        "11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 1 2 3 4 5 6 7 8 9 10 ",
        "16 17 18 19 20 21 22 23 24 25 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 ",
        "21 22 23 24 25 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 ",
        "2 3 4 5 1 7 8 9 10 6 12 13 14 15 11 17 18 19 20 16 22 23 24 25 21 ",
        "7 8 9 10 6 12 13 14 15 11 17 18 19 20 16 22 23 24 25 21 2 3 4 5 1 ",
        "12 13 14 15 11 17 18 19 20 16 22 23 24 25 21 2 3 4 5 1 7 8 9 10 6 ",
        "17 18 19 20 16 22 23 24 25 21 2 3 4 5 1 7 8 9 10 6 12 13 14 15 11 ",
        "22 23 24 25 21 2 3 4 5 1 7 8 9 10 6 12 13 14 15 11 17 18 19 20 16 ",
        "3 4 5 1 2 8 9 10 6 7 13 14 15 11 12 18 19 20 16 17 23 24 25 21 22 ",
        "8 9 10 6 7 13 14 15 11 12 18 19 20 16 17 23 24 25 21 22 3 4 5 1 2 ",
        "13 14 15 11 12 18 19 20 16 17 23 24 25 21 22 3 4 5 1 2 8 9 10 6 7 ",
        "18 19 20 16 17 23 24 25 21 22 3 4 5 1 2 8 9 10 6 7 13 14 15 11 12 ",
        "23 24 25 21 22 3 4 5 1 2 8 9 10 6 7 13 14 15 11 12 18 19 20 16 17 ",
        "4 5 1 2 3 9 10 6 7 8 14 15 11 12 13 19 20 16 17 18 24 25 21 22 23 ",
        "9 10 6 7 8 14 15 11 12 13 19 20 16 17 18 24 25 21 22 23 4 5 1 2 3 ",
        "14 15 11 12 13 19 20 16 17 18 24 25 21 22 23 4 5 1 2 3 9 10 6 7 8 ",
        "19 20 16 17 18 24 25 21 22 23 4 5 1 2 3 9 10 6 7 8 14 15 11 12 13 ",
        "24 25 21 22 23 4 5 1 2 3 9 10 6 7 8 14 15 11 12 13 19 20 16 17 18 ",
        "5 1 2 3 4 10 6 7 8 9 15 11 12 13 14 20 16 17 18 19 25 21 22 23 24 ",
        "10 6 7 8 9 15 11 12 13 14 20 16 17 18 19 25 21 22 23 24 5 1 2 3 4 ",
        "15 11 12 13 14 20 16 17 18 19 25 21 22 23 24 5 1 2 3 4 10 6 7 8 9 ",
        "20 16 17 18 19 25 21 22 23 24 5 1 2 3 4 10 6 7 8 9 15 11 12 13 14 ",
        "25 21 22 23 24 5 1 2 3 4 10 6 7 8 9 15 11 12 13 14 20 16 17 18 19"
    );

        // confronto sol attesa vs effettiva
        assertEq(keccak256(bytes(solution_string)), keccak256(bytes(expected_solution)));
    }
*/
}