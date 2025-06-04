// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DrugDistributorsRegistry {
    // ساختار توزیع‌کننده دارو
    struct Distributor {
        uint256 id;
        string name;
        string location;
        bool isApproved;
        address distributorAddress;
    }

    // نقشه برای نگهداری اطلاعات توزیع‌کنندگان
    mapping(address => Distributor) public distributors;

    // شناسه توزیع‌کننده‌ها
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

    // ثبت‌نام توزیع‌کننده جدید
    function registerDistributor(string memory _name, string memory _location) public {
        require(distributors[msg.sender].distributorAddress == address(0), "Distributor already registered");

        currentId++;
        
        // ذخیره اطلاعات توزیع‌کننده
        distributors[msg.sender] = Distributor({
            id: currentId,
            name: _name,
            location: _location,
            isApproved: false,  // در ابتدا عضویت تایید نشده است
            distributorAddress: msg.sender
        });
    }

    // تایید عضویت توزیع‌کننده توسط مالک قرارداد
    function approveDistributor(address _distributorAddress) public onlyOwner {
        require(distributors[_distributorAddress].distributorAddress != address(0), "Distributor not registered");

        distributors[_distributorAddress].isApproved = true;
    }

    // لغو عضویت توزیع‌کننده توسط مالک قرارداد
    function revokeDistributor(address _distributorAddress) public onlyOwner {
        require(distributors[_distributorAddress].distributorAddress != address(0), "Distributor not registered");

        distributors[_distributorAddress].isApproved = false;
    }

    // بررسی وضعیت تایید عضویت توزیع‌کننده
    function isApprovedDistributor(address _distributorAddress) public view returns (bool) {
        return distributors[_distributorAddress].isApproved;
    }
}
