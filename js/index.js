const { ethers } = require("ethers");
const { config } = require("dotenv");

// load .env
config();

const provider = new ethers.JsonRpcProvider("http://localhost:8545");
let wallet = ethers.Wallet.fromPhrase(process.env.MNEMONIC, provider);

const contractAddress = process.argv[2];
if (!contractAddress) {
  console.warn("Contract Address not passed: ", contractAddress);
  console.log("Please pass in the contract address like so: 'npm run test <CONTRACT_ADDRESS>'");
}
const foodDiaryContract = new ethers.Contract(contractAddress, foodDiaryAbi(), wallet);

async function interactWithContract() {
  // User methods
  // Add food entry (example)
  const tx1 = await foodDiaryContract.addFoodEntry(
    ethers.encodeBytes32String("Banana"),
    150,
    Math.floor(Date.now() / 1000),
  );
  await tx1.wait();

  // Get food entries for the user
  const entries = await foodDiaryContract.getFoodEntries();
  console.log("Food Entries:", entries);

  // Admin only methods

  const [lastWeekEntries, last2WeekEntries] = await foodDiaryContract.getEntriesLastTwoWeeks();
  console.log("Entries Last Week:", lastWeekEntries.toString());
  console.log("Entries Week Before Last:", last2WeekEntries.toString());

  // Set user's daily BMR (example)
  const tx2 = await foodDiaryContract.setUserDailyCalorieThreshold(wallet.address, 2200);
  await tx2.wait();

  // Get average calories for user for past week
  const average = await foodDiaryContract.getAverageCalories(wallet.address, 7);
  console.log("Average Calories in last 3 days:", average.toString());

  // Get user daily calorie threshold
  const dailyCalorieThreshold = await foodDiaryContract.getUserDailyCalorieThreshold(wallet.address);
  console.log("dailyCalorieThreshold:", dailyCalorieThreshold);

  await foodDiaryContract.setUserDailyCalorieThreshold(wallet.address, 3000);
  const newDailyCalorieThreshold = await foodDiaryContract.getUserDailyCalorieThreshold(wallet.address);
  console.log("New dailyCalorieThreshold:", newDailyCalorieThreshold);
}

interactWithContract();

function foodDiaryAbi() {
  return [
    {
      inputs: [],
      stateMutability: "nonpayable",
      type: "constructor",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "address",
          name: "user",
          type: "address",
        },
        {
          indexed: false,
          internalType: "bytes32",
          name: "foodName",
          type: "bytes32",
        },
        {
          indexed: false,
          internalType: "uint24",
          name: "calories",
          type: "uint24",
        },
        {
          indexed: false,
          internalType: "uint32",
          name: "timestamp",
          type: "uint32",
        },
      ],
      name: "AddFoodEntry",
      type: "event",
    },
    {
      inputs: [],
      name: "DEFAULT_DAILY_CALORIE_THRESHOLD",
      outputs: [
        {
          internalType: "uint16",
          name: "",
          type: "uint16",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "_name",
          type: "bytes32",
        },
        {
          internalType: "uint24",
          name: "_calories",
          type: "uint24",
        },
        {
          internalType: "uint32",
          name: "_timestamp",
          type: "uint32",
        },
      ],
      name: "addFoodEntry",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [],
      name: "admin",
      outputs: [
        {
          internalType: "address",
          name: "",
          type: "address",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "_user",
          type: "address",
        },
        {
          internalType: "uint256",
          name: "_daysAgo",
          type: "uint256",
        },
      ],
      name: "getAverageCalories",
      outputs: [
        {
          internalType: "uint256",
          name: "",
          type: "uint256",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "getEntriesLastTwoWeeks",
      outputs: [
        {
          internalType: "uint128",
          name: "",
          type: "uint128",
        },
        {
          internalType: "uint128",
          name: "",
          type: "uint128",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "getFoodEntries",
      outputs: [
        {
          components: [
            {
              internalType: "bytes32",
              name: "name",
              type: "bytes32",
            },
            {
              internalType: "uint24",
              name: "calories",
              type: "uint24",
            },
            {
              internalType: "uint32",
              name: "timestamp",
              type: "uint32",
            },
          ],
          internalType: "struct FoodDiary.FoodEntry[]",
          name: "",
          type: "tuple[]",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "_user",
          type: "address",
        },
      ],
      name: "getUserDailyCalorieThreshold",
      outputs: [
        {
          internalType: "uint256",
          name: "",
          type: "uint256",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "_user",
          type: "address",
        },
        {
          internalType: "uint256",
          name: "_dailyCalorieThreshold",
          type: "uint256",
        },
      ],
      name: "setUserDailyCalorieThreshold",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
  ];
}
