// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RegulatoryAuthoritiesRegistry {
    // ساختار نهاد نظارتی
    struct Authority {
        uint256 id;
        string name;
        string jurisdiction;
        bool isApproved;
        address authorityAddress;
    }

    // نقشه برای نگهداری اطلاعات نهادهای نظارتی
    mapping(address => Authority) public authorities;

    // شناسه نهادها
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

    // ثبت‌نام نهاد نظارتی جدید
    function registerAuthority(string memory _name, string memory _jurisdiction) public {
        require(authorities[msg.sender].authorityAddress == address(0), "Authority already registered");

        currentId++;
        
        // ذخیره اطلاعات نهاد نظارتی
        authorities[msg.sender] = Authority({
            id: currentId,
            name: _name,
            jurisdiction: _jurisdiction,
            isApproved: false,  // در ابتدا عضویت تایید نشده است
            authorityAddress: msg.sender
        });
    }

    // تایید عضویت نهاد نظارتی توسط مالک قرارداد
    function approveAuthority(address _authorityAddress) public onlyOwner {
        require(authorities[_authorityAddress].authorityAddress != address(0), "Authority not registered");

        authorities[_authorityAddress].isApproved = true;
    }

    // لغو عضویت نهاد نظارتی توسط مالک قرارداد
    function revokeAuthority(address _authorityAddress) public onlyOwner {
        require(authorities[_authorityAddress].authorityAddress != address(0), "Authority not registered");

        authorities[_authorityAddress].isApproved = false;
    }

    // بررسی وضعیت تایید عضویت نهاد نظارتی
    function isApprovedAuthority(address _authorityAddress) public view returns (bool) {
        return authorities[_authorityAddress].isApproved;
    }

    // دسترسی به اطلاعات نهاد نظارتی (فقط توسط مالک قرارداد)
    function getAuthorityInfo(address _authorityAddress) public view onlyOwner returns (string memory, string memory, bool) {
        require(authorities[_authorityAddress].authorityAddress != address(0), "Authority not registered");

        Authority memory authority = authorities[_authorityAddress];
        return (authority.name, authority.jurisdiction, authority.isApproved);
    }
}
