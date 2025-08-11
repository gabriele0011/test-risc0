/*
 *    The following test instantiates the IRiscZeroVerifier and HeapSort smart contracts and generates a proof that will
 *    then be verified in the HeapSort smart contract. All the program logic, including proof generation via the prove
 *    function, checks to verify that the journal produced corresponds to the expected solution, and the call to the smart contract
 *    via the set function (within which the journal and seal are passed) that verifies the receipt via the smart contract,
 *    are included in the test_SortUnsortedArray function, which works with a predefined array of 10 elements.
 *    At the end, a check is made to ensure that the verification was successful and that the status of the smart contract has been
 *    modified correctly.
 */

import {RiscZeroCheats} from "risc0/test/RiscZeroCheats.sol";
import {console2} from "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";
import {IRiscZeroVerifier} from "risc0/IRiscZeroVerifier.sol";
import {HeapSort} from "../contracts/HeapSort.sol";
import {Elf} from "./Elf.sol"; // auto-generated contract after running `cargo build`.

contract HeapSortTest is RiscZeroCheats, Test {
    HeapSort public heapSort;

    function setUp() public {
        IRiscZeroVerifier verifier = deployRiscZeroVerifier();
        heapSort = new HeapSort(verifier);
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
        (bytes memory journal, bytes memory seal) = prove(
            Elf.HEAP_SORT_PATH,
            abi.encode(unsortedArray)
        );

        // Decode the journal to get the sorted array from the guest.t the sorted array from the guest.
        int256[] memory provenSortedArray = abi.decode(journal, (int256[]));

        // Check that the journal output is the correctly sorted array.        // Check that the journal output is the correctly sorted array.
        assertEq(provenSortedArray, expectedSortedArray);

        // Set the state on the contract.
        heapSort.set(provenSortedArray, seal);

        // Verify that the contract now holds the sorted array. Verify that the contract now holds the sorted array.
        assertEq(heapSort.get(), expectedSortedArray);
    }
}
