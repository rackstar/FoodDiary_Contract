// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

contract FoodDiary {
    event AddFoodEntry(address indexed user, bytes32 foodName, uint24 calories, uint32 timestamp);

    struct FoodEntry {
        // bytes32 is cheaper than string as we ensure the string fits in a 32 byte slot
        // max 32 ASCII/UTF-8 characters - anymore will be truncated
        bytes32 name;
        // Slot packing - ensure both calorie and timestamp fits in a 32 bytes slot to save gas
        // uint24 (3 bytes) - 16,777,215 maximum calorie per food entry
        uint24 calories;
        // uin32 (8 bytes) - max unix timestamp Sun Feb 07 2106
        uint32 timestamp;
    }

    address public admin;
    uint16 public constant DEFAULT_DAILY_CALORIE_THRESHOLD = 2100;
    uint32[] private _foodEntryTimestamps; // uint32 will let 8 timestamp entries be packed into a slot

    mapping(address => FoodEntry[]) private usersFoodEntries;
    mapping(address => uint256) private usersDailyCalorieThreshold;

    constructor() {
        // Set the contract initiator as the admin of the contract.
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Unauthorized");
        _;
    }

    // External methods

    // TODO: js validate bytes32 _name, uint24 _calories, uint32 _timestamp correct length
    function addFoodEntry(bytes32 _name, uint24 _calories, uint32 _timestamp) external {
        FoodEntry memory foodEntry = FoodEntry(_name, _calories, _timestamp);
        usersFoodEntries[msg.sender].push(foodEntry);
        _foodEntryTimestamps.push(_timestamp);
        emit AddFoodEntry(msg.sender, _name, _calories, _timestamp);
    }

    function getFoodEntries() external view returns (FoodEntry[] memory) {
        return usersFoodEntries[msg.sender];
    }

    function getUserDailyCalorieThreshold(address _user) external view returns (uint256) {
        uint256 userDailyCalorieThreshold = usersDailyCalorieThreshold[_user];
        if (userDailyCalorieThreshold == 0) {
            // not set - return default value
            return DEFAULT_DAILY_CALORIE_THRESHOLD;
        } else {
            return userDailyCalorieThreshold;
        }
    }

    // Admin only external methods

    function setUserDailyCalorieThreshold(address _user, uint256 _dailyCalorieThreshold) external onlyAdmin {
        usersDailyCalorieThreshold[_user] = _dailyCalorieThreshold;
    }

    function getAverageCalories(address _user, uint256 _daysAgo) external view onlyAdmin returns (uint256) {
        // cache the food entries
        FoodEntry[] memory userFoodEntries = usersFoodEntries[_user];
        if (userFoodEntries.length == 0) {
            return 0;
        }

        uint256 totalCalories = 0;
        // Slot packing
        uint128 numberOfEntries = 0;
        uint128 timestampLimit = uint128(block.timestamp - (_daysAgo * 1 days) - 1); // again -1 lets us avoid >=

        // loop backwards to save unnecessary iteration
        for (uint256 i = userFoodEntries.length - 1; i >= 0;) {
            // remove over/underflow check to save gas
            unchecked {
                if (userFoodEntries[i].timestamp > timestampLimit) {
                    totalCalories += userFoodEntries[i].calories;
                    numberOfEntries += 1;
                } else {
                    // older than limit
                    break;
                }
                if (i == 0) {
                    break; // weve reached the end of array
                }
                i--;
            }
        }

        // Check is numberOfEntries to prevent a division by zero error
        if (numberOfEntries == 0) {
            return 0;
        }

        return totalCalories / numberOfEntries;
    }

    function getEntriesLastTwoWeeks() external view onlyAdmin returns (uint128, uint128) {
        uint128 lastWeekEntries = 0;
        uint128 last2WeekEntries = 0;
        // - 1 second will let us avoid using >=, saving gas
        uint256 oneWeekAgo = block.timestamp - 1 weeks - 1 seconds;
        uint256 twoWeeksAgo = block.timestamp - 2 weeks - 1 seconds;

        // loop backwards to save unnecessary iteration
        for (uint256 i = _foodEntryTimestamps.length - 1; i >= 0;) {
            // disable overflow check to save gas (since 0.8.0 arithmetic operations are now checked for overflows)
            unchecked {
                // cache foodEntryTimestamp to avoid reading it off storage twice
                uint32 foodEntryTimestamp = _foodEntryTimestamps[i];
                if (foodEntryTimestamp > oneWeekAgo) {
                    // last week
                    lastWeekEntries++;
                } else if (foodEntryTimestamp > twoWeeksAgo) {
                    // last two weeks
                    last2WeekEntries++;
                } else {
                    // older than 2 weeks ago
                    break;
                }
                if (i == 0) {
                    break; // weve reached the end of array
                }
                i--;
            }
        }
        return (lastWeekEntries, last2WeekEntries);
    }
}
