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

import {IRiscZeroVerifier} from "risc0/IRiscZeroVerifier.sol";
import {ImageID} from "./ImageID.sol"; // auto-generated contract after running `cargo build`.

/// @title A starter application using RISC Zero.
/// @notice This basic application holds a number, guaranteed to be even.
/// @dev This contract demonstrates one pattern for offloading the computation of an expensive
///      or difficult to implement function to a RISC Zero guest running on the zkVM.
contract MergeSort {
    /// @notice RISC Zero verifier contract address.
    IRiscZeroVerifier public immutable verifier;
    /// @notice Image ID of the only zkVM binary to accept verification from.
    ///         The image ID is similar to the address of a smart contract.
    ///         It uniquely represents the logic of that guest program,
    ///         ensuring that only proofs generated from a pre-defined guest program
    ///         (in this case, checking if a number is even) are considered valid.
    bytes32 public constant imageId = ImageID.MERGE_SORT_ID;

    /// @notice An array that is guaranteed, by the RISC Zero zkVM, to be sorted.
    ///         It can be set by calling the `set` function.
    int32[] public sorted_array;

    /// @notice Initialize the contract, binding it to a specified RISC Zero verifier.
    constructor(IRiscZeroVerifier _verifier) {
        verifier = _verifier;
    }

    /// @notice Set the sorted array stored on the contract. Requires a RISC Zero proof.
    function set(int32[] memory _sorted_array, bytes calldata seal) public {
        // The journal is the ABI-encoded representation of the function outputs.
        // In this case, the sorted array.
        bytes memory journal = abi.encode(_sorted_array);
        // Verify the receipt, ensuring the journal matches the commitment.
        verifier.verify(seal, imageId, sha256(journal));
        // Store the sorted array.
        sorted_array = _sorted_array;
    }

    /// @notice Returns the sorted array.
    function get() public view returns (int32[] memory) {
        return sorted_array;
    }
}
