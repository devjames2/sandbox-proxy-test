const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");
describe("MyCollectible", function () {
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
  it("Should return the listing price as 0", async function () {
    const listingPrice = await marketUpgradeable.getListingPrice();
    expect(listingPrice).to.equal(0);
  });

  it("Should return the tokenId 1 after mint and after upgrade, tokenId should be 2 after mint again", async function () {
    const transaction = await myCollectibleUpgradeable.mintToken();
    const tx = await transaction.wait();
    const tokenId = tx.events[0].args[2].toNumber();
    expect(tokenId).to.equal(1);

    const MyCollectibleV2 = await ethers.getContractFactory("MyCollectibleV2");
    await upgrades.upgradeProxy(myCollectibleUpgradeable.address, MyCollectibleV2);
    const myCollectibleUpgradeableV2 = MyCollectibleV2.attach(
      myCollectibleUpgradeable.address
    );
    const transactionV2 = await myCollectibleUpgradeableV2.mintToken();
    const txV2 = await transactionV2.wait();
    const tokenIdV2 = txV2.events[0].args[2].toNumber();
    expect(tokenIdV2).to.equal(2);
  });
});

