//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract LabelNFT is ERC1155Supply {
  using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address contractAddress;
    string _name;
    string _symbol;

    constructor(address marketplaceAddress) ERC1155("https://abcoathup.github.io/SampleERC1155/api/token/{id}.json") {
        contractAddress = marketplaceAddress;
        _name = "LABLE TOKEN";
        _symbol = "LMT";
    }

    function mintToken(uint256 amount) public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId, amount, "");
        setApprovalForAll(contractAddress, true);
        return newItemId;
    }

    function name() external view returns (string memory) {
      return _name;
    }

    function symbol() external view returns (string memory) {
      return _symbol;
    }

}
