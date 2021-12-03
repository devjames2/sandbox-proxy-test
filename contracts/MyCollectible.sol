//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

import "hardhat/console.sol";

contract MyCollectible is ERC721Upgradeable {
  using CountersUpgradeable for CountersUpgradeable.Counter;

  CountersUpgradeable.Counter private _tokenIds;

  address contractAddress;

  function initialize(address marketAddress) public initializer {
    __ERC721_init("MyCollectible", "MCO");
    contractAddress = marketAddress;
  }

  function getContractAddress() public view returns (address) {
    return contractAddress;
  }

  function mintToken() public returns (uint256) {
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();
    _mint(msg.sender, newItemId);
    setApprovalForAll(contractAddress, true);
    return newItemId;
  }
}