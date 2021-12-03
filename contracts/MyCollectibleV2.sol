//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

import "hardhat/console.sol";

contract MyCollectibleV2 is ERC721Upgradeable {
  using CountersUpgradeable for CountersUpgradeable.Counter;

  CountersUpgradeable.Counter private _tokenIds;

  address contractAddress;

  uint256 someValue;

  function initialize(address marketAddress) public initializer {
    __ERC721_init("MyCollectible", "MCO");
    _tokenIds.increment();
    contractAddress = marketAddress;
    console.log("current token ID is:", _tokenIds.current());
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

  function setSomeValue(uint256 _someValue) public {
    someValue = _someValue;
  }

  function getSomeValue() public view returns (uint256) {
    return someValue;
  }
}