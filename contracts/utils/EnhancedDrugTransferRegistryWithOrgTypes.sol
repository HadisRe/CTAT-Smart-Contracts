// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EnhancedDrugTransferRegistryWithOrgTypes {
    // Enumeration type for organization types
    enum OrgType { Manufacturer, Distributor, Storage, Pharmacy, Regulatory }

    // Organization structure
    struct Organization {
        uint256 id;
        string name;
        OrgType orgType;
        bool isApproved;
        address orgAddress;
    }

    // Drug transfer structure
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

    // Mapping for recording drug transfers
    mapping(uint256 => DrugTransfer) public transfers;

    // Mapping for storing organization information
    mapping(address => Organization) public organizations;

    // Transfer and organization IDs
    uint256 private currentTransferId;
    uint256 private currentOrgId;

    // Contract owner
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // Modifier to ensure only owner can perform specific operations
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Modifier to ensure only approved organizations can perform specific operations
    modifier onlyApprovedOrganization() {
        require(organizations[msg.sender].isApproved, "Only approved organizations can perform this action");
        _;
    }

    // Register new organization with organization type
    function registerOrganization(string memory _name, OrgType _orgType) public {
        require(organizations[msg.sender].orgAddress == address(0), "Organization already registered");

        currentOrgId++;

        // Store organization information
        organizations[msg.sender] = Organization({
            id: currentOrgId,
            name: _name,
            orgType: _orgType,
            isApproved: false,
            orgAddress: msg.sender
        });
    }

    // Approve organization by contract owner
    function approveOrganization(address _orgAddress) public onlyOwner {
        require(organizations[_orgAddress].orgAddress != address(0), "Organization not registered");

        organizations[_orgAddress].isApproved = true;
    }

    // Revoke organization membership by contract owner
    function revokeOrganization(address _orgAddress) public onlyOwner {
        require(organizations[_orgAddress].orgAddress != address(0), "Organization not registered");

        organizations[_orgAddress].isApproved = false;
    }

    // Record drug transfer only by manufacturers or distributors
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

        // Store drug transfer information
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

    // Update drug transfer status and temperature by approved organization
    function updateTransferStatusAndTemperature(uint256 _transferId, string memory _newStatus, uint256 _newTemperature, bool _isSafe) public onlyApprovedOrganization {
        require(_transferId > 0 && _transferId <= currentTransferId, "Invalid transfer ID");
        require(transfers[_transferId].sender == msg.sender, "Only the sender can update the status");

        transfers[_transferId].status = _newStatus;
        transfers[_transferId].temperature = _newTemperature;
        transfers[_transferId].isSafe = _isSafe;
    }

    // Access drug transfer information by transfer ID (only by approved organizations)
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
