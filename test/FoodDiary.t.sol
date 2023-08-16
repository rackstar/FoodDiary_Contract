// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import "forge-std/Test.sol";

import { FoodDiary } from "../src/FoodDiary.sol";

contract FoodDiaryTest is Test {
    FoodDiary internal foodDiary;
    address constant testUser = address(0x008046D33856ab458B1AE7774E9B47fCE3bCeDe0);

    function setUp() public virtual {
        // Instantiate the contract-under-test.
        foodDiary = new FoodDiary();
    }

    function testAddFoodEntry() public {
        bytes32 testName = "Banana";
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
        uint256 defaultDailyCalorie = foodDiary.getUserDailyCalorieThreshold(testUser);
        assertEq(defaultDailyCalorie, 2100, "Incorrect default daily calorie threshold");

        // Set new daily calorie threshold
        uint newDailyCalorieThreshold = 3000;
        foodDiary.setUserDailyCalorieThreshold(testUser, newDailyCalorieThreshold);
        uint256 updatedDailyCalorie = foodDiary.getUserDailyCalorieThreshold(testUser);
        assertEq(updatedDailyCalorie, newDailyCalorieThreshold, "Incorrect daily calorie threshold");
    }

    function testGetEntriesLastTwoWeeks() public {
        // olders entries must be added first (20 days -> today)
        for (uint i = 20; i >= 0; i--) {
            uint nDays = i * 1 days;
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

}
