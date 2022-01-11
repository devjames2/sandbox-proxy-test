const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

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

    console.log("LabelMarket address is: ", labelMarketAddress);
    console.log("LabelNFT address is", labelNFTAddress);

  });

  it("should return minted token's id", async () => {
    const transaction = await labelNFT.mintToken(33);
    const tx = await transaction.wait();
    // console.log(tx);
  });

  it("can make market item using minted token", async () => {
    const auctionPrice = ethers.utils.parseUnits("100", "ether");
    const transaction = await labelNFT.mintToken(32);
    const tx = await transaction.wait();
    const transaction2 = await labelMarket.makeMarketItem(labelNFTAddress, 1, auctionPrice, 32);
    const tx2 = await transaction2.wait();
    const marketItems = await labelMarket.fetchMarketTokens();

    // console.log(marketItems);
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

    // console.log(marketItems);
  });
});