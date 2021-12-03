//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "hardhat/console.sol";

contract Market is ERC721Upgradeable, ReentrancyGuardUpgradeable {
  uint256 listingPrice;

  function initialize(uint256 _listingPrice) public initializer {
    __ReentrancyGuard_init();
    listingPrice = _listingPrice;

    console.log("Incomming listing price value is:", _listingPrice);
  }

  function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }
}