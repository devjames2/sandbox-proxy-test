const { expect, assert } = require("chai");
const { ethers, waffle } = require("hardhat");
const provider = waffle.provider;


describe("Before go to the production env.", function () {
  let nft1155Address;
  let nft1155;

  // refs. https://github.com/nomiclabs/hardhat/issues/1972#issuecomment-948787738
  function sign(address, data) {
    return provider.send("eth_sign", [
      address,
      ethers.utils.hexlify(ethers.utils.toUtf8Bytes("foo")),
    ]);
  }

  beforeEach(async () => {
    const NFT1155 = await ethers.getContractFactory("NFT1155");
    nft1155 = await NFT1155.deploy(
      "https://abcoathup.github.io/SampleERC1155/api/token/{id}.json"
    );
    await nft1155.deployed();
    nft1155Address = nft1155.address;
  });

  it("should redeem", async () => {
    // Given
    const signer = await ethers.getSigner();
    const [a, creatorAddress] = await ethers.getSigners();
    const [b, creatorAddress2] = await ethers.getSigners();
    const [c, creatorAddress3] = await ethers.getSigners();
    const [d, buyerAddress] = await ethers.getSigners();
    const signed = await sign(creatorAddress.address, "test");
    const NFTVoucher = {
      tokenId: 1,
      amount: 10,
      minPrice: ethers.utils.parseUnits("10", "ether"),
      uri: "0x",
      signature: signed,
      owner: creatorAddress.address,
      creatorAddress: [
        creatorAddress.address,
        creatorAddress2.address,
        creatorAddress3.address,
      ],
      royalties: [3, 3, 3],
      fee: 3,
      isCreator: true,
      totalAmount: 10,
    };

    const transaction = await nft1155.redeem(buyerAddress.address, NFTVoucher);
    const tx = await transaction.wait();
    console.log(tx);
  });
});

// uri when deploy
// "https://abcoathup.github.io/SampleERC1155/api/token/{id}.json"
// redeemer address
// "0x28f89275cd7ce2576d467bc85fe42fe2324b2212"
// place bid
// "0xc778417E063141139Fce010982780140Aa0cD5Ab"
// nftContract
// "0x3EE41D721DF82074d7034361Bc5728E33257C561"
// redeemer tuple for remix test
// ["0xC6159EEa73133F9813304a272DB2203c09b872F1", 1000000000000]
// voucher tuple for remix test
// [2, 10, 100000000, "0x", "0x", "0x2B2Fd78FE148342d0d4490319f0c9f3C57D75c3B", ["0x2B2Fd78FE148342d0d4490319f0c9f3C57D75c3B","0x5E4E12042cbe7EFCFcCd235265b2a8b190b5Fd5A"], [10, 10], 3, true, 10]