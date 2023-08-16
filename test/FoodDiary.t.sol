// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import "forge-std/Test.sol";

import { FoodDiary } from "../src/FoodDiary.sol";

contract FoodDiaryTest is Test {
    FoodDiary internal foodDiary;
    address private constant TEST_USER = address(0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496);

    function setUp() public virtual {
        // Instantiate the contract-under-test.
        foodDiary = new FoodDiary();
    }

    function testAddFoodEntry() public {
        bytes32 testName = "Pad Thai";
        uint24 testCalories = 105;
        uint32 testTimestamp = uint32(block.timestamp);

        foodDiary.addFoodEntry(testName, testCalories, testTimestamp);
        FoodDiary.FoodEntry[] memory entries = foodDiary.getFoodEntries();

        assertEq(entries[0].name, testName, "Incorrect food entry name");
        assertEq(entries[0].calories, testCalories, "Incorrect food entry calories");
        assertEq(entries[0].timestamp, testTimestamp, "Incorrect food entry timestamp");
    }

    function testCalorieThreshold() public {
        // Default daily calorie threshold
        uint256 defaultDailyCalorie = foodDiary.getUserDailyCalorieThreshold(TEST_USER);
        assertEq(defaultDailyCalorie, 2100, "Incorrect default daily calorie threshold");

        // Set new daily calorie threshold
        uint256 newDailyCalorieThreshold = 3000;
        foodDiary.setUserDailyCalorieThreshold(TEST_USER, newDailyCalorieThreshold);
        uint256 updatedDailyCalorie = foodDiary.getUserDailyCalorieThreshold(TEST_USER);
        assertEq(updatedDailyCalorie, newDailyCalorieThreshold, "Incorrect daily calorie threshold");
    }

    function testGetEntriesLastTwoWeeks() public {
        // olders entries must be added first (20 days -> today)
        for (uint256 i = 20; i >= 0; i--) {
            uint256 nDays = i * 1 days;
            foodDiary.addFoodEntry("Apple", uint24(i), uint32(block.timestamp - nDays));
            if (i == 0) {
                break; // avoids underflow
            }
        }

        (uint128 lastWeek, uint128 last2Weeks) = foodDiary.getEntriesLastTwoWeeks();
        // 1 entry per day, 7 in a week + 1 today (today's entry timestamp == block.timestamp)
        assertEq(lastWeek, 8, "Last week entries does not match expected value.");
        // 1 entry per day, 7 in a week
        assertEq(last2Weeks, 7, "The entries for the week before last does not match expected value.");
    }

    function testGetAverageCalories() public {
        // Add mock entries to test the function
        bytes32 testName = "Bimbimbap";
        uint24 testCalories1 = 500;
        uint24 testCalories2 = 700;
        uint24 testCalories3 = 900;
        uint24 testCalories4 = 500;
        uint24 testCalories5 = 700;
        uint24 testCalories6 = 900;
        uint24 testCalories7 = 700;
        uint32 testTimestamp = uint32(block.timestamp);

        foodDiary.addFoodEntry(testName, testCalories7, testTimestamp - 7 days);
        foodDiary.addFoodEntry(testName, testCalories6, testTimestamp - 6 days);
        foodDiary.addFoodEntry(testName, testCalories5, testTimestamp - 5 days);
        foodDiary.addFoodEntry(testName, testCalories4, testTimestamp - 4 days);
        foodDiary.addFoodEntry(testName, testCalories3, testTimestamp - 3 days);
        foodDiary.addFoodEntry(testName, testCalories2, testTimestamp - 2 days);
        foodDiary.addFoodEntry(testName, testCalories1, testTimestamp - 1 days);

        uint256 expectedAverageFor7Days = (
            testCalories1 + testCalories2 + testCalories3 + testCalories4 + testCalories5 + testCalories6
                + testCalories7
        ) / 7;
        uint256 averageFor7Days = foodDiary.getAverageCalories(TEST_USER, 7);
        assertEq(averageFor7Days, expectedAverageFor7Days, "Average for 7 days does not match expected value.");
    }
}
