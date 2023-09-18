// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Events {
    event EquipmentMinted(
        address indexed owner,
        uint256 indexed itemId,
        string name,
        string itemType
    );

    event ShieldBurned(
        address indexed owner,
        uint256 indexed knightId,
        uint256 indexed shieldId,
        bool gotSword
    );
}
