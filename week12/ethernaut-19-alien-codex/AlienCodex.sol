// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "./Ownable-05.sol";

contract AlienCodex is Ownable {
    bool public contact;
    bytes32[] public codex;

    modifier contacted() {
        assert(contact);
        _;
    }

    function makeContact() internal {
        contact = true;
    }

    function record(bytes32 _content) internal contacted {
        codex.push(_content);
    }

    function retract() internal contacted {
        codex.length--;
    }

    function revise(uint i, bytes32 _content) internal contacted {
        codex[i] = _content;
    }
}
