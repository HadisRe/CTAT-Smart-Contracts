// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AccessToken.sol"; // اطمینان حاصل کنید که مسیر صحیح فایل AccessToken.sol را تنظیم کرده‌اید

import "./PatientsRegistry.sol"; // اطمینان حاصل کنید که مسیر صحیح فایل AccessToken.sol را تنظیم کرده‌اید
 
contract PolicyToken {
    // ساختار برای نگهداری سیاست دسترسی بیمار به دارو
    struct Policy {
        uint256 id;
        address patientAddress;
        uint256 drugId;
        AccessType accessType;
    }

    uint256 private currentPolicyId;
    mapping(uint256 => Policy) public policies;

    // مالک قرارداد برای مدیریت کلی
    address public owner;

    // تنظیم مالک در کانستراکتور
    constructor() {
        owner = msg.sender;
    }

    // Modifier برای اطمینان از اینکه تنها مالک می‌تواند عملیات‌های خاصی را انجام دهد
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // تابعی برای ایجاد یک سیاست جدید
    function createPolicy(address _patientAddress, uint256 _drugId, AccessType _accessType) public onlyOwner returns (uint256) {
        currentPolicyId++;
        uint256 newPolicyId = currentPolicyId;

        // ایجاد سیاست جدید و ذخیره آن در مپینگ
        policies[newPolicyId] = Policy({
            id: newPolicyId,
            patientAddress: _patientAddress,
            drugId: _drugId,
            accessType: _accessType
        });

        return newPolicyId; // برگرداندن آی‌دی سیاست جدید
    }

    // تابع برای بررسی اطلاعات سیاست
    function getPolicy(uint256 policyId) public view returns (Policy memory) {
        return policies[policyId];
    }

    // تابع برای بررسی اینکه آیا بیمار به دارو دسترسی دارد یا خیر
    function hasAccess(address _patientAddress, uint256 _drugId, AccessType _requiredAccessType) public view returns (bool) {
        for (uint256 i = 1; i <= currentPolicyId; i++) {
            Policy memory policy = policies[i];
            if (policy.patientAddress == _patientAddress && policy.drugId == _drugId && policy.accessType == _requiredAccessType) {
                return true;
            }
        }
        return false;
    }
}
