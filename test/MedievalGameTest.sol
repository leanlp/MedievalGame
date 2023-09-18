// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "ds-test/test.sol";
import "../src/medievalGame.sol";

contract MedievalGameTest is DSTest, IERC721Receiver, IERC1155Receiver {
    MedievalGame game;

    function setUp() public {
        game = new MedievalGame();
    }

    function testMintKnight() public {
        game.mintKnight("hashIpfsforEachNFT");
        assertEq(game.balanceOf(address(this)), 1);
    }

    function testFailMintTooManyItems() public {
        for (uint i = 0; i < 1001; i++) {
            game.mintEquipment("Item", "Type", "hash");
        }
    }

    function testMintEquipment() public {
        game.mintEquipment{value: 0.1 ether}("Sword", "Weapon", "hash");
        assertEq(game.balanceOf(address(this)), 0);
        assertEq(game.mintedItemCount(), 1);
    }

    function testBurnShieldAndGetSword() public {
        game.mintKnight("hashIpfsforEachNFT");
        game.mintEquipment{value: 0.1 ether}("Shield", "Defense", "hash");
        uint256 knightId = 1; // Assuming it's the first knight minted
        uint256 shieldId = 1; // Assuming it's the first item minted

        game.setKnightGear(knightId, 0, 0, shieldId);
        game.burnShield(knightId);
    }

    //     function testPauseContract() public {
    //     game.pauseContract();
    //     game.mintEquipment{value: 0.1 ether}("Sword", "Weapon", "hash");
    //         assertEq(game.balanceOf(address(this)), 0);
    //         assertEq(game.mintedItemCount(), 0);
    // }

    function testMintKnightPaused() public {
        game.pauseContract();
        assertTrue(try_mintKnight());
    }

    function try_mintKnight() internal returns (bool) {
        try game.mintKnight("hashIpfsforEachNFT") {
            return false; // If it succeeds, return false because we expected it to fail
        } catch {
            return true; // If it fails, return true because we expected it to fail
        }
    }

    function testPauseContract() public {
        game.pauseContract();
        assertTrue(try_mintEquipment());
    }

    function try_mintEquipment() internal returns (bool) {
        try game.mintEquipment{value: 0.1 ether}("Sword", "Weapon", "hash") {
            return false; // If it succeeds, return false because we expected it to fail
        } catch {
            return true; // If it fails, return true because we expected it to fail
        }
    }

    function testUnpauseContract() public {
        game.pauseContract();
        game.unpauseContract();
        game.mintEquipment{value: 0.1 ether}("Sword", "Weapon", "hash");
        assertEq(game.balanceOf(address(this)), 0);
        assertEq(game.mintedItemCount(), 1);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC721Receiver).interfaceId ||
            interfaceId == type(IERC1155Receiver).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
}
