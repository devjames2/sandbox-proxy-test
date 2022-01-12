//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "hardhat/console.sol";

contract LabelMarket is ReentrancyGuard, ERC1155Holder {
    using Counters for Counters.Counter;

    /* number of items minting, number of transactions, tokens that have not been sold
     keep track of tokens total number - tokenId
     arrays need to know the length - help to keep track for arrays */

    Counters.Counter private _tokenIds;
    Counters.Counter private _tokensSold;
    
    address payable owner;
    uint256 listingPrice = 0.0002 ether;

    constructor() {
        owner = payable(msg.sender);
    }

    struct MarketToken {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        uint256 amount;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => MarketToken) private idToMarketToken;

    event MarketTokenMinted(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 amount,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    function makeMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        uint256 amount
    ) public payable nonReentrant {
      _tokenIds.increment();
        uint256 itemId = _tokenIds.current();

        //putting it up for sale - bool - no owner
        idToMarketToken[itemId] = MarketToken(
            itemId,
            nftContract,
            tokenId,
            amount,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        IERC1155(nftContract).safeTransferFrom(msg.sender, address(this), tokenId, amount, "");

        emit MarketTokenMinted(
          itemId,
          nftContract,
          tokenId,
          amount,
          msg.sender,
          address(0),
          price,
          false
        );
    }

    function createMarketSale(address nftContract, uint256 itemId)
      public
      payable
      nonReentrant
    {
      uint256 price = idToMarketToken[itemId].price;
      uint256 tokenId = idToMarketToken[itemId].tokenId;
      uint256 amount = idToMarketToken[itemId].amount;

      require(
        msg.value == price,
        "Please submit the asking price in order to continue"
      );

      // console.log("idToMarketToken[itemId].seller is : ", idToMarketToken[itemId].seller);
      // console.log("idToMarketToken[itemId].seller.balance is : ", idToMarketToken[itemId].seller.balance);

      idToMarketToken[itemId].seller.transfer(msg.value);

      // console.log("msg.value is : ", msg.value);
      // console.log("idToMarketToken[itemId].seller.balance is : ", idToMarketToken[itemId].seller.balance);
      IERC1155(nftContract).safeTransferFrom(address(this), msg.sender, tokenId, amount, "");
      idToMarketToken[itemId].owner = payable(msg.sender);
      idToMarketToken[itemId].sold = true;
      _tokensSold.increment();

      // payable(owner).transfer(price);

      // emit WhatIsValue(msg.value);
      // emit WhatIsPrice(price);
    }

    function fetchMarketTokens() public view returns (MarketToken[] memory) {
      uint256 itemCount = _tokenIds.current();
        uint256 unsoldItemCount = _tokenIds.current() - _tokensSold.current();
        uint256 currentIndex = 0;

        // looping over the number of items created (if number has not been sold populate the array)
        MarketToken[] memory items = new MarketToken[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketToken[i + 1].owner == address(0)) {
                uint256 currentId = i + 1;
                MarketToken storage currentItem = idToMarketToken[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchMarketTokenById(uint256 itemId) public view returns (MarketToken memory) {
      return idToMarketToken[itemId];
    }

    function fetchMarketTokenPriceById(uint256 itemId) public view returns (uint256) {
      return idToMarketToken[itemId].price;
    }

    function fetchOwner() public view returns (address) {
      return owner;
    }
}
