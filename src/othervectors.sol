// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OtherVectors {
    address public trustedContract;
    uint256 private secretNumber;
    uint256 public deadline;

    event CallResult(bool success, bytes data);

    constructor(address _trustedContract, uint256 _deadline) {
        trustedContract = _trustedContract;
        deadline = _deadline;
    }

    // Delegatecall to Untrusted Callee
    function delegateCallToUntrusted(bytes memory _data) public returns (bool success, bytes memory result) {
        (success, result) = trustedContract.delegatecall(_data);
        emit CallResult(success, result);
    }

    // Time Manipulation
    function isExpired() public view returns (bool) {
        return block.timestamp >= deadline;
    }

    // Malicious Library
    function transferWithMaliciousLib(address _to, uint256 _amount) public {
        MaliciousLibrary.transfer(_to, _amount);
    }

    // Phishing with Fake Interfaces
    function callFakeInterface(address _addr) public {
        IPotentialInterface(_addr).withdraw();
    }

    // External Contract Dependence
    function callExternalFunction(address _addr) public {
        require(_addr.call(abi.encodeWithSignature("withdraw()")));
    }

    // Solidity Compiler Bugs
    function readSecretNumber() public view returns (uint256) {
        return secretNumber;
    }

    // DOS with Blockhash
    function blockHash(uint256 _blockNumber) public view returns (bytes32) {
        return blockhash(_blockNumber);
    }

    receive() external payable {}

    // Malicious Library
    library MaliciousLibrary {
        function transfer(address _to, uint256 _amount) public {
            (bool success, ) = _to.call{value: _amount}("");
            require(success);
        }
    }

    // Fake Interface
    interface IPotentialInterface {
        function withdraw() external;
    }
}