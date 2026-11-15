// Rebuilt by the imd.fun swarm
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.4;

contract GasTokenProxy {
    address payable constant OWNER = 0x652740D58E182A6aE5fd5217063094A98d6AB8D1;

    uint256 constant GAS_SLOT = 0xdeadbeef;

    mapping(address => bool) authorized;

    modifier onlyOwner() {
        require(msg.sender == OWNER);
        _;
    }

    constructor() public payable {
        authorized[OWNER] = true;
    }

    receive() external payable {}

    function execute(bytes memory data) public onlyOwner {
        _execute(data);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw(uint256 amount) public onlyOwner {
        address payable owner = OWNER;
        owner.transfer(amount);
    }

    function executeFixed_dgk33i7(address target) public onlyOwner {
        bytes memory data = hex"51b8a680";
        target.delegatecall(data);
    }

    function store(uint256 value) public {
        if (!isAuthorized(msg.sender)) return;
        uint256 slot = GAS_SLOT;
        if (value == 0) return;
        uint256 length;
        assembly { length := sload(slot) }
        uint256 start = slot + length + 1;
        uint256 end = slot + length + value;
        assert(end >= start);
        for (uint256 i = start; i <= end; i++) {
            assembly { sstore(i, 1) }
        }
        assembly { sstore(slot, add(length, value)) }
    }

    function grantAccess(address[] memory accounts) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            authorized[accounts[i]] = true;
        }
    }

    function delegate(address target, bytes memory data, uint256 burnOnSuccess, uint256 burnOnFailure) public {
        if (!isAuthorized(msg.sender)) return;
        uint256 balanceBefore = address(this).balance;
        (bool success, ) = target.delegatecall(data);
        uint256 balanceAfter = address(this).balance;
        require(balanceBefore <= balanceAfter);
        if (success) {
            if (burnOnSuccess > 0) _burn(burnOnSuccess);
        } else {
            if (burnOnFailure > 0) _burn(burnOnFailure);
        }
    }

    function isAuthorized(address account) public view returns (bool) {
        return authorized[account];
    }

    function _execute(bytes memory data) internal {
        for (uint256 i = 0; i < data.length; ) {
            address to = _toAddress(data, i);
            uint256 value = _toUint(data, i + 20);
            uint256 length = _toUint(data, i + 20 + 32);
            uint256 ptr = _pointer(data, i + 20 + 32 + 32);
            assembly {
                switch call(sub(gas(), 5000), to, value, ptr, length, 0, 0)
                case 0 { revert(0, 0) }
            }
            i += 84 + length;
        }
    }

    function _burn(uint256 value) internal {
        uint256 slot = GAS_SLOT;
        uint256 length;
        assembly { length := sload(slot) }
        if (length < value) return;
        uint256 start = slot + length - value + 1;
        uint256 end = slot + length;
        for (uint256 i = start; i <= end; i++) {
            assembly { sstore(i, 0) }
        }
        assembly { sstore(slot, sub(length, value)) }
    }

    function _toAddress(bytes memory data, uint256 offset) internal pure returns (address) {
        uint256 word;
        word = _toUint(data, offset);
        return address(uint160((word & 0xffffffffffffffffffffffffffffffffffffffff000000000000000000000000) / 0x1000000000000000000000000));
    }

    function _toUint(bytes memory data, uint256 offset) internal pure returns (uint256 result) {
        assembly {
            result := mload(add(add(data, offset), 0x20))
        }
    }

    function _pointer(bytes memory data, uint256 offset) internal pure returns (uint256 ptr) {
        assembly {
            ptr := add(add(data, offset), 0x20)
        }
    }
}
