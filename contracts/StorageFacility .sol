// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StorageFacilities {
    // ساختار مرکز انبارداری
    struct StorageCenter {
        uint256 id;
        string name;
        string location; // موقعیت مکانی مرکز انبارداری
        bool isApproved; // وضعیت تایید مرکز
        address centerAddress; // آدرس مرکز انبارداری
    }

    // نقشه برای نگهداری اطلاعات مراکز انبارداری
    mapping(address => StorageCenter) public storageCenters;

    // شناسه مراکز انبارداری
    uint256 private currentId;

    // مالک قرارداد برای مدیریت
    address public owner;

    constructor() {
        owner = msg.sender; // تنظیم مالک قرارداد
    }

    // Modifier برای اطمینان از عملیات توسط مالک
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // ثبت‌نام مرکز انبارداری جدید
    function registerStorageCenter(
        string memory _name,
        string memory _location
    ) public {
        require(
            storageCenters[msg.sender].centerAddress == address(0),
            "Storage center already registered"
        );

        currentId++;

        storageCenters[msg.sender] = StorageCenter({
            id: currentId,
            name: _name,
            location: _location,
            isApproved: false, // وضعیت تایید نشده به صورت پیش‌فرض
            centerAddress: msg.sender
        });
    }

    // تایید مرکز انبارداری
    function approveStorageCenter(address _centerAddress) public onlyOwner {
        require(
            storageCenters[_centerAddress].centerAddress != address(0),
            "Storage center not registered"
        );

        storageCenters[_centerAddress].isApproved = true;
    }

    // لغو تایید مرکز انبارداری
    function revokeStorageCenter(address _centerAddress) public onlyOwner {
        require(
            storageCenters[_centerAddress].centerAddress != address(0),
            "Storage center not registered"
        );

        storageCenters[_centerAddress].isApproved = false;
    }

    // بررسی وضعیت تایید مرکز انبارداری
    function isApprovedStorageCenter(address _centerAddress)
        public
        view
        returns (bool)
    {
        return storageCenters[_centerAddress].isApproved;
    }
}
