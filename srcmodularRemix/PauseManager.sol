// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract PauseManager is Ownable, Pausable {

    event ContractPaused(bool paused);
    
   
    function pauseContract() external onlyOwner {
        _pause();
        emit ContractPaused(true);
    }

   
    function unpauseContract() external onlyOwner {
        _unpause();
        emit ContractPaused(false);
    }
}
