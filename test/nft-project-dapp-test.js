const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");
const { create } = require("ipfs-http-client");
const Web3Modal = require("web3modal");
describe("Before go to the production env.", function () {
  let marketUpgradeable;
  let myCollectibleUpgradeable;

  beforeEach(async () => {
    const Market = await ethers.getContractFactory("Market");
    marketUpgradeable = await upgrades.deployProxy(Market, [0], {
      initializer: "initialize",
    });

    await marketUpgradeable.deployed();

    const MyCollectible = await ethers.getContractFactory("MyCollectible");
    myCollectibleUpgradeable = await upgrades.deployProxy(
      MyCollectible,
      [marketUpgradeable.address],
      { initializer: "initialize" }
    );

    await myCollectibleUpgradeable.deployed();

    console.log("Market deployed to:", marketUpgradeable.address);
    console.log("MyCollectible deployed to:", myCollectibleUpgradeable.address);
  });

  it("Should token include token uri", async () => {
    const transaction = await myCollectibleUpgradeable.mintToken("sampleURI");
    const tx = await transaction.wait();
    const tokenId = tx.events[0].args[2].toNumber();
    expect(tokenId).to.equal(1);
  });
});