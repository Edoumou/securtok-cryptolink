// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/ERC7092.sol";
import "./utils/ERC7092CrossChain.sol";

contract BondERC7092 is ERC7092, ERC7092CrossChain {
    constructor(
        BondData.Bond memory _bond,
        BondData.Issuer memory _issuer
    ) {
        bonds = _bond;
        issuer = _issuer;

        _principals[msg.sender] = _bond.issueVolume;
    }

    /**
    * CryptoLink message processing
    */
    function messageProcess(
        uint,
        uint _sourceChainID,
        address _sender,
        address,
        uint,
        bytes calldata _data
    ) external override  onlySelf(_sender, _sourceChainID)  {
        // execute message
        (bool success, ) = address(this).call(_data);
        require(success);
    }
}