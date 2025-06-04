// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DrugTracking {
    // ساختار دارو و اطلاعات مرتبط
    struct Drug {
        uint256 id;
        string name;
        uint256 productionDate;
        uint256 expirationDate;
        uint256 humidity;
        string status;  // "normal", "out of range"
        uint256 lastDeliveredAt; // زمان تحویل دارو
        uint256 temperature;
        bool isSafe;
        address currentHolder;
    }

    uint256 private currentDrugId;
    mapping(uint256 => Drug) public drugs;

    // رویدادها
    event DrugTracked(uint256 drugId, string status, uint256 timestamp, uint256 temperature, bool isSafe);
    event AccessGranted(uint256 drugId, address indexed grantedTo);

    // مالک قرارداد
    address public owner;

    constructor() {
        owner = msg.sender; // تنظیم مالک قرارداد
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // تابع ایجاد اطلاعات دارو
    function createDrug(
        string memory _name,
        uint256 _productionDate,
        uint256 _expirationDate,
        uint256 _humidity,
        string memory _status,
        uint256 _lastDeliveredAt,
        uint256 _temperature,
        bool _isSafe
    ) public onlyOwner {
        currentDrugId++;
        uint256 newDrugId = currentDrugId;

        drugs[newDrugId] = Drug({
            id: newDrugId,
            name: _name,
            productionDate: _productionDate,
            humidity: _humidity,
            status: _status,
            lastDeliveredAt: _lastDeliveredAt,
            expirationDate: _expirationDate,
            temperature: _temperature,
            isSafe: _isSafe,
            currentHolder: msg.sender
        });

        emit DrugTracked(newDrugId, "Created", block.timestamp, _temperature, _isSafe);
    }

    // دریافت اطلاعات دارو
    function fetchDrug(uint256 _drugId) public {
        require(_existsInStruct(_drugId), "Drug does not exist");

        Drug memory drug = drugs[_drugId];
        emit DrugTracked(_drugId, "Fetched", block.timestamp, drug.temperature, drug.isSafe);
    }

    // به‌روزرسانی شرایط دارو
    function updateDrugCondition(uint256 _drugId, uint256 _newTemperature, bool _isSafe) public onlyOwner {
        require(_existsInStruct(_drugId), "Drug does not exist");

        Drug storage drug = drugs[_drugId];
        drug.temperature = _newTemperature;
        drug.isSafe = _isSafe;

        emit DrugTracked(_drugId, "Condition Updated", block.timestamp, _newTemperature, _isSafe);
    }

    // اعطای دسترسی به اطلاعات دارو
    function grantAccess(uint256 _drugId, address _grantedTo) public onlyOwner {
        require(_existsInStruct(_drugId), "Drug does not exist");

        emit AccessGranted(_drugId, _grantedTo);
    }

    // بررسی وجود دارو در استراکت
    function _existsInStruct(uint256 _drugId) internal view returns (bool) {
        return drugs[_drugId].id == _drugId;
    }
}
