const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");
const { create } = require("ipfs-http-client");
const Web3Modal = require("web3modal");
describe("Before go to the production env.", function () {
  let opentrackItemUpgradable;

  beforeEach(async () => {
    const OpentrackItem = await ethers.getContractFactory("OpentrackItem");
    opentrackItemUpgradable = await upgrades.deployProxy(OpentrackItem, [0], {
      initializer: "initialize",
    });

    await opentrackItemUpgradable.deployed();

    console.log("OpentrackItem deployed to:", opentrackItemUpgradable.address);
  });

  it("Should item has listing price", async () => {
    console.log('test');
  });
});