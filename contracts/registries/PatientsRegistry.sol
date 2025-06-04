// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AccessToken.sol"; // اطمینان حاصل کنید که مسیر صحیح فایل AccessToken.sol را تنظیم کرده‌اید
import "./AccessType.sol";
contract PatientsRegistry {
    // ساختار بیمار
    struct Patient {
        uint256 id;
        string name;
        uint256 age;
        string medicalCondition;
        address patientAddress;
        bool isRegistered;

        uint256 accessToken;
        uint256 policyToken;
    }

    // نقشه برای نگهداری اطلاعات بیماران
    mapping(address => Patient) public patients;

    // شناسه بیماران
    uint256 private currentId;

    // مالک قرارداد برای مدیریت کلی
    address public owner;

    // آدرس قرارداد AccessToken
    AccessToken private accessTokenContract;

    // تنظیم مالک و آدرس قرارداد AccessToken در کانستراکتور
    constructor(address _accessTokenAddress) {
        owner = msg.sender;
        accessTokenContract = AccessToken(_accessTokenAddress);
    }

    // Modifier برای اطمینان از اینکه تنها مالک می‌تواند عملیات‌های خاصی را انجام دهد
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // ثبت‌نام بیمار جدید
    function registerPatient(string memory _name, uint256 _age, string memory _medicalCondition) public {
        require(!patients[msg.sender].isRegistered, "Patient already registered");

        currentId++;
        
        // ذخیره اطلاعات بیمار
        patients[msg.sender] = Patient({
            id: currentId,
            name: _name,
            age: _age,
            medicalCondition: _medicalCondition,
            patientAddress: msg.sender,
            isRegistered: true,
            accessToken: 0,
            policyToken: 0
        });
    }

    // تابعی برای اختصاص توکن دسترسی به بیمار
    function assignAccessToken(address _patientAddress, uint256 _accessTokenId) public onlyOwner {
        require(patients[_patientAddress].isRegistered, "Patient not registered");

        // اطمینان از اینکه مالک توکن ERC721 همان مالک قرارداد است
        require(accessTokenContract.ownerOf(_accessTokenId) == msg.sender, "You are not the owner of this access token");

        // تخصیص accessToken به بیمار
        patients[_patientAddress].accessToken = _accessTokenId;
    }

    // تابعی برای به‌روزرسانی وضعیت پزشکی بیمار (تنها بیمار قادر به بروزرسانی است)
    function updateMedicalCondition(string memory _newCondition) public {
        require(patients[msg.sender].isRegistered, "Patient not registered");
        
        // بروزرسانی وضعیت پزشکی
        patients[msg.sender].medicalCondition = _newCondition;
    }

    // بررسی وضعیت ثبت‌نام بیمار
    function isRegisteredPatient(address _patientAddress) public view returns (bool) {
        return patients[_patientAddress].isRegistered;
    }

    // دسترسی به اطلاعات بیمار (فقط توسط مالک قرارداد)
    function getPatientInfo(address _patientAddress) public view onlyOwner returns (string memory, uint256, string memory) {
        require(patients[_patientAddress].isRegistered, "Patient not registered");

        Patient memory patient = patients[_patientAddress];
        return (patient.name, patient.age, patient.medicalCondition);
    }


  // تابعی برای سوزاندن توکن دسترسی در صورت پایان یافتن تاریخ اعتبار
    function burnExpiredAccessToken(address _patientAddress) public onlyOwner {
        require(patients[_patientAddress].isRegistered, "Patient not registered");
        uint256 accessTokenId = patients[_patientAddress].accessToken;
        require(accessTokenId != 0, "No access token assigned");

        // دریافت اطلاعات دسترسی
        AccessToken.Access memory access = accessTokenContract.getAccess(accessTokenId);
        require(block.timestamp > access.endDate, "Access token is not expired yet");

        // سوزاندن توکن با استفاده از انتقال آن به آدرس صفر
        accessTokenContract.safeTransferFrom(msg.sender, address(0), accessTokenId);

        // حذف توکن دسترسی از بیمار
        patients[_patientAddress].accessToken = 0;
    }

}
