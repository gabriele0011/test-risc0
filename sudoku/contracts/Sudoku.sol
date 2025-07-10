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
contract Sudoku {

    /// @notice RISC Zero verifier contract address.
    IRiscZeroVerifier public immutable verifier;

    /// @notice Image ID of the only zkVM binary to accept verification from.
    bytes32 public constant imageId = ImageID.SUDOKU_ID;

    /// @notice Flat matrix, set by zkVM proof.
    bytes public matrix;

    /// @notice Initialize the contract, binding it to a specified RISC Zero verifier.
    constructor(IRiscZeroVerifier _verifier) {
        verifier = _verifier;
    }
    
    /// @notice Imposta la matrice flat, richiede una proof zkVM valida.
    function set(bytes memory x, bytes calldata seal) public {
        bytes memory journal = abi.encode(x);
        verifier.verify(seal, imageId, sha256(journal));
        matrix = x; 
    }

    /// @notice Restituisce la matrice flat salvata.
    function get() public view returns (bytes memory) {
        return matrix;
    }
}
