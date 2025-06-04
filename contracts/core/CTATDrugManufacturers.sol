// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IDrugManufacturersRegistry {
    function isApprovedManufacturer(address _manufacturerAddress) external view returns (bool);
}

contract CTAToken is ERC721 {
    // ساختار دارو و اطلاعات مرتبط
    struct Drug {
        uint256 id;
        string name;
        uint256 productionDate;
        uint256 expirationDate;
        uint256 temperature;  // دمای فعلی دارو
        bool isSafe;   
       // وضعیت سلامت دارو (True = سالم، False = ناسالم)
        address currentHolder;
    }

    uint256 private currentDrugId;
    mapping(uint256 => Drug) public drugs;
// Modifier برای اطمینان از اینکه تنها مالک می‌تواند عملیات‌های خاصی را انجام دهد
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

       // مالک قرارداد برای مدیریت عضویت‌ها
    address public owner;

     
    // آدرس قرارداد تولیدکنندگان
    address public manufacturersRegistry;

    // رویدادها
    event DrugTracked(uint256 drugId, string status, uint256 timestamp, uint256 temperature, bool isSafe);
    event AccessGranted(uint256 drugId, address indexed grantedTo);

    constructor(address _manufacturersRegistry) ERC721("ConditionalTrackableAccessToken", "CTAT")  {
        manufacturersRegistry = _manufacturersRegistry;
         owner = msg.sender; // 
    }

    modifier onlyApprovedManufacturer() {
        IDrugManufacturersRegistry registry = IDrugManufacturersRegistry(manufacturersRegistry);
        require(registry.isApprovedManufacturer(msg.sender), "Only approved manufacturers can perform this action");
        _;
    }

    // تابع ایجاد توکن دارو و ثبت اطلاعات اولیه آن
    function createDrug(
        string memory _name,
        uint256 _productionDate,
        uint256 _expirationDate,
        uint256 _temperature,
        bool _isSafe
    ) public onlyApprovedManufacturer {
        currentDrugId++;
        uint256 newDrugId = currentDrugId;

        /// _mint(msg.sender, newDrugId);

        drugs[newDrugId] = Drug({
            id: newDrugId,
            name: _name,
            productionDate: _productionDate,
            expirationDate: _expirationDate,
            temperature: _temperature,
            isSafe: _isSafe,
            currentHolder: msg.sender
        });

        emit DrugTracked(newDrugId, "Created", block.timestamp, _temperature, _isSafe);
    }

    // انتقال دارو به سازمان دیگر در زنجیره تأمین
    function transferDrug(uint256 _drugId, address _to) public {
        require(ownerOf(_drugId) == msg.sender, "Only current holder can transfer the drug");
        require(drugs[_drugId].isSafe, "Drug is not safe for transfer");

        // انتقال مالکیت دارو
        _transfer(msg.sender, _to, _drugId);
        drugs[_drugId].currentHolder = _to;

        emit DrugTracked(_drugId, "Transferred", block.timestamp, drugs[_drugId].temperature, drugs[_drugId].isSafe);
    }

    // واکشی و چاپ اطلاعات دارو با استفاده از رویداد
    function fetchDrug(uint256 _drugId) public {
        require(_existsInStruct(_drugId), "Drug does not exist");

        Drug memory drug = drugs[_drugId];
        emit DrugTracked(_drugId, "Fetched", block.timestamp, drug.temperature, drug.isSafe);
    }

    // به‌روزرسانی دمای دارو توسط اوراکل یا سیستم IoT
    function updateDrugCondition(uint256 _drugId, uint256 _newTemperature, bool _isSafe) public onlyOwner  {
        require(_existsInStruct(_drugId), "Drug does not exist");

        Drug storage drug = drugs[_drugId];
        drug.temperature = _newTemperature;
        drug.isSafe = _isSafe;

        emit DrugTracked(_drugId, "Condition", block.timestamp, _newTemperature, _isSafe);
    }

    // اعطای دسترسی به اطلاعات دارو
    function grantAccess(uint256 _drugId, address _grantedTo) public onlyOwner {
        require(_existsInStruct(_drugId), "Drug does not exist");

        emit AccessGranted(_drugId, _grantedTo);
    }

    // تابع چک کردن وجود دارو در استراکت
    function _existsInStruct(uint256 _drugId) internal view returns (bool) {
        return drugs[_drugId].id == _drugId;
    }
}
