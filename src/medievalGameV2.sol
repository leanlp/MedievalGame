// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract MedievalGame is ERC721Pausable, Ownable, ERC1155Pausable {
    using Counters for Counters.Counter;
    Counters.Counter private _knightIds;
    Counters.Counter private _itemIds;

    uint256 public constant MAX_MINTABLE_ITEMS = 1000;
    uint256 public mintedItemCount = 0;
    uint256 public constant ITEM_MINT_PRICE = 0.1 ether;

    struct Gear {
        string name;
        string itemType;
    }

    struct Knight {
        uint256 armorId;
        uint256 swordId;
        uint256 shieldId;
    }

    mapping(uint256 => Knight) private _knights;
    mapping(uint256 => Gear) private _gearItems;
    mapping(uint256 => string) private _hashIpfs;
    mapping(uint256 => string) private _gearIpfsHashes;


    event EquipmentMinted(address indexed owner, uint256 indexed itemId, string name, string itemType);
    event ShieldBurned(address indexed owner, uint256 indexed knightId, uint256 indexed shieldId, bool gotSword);

    constructor() ERC721("KnightToken", "KNIGHT") ERC1155("https://ipfs.io/ipfs/{id}") {}

    function mintKnight(string memory p_hashIpfs) external {
        _knightIds.increment();
        uint256 newKnightId = _knightIds.current();
        _safeMint(msg.sender, newKnightId);
        _hashIpfs[_knightIds.current()] = p_hashIpfs;
    }
    function uri(uint256 tokenId) public override view returns(string memory){
    return(string(abi.encodePacked("https://ipfs.io/ipfs/", _hashIpfs[tokenId])));
    }

    function mintEquipment(string calldata name, string calldata itemType, string memory p_gearIpfsHashes) external payable {
        require(msg.value == ITEM_MINT_PRICE, "Incorrect ETH amount");
        require(mintedItemCount < MAX_MINTABLE_ITEMS, "Max mintable items reached");
        
        _itemIds.increment();
        uint256 newItemId = _itemIds.current();
        _gearItems[newItemId] = Gear(name, itemType);
        mintedItemCount += 1;

        _gearIpfsHashes[_itemIds.current()]= p_gearIpfsHashes;
        _mint(msg.sender, newItemId, 1, "");
        emit EquipmentMinted(msg.sender, newItemId, name, itemType);
    }

    function setKnightGear(uint256 knightId, uint256 armorId, uint256 swordId, uint256 shieldId) external {
        require(ownerOf(knightId) == msg.sender, "Not the owner of the knight");
        _knights[knightId] = Knight(armorId, swordId, shieldId);
    }

  function getGearIpfsHash(uint256 itemId) external view returns (string memory) {
    require(bytes(_gearItems[itemId].itemType).length > 0, "Item does not exist");
    return _gearIpfsHashes[itemId];
}

 function burnShield(uint256 knightId) external {
    require(ownerOf(knightId) == msg.sender, "Not the owner of the knight");
    uint256 shieldId = _knights[knightId].shieldId;
    require(shieldId != 0, "No shield to burn");

    _knights[knightId].shieldId = 0;
    _burn(msg.sender, shieldId, 1);

    bool gotSword = (block.timestamp % 100) < 80;  // 80% chance to get a sword

    if(gotSword) {
        _itemIds.increment();
        uint256 newSwordId = _itemIds.current();
        string memory name = string(abi.encodePacked("Sword ", Strings.toString(newSwordId)));
        _gearItems[newSwordId] = Gear(name, "Sword");
        _mint(msg.sender, newSwordId, 1, "");
    }

    emit ShieldBurned(msg.sender, knightId, shieldId, gotSword);
}

    function pauseContract() external onlyOwner {
        _pause();
    }

    function unpauseContract() external onlyOwner {
        _unpause();
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC1155) returns (bool) {
        return ERC721.supportsInterface(interfaceId) || ERC1155.supportsInterface(interfaceId);
    }

function setApprovalForAll(address operator, bool approved) public virtual override(ERC721, ERC1155) {
        ERC721.setApprovalForAll(operator, approved);
        ERC1155.setApprovalForAll(operator, approved);
    }

    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual override(ERC721, ERC1155) {
        ERC721._setApprovalForAll(owner, operator, approved);
        ERC1155._setApprovalForAll(owner, operator, approved);
    }

function isApprovedForAll(address account, address operator) public view virtual override(ERC721, ERC1155) returns (bool) {
        return ERC721.isApprovedForAll(account, operator) || ERC1155.isApprovedForAll(account, operator);
    }

}
