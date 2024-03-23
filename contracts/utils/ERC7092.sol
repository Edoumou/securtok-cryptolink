// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../IERC7092.sol";
import "../BondStorage.sol";
import "./InternalCall.sol";

contract ERC7092 is IERC7092, InternalCall {
    function isin() external view returns(string memory) {
        return bonds.isin;
    }
    
    function name() external view returns(string memory) {
        return bonds.name;
    }

    function symbol() external view returns(string memory) {
        return bonds.symbol;
    }

    function currency() external view returns(address) {
        return bonds.currency;
    }

    function denomination() external view returns(uint256) {
        return bonds.denomination;
    }

    function issueVolume() external view returns(uint256) {
        return bonds.issueVolume;
    }

    function totalSupply() external view returns(uint256) {
        uint256 _issueVolume = bonds.issueVolume;
        uint256 _denomination = bonds.denomination;

        return _issueVolume / _denomination;
    }

    function couponRate() external view returns(uint256) {
        return bonds.couponRate;
    }

    function issueDate() external view returns(uint256) {
        return bonds.issueDate;
    }

    function maturityDate() external view returns(uint256) {
        return bonds.maturityDate;
    }

    function principalOf(address _account) external view returns(uint256) {
        return _principals[_account];
    }

    function balanceOf(address _account) public view returns(uint256) {
        uint256 _principal = _principals[_account];
        uint256 _denomination = bonds.denomination;

        return _principal / _denomination;
    }

    function allowance(
        address _owner,
        address _spender
    ) external view returns(uint256) {
        return _approvals[_owner][_spender];
    }

    function approve(
        address _spender,
        uint256 _amount
    ) external returns(bool) {
        address _owner = msg.sender;
        _approve(_owner, _spender, _amount);

        emit Approval(_owner, _spender, _amount);

        return true;
    }

    function decreaseAllowance(
        address _spender,
        uint256 _amount
    ) external returns(bool) {
        address _owner = msg.sender;
        _decreaseAllowance(_owner, _spender, _amount);

        emit Approval(_owner, _spender, _amount);

        return true;
    }

    function transfer(
        address _to,
        uint256 _amount,
        bytes calldata _data
    ) external returns(bool) {
        address _from = msg.sender;
        _transfer(_from, _to, _amount, _data);

        emit Transfer(_from, _to, _amount);

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount,
        bytes calldata _data
    ) external returns(bool) {
        address _spender = msg.sender;
        _spendApproval(_from, _spender, _amount);
        _transfer(_from, _to, _amount, _data);

        emit Transfer(_from, _to, _amount);

        return true;
    }

    function batchApprove(
        address[] calldata _spender,
        uint256[] calldata _amount
    ) external returns(bool) {
        address _owner = msg.sender;
        _batchApprove(_owner, _spender, _amount);

        emit ApprovalBatch(_owner, _spender, _amount);

        return true;
    }

    function batchDecreaseAllowance(
        address[] calldata _spender,
        uint256[] calldata _amount
    ) external returns(bool) {
        address _owner = msg.sender;
        _batchDecreaseAllowance(_owner, _spender, _amount);

        emit ApprovalBatch(_owner, _spender, _amount);

        return true;
    }

    function batchTransfer(
        address[] calldata _to,
        uint256[] calldata _amount,
        bytes[] calldata _data
    ) external returns(bool) {
        address[] memory _from;
        for(uint256 i; i < _to.length; i++) {
            _from[i] = msg.sender;
        }

        _batchTransfer(_from, _to, _amount, _data);

        emit TransferBatch(_from, _to, _amount);

        return true;
    }

    function batchTransferFrom(
        address[] calldata _from,
        address[] calldata _to,
        uint256[] calldata _amount,
        bytes[] calldata _data
    ) external returns(bool) {
        address _spender = msg.sender;
        _batchSpendApproval(_from, _spender, _amount);
        _batchTransfer(_from, _to, _amount, _data);

        return true;
    }
}