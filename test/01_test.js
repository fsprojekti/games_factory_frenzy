const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("FactoryFrenzy with Prodex Token", function () {
    let factoryFrenzy;
    let prodexToken;
    let jobs;
    let owner;
    let addr1;
    let addr2;
    const gridSize = 5; // Same grid size as your contract uses in the initialize function
    const initialProdexSupply = ethers.parseUnits("1000000", 18); // 1 million Prodex tokens

    before(async function () {
        // Get the ContractFactory and Signers here.
        const Prodex = await ethers.getContractFactory("ProdexToken"); // ProdexToken contract
        const FactoryFrenzy = await ethers.getContractFactory("FactoryFrenzy");
        [owner, addr1, addr2] = await ethers.getSigners();

        // Deploy the Prodex token with an initial supply of 1 million tokens
        prodexToken = await Prodex.deploy(initialProdexSupply);

        // Deploy the FactoryFrenzy contract with the Prodex token address
        factoryFrenzy = await FactoryFrenzy.deploy(prodexToken.target);

        // Fund the FactoryFrenzy contract with Prodex tokens for rewards
        await prodexToken.transfer(factoryFrenzy.target, ethers.parseUnits("500000", 18)); // Transfer 500,000 Prodex tokens to the contract

    });

    // Test the successful deployment of the Prodex token and FactoryFrenzy contract
    it("should deploy Prodex token and set initial supply correctly", async function () {
        // Check the initial total supply of Prodex tokens
        const totalSupply = await prodexToken.totalSupply();
        expect(totalSupply).to.equal(initialProdexSupply);

        // Check the owner's balance (should be 1 million Prodex tokens minus the 500,000 transferred to the contract)
        const ownerBalance = await prodexToken.balanceOf(owner.address);
        expect(ownerBalance).to.equal(ethers.parseUnits("500000", 18)); // Owner should have 500,000 Prodex tokens remaining

        // Check the FactoryFrenzy contract balance (should be 500,000 Prodex tokens)
        const factoryBalance = await prodexToken.balanceOf(factoryFrenzy.target);
        expect(factoryBalance).to.equal(ethers.parseUnits("500000", 18)); // Contract should have 500,000 tokens for rewards
    });

    it("should print the number of available rewards for each jobSpot in matrix style", async function () {
        console.log("Printing available rewards in matrix format:");

        for (let i = 0; i < gridSize; i++) {
            let row = "";
            for (let j = 0; j < gridSize; j++) {
                // Create the job ID like in the initialize function (e.g., A1, B2, etc.)
                const jobId = String.fromCharCode(65 + i) + (j + 1).toString();

                // Call the getJobReward function to get the reward for each job
                const availableReward = await factoryFrenzy.getJobReward(jobId);

                // Add the reward to the row string
                row += `${ethers.formatEther(availableReward).toString().padStart(5, " ")} `;
            }
            // Print the entire row for the current grid row
            console.log(`Row ${String.fromCharCode(65 + i)}: ${row}`);
        }
    });

    // Test to check if jobs were created with rewards after initialization
    it("should have created jobs with rewards after initialization", async function () {
        // Loop through the expected grid size and check if jobs exist
        let jobsWithRewardsCount = 0;

        for (let i = 0; i < gridSize; i++) {
            for (let j = 0; j < gridSize; j++) {
                // Create the job ID like in the initialize function (e.g., A1, B2, etc.)
                const jobId = String.fromCharCode(65 + i) + (j + 1).toString();

                // Fetch the jobSpot data from the mapping
                const job = await factoryFrenzy.jobSpots(jobId);

                // Check if jobs have a reward set
                if (job.reward > 0) {
                    jobsWithRewardsCount++;
                }
            }
        }
        // Ensure that at least 1 job has been created with a reward
        expect(jobsWithRewardsCount).to.be.greaterThan(0, "No jobs with rewards were created in the contract");
    });

    it("should allow a user to collect the reward from a random job spot and deplete the reward", async function () {
        let user = addr1; // Set the user to addr1
        // Pick a random jobSpot (row and column within the grid)
        const randomRow = Math.floor(Math.random() * gridSize); // Random row index
        const randomCol = Math.floor(Math.random() * gridSize); // Random column index
        let jobSpotId = String.fromCharCode(65 + randomRow) + (randomCol + 1).toString(); // Generate ID like A1, B2, etc.

        console.log(`Random JobSpot selected: ${jobSpotId}`);

        // Set a random UUID for this jobSpot (you can customize the UUID logic)
        const jobSpotUUID = "empty";

        // Fetch the jobSpot details before collection
        const jobSpotBefore = await factoryFrenzy.jobSpots(jobSpotId);
        const reward = jobSpotBefore.reward;

        console.log(`Reward at ${jobSpotId}: ${ethers.formatEther(reward)}`);

        // Simulate the user collecting the reward from this jobSpot
        await factoryFrenzy.connect(user).collectJob(jobSpotId, jobSpotUUID);

        // Check that the user received the correct amount of Prodex tokens
        const userTokenBalance = await prodexToken.balanceOf(user.address);
        expect(userTokenBalance).to.equal(reward, "User should have received the correct reward in Prodex tokens");

        // Fetch the jobSpot details after collection
        const jobSpotAfter = await factoryFrenzy.jobSpots(jobSpotId);

        // Verify that the reward has been collected and the job spot is depleted
        expect(jobSpotAfter.collector).to.equal(user.address, "The collector should be the user who collected the reward");

        console.log(`Collector for ${jobSpotId}: ${jobSpotAfter.collector}`);
    });

    it("should print the number of available rewards for each jobSpot in matrix style", async function () {
        console.log("Printing available rewards in matrix format:");

        for (let i = 0; i < gridSize; i++) {
            let row = "";
            for (let j = 0; j < gridSize; j++) {
                // Create the job ID like in the initialize function (e.g., A1, B2, etc.)
                const jobId = String.fromCharCode(65 + i) + (j + 1).toString();

                // Call the getJobReward function to get the reward for each job
                const availableReward = await factoryFrenzy.getJobReward(jobId);

                // Add the reward to the row string
                row += `${ethers.formatEther(availableReward).toString().padStart(5, " ")} `;
            }
            // Print the entire row for the current grid row
            console.log(`Row ${String.fromCharCode(65 + i)}: ${row}`);
        }
    });
});
