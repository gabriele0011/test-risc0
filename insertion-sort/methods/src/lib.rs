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

//! Generated crate containing the image ID and ELF binary of the build guest.
include!(concat!(env!("OUT_DIR"), "/methods.rs"));

#[cfg(test)]
mod tests {
    use alloy_primitives::U256;
    use alloy_sol_types::SolValue;
    use risc0_zkvm::{default_executor, ExecutorEnv};

    #[test]
    fn proves_insertion_sort() {
        
        let arr = vec![23, 7, 41, 15, 8, 34, 2, 19, 46, 12]; 
        let env = ExecutorEnv::builder()
            .write_slice(&arr.abi_encode())
            .build()
            .unwrap();

        // NOTE: Use the executor to run tests without proving.
        let session_info = default_executor().execute(env, super::INSERTION_SORT_ELF).unwrap();

        let expected_solution = vec![2, 7, 8, 12, 15, 19, 23, 34, 41, 46];
        
        let ord_arr = Vec::<i32>::abi_decode(&session_info.journal.bytes).unwrap();
        println!("Array ricevuto dal guest: {:?}", ord_arr);
        assert_eq!(ord_arr, expected_solution);
    }
}
