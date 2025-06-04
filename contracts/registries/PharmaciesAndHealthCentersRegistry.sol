// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PharmaciesAndHealthCentersRegistry {
    // ساختار داروخانه و مرکز بهداشتی
    struct HealthCenter {
        uint256 id;
        string name;
        string location;
        bool isApproved;
        address centerAddress;
    }

    // نقشه برای نگهداری اطلاعات داروخانه‌ها و مراکز بهداشتی
    mapping(address => HealthCenter) public healthCenters;

    // شناسه داروخانه‌ها و مراکز بهداشتی
    uint256 private currentId;

    // مالک قرارداد برای مدیریت عضویت‌ها
    address public owner;

    constructor() {
        owner = msg.sender; // تنظیم مالک قرارداد
    }

    // Modifier برای اطمینان از اینکه تنها مالک می‌تواند عملیات‌های خاصی را انجام دهد
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // ثبت‌نام داروخانه یا مرکز بهداشتی جدید
    function registerHealthCenter(string memory _name, string memory _location) public {
        require(healthCenters[msg.sender].centerAddress == address(0), "Health Center already registered");

        currentId++;
        
        // ذخیره اطلاعات مرکز بهداشتی
        healthCenters[msg.sender] = HealthCenter({
            id: currentId,
            name: _name,
            location: _location,
            isApproved: false,  // در ابتدا عضویت تایید نشده است
            centerAddress: msg.sender
        });
    }

    // تایید عضویت داروخانه یا مرکز بهداشتی توسط مالک قرارداد
    function approveHealthCenter(address _centerAddress) public onlyOwner {
        require(healthCenters[_centerAddress].centerAddress != address(0), "Health Center not registered");

        healthCenters[_centerAddress].isApproved = true;
    }

    // لغو عضویت داروخانه یا مرکز بهداشتی توسط مالک قرارداد
    function revokeHealthCenter(address _centerAddress) public onlyOwner {
        require(healthCenters[_centerAddress].centerAddress != address(0), "Health Center not registered");

        healthCenters[_centerAddress].isApproved = false;
    }

    // بررسی وضعیت تایید عضویت داروخانه یا مرکز بهداشتی
    function isApprovedHealthCenter(address _centerAddress) public view returns (bool) {
        return healthCenters[_centerAddress].isApproved;
    }
}
