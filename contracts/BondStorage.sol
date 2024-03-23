// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BondData.sol";

contract BondStorage {
    mapping(address => uint256) internal _principals;
    mapping(address => mapping(address => uint256)) internal _approvals;
    mapping(address => uint256) internal _balances;

    BondData.Bond bonds;
    BondData.Issuer public issuer;

    event MessageSent(
        uint256 destinationChainID,
        address destinationContract
    );

    event MessageSent(
        uint256[] destinationChainID,
        address[] destinationContract
    );
}