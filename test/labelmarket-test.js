const { expect, assert } = require("chai");
const { ethers, upgrades, waffle } = require("hardhat");
const provider = waffle.provider;

describe("Before go to the production env.", function () {
  let labelMarket;
  let labelNFT;
  let labelMarketAddress;
  let labelNFTAddress;

  beforeEach(async () => {
    const LabelMarket = await ethers.getContractFactory("LabelMarket");
    labelMarket = await LabelMarket.deploy();
    await labelMarket.deployed();
    labelMarketAddress = labelMarket.address;

    const LabelNFT = await ethers.getContractFactory("LabelNFT");
    labelNFT = await LabelNFT.deploy(labelMarketAddress);
    await labelNFT.deployed();
    labelNFTAddress = labelNFT.address;

    // console.log("LabelMarket address is: ", labelMarketAddress);
    // console.log("LabelNFT address is", labelNFTAddress);

  });

  it("should return minted token's id", async () => {
    const transaction = await labelNFT.mintToken(33);
    const tx = await transaction.wait();
    // console.log(tx);

    const isMinted = await labelNFT.exists(1);

    assert.equal(isMinted, true);
  });

  it("can make market item using minted token", async () => {
    const auctionPrice = ethers.utils.parseUnits("100", "ether");
    const transaction = await labelNFT.mintToken(32);
    const tx = await transaction.wait();
    const transaction2 = await labelMarket.makeMarketItem(labelNFTAddress, 1, auctionPrice, 32);
    const tx2 = await transaction2.wait();
    const marketItems = await labelMarket.fetchMarketTokens();

    assert.equal(marketItems.length, 1);
  });

  it("can make market sale", async () => {
    const auctionPrice = ethers.utils.parseUnits("100", "ether");
    const transaction = await labelNFT.mintToken(32);
    const tx = await transaction.wait();
    const transaction2 = await labelMarket.makeMarketItem(
      labelNFTAddress,
      1,
      auctionPrice,
      32
    );
    
    const [_, buyerAddress] = await ethers.getSigners();

    await labelMarket.connect(buyerAddress).createMarketSale(labelNFTAddress, 1, { value: auctionPrice });

    const marketItems = await labelMarket.fetchMarketTokens();

    assert.equal(marketItems.length, 0);

  });

  it("should return higher balance for the seller", async () => {
    // Given
    const auctionPrice = ethers.utils.parseUnits("10", "ether");
    const transaction = await labelNFT.mintToken(32);
    const [_, buyerAddress] = await ethers.getSigners();
    const beforeBuyerBalance = await buyerAddress.getBalance();
    const signer = await ethers.getSigner();
    const beforeSellerBalance = await provider.getBalance(signer.address);

    // When
    // make a sell list using signer's token
    const tx = await transaction.wait();
    const transaction2 = await labelMarket.makeMarketItem(
      labelNFTAddress,
      1,
      auctionPrice,
      32
      );
    // const tx2 = await transaction2.wait();
    
    const beforeMarketItems = await labelMarket.fetchMarketTokens();
    
    // signer2 buys sell listed token
    await labelMarket
      .connect(buyerAddress)
      .createMarketSale(labelNFTAddress, 1, { value: auctionPrice });

      
    // Then
    const afterSellerBalance = await provider.getBalance(signer.address);
    const afterMarketItems = await labelMarket.fetchMarketTokens();
    const afterBuyerBalance = await buyerAddress.getBalance();

    assert.isTrue(afterBuyerBalance < beforeBuyerBalance);
    assert.isTrue(beforeSellerBalance < afterSellerBalance);
    assert.equal(beforeMarketItems.length, 1);
    assert.equal(afterMarketItems.length, 0);
  });
});