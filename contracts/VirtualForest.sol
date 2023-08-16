// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract VF is ERC721{

    uint256 seedId;
    uint256 timeToGetSeed;


    enum Stages {
        seed,
        sapling,
        tree
    }

    mapping(uint256 => address) public seedToAddress;
    mapping(address => uint256) public addressToGetSeedTime;
    mapping(address => mapping (uint256 => bool)) wateredSeed;
    mapping(uint256 => uint256) trackWatering;
    mapping(uint256 => uint256) seedOriginTime;
    mapping(uint256 => Stages) public seedStages;
    mapping(uint256 => uint256) fullyGrowthTimeOfSeed;
    mapping(address => address) approvedAddresses;
    mapping(uint256 => bool) seedIsLive;
    mapping(address => bool) isPlayer;
    mapping(uint256 => bool) usedMannure;

    constructor()ERC721("ZURIAN", "VF"){}

    function getSeed() public  { 
        require(block.timestamp > addressToGetSeedTime[msg.sender], "Wait for 1 day to get seed once again");
        seedId++;
        require(msg.sender != address(0), "only callable by valid address");
        mint(msg.sender, seedId);
        //addressToSeed[msg.sender] = seedId;
        seedToAddress[seedId] = msg.sender;
        addressToGetSeedTime[msg.sender] = block.timestamp + 20 seconds;   // 1 days
        trackWatering[seedId] = block.timestamp + 10 seconds;   // i days
        seedOriginTime[seedId] = block.timestamp;
        fullyGrowthTimeOfSeed[seedId] = block.timestamp + 1 minutes;  // 15 days
        seedIsLive[seedId] = true;
        isPlayer[msg.sender] = true;
    }

    function giveWater(uint256 _seedId) public {
        
        require(seedStages[_seedId] != Stages.tree || seedIsLive[_seedId] == true, "Trees does not need watering");
        address seedOwner = seedToAddress[_seedId];
        require(msg.sender == seedToAddress[_seedId] || msg.sender == approvedAddresses[seedOwner]);
        
        if(block.timestamp > trackWatering[_seedId]){  // checking if current time is exceeds watering timing limit
            if(block.timestamp > seedOriginTime[_seedId] + 15 seconds){  // checking if current time is equal to origin time + 5 days
                fullyGrowthTimeOfSeed[_seedId] += 20 seconds;            // if yes then we won't remove token, instead we increase the fully growth time by 2 days
                trackWatering[_seedId] = block.timestamp +  10 seconds; // 1 days
            }else {
                //_burn(_seedId);
                seedIsLive[_seedId] = false;
                revert("your seed is dead");
            }

        }else {
            if(block.timestamp > seedOriginTime[_seedId] + 30 seconds){  // if current time does not exceeds wateing timing limit then chencking whether its been 2 days from originate
                require(block.timestamp < seedOriginTime[_seedId] + 15 days);  // This is because we want to run this section only when the seed is sapling
                seedStages[_seedId] = Stages.sapling;   // if yes then make the seed to sapling
                trackWatering[_seedId] = block.timestamp + 10 seconds; // 1 days
            }else{ // If the seed is still in seed phase then just update the watering time
                trackWatering[_seedId] = block.timestamp + 1 days; 
            }

            if(block.timestamp > seedOriginTime[_seedId] + 1 minutes){  // 15 days
                if(block.timestamp >= fullyGrowthTimeOfSeed[_seedId]){
                    seedStages[_seedId] = Stages.tree;
                   mint(msg.sender, _seedId);
                }
                
            }
        }
        //trackWatering[_seedId] = block.timestamp + 1 days;
        
    }

    function approveFriend(address _address) public {  // Approving friend to give water instead of owner
        require(isPlayer[msg.sender] && isPlayer[_address]);
        approvedAddresses[msg.sender] = _address;
    }

    function applyMannure(uint256 _mannureId, uint256 _seedId) public {
        require(isPlayer[msg.sender] && !usedMannure[_mannureId]);
        fullyGrowthTimeOfSeed[_seedId] -= 3 days;   // If used mannure then decreasing the minting time by 3 days
        usedMannure[_mannureId] = true;
    }

    function mint(address _to, uint256 _tokenId) internal {
        _safeMint(_to, _tokenId);
    }
}
