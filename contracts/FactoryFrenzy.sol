// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title FactoryFrenzy
 * @dev A manufacturing game where Automated Robot Vehicles (ARVs) collect jobs from various job spots in a factory.
 * Each job spot contains one job with a varying reward, which is paid in ERC20 tokens when the job is collected.
 */
contract FactoryFrenzy is Ownable {
    IERC20 public rewardToken;  // ERC20 token used for paying ARVs

    // Struct representing a jobSpot
    struct JobSpot {
        string UUID;  // Unique RFID identifier for jobSpot
        uint256 reward;  // Reward for collecting the job at this jobSpot (e.g., tokens or points)
        address collector;  // Address of the ARV (user) who collected the job
    }

    // Mapping from jobSpot ID (e.g., "A1", "B3") to the corresponding JobSpot struct
    mapping(string => JobSpot) public jobSpots;

    // Array to store job spot IDs for easy retrieval
    string[] public jobSpotIds;

    // Constructor initializes the contract, sets the reward token, and sets the owner
    constructor(IERC20 _rewardToken) Ownable(msg.sender){
        rewardToken = _rewardToken;  // Set the ERC20 token used for rewards
        initialize(5);  // Initialize a 5x5 grid of job spots (25 spots)
    }

    /**
     * @dev Initializes the jobSpots as a grid of size x size.
     * Each job spot gets a random reward and a unique ID (e.g., "A1", "B3").
     * @param size The size of the grid (e.g., 5 means a 5x5 grid).
     */
    function initialize(uint size) public onlyOwner {
        for (uint i = 0; i < size; i++) {
            for (uint j = 0; j < size; j++) {
                string memory jobId = string(abi.encodePacked(_toAlphabetCharacter(i), uintToString(j + 1)));
                jobSpots[jobId] = JobSpot({
                    UUID: "empty",  // Initially, the UUID is empty, but it can be set later
                    reward: random(100) * 10 ** 18,  // Assign a random reward (e.g., between 1 and 100 ERC20 tokens)
                    collector: address(0)  // Initially, no ARV has collected the job
                });
                jobSpotIds.push(jobId);  // Store the job spot ID in the array
            }
        }
    }

    /**
     * @dev Converts a number (0-25) to an uppercase ASCII character ('A' - 'Z').
     * This is used to generate job spot IDs like "A1", "B3".
     */
    function _toAlphabetCharacter(uint256 i) internal pure returns (bytes1) {
        require(i < 26, "Index out of range for alphabet conversion");
        return bytes1(uint8(i + 65));  // 65 is ASCII for 'A'
    }

    /**
     * @dev Converts a uint to its string representation.
     * This is used to generate the numeric part of job spot IDs like "A1", "B3".
     */
    function uintToString(uint v) internal pure returns (string memory) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v /= 10;
            reversed[i++] = bytes1(uint8(48 + remainder));  // 48 is ASCII for '0'
        }
        bytes memory s = new bytes(i);
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - 1 - j];  // Reverse the string
        }
        return string(s);
    }

    /**
     * @dev Allows the owner to set the UUID (RFID identifier) for a specific job spot.
     * This links the job spot to a physical location in the factory.
     */
    function setJobSpotUUID(string memory jobSpotId, string memory jobSpotUUID) public onlyOwner {
        require(bytes(jobSpots[jobSpotId].UUID).length == 0, "JobSpot UUID already set");
        require(bytes(jobSpots[jobSpotId].UUID).length > 0, "JobSpot with provided id does not exist");
        jobSpots[jobSpotId].UUID = jobSpotUUID;
    }

    /**
     * @dev Allows an ARV (msg.sender) to collect the job at a specific job spot.
     * The ARV must provide the correct UUID for the job spot and will receive the reward in ERC20 tokens.
     */
    function collectJob(string memory jobSpotId, string memory jobSpotUUID) public {
        // Ensure the job spot exists
        require(bytes(jobSpots[jobSpotId].UUID).length > 0, "JobSpot with provided id does not exist");

        // Ensure the provided UUID matches the job spot's UUID
        require(keccak256(abi.encodePacked(jobSpots[jobSpotId].UUID)) == keccak256(abi.encodePacked(jobSpotUUID)), "JobSpot id and UUID do not match");

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
     * This represents the value that an ARV will collect when they pick up the job.
     */
    function getJobReward(string memory jobSpotId) public view returns (uint256) {
        //Check if the jobSpot job was already collected if it was return 0
        if(jobSpots[jobSpotId].collector != address(0)){
            return 0;
        }
        return jobSpots[jobSpotId].reward;
    }

    /**
     * @dev Returns an array of all job spot IDs (e.g., ["A1", "B2", "C3"]).
     */
    function getAllJobSpots() public view returns (string[] memory) {
        return jobSpotIds;
    }

    /**
     * @dev Allows the factory owner to deposit ERC20 tokens into the factory for paying rewards.
     */
    function depositTokens(uint256 amount) public onlyOwner {
        rewardToken.transferFrom(msg.sender, address(this), amount);
    }

    /**
     * @dev Allows the factory owner to withdraw ERC20 tokens from the factory.
     */
    function withdrawTokens(uint256 amount) public onlyOwner {
        require(rewardToken.balanceOf(address(this)) >= amount, "Not enough tokens in the contract");
        rewardToken.transfer(msg.sender, amount);
    }

    /**
 * @dev Calculates and returns the total rewards available across all job spots.
 */
    function totalRewards() public view returns (uint256 totalReward) {
        for (uint i = 0; i < jobSpotIds.length; i++) {
            totalReward += jobSpots[jobSpotIds[i]].reward;
        }
    }

    // Event for job collection, including the ARV address, job spot ID, and reward
    event JobCollected(address indexed collector, string jobSpotId, uint256 reward);
}
