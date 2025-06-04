// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DrugManufacturersRegistry {
    // ساختار تولیدکننده دارو
    struct Manufacturer {
        uint256 id;
        string name;
        string location;
        bool isApproved;
        address manufacturerAddress;
    }

    // نقشه برای نگهداری اطلاعات تولیدکنندگان
    mapping(address => Manufacturer) public manufacturers;
 
    // شناسه تولیدکننده‌ها
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

    // ثبت‌نام تولیدکننده جدید
    function registerManufacturer(string memory _name, string memory _location) public {
        require(manufacturers[msg.sender].manufacturerAddress == address(0), "Manufacturer already registered");

        currentId++;
        
        // ذخیره اطلاعات تولیدکننده
        manufacturers[msg.sender] = Manufacturer({
            id: currentId,
            name: _name,
            location: _location,
            isApproved: false,  // در ابتدا عضویت تایید نشده است
            manufacturerAddress: msg.sender
        });
    }

    // تایید عضویت تولیدکننده توسط مالک قرارداد
    function approveManufacturer(address _manufacturerAddress) public onlyOwner {
        require(manufacturers[_manufacturerAddress].manufacturerAddress != address(0), "Manufacturer not registered");

        manufacturers[_manufacturerAddress].isApproved = true;
    }

    // لغو عضویت تولیدکننده توسط مالک قرارداد
    function revokeManufacturer(address _manufacturerAddress) public onlyOwner {
        require(manufacturers[_manufacturerAddress].manufacturerAddress != address(0), "Manufacturer not registered");

        manufacturers[_manufacturerAddress].isApproved = false;
    }

    // بررسی وضعیت تایید عضویت تولیدکننده
    function isApprovedManufacturer(address _manufacturerAddress) public view returns (bool) {
        return manufacturers[_manufacturerAddress].isApproved;
    }
}
