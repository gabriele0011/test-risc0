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

import {RiscZeroCheats} from "risc0/test/RiscZeroCheats.sol";
import {console2} from "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";
import {IRiscZeroVerifier} from "risc0/IRiscZeroVerifier.sol";
import {InsertionSort} from "../contracts/InsertionSort.sol";
import {Elf} from "./Elf.sol"; // auto-generated contract after running `cargo build`.

contract InsertionSortTest is RiscZeroCheats, Test {
    InsertionSort public insertionSort;

    function setUp() public {
        IRiscZeroVerifier verifier = deployRiscZeroVerifier();
        insertionSort = new InsertionSort(verifier);
    }

    function test_SortUnsortedArray() public {
        // Inizializza esplicitamente un array dinamico in memoria.
        int256[] memory unsortedArray = new int256[](10);
        unsortedArray[0] = 23;
        unsortedArray[1] = 7;
        unsortedArray[2] = 41;
        unsortedArray[3] = 15;
        unsortedArray[4] = 8;
        unsortedArray[5] = 34;
        unsortedArray[6] = 2;
        unsortedArray[7] = 19;
        unsortedArray[8] = 46;
        unsortedArray[9] = 12;

        int256[] memory expectedSortedArray = new int256[](10);
        expectedSortedArray[0] = 2;
        expectedSortedArray[1] = 7;
        expectedSortedArray[2] = 8;
        expectedSortedArray[3] = 12;
        expectedSortedArray[4] = 15;
        expectedSortedArray[5] = 19;
        expectedSortedArray[6] = 23;
        expectedSortedArray[7] = 34;
        expectedSortedArray[8] = 41;
        expectedSortedArray[9] = 46;

        // Prove the sorting of the array in the zkVM
        // The input to the guest is the ABI-encoded unsorted array
        (bytes memory journal, bytes memory seal) = prove(Elf.INSERTION_SORT_PATH, abi.encode(unsortedArray));

        // Decode the journal to get the sorted array from the guest.t the sorted array from the guest.
        int256[] memory provenSortedArray = abi.decode(journal, (int256[]));

        // Check that the journal output is the correctly sorted array.        // Check that the journal output is the correctly sorted array.
        assertEq(provenSortedArray, expectedSortedArray);

        // Set the state on the contract.
        insertionSort.set(provenSortedArray, seal);

        // Verify that the contract now holds the sorted array. Verify that the contract now holds the sorted array.
        assertEq(insertionSort.get(), expectedSortedArray);
    }

}