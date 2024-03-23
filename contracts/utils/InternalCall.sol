// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@cryptolink/contracts/message/MessageClient.sol";
import "../BondStorage.sol";

abstract contract InternalCall is BondStorage, MessageClient {
    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal virtual {
        require(_owner != address(0), "wrong address");
        require(_spender != address(0), "wrong address");
        require(_amount > 0, "invalid amount");

        uint256 _approval = _approvals[_owner][_spender];
        uint256 _denomination = bonds.denomination;
        uint256 _maturityDate = bonds.maturityDate;

        uint256 _principal = _principals[_owner];
        uint256 _balance = _principal / _denomination;

        require(block.timestamp < _maturityDate, "matured");
        require(_amount <= _balance, "insufficient balance");
        require((_amount * _denomination) % _denomination == 0, "invalid amount");

        _approvals[_owner][_spender]  = _approval + _amount;
    }

    function _decreaseAllowance(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal virtual {
        require(_owner != address(0), "wrong address");
        require(_spender != address(0), "wrong address");
        require(_amount > 0, "invalid amount");

        uint256 _approval = _approvals[_owner][_spender];
        uint256 _denomination = bonds.denomination;
        uint256 _maturityDate = bonds.maturityDate;

        require(block.timestamp < _maturityDate, "matured");
        require(_amount <= _approval, "insufficient approval");
        require((_amount * _denomination) % _denomination == 0, "invalid amount");

        _approvals[_owner][_spender]  = _approval - _amount;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _amount,
        bytes calldata _data
    ) internal virtual {
        require(_from != address(0), "wrong address");
        require(_to != address(0), "wrong address");
        require(_amount > 0, "invalid amount");

        uint256 principal = _principals[_from];
        uint256 _denomination = bonds.denomination;
        uint256 _maturityDate = bonds.maturityDate;

        uint256 _principal = _principals[_from];
        uint256 _balance = _principal / _denomination;

        require(block.timestamp < _maturityDate, "matured");
        require(_amount <= _balance, "insufficient balance");
        require((_amount * _denomination) % _denomination == 0, "invalid amount");

        uint256 principalTo = _principals[_to];

        _beforeBondTransfer(_from, _to, _amount, _data);

        unchecked {
            uint256 _principalTransferred = _amount * _denomination;

            _principals[_from] = principal - _principalTransferred;
            _principals[_to] = principalTo + _principalTransferred;
        }

        _afterBondTransfer(_from, _to, _amount, _data);
    }

    function _spendApproval(address _from, address _spender, uint256 _amount) internal virtual {
        uint256 currentApproval = _approvals[_from][_spender];
        require(_amount <= currentApproval, "insufficient allowance");

        unchecked {
            _approvals[_from][_spender] = currentApproval - _amount;
        }
   }

   function _batchApprove(
    address _owner,
    address[] calldata _spender,
    uint256[] calldata _amount
   ) internal virtual {
        uint256 _denomination = bonds.denomination;
        uint256 _maturityDate = bonds.maturityDate;

        uint256 _principal = _principals[_owner];
        uint256 _balance = _principal / _denomination;

        require(_owner != address(0), "wrong address");
        require(block.timestamp < _maturityDate, "matured");

        uint256 totalAmount;
        for(uint256 i; i < _spender.length; i++) {
            totalAmount = totalAmount + _amount[i];

            require(_spender[i] != address(0), "wrong address");
            require(_amount[i] > 0, "invalid amount");
            require(totalAmount <= _balance, "insufficient balance");
            require((totalAmount * _denomination) % _denomination == 0, "invalid amount");

            uint256 _approval = _approvals[_owner][_spender[i]];

            _approvals[_owner][_spender[i]]  = _approval + _amount[i];
        }
    }

    function _batchDecreaseAllowance(
        address _owner,
        address[] calldata _spender,
        uint256[] calldata _amount
    ) internal virtual {
        uint256 _denomination = bonds.denomination;
        uint256 _maturityDate = bonds.maturityDate;

        require(_owner != address(0), "wrong address");
        require(block.timestamp < _maturityDate, "matured");

        for(uint256 i; i < _spender.length; i++) {
            uint256 _approval = _approvals[_owner][_spender[i]];

            require(_amount[i] <= _approval, "insufficient approval");
            require(_amount[i] > 0, "invalid amount");
            require((_amount[i] * _denomination) % _denomination == 0, "invalid amount");

            _approvals[_owner][_spender[i]]  = _approval - _amount[i];
        }
    }

    function _batchTransfer(
        address[] memory _from,
        address[] memory _to,
        uint256[] calldata _amount,
        bytes[] calldata _data
    ) internal virtual {
        uint256 _denomination = bonds.denomination;
        uint256 _maturityDate = bonds.maturityDate;

        require(block.timestamp < _maturityDate, "matured");

        for(uint256 i; i < _from.length; i++) {
            uint256 principal = _principals[_from[i]];

            uint256 _principal = _principals[_from[i]];
            uint256 _balance = _principal / _denomination;

            require(_from[i] != address(0), "wrong address");
            require(_to[i] != address(0), "wrong address");
            require(_amount[i] > 0, "invalid amount");
            require(_amount[i] <= _balance, "insufficient balance");
            require((_amount[i] * _denomination) % _denomination == 0, "invalid amount");

            uint256 principalTo = _principals[_to[i]];

            _batchBeforeBondTransfer(_from, _to, _amount, _data);

            unchecked {
                uint256 _principalTransferred = _amount[i] * _denomination;

                _principals[_from[i]] = principal - _principalTransferred;
                _principals[_to[i]] = principalTo + _principalTransferred;
            }

            _batchAfterBondTransfer(_from, _to, _amount, _data);
        }
    }

    function _batchSpendApproval(
        address[] calldata _from,
        address _spender,
        uint256[] calldata _amount
    ) internal virtual {
        for(uint256 i; i < _from.length; i++) {
            uint256 currentApproval = _approvals[_from[i]][_spender];
            require(_amount[i] <= currentApproval, "insufficient allowance");

            unchecked {
                _approvals[_from[i]][_spender] = currentApproval - _amount[i];
            }
        }
    }

    function _crossTransfer(
        address _from,
        address _to,
        uint256 _amount,
        bytes calldata _data
    ) internal virtual {
        require(_to != address(0), "wrong address");
        require(_amount > 0, "invalid amount");

        uint256 _denomination = bonds.denomination;
        uint256 _maturityDate = bonds.maturityDate;

        require(block.timestamp < _maturityDate, "matured");
        require((_amount * _denomination) % _denomination == 0, "invalid amount");

        uint256 principalTo = _principals[_to];

        _beforeBondTransfer(_from, _to, _amount, _data);

        unchecked {
            uint256 _principalTransferred = _amount * _denomination;
            uint256 _issueVolume = bonds.denomination;

            _principals[_to] = principalTo + _principalTransferred;
            bonds.issueVolume = _issueVolume + _principalTransferred;
        }

        //emit Transfer(_from, _to, _amount);

        _afterBondTransfer(_from, _to, _amount, _data);
    }

    function _crossChainApproval(
        address _owner,
        address _spender,
        uint256 _amount,
        bytes32 _destinationChainID,
        address _destinationContract,
        string memory _functionSignature
    ) internal virtual {
        uint256 destinationChainID = uint256(_destinationChainID);
        bytes memory data = abi.encodeWithSignature(_functionSignature, _owner, _spender, _amount);

        // send cross-chain message
        _sendMessage(destinationChainID, data);

        emit MessageSent(destinationChainID, _destinationContract);
    }

    function _crossChainBatchApproval(
        address _owner,
        address[] calldata _spender,
        uint256[] calldata _amount,
        bytes32[] calldata _destinationChainID,
        address[] calldata _destinationContract,
        string memory _functionSignature
    ) internal virtual {
        uint256[] memory destinationChainIDs;
        for(uint256 i; i < _spender.length; i++) {
            uint256 destinationChainID = uint256(_destinationChainID[i]);
            bytes memory data = abi.encodeWithSignature(_functionSignature, _owner, _spender[i], _amount[i]);
            destinationChainIDs[i] = destinationChainID;

            // send cross-chain message
            _sendMessage(destinationChainID, data);
        }

        emit MessageSent(destinationChainIDs, _destinationContract);
    }

    function _crossChainTransfer(
        address _from,
        address _to,
        uint256 _amount,
        bytes calldata _data,
        bytes32 _destinationChainID,
        address _destinationContract,
        string memory _functionSignature
    ) internal virtual {
        require(_from != address(0), "wrong address");
        require(_to != address(0), "wrong address");
        require(_amount > 0, "invalid amount");

        uint256 principal = _principals[_from];
        uint256 _denomination = bonds.denomination;
        uint256 _maturityDate = bonds.maturityDate;

        uint256 _principal = _principals[_from];
        uint256 _balance = _principal / _denomination;

        require(block.timestamp < _maturityDate, "matured");
        require(_amount <= _balance, "insufficient balance");
        require((_amount * _denomination) % _denomination == 0, "invalid amount");

        _beforeBondTransfer(_from, _to, _amount, _data);

        unchecked {
            uint256 _principalTransferred = _amount * _denomination;
            uint256 _issueVolume = bonds.denomination;

            _principals[_from] = principal - _principalTransferred;
            bonds.issueVolume = _issueVolume - _principalTransferred;
        }

        //emit Transfer(_from, address(0), _amount);

        _afterBondTransfer(_from, _to, _amount, _data);

        // send cross-chain message
        uint256 destinationChainID = uint256(_destinationChainID);

        _sendMessage(
            destinationChainID,
            abi.encodeWithSignature(_functionSignature, _to, _amount, _data)
        );

        emit MessageSent(destinationChainID, _destinationContract);
    }

    function _crossChainBatchTransfer(
        address[] memory _from,
        address[] calldata _to,
        uint256[] calldata _amount,
        bytes[] calldata _data,
        bytes32[] calldata _destinationChainID,
        address[] calldata _destinationContract,
        string memory _functionSignature
    ) internal virtual {
        uint256 _denomination = bonds.denomination;
        uint256 _maturityDate = bonds.maturityDate;
        uint256 _issueVolume = bonds.denomination;

        require(block.timestamp < _maturityDate, "matured");

        uint256 totalPrincipalTransferred;
        uint256[] memory destinationChainID;
        for(uint256 i; i < _from.length; i++) {
            uint256 principal = _principals[_from[i]];
            uint256 _balance = principal / _denomination;

            require(_from[i] != address(0), "wrong address");
            require(_to[i] != address(0), "wrong address");
            require(_amount[i] > 0, "invalid amount");
            require(_amount[i] <= _balance, "insufficient balance");
            require((_amount[i] * _denomination) % _denomination == 0, "invalid amount");

            _beforeBondTransfer(_from[i], address(0), _amount[i], _data[i]);

            unchecked {
                uint256 _principalTransferred = _amount[i] * _denomination;
                totalPrincipalTransferred = totalPrincipalTransferred + _principalTransferred;

                _principals[_from[i]] = principal - _principalTransferred;
            }

            //emit TransferBatch(_from, _to, _amount);

            _afterBondTransfer(_from[i], address(0), _amount[i], _data[i]);

            
            uint256 destChainID = uint256(_destinationChainID[i]);
            bytes memory data = abi.encodeWithSignature(_functionSignature, _to[i], _amount[i], _data[i]);

            destinationChainID[i] = destChainID;

            // send cross-chain message
            _sendMessage(destinationChainID[i], data);
        }

        bonds.issueVolume = _issueVolume - totalPrincipalTransferred;

        emit MessageSent(destinationChainID, _destinationContract);
    }

    function crossApprove(
        address _owner,
        address _spender,
        uint256 _amount
    ) public {
        _approve(_owner, _spender, _amount);
    }

    function crossDecreaseAllowance(
        address _owner,
        address _spender,
        uint256 _amount
    ) public {
        _decreaseAllowance(_owner, _spender, _amount);
    }

    function crossTransfer(
        address _to,
        uint256 _amount,
        bytes calldata _data
    ) public {
        _crossTransfer(address(0), _to, _amount, _data);
    }

    function _beforeBondTransfer(
        address _from,
        address _to,
        uint256 _amount,
        bytes calldata _data
    ) internal virtual {}

    function _afterBondTransfer(
        address _from,
        address _to,
        uint256 _amount,
        bytes calldata _data
    ) internal virtual {}

    function _batchBeforeBondTransfer(
        address[] memory _from,
        address[] memory _to,
        uint256[] calldata _amount,
        bytes[] calldata _data
    ) internal virtual {}

    function _batchAfterBondTransfer(
        address[] memory _from,
        address[] memory _to,
        uint256[] calldata _amount,
        bytes[] calldata _data
    ) internal virtual {}
}