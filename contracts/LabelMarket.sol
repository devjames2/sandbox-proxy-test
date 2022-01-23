//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./LabelNFT.sol";

import "hardhat/console.sol";

interface IWETH9 {
    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);
    function approve(address guy, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint wad) external returns (bool);
}

contract LabelMarket is ReentrancyGuard, ERC1155Holder {
    using Counters for Counters.Counter;

    /* number of items minting, number of transactions, tokens that have not been sold
     keep track of tokens total number - tokenId
     arrays need to know the length - help to keep track for arrays */

    Counters.Counter private _tokenIds;
    Counters.Counter private _tokensSold;
    
    address payable owner;
    uint256 listingPrice = 0.0002 ether;
    IWETH9 public weth;

    constructor() {
        owner = payable(msg.sender);
        weth = IWETH9(0xc778417E063141139Fce010982780140Aa0cD5Ab);
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

    struct NFTVoucher {
        /// @notice The id of the token to be redeemed. Must be unique - if another token with this ID already exists, the redeem function will revert.
        uint256 tokenId;
        /// @notice amount of the token to be redeemed
        uint256 amount;
        /// @notice The minimum price (in wei) that the NFT creator is willing to accept for the initial sale of this NFT.
        uint256 minPrice;
        /// @notice The metadata URI to associate with this token.
        bytes uri;
        /// @notice the EIP-712 signature of all other fields in the NFTVoucher struct. For a voucher to be valid, it must be signed by an account with the MINTER_ROLE.
        bytes signature;
        /// @notice Owner Wallet Address
        address owner;
        /// @notice Creator Wallet Addresses
        address[] creatorAddress;
        /// @notice royalty for creators
        // mapping(address => uint8) royalties;
        uint8[] royalties;
        /// @notice exchange fee
        uint256 fee;
        /// @notice whether owner is creator
        bool isCreator;
        /// @notice total amount of tokenId
        uint256 totalAmount;
    }

    struct Redeemer {
      address owner;
      uint256 price;
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

//     function redeem() { <-- redeemer 가 호출하는 함수

//     }


// // label market (drop관련)
//     function registerSellersWallet() { <-- seller
//       // seller nft -> operator가 옮길 수 있는 권한 획득

//     }

//     function registerBuyersWallet() { <-- buyer bid 한 가격 만큼만 approve
//       // buyer's erc20 token -> operator 가 옮길 수 있는 권한 획득
//       // 10 weth
//     }

//     function endBid(Voucher, Bid) {
//       // market fee -> market 10% 10weth 9weth
//       // redeem(buyer's erc20 token)

//       // seller's nft -> buyer
//     }

// label market for all users

    function callTest(uint price) public returns (bool, bytes memory) {
      (bool success, bytes memory data) = address(0xc778417E063141139Fce010982780140Aa0cD5Ab).call(abi.encodeWithSignature("approve(address guy,uint wad)", address(this), price));

      return (success, data);
    }

    function delegateCallTest(uint price) public returns (bool, bytes memory) {
      (bool success, bytes memory data) = address(0xc778417E063141139Fce010982780140Aa0cD5Ab).delegatecall(abi.encodeWithSignature("approve(address guy,uint wad)", address(this), price));

      return (success, data);
    }

    function placeBid(uint256 price) public nonReentrant {
      require(weth.approve(
        address(this),
        price),
        "Approve has failed");
    }

    function redeem(address nftContract, Redeemer calldata redeemer, NFTVoucher calldata voucher)
        public
        payable
        returns (uint256, bool, bytes memory)
    {
      // recover(signature) == redeemer ?
      // require(msg.sender(signature) === admin's address)
      // IERC1155(nftContract)._mint(voucher.owner, voucher.tokenId, voucher.amount, "");

      // nftContract.mintTokenForRedeem(voucher.owner, voucher.tokenId, voucher.amount, "");

      // nftContract.call(bytes4(keccak256("name()")));

      LabelNFT nft = LabelNFT(nftContract);
      nft.mintTokenForRedeem(voucher.owner, voucher.tokenId, voucher.amount, "");

      // owner 가 buyer 한테 NFT Token 을 전달한다.
      IERC1155(nftContract).safeTransferFrom(
          voucher.owner,
          redeemer.owner,
          voucher.tokenId,
          voucher.amount,
          ""
      );

      // platform fee 정산 buyer 가 줄 돈으로 계산
      // ----

      // royalty 정산
      // ----

      // buyer가 owner한테 erc20 token을 전달한다.
      // ----
      // buyer의 erc20에 대한 approve 는 이미 되어 있다고 가정
      // require(ERC20.isApprove(market) ? true, error);
      // ERC20.transfer(buyer, voucher.owner, price - serviceFee - royalty);
      // ERC20.transfer(buyer, market, serviceFee);
      // ERC20.transfer(buyer, creator, royalty);
      // require(weth.transferFrom(redeemer.owner, voucher.owner, redeemer.price), "Fail to transfer ERC20");
      (bool success, bytes memory data) = address(0xc778417E063141139Fce010982780140Aa0cD5Ab).call(abi.encodeWithSignature("transferFrom(address src, address dst, uint wad)", redeemer.owner, voucher.owner, redeemer.price));

      return (voucher.tokenId, success, data);
    }

    function makeMarketItemForCreator(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        uint256 amount,
        address creator
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

        IERC1155(nftContract).safeTransferFrom(creator, address(this), tokenId, amount, "");

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
