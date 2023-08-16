// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

contract FoodDiary {
    event AddFoodEntry(address indexed user, bytes32 foodName, uint calories, uint timestamp);

    struct FoodEntry {
        // bytes32 is cheaper than string as we ensure the string fits in a 32 byte slot
        // max 32 ASCII/UTF-8 characters - anymore will be truncated
        bytes32 name;
        // Slot packing - ensure both calorie and timestamp fits in a 32 bytes slot to save gas
        // uint24 (3 bytes) - 16,777,215 maximum calorie per food entry
        uint24 calories;
        // uin32 (8 bytes) - max unix timestamp Feb 07 2106
        uint32 timestamp;
    }

    address public admin;
    uint16 public constant defaultDailyCalorieThreshold = 2100;

    mapping(address => FoodEntry[]) usersFoodEntries;
    mapping(address => uint256) usersDailyCalorieThreshold;

    constructor() public {
        // Set the contract initiator as the admin of the contract.
        admin = msg.address;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Unauthorized");
        _;
    }

    // TODO: js validate bytes32 _name, uint24 _calories, uint32 _timestamp correct length
    function addFoodEntry(bytes32 _name, uint24 _calories, uint32 _timestamp) external {
        FoodEntry memory food = FoodEntry(_name, _calories, _timestamp);
        usersFoodEntries[msg.address].push(food);
        event AddFoodEntry(msg.address, _name, _calories, _timestamp);
    }

    // Admin only methods

    function setUserDailyCalorieThreshold(address _user, uint256 _dailyCalorieThreshold) external onlyAdmin {
        usersDailyCalorieThreshold[_user] = _dailyCalorieThreshold;
    }

    function getEntiresLastTwoWeeks() onlyAdmin external returns (uint256, uint256) {
        uint128 memory lastWeekEntries = 0;
        uint128 memory last2WeekEntries = 0;
        // - 1 second will let us avoid using >=, saving gas
        uint64 memory oneWeekAgo = block.timestamp - 1 week - 1 second;
        uint64 memory twoWeekAgo = block.timestamp - 2 week - 1 second;

        // looping backwards will save unnecessary iteration, avoiding >= will also save gas
        for(uint256 i = foodEntryTimestamps.length - 1; i > -1;) {
            // disable overflow check to save gas (since 0.8.0 arithmetic operations are now checked for overflows)
            unchecked {
                // cache foodEntryTimestamp to avoid reading it off storage twice
                uint32 memory foodEntryTimestamp = foodEntryTimestamps[i];
                if (foodEntryTimestamp > oneWeekAgo) {
                    lastWeekEntries++;
                } else if (foodEntryTimestamp > twoWeeksAgo) {
                    last2WeekEntries++;
                } else {
                    // older than 2 weeks ago
                    break;
                }
                i--;
            }
        }
        return (lastWeekEntries, last2WeekEntries);
    }
}
