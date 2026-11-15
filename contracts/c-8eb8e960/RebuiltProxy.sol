// Rebuilt by the imd.fun swarm
pragma solidity ^0.4.24;

import "./AdminUpgradeabilityProxy.sol";

/// @dev Deployment wrapper for the ZeppelinOS admin proxy.
contract RebuiltProxy is AdminUpgradeabilityProxy {
    constructor(address implementation) AdminUpgradeabilityProxy(implementation) public {}
}
