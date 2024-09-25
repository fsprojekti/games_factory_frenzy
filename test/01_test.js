const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("FactoryFrenzy Contract", function () {
    let factoryFrenzy;
    let jobs;
    let owner;
    let addr1;
    let addr2;
    const gridSize = 5; // Same grid size as your contract uses in the initialize function

    before(async function () {
        // Get the ContractFactory and Signers here.
        factoryFrenzy = await ethers.getContractFactory("FactoryFrenzy");
        [owner, addr1, addr2] = await ethers.getSigners();

        // Deploy the contract and set the owner as msg.sender
        jobs = await factoryFrenzy.deploy();
    });

    // Test the successful deployment of the contract
    it("should deploy successfully and set the correct owner", async function () {
        // Check if the contract was deployed by checking the address
        expect(jobs.target).to.properAddress;

        // Check if the owner is set correctly
        expect(await jobs.owner()).to.equal(owner.address);
    });

    it("should print the number of available jobs for each jobSpot in matrix style", async function () {
        console.log("Printing available jobs in matrix format:");

        for (let i = 0; i < gridSize; i++) {
            let row = "";
            for (let j = 0; j < gridSize; j++) {
                // Create the job ID like in the initialize function (e.g., A1, B2, etc.)
                const jobId = String.fromCharCode(65 + i) + (j + 1).toString();

                // Call the availableJobs function to get the number of available jobs
                const availableJobs = await jobs.availableJobs(jobId);

                // Add the number of available jobs to the row string
                row += `${availableJobs.toString().padStart(3, " ")} `;
            }
            // Print the entire row for the current grid row
            console.log(`Row ${String.fromCharCode(65 + i)}: ${row}`);
        }
    });


    // Test to check if jobs were created
    it("should have created jobs after initialization", async function () {
        // Loop through the expected grid size and check if jobs exist
        let jobsCount = 0;

        for (let i = 0; i < gridSize; i++) {
            for (let j = 0; j < gridSize; j++) {
                // Create the job ID like in the initialize function (e.g., A1, B2, etc.)
                const jobId = String.fromCharCode(65 + i) + (j + 1).toString();

                // Fetch the jobSpot data from the mapping
                const job = await jobs.jobSpots(jobId);

                // Check if jobs were issued
                if (job.jobsIssued > 0) {
                    jobsCount++;
                }
            }
        }
        // Ensure that at least 1 job has been created
        expect(jobsCount).to.be.greaterThan(0, "No jobs were created in the contract");
    });

    it("should allow a user to collect all jobs from a random job spot and deplete the spot", async function () {
        let user = addr1; // Set the user to addr1
        // Pick a random jobSpot (row and column within the grid)
        const randomRow = Math.floor(Math.random() * gridSize); // Random row index
        const randomCol = Math.floor(Math.random() * gridSize); // Random column index
        let jobSpotId = String.fromCharCode(65 + randomRow) + (randomCol + 1).toString(); // Generate ID like A1, B2, etc.

        console.log(`Random JobSpot selected: ${jobSpotId}`);

        // Set a random UUID for this jobSpot (you can customize the UUID logic)
        const jobSpotUUID = "empty";

        // Fetch the jobSpot details before collection
        const jobSpotBefore = await jobs.jobSpots(jobSpotId);
        const jobsIssued = jobSpotBefore.jobsIssued;

        console.log(`Jobs issued at ${jobSpotId}: ${jobsIssued}`);

        // Simulate the user collecting all jobs from this jobSpot
        await jobs.connect(user).collectAllJobs(jobSpotId, jobSpotUUID);

        // Check that the user received the correct amount of NFTs
        const userBalance = await jobs.balanceOf(user.address);
        expect(userBalance).to.equal(jobsIssued, "User should have collected all jobs from the jobSpot");

        // Fetch the jobSpot details after collection
        const jobSpotAfter = await jobs.jobSpots(jobSpotId);

        // Verify that all jobs have been collected and the job spot is depleted
        expect(jobSpotAfter.jobsCollected).to.equal(jobsIssued, "All jobs should have been collected");
        expect(jobSpotAfter.collector).to.equal(user.address, "The collector should be the user who collected the jobs");

        console.log(`Jobs collected at ${jobSpotId}: ${jobSpotAfter.jobsCollected}`);
        console.log(`Collector for ${jobSpotId}: ${jobSpotAfter.collector}`);
    });

    it("should print the number of available jobs for each jobSpot in matrix style", async function () {
        console.log("Printing available jobs in matrix format:");

        for (let i = 0; i < gridSize; i++) {
            let row = "";
            for (let j = 0; j < gridSize; j++) {
                // Create the job ID like in the initialize function (e.g., A1, B2, etc.)
                const jobId = String.fromCharCode(65 + i) + (j + 1).toString();

                // Call the availableJobs function to get the number of available jobs
                const availableJobs = await jobs.availableJobs(jobId);

                // Add the number of available jobs to the row string
                row += `${availableJobs.toString().padStart(3, " ")} `;
            }
            // Print the entire row for the current grid row
            console.log(`Row ${String.fromCharCode(65 + i)}: ${row}`);
        }
    });
});

