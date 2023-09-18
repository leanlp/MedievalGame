// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract EquipmentManager is ERC1155Pausable {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;

    uint256 public constant MAX_MINTABLE_ITEMS = 1000;
    uint256 public mintedItemCount = 0;
    uint256 public constant ITEM_MINT_PRICE = 0.1 ether;

    struct Gear {
        string name;
        string itemType;
    }

    mapping(uint256 => Gear) private _gearItems;
    mapping(uint256 => string) private _gearIpfsHashes;

    event EquipmentMintedMinted(
        address indexed owner,
        uint256 indexed itemId,
        string name,
        string itemType
    );

    constructor(string memory baseURI) ERC1155("baseURI") {}

    function mintEquipment(
        string calldata name,
        string calldata itemType,
        string memory p_gearIpfsHashes
    ) external payable {
        require(msg.value == ITEM_MINT_PRICE, "Incorrect ETH amount");
        require(
            mintedItemCount < MAX_MINTABLE_ITEMS,
            "Max mintable items reached"
        );

        _itemIds.increment();
        uint256 newItemId = _itemIds.current();
        _gearItems[newItemId] = Gear(name, itemType);
        mintedItemCount += 1;

        _gearIpfsHashes[newItemId] = p_gearIpfsHashes;
        _mint(msg.sender, newItemId, 1, "");
        emit EquipmentMintedMinted(msg.sender, newItemId, name, itemType);
    }

    function getGearDetails(uint256 itemId) external view returns (Gear memory) {
        require(bytes(_gearItems[itemId].itemType).length > 0, "Item does not exist");
        return _gearItems[itemId];
    }

    function getGearIpfsHash(uint256 itemId) external view returns (string memory) {
        require(bytes(_gearItems[itemId].itemType).length > 0, "Item does not exist");
        return _gearIpfsHashes[itemId];
    }
}
