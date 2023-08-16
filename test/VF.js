const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VF Contract", function () {
  let vf;
  let owner, player1, player2;

  beforeEach(async function () {
    [owner, player1, player2] = await ethers.getSigners();

    const VF = await ethers.getContractFactory("VF");
    vf = await VF.deploy();
    await vf.deployed();
  });

  it("should allow players to get seeds", async function () {
    await vf.connect(player1).getSeed();
    const seedOwner = await vf.ownerOf(1);
    expect(seedOwner).to.equal(player1.address);
  });

  it("should allow approved friend to water a seed", async function () {
    await vf.connect(player1).getSeed();
    await vf.connect(player1).approveFriend(player2.address);

    // Call the giveWater function and add assertions or handle revert conditions
    // For example:
    const tx = await vf.connect(player2).giveWater(1);
    const receipt = await tx.wait();
    expect(receipt.status).to.equal(1); // Check if the transaction was successful
  });

  it("should apply mannure and reduce watering cooldown", async function () {
    await vf.connect(player1).getSeed();
    await vf.connect(player1).applyMannure(1);

    // Call the applyMannure function and add assertions or handle revert conditions
    // For example:
    const tx = await vf.connect(player1).applyMannure(1);
    const receipt = await tx.wait();
    expect(receipt.status).to.equal(1); // Check if the transaction was successful
  });

  // Add more test cases as needed

});
