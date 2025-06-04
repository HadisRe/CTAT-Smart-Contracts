// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EnhancedDrugTransferRegistryWithOrgTypes {
    // نوع شمارشی برای انواع سازمان‌ها
    enum OrgType { Manufacturer, Distributor, Storage, Pharmacy, Regulatory }

    // ساختار سازمان
    struct Organization {
        uint256 id;
        string name;
        OrgType orgType;
        bool isApproved;
        address orgAddress;
    }

    // ساختار انتقال دارو
    struct DrugTransfer {
        uint256 id;
        address sender;
        address receiver;
        string drugName;
        uint256 quantity;
        uint256 productionDate;
        uint256 expirationDate;
        uint256 temperature;
        bool isSafe;
        uint256 timestamp;
        string status;
    }

    // نقشه برای ثبت انتقال‌های دارو
    mapping(uint256 => DrugTransfer) public transfers;

    // نقشه برای نگهداری اطلاعات سازمان‌ها
    mapping(address => Organization) public organizations;

    // شناسه انتقال‌ها و سازمان‌ها
    uint256 private currentTransferId;
    uint256 private currentOrgId;

    // مالک قرارداد
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // Modifier برای اطمینان از اینکه تنها مالک می‌تواند عملیات‌های خاصی را انجام دهد
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Modifier برای اطمینان از اینکه تنها سازمان‌های تاییدشده می‌توانند عملیات‌های خاصی را انجام دهند
    modifier onlyApprovedOrganization() {
        require(organizations[msg.sender].isApproved, "Only approved organizations can perform this action");
        _;
    }

    // ثبت‌نام سازمان جدید با نوع سازمان
    function registerOrganization(string memory _name, OrgType _orgType) public {
        require(organizations[msg.sender].orgAddress == address(0), "Organization already registered");

        currentOrgId++;

        // ذخیره اطلاعات سازمان
        organizations[msg.sender] = Organization({
            id: currentOrgId,
            name: _name,
            orgType: _orgType,
            isApproved: false,
            orgAddress: msg.sender
        });
    }

    // تایید سازمان توسط مالک قرارداد
    function approveOrganization(address _orgAddress) public onlyOwner {
        require(organizations[_orgAddress].orgAddress != address(0), "Organization not registered");

        organizations[_orgAddress].isApproved = true;
    }

    // لغو عضویت سازمان توسط مالک قرارداد
    function revokeOrganization(address _orgAddress) public onlyOwner {
        require(organizations[_orgAddress].orgAddress != address(0), "Organization not registered");

        organizations[_orgAddress].isApproved = false;
    }

    // ثبت انتقال دارو فقط توسط تولیدکنندگان یا توزیع‌کنندگان
    function recordDrugTransfer(
        address _receiver,
        string memory _drugName,
        uint256 _quantity,
        uint256 _productionDate,
        uint256 _expirationDate,
        uint256 _temperature,
        bool _isSafe,
        string memory _status
    ) public onlyApprovedOrganization {
        require(
            organizations[msg.sender].orgType == OrgType.Manufacturer || organizations[msg.sender].orgType == OrgType.Distributor,
            "Only Manufacturers or Distributors can record drug transfer"
        );
        require(organizations[_receiver].isApproved, "Receiver organization is not approved");
        require(_quantity > 0, "Quantity must be greater than zero");
        require(_expirationDate > _productionDate, "Expiration date must be after production date");

        currentTransferId++;

        // ذخیره اطلاعات انتقال دارو
        transfers[currentTransferId] = DrugTransfer({
            id: currentTransferId,
            sender: msg.sender,
            receiver: _receiver,
            drugName: _drugName,
            quantity: _quantity,
            productionDate: _productionDate,
            expirationDate: _expirationDate,
            temperature: _temperature,
            isSafe: _isSafe,
            timestamp: block.timestamp,
            status: _status
        });
    }

    // به‌روزرسانی وضعیت انتقال دارو و دما توسط سازمان تایید شده
    function updateTransferStatusAndTemperature(uint256 _transferId, string memory _newStatus, uint256 _newTemperature, bool _isSafe) public onlyApprovedOrganization {
        require(_transferId > 0 && _transferId <= currentTransferId, "Invalid transfer ID");
        require(transfers[_transferId].sender == msg.sender, "Only the sender can update the status");

        transfers[_transferId].status = _newStatus;
        transfers[_transferId].temperature = _newTemperature;
        transfers[_transferId].isSafe = _isSafe;
    }

    // دسترسی به اطلاعات انتقال دارو با ID انتقال (فقط توسط سازمان‌های تایید شده)
    function getTransferInfo(uint256 _transferId) public view onlyApprovedOrganization returns (
        address sender,
        address receiver,
        string memory drugName,
        uint256 quantity,
        uint256 productionDate,
        uint256 expirationDate,
        uint256 temperature,
        bool isSafe,
        uint256 timestamp,
        string memory status
    ) {
        require(_transferId > 0 && _transferId <= currentTransferId, "Invalid transfer ID");

        DrugTransfer memory transfer = transfers[_transferId];
        return (
            transfer.sender,
            transfer.receiver,
            transfer.drugName,
            transfer.quantity,
            transfer.productionDate,
            transfer.expirationDate,
            transfer.temperature,
            transfer.isSafe,
            transfer.timestamp,
            transfer.status
        );
    }
}
