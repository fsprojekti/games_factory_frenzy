// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract FactoryFrenzy is ERC721, Ownable {
    // Token ID counter
    uint256 private _nextTokenId;

    // Struct representing a jobSpot without an ID
    struct JobSpot {
        string UUID;  // Unique RFID identifier for jobSpot
        uint8 jobsIssued;  // Number of jobs issued at jobSpot
        uint8 jobsCollected;  // Number of jobs collected from jobSpot
        address collector;  // Address of the user who collected the jobs
    }

    // Mapping from jobSpot ID to JobSpot struct
    mapping(string => JobSpot) public jobSpots;

    // Pass msg.sender as the initial owner to the Ownable constructor
    constructor() ERC721("Jobs", "JOB") Ownable(msg.sender) {
        _nextTokenId = 1; // Initialize the token counter
        initialize(5); // For example, initialize a 5x5 grid
    }

    // Initialize the jobSpots as a matrix of size x size
    function initialize(uint size) public onlyOwner {
        for (uint i = 0; i < size; i++) {
            for (uint j = 0; j < size; j++) {
                string memory jobId = string(abi.encodePacked(_toAlphabetCharacter(i), uintToString(j + 1)));
                jobSpots[jobId] = JobSpot({
                    UUID: "empty",  // Initialize UUID as empty, to be set later
                    jobsIssued: uint8(random(10)),  // Random jobs issued
                    jobsCollected: 0,
                    collector: address(0)  // Initialize collector as address(0)
                });
            }
        }
    }

    // Function to convert uint to a corresponding ASCII uppercase letter (A-Z)
    function _toAlphabetCharacter(uint256 i) internal pure returns (bytes1) {
        require(i < 26, "Index out of range for alphabet conversion");
        return bytes1(uint8(i + 65)); // 65 is ASCII value for 'A'
    }

    // Convert uint to string
    function uintToString(uint v) internal pure returns (string memory) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = bytes1(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i);
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - 1 - j];
        }
        return string(s);
    }

    // Function to set the UUID for a jobSpot
    function setJobSpotUUID(string memory jobSpotId, string memory jobSpotUUID) public onlyOwner {
        require(bytes(jobSpots[jobSpotId].UUID).length == 0, "JobSpot UUID already set");
        require(bytes(jobSpots[jobSpotId].UUID).length > 0, "JobSpot with provided id does not exist");
        jobSpots[jobSpotId].UUID = jobSpotUUID;
    }

    // Collect all jobs by providing jobSpot ID and UUID
    function collectAllJobs(string memory jobSpotId, string memory jobSpotUUID) public {
        // Check if the jobSpot exists
        require(bytes(jobSpots[jobSpotId].UUID).length > 0, "JobSpot with provided id does not exist");

        // Check if the UUID matches
        require(keccak256(abi.encodePacked(jobSpots[jobSpotId].UUID)) == keccak256(abi.encodePacked(jobSpotUUID)), "JobSpot id and UUID do not match");

        // Require that there are jobs left to collect
        require(jobSpots[jobSpotId].jobsCollected < jobSpots[jobSpotId].jobsIssued, "All jobs at this jobSpot have already been collected");

        // Set the collector to the user's address
        jobSpots[jobSpotId].collector = msg.sender;

        // Collect all the remaining jobs
        uint8 jobsToCollect = jobSpots[jobSpotId].jobsIssued - jobSpots[jobSpotId].jobsCollected;

        for (uint8 i = 0; i < jobsToCollect; i++) {
            uint256 newTokenId = _nextTokenId; // Assign the next token ID
            _nextTokenId++; // Increment the token ID counter for the next mint
            _mint(msg.sender, newTokenId); // Mint the NFT with the token ID
        }

        // Mark all jobs as collected
        jobSpots[jobSpotId].jobsCollected = jobSpots[jobSpotId].jobsIssued;
    }

    // Random number generator using block properties
    function random(uint256 n) internal view returns (uint256) {
        return (uint256(keccak256(abi.encodePacked(block.number, block.timestamp, msg.sender, totalJobsIssued()))) % n) + 1;
    }

    // Function to get the total supply of NFTs minted
    function totalSupply() public view returns (uint256) {
        return _nextTokenId - 1; // Since _nextTokenId starts from 1, subtract 1 to get the actual supply
    }

    // Function to calculate the total number of jobs issued
    function totalJobsIssued() public view returns (uint256 totalJobs) {
        for (uint i = 0; i < 5; i++) {
            for (uint j = 0; j < 5; j++) {
                string memory jobId = string(abi.encodePacked(_toAlphabetCharacter(i), uintToString(j + 1)));
                totalJobs += jobSpots[jobId].jobsIssued;
            }
        }
    }

    // Function to get available jobs at a jobSpot
    function availableJobs(string memory jobSpotId) public view returns (uint8) {
        return jobSpots[jobSpotId].jobsIssued - jobSpots[jobSpotId].jobsCollected;
    }
}
