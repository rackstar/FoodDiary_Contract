// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

contract FoodDiary {
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
    }

    // Admin only methods

    function setUserDailyCalorieThreshold(address _user, uint256 _dailyCalorieThreshold) external onlyAdmin {
        usersDailyCalorieThreshold[_user] = _dailyCalorieThreshold;
    }
}
