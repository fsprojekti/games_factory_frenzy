// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title FactoryFrenzy
 * @dev A simplified version of the manufacturing game where Automated Robot Vehicles (ARVs) collect rewards from various job spots.
 * Each job spot contains one job with a varying reward, which is paid in ERC20 tokens when the job is collected.
 */
contract FactoryFrenzy {

    IERC20 public rewardToken;  // ERC20 token used for paying rewards

    // Struct representing a jobSpot
    struct JobSpot {
        uint256 reward;  // Reward for collecting the job at this jobSpot (in ERC20 tokens)
        address collector;  // Address of the ARV (user) who collected the job
    }

    // Mapping from jobSpot ID (as uint8) to JobSpot struct
    mapping(uint8 => JobSpot) public jobSpots;

    // Array to store job spot IDs for easy retrieval
    uint8[] public jobSpotIds;

    // Constructor initializes the contract and sets the reward token
    constructor(IERC20 _rewardToken) {
        rewardToken = _rewardToken;  // Set the ERC20 token used for rewards
    }

    /**
     * @dev Initializes the jobSpots as a grid of size x size.
     * Each job spot gets a random reward and a unique ID (0, 1, 2, etc.).
     * @param size The size of the grid (e.g., 5 means a 5x5 grid, 25 total spots).
     */
    function initialize(uint8 size) public {
        for (uint8 i = 0; i < size * size; i++) {
            jobSpots[i] = JobSpot({
                reward: random(100) * 10 ** 18,  // Assign a random reward (between 1 and 100 ERC20 tokens)
                collector: address(0)  // Initially, no ARV has collected the job
            });
            jobSpotIds.push(i);  // Store the job spot ID in the array
        }
    }

    /**
     * @dev Allows an ARV (msg.sender) to collect the job at a specific job spot.
     * The ARV will receive the reward in ERC20 tokens.
     */
    function collectJob(uint8 jobSpotId) public {
        // Ensure the job has not been collected yet
        require(jobSpots[jobSpotId].collector == address(0), "Job at this jobSpot has already been collected");

        // Set the collector to the ARV's address
        jobSpots[jobSpotId].collector = msg.sender;

        // Transfer the ERC20 reward to the ARV
        uint256 reward = jobSpots[jobSpotId].reward;
        require(rewardToken.balanceOf(address(this)) >= reward, "Factory does not have enough reward tokens");
        rewardToken.transfer(msg.sender, reward);

        // Emit an event for reward collection
        emit JobCollected(msg.sender, jobSpotId, reward);
    }

    /**
     * @dev Generates a pseudo-random number between 1 and n, using block properties as a seed.
     * This randomness is used for determining the reward at each job spot.
     */
    function random(uint256 n) internal view returns (uint256) {
        return (uint256(keccak256(abi.encodePacked(block.number, block.timestamp, msg.sender, totalRewards()))) % n) + 1;
    }

    /**
     * @dev Returns the reward for a job at a given job spot.
     * If the job has already been collected, the reward will be 0.
     * @param jobSpotId The ID of the job spot to query.
     */
    function getJobReward(uint8 jobSpotId) public view returns (uint256) {
        if (jobSpots[jobSpotId].collector != address(0)) {
            return 0;  // Return 0 if the job has already been collected
        }
        return jobSpots[jobSpotId].reward;
    }

    /**
     * @dev Returns an array of all job spot IDs (e.g., [0, 1, 2, 3]).
     */
    function getAllJobSpots() public view returns (uint8[] memory) {
        return jobSpotIds;
    }

    /**
 * @dev Calculates and returns the total rewards across all job spots.
 * This sums up the reward for each job spot, regardless of whether it has been collected.
 */
    function totalRewards() public view returns (uint256 totalReward) {
        for (uint8 i = 0; i < jobSpotIds.length; i++) {
            totalReward += jobSpots[jobSpotIds[i]].reward;
        }
    }


    /**
     * @dev Allows the factory owner to deposit ERC20 tokens into the factory for paying rewards.
     */
    function depositTokens(uint256 amount) public {
        rewardToken.transferFrom(msg.sender, address(this), amount);
    }

    /**
     * @dev Allows the factory owner to withdraw ERC20 tokens from the factory.
     */
    function withdrawTokens(uint256 amount) public {
        require(rewardToken.balanceOf(address(this)) >= amount, "Not enough tokens in the contract");
        rewardToken.transfer(msg.sender, amount);
    }

    // Event for job collection, including the ARV address, job spot ID, and reward
    event JobCollected(address indexed collector, uint8 jobSpotId, uint256 reward);
}
