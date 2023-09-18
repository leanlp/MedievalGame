// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";

contract KnightManager is ERC721Pausable {
    using Counters for Counters.Counter;
    Counters.Counter private _knightIds;

    struct Knight {
        uint256 armorId;
        uint256 swordId;
        uint256 shieldId;
    }

    mapping(uint256 => Knight) private _knights;
    mapping(uint256 => string) private _hashIpfs;

    event KnightMinted(address indexed owner, uint256 indexed knightId, string hashIpfs);

    constructor() ERC721("KnightToken", "KNIGHT") {}

    function mintKnight(string memory p_hashIpfs) external {
        _knightIds.increment();
        uint256 newKnightId = _knightIds.current();
        _safeMint(msg.sender, newKnightId);
        _hashIpfs[newKnightId] = p_hashIpfs;

        emit KnightMinted(msg.sender, newKnightId, p_hashIpfs);
    }

   function uri(uint256 tokenId) public view virtual returns (string memory) {
    return string(abi.encodePacked("https://ipfs.io/ipfs/", _hashIpfs[tokenId]));
}

    function setKnightGear(uint256 knightId, uint256 armorId, uint256 swordId, uint256 shieldId) external {
        require(ownerOf(knightId) == msg.sender, "Not the owner of the knight");
        _knights[knightId] = Knight(armorId, swordId, shieldId);
    }

    function getKnight(uint256 knightId) external view returns (Knight memory) {
        return _knights[knightId];
    }
}
