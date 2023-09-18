// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./KnightManager.sol";
import "./EquipmentManager.sol";
import "./RandomNumberGenerator.sol";
import "./PauseManager.sol";
import "./Events.sol";

contract MedievalGameModular is
    KnightManager,
    EquipmentManager,
    RandomNumberGenerator,
    PauseManager,
    Events
{
    constructor(
        address vrfCoordinatorV2,
        bytes32 gasLane,
        uint64 suscriptionId,
        uint32 callbackGasLimit,
        uint256 initialMintFee
    )
        KnightManager()
        EquipmentManager("")
        RandomNumberGenerator(
            vrfCoordinatorV2,
            gasLane,
            suscriptionId,
            callbackGasLimit,
            initialMintFee
        )
        PauseManager()
    {}

    function uri(uint256 tokenId) public view virtual override(KnightManager, ERC1155) returns (string memory) {
       
        string memory uriFromKnightManager = KnightManager.uri(tokenId);
        if (bytes(uriFromKnightManager).length > 0) {
            return uriFromKnightManager;
        } else {
            return ERC1155.uri(tokenId);
        }
    }

      function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC1155) returns (bool) {
        return ERC721.supportsInterface(interfaceId) || ERC1155.supportsInterface(interfaceId);
    }

    function setApprovalForAll(address operator, bool approved) public virtual override(ERC721, ERC1155) {
        ERC721.setApprovalForAll(operator, approved);
        ERC1155.setApprovalForAll(operator, approved);
    }
    function isApprovedForAll(address account, address operator) 
        public 
        view 
        virtual 
        override(ERC721, ERC1155) 
        returns (bool) 
    {
        return ERC721.isApprovedForAll(account, operator) || ERC1155.isApprovedForAll(account, operator);
    }

     function _setApprovalForAll(address owner, address operator, bool approved) 
        internal 
        virtual 
        override(ERC721, ERC1155) 
    {
        // Your custom implementation here

        // Example: call both parent contract implementations
        ERC721._setApprovalForAll(owner, operator, approved);
        ERC1155._setApprovalForAll(owner, operator, approved);
    }

}
