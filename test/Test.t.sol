// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {AttackVector} from "../src/vectors.sol";


contract attackTest is Test{
    VulnerableContract public contractInstance;

    function beforeAll() public {
        contractInstance = new VulnerableContract(1000);
    }

    function testIntegerOverflow() public {
        // Test minting to cause integer overflow
        contractInstance.mint(address(this), type(uint256).max);
    }

    function testReentrancy() public payable {
        // Test reentrancy in maliciousWithdraw function
        contractInstance.maliciousWithdraw(address(this), 1 ether);
    }

    function testDoSWithGasLimit() public {
        // Test addUser function to reach gas limit
        for (uint256 i = 0; i < 1000; i++) {
            contractInstance.addUser(address(i));
        }
    }

    function testUncheckedExternalCall() public {
        // Test maliciousWithdraw to an untrusted contract
        contractInstance.maliciousWithdraw(address(this), 1 ether);
    }

    function testAccessControlIssues() public {
        // Test unauthorized mint, burn, addAdmin, removeAdmin, addUser calls
        contractInstance.mint(address(this), 100);
        contractInstance.burn(50);
        contractInstance.addAdmin(address(this));
        contractInstance.removeAdmin(address(this));
        contractInstance.addUser(address(this));
    }

    function testLackOfInputValidation() public {
        // Test addUser without owner/admin rights
        contractInstance.addUser(address(1));
    }

    function testLackOfEventEmitting() public {
        // Test transactions without emitted events
        contractInstance.transfer(address(1), 100);
        contractInstance.mint(address(this), 100);
        contractInstance.burn(50);
        contractInstance.pause();
        contractInstance.unpause();
        contractInstance.addAdmin(address(this));
        contractInstance.removeAdmin(address(this));
        contractInstance.addUser(address(this));
        contractInstance.maliciousWithdraw(address(this), 1 ether);
    }
}