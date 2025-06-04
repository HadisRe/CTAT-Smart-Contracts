// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AccessToken is ERC721 {

    enum AccessType { READ, WRITE, EXEC }
    // ساختار دسترسی
    struct Access {
        uint256 id;
        string name;
        uint256 startDate;
        uint256 endDate;
        AccessType typeAccess;
    }
    address public owner;
    uint256 private currentAccessId; // شمارنده برای ایجاد دسترسی‌های جدید
    mapping(uint256 => Access) public accesses; // مپینگ برای دسترسی‌ها

    // رویدادها
    event DrugTracked(uint256 drugId, string status, uint256 timestamp, uint256 temperature, bool isSafe);
    event AccessGranted(uint256 accessId, address indexed grantedTo);
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

     constructor() ERC721("AccessToken", "ATKN")   {
        owner=msg.sender;
     }

    // تابع برای ایجاد دسترسی و صدور توکن ERC721 جدید
    function createAccess(
        string memory _name,
        uint256 _startDate,
        uint256 _endDate,
        AccessType _typeAccess
    ) public onlyOwner returns (uint256) {
        currentAccessId += 1; // افزایش شمارنده
        uint256 newAccessId = currentAccessId;

        // ایجاد دسترسی و ذخیره آن در مپینگ
        accesses[newAccessId] = Access({
            id: newAccessId,
            name: _name,
            startDate: _startDate,
            endDate: _endDate,
            typeAccess: _typeAccess
        });

        // صدور توکن ERC721 به آدرس مالک
        _safeMint(msg.sender, newAccessId);

        // ارسال رویداد
        emit AccessGranted(newAccessId, msg.sender);

        return newAccessId; // برگرداندن آی‌دی دسترسی جدید
    }

    // تابع برای بررسی اطلاعات دسترسی
    function getAccess(uint256 accessId) public view returns (Access memory) {
        return accesses[accessId];
    }



 
}