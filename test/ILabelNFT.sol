//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ILabelNFT {
  function mintToken(uint256 amount) external returns (uint256);

  function mintTokenAtCreator(uint256 amount, address creator) external returns (uint256);

  function mintTokenForRedeem(address creator, uint256 newItemId, uint256 amount, bytes memory data) external returns (uint256);

  function name() external view returns (string memory);

  function symbol() external view returns (string memory);
}