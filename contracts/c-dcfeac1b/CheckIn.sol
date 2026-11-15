// Rebuilt by the imd.fun swarm
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

/// @notice Records each account's latest check-in time and lifetime check-in count.
contract CheckInLedger {
    struct CheckInRecord {
        uint256 lastCheckIn;
        uint256 count;
    }

    mapping(address => CheckInRecord) public checkInRecords;

    event CheckIn(address indexed user, uint256 timestamp, uint256 count);

    function checkIn() public {
        CheckInRecord storage record = checkInRecords[msg.sender];
        record.lastCheckIn = block.timestamp;
        record.count++;
        emit CheckIn(msg.sender, block.timestamp, record.count);
    }

    function getCheckInRecord(address user) public view returns (uint256, uint256) {
        return (checkInRecords[user].lastCheckIn, checkInRecords[user].count);
    }
}
