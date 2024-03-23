// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../IERC7092.sol";
import "./InternalCall.sol";

contract ERC7092CrossChain is IERC7092CrossChain, InternalCall {
    function crossChainApprove(
        address _spender,
        uint256 _amount,
        bytes32 _destinationChainID,
        address _destinationContract
    ) external returns(bool) {
        address _owner = msg.sender;
        _crossChainApproval(
            _owner,
            _spender,
            _amount,
            _destinationChainID,
            _destinationContract,
            "crossApprove(address,address,uint256)"
        );

        emit CrossChainApproval(_owner, _spender, _amount, _destinationChainID);

        return true;
    }

    function crossChainBatchApprove(
        address[] calldata _spender,
        uint256[] calldata _amount,
        bytes32[] calldata _destinationChainID,
        address[] calldata _destinationContract
    ) external returns(bool) {
        address _owner = msg.sender;
        _crossChainBatchApproval(
            _owner,
            _spender,
            _amount,
            _destinationChainID,
            _destinationContract,
            "crossApprove(address,address,uint256)"
        );

        emit CrossChainApprovalBatch(_owner, _spender, _amount, _destinationChainID);

        return true;
    }

    function crossChainDecreaseAllowance(
        address _spender,
        uint256 _amount,
        bytes32 _destinationChainID,
        address _destinationContract
    ) external {
        address _owner = msg.sender;
        _crossChainApproval(
            _owner,
            _spender,
            _amount,
            _destinationChainID,
            _destinationContract,
            "crossDecreaseAllowance(address,address,uint256)"
        );

        emit CrossChainApproval(_owner, _spender, _amount, _destinationChainID);
    }

    function crossChainBatchDecreaseAllowance(
        address[] calldata _spender,
        uint256[] calldata _amount,
        bytes32[] calldata _destinationChainID,
        address[] calldata _destinationContract
    ) external {
        address _owner = msg.sender;
        _crossChainBatchApproval(
            _owner,
            _spender,
            _amount,
            _destinationChainID,
            _destinationContract,
            "crossDecreaseAllowance(address,address,uint256)"
        );

        emit CrossChainApprovalBatch(_owner, _spender, _amount, _destinationChainID);
    }

    function crossChainTransfer(
        address _to,
        uint256 _amount,
        bytes calldata _data,
        bytes32 _destinationChainID,
        address _destinationContract
    ) external returns(bool) {
        address _from = msg.sender;
        _crossChainTransfer(
            _from,
            _to,
            _amount,
            _data,
            _destinationChainID,
            _destinationContract,
            "crossTransfer(address,uint256,bytes)"
        );

        emit CrossChainTransfer(_from, _to, _amount, _destinationChainID);

        return true;
    }

    function crossChainBatchTransfer(
        address[] calldata _to,
        uint256[] calldata _amount,
        bytes[] calldata _data,
        bytes32[] calldata _destinationChainID,
        address[] calldata _destinationContract
    ) external returns(bool) {
        address[] memory _from;
        for(uint256 i; i < _to.length; i++) {
            _from[i] = msg.sender;
        }

        _crossChainBatchTransfer(
            _from,
            _to,
            _amount,
            _data,
            _destinationChainID,
            _destinationContract,
            "crossTransfer(address,uint256,bytes)"
        );

        emit CrossChainTransferBatch(_from, _to, _amount, _destinationChainID);

        return true;
    }

    function crossChainTransferFrom(
        address _from,
        address _to,
        uint256 _amount,
        bytes calldata _data,
        bytes32 _destinationChainID,
        address _destinationContract
    ) external returns(bool) {
        address _spender = msg.sender;
        _spendApproval(_from, _spender, _amount);
        _crossChainTransfer(
            _from,
            _to,
            _amount,
            _data,
            _destinationChainID,
            _destinationContract,
            "crossTransfer(address,uint256,bytes)"
        );

        emit CrossChainTransfer(_from, _to, _amount, _destinationChainID);

        return true;
    }

    function crossChainBatchTransferFrom(
        address[] calldata _from,
        address[] calldata _to,
        uint256[] calldata _amount,
        bytes[] calldata _data,
        bytes32[] calldata _destinationChainID,
        address[] calldata _destinationContract
    ) external returns(bool) {
        address _spender = msg.sender;
        _batchSpendApproval(_from, _spender, _amount);
        _crossChainBatchTransfer(
            _from,
            _to,
            _amount,
            _data,
            _destinationChainID,
            _destinationContract,
            "crossTransfer(address,uint256,bytes)"
        );

        emit CrossChainTransferBatch(_from, _to, _amount, _destinationChainID);

        return true;
    }
}