pragma solidity ^0.8.0;

import "./CTATDrugManufacturers.sol";

contract SupplyChainAccessControl is CTAToken{

    enum Role { Manufacturer, Distributor, Pharmacy, Regulator, Patient }
    
    mapping(address => Role) public userRoles;
    mapping(address => bool) public emergencyAccess;
    
    // Emergency token storage
    uint256 public emergencyTokenCounter;
    mapping(address => uint256) public emergencyTokens;

    modifier onlyRole(Role role) {
        require(userRoles[msg.sender] == role, "Access denied: incorrect role");
        _;
    }
   
    uint256 public currentDrugId;
    
    modifier checkTemperature(uint drugId) {
        require(drugs[drugId].temperature <= 25, "Temperature out of range");
        _;
    }

    modifier checkRoleAccess(uint drugId) {
        if(userRoles[msg.sender] == Role.Manufacturer) {
            require(drugs[drugId].temperature <= 25, "Manufacturer: Temperature out of range");
        } else if(userRoles[msg.sender] == Role.Distributor) {
            require(drugs[drugId].temperature <= 25, "Distributor: Temperature out of range");
        }
        _;
    }

    function setRole(address user, Role role) public {
        userRoles[user] = role;
    }

    function checkDrugConditions(uint drugId) public view {
        require(drugs[drugId].temperature >= 2 && drugs[drugId].temperature <= 25, "Temperature out of range");
        require(block.timestamp <= drugs[drugId].expirationDate, "Drug has expired");
        require(drugs[drugId].humidity <= 60, "Humidity out of range");
        require(keccak256(abi.encodePacked(drugs[drugId].status)) == keccak256(abi.encodePacked("normal")), "Drug status is not normal");
        require(block.timestamp - drugs[drugId].lastDeliveredAt <= 7 days, "Drug delivery too old");
        require(drugs[drugId].isSafe, "Drug is not safe for use");
        require(drugs[drugId].currentHolder == msg.sender, "You are not the current holder of the drug");
    }

    // Function to create drug token and register its initial information
    function registerDrug(
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
            expirationDate: _expirationDate,
            humidity: _humidity,
            status: _status,
            lastDeliveredAt: _lastDeliveredAt,
            temperature: _temperature,
            isSafe: _isSafe,
            currentHolder: msg.sender
        });
    }

    function viewDrug(uint drugId) public view returns (string memory, uint256, uint256, string memory) {
        return (drugs[drugId].name, drugs[drugId].temperature, drugs[drugId].humidity, drugs[drugId].status);
    }

    function activateEmergencyAccess(uint drugId) public onlyRole(Role.Distributor) {
        require(drugs[drugId].temperature > 25, "Emergency access only when temperature is out of range");
        
        // Activate emergency access
        emergencyAccess[msg.sender] = true;

        // Define and assign a new token
        emergencyTokenCounter++;
        uint256 newToken = emergencyTokenCounter;

        // Store token for user
        emergencyTokens[msg.sender] = newToken;

        // Declare emergency status for drug
        drugs[drugId].status = "out of range";
    }

    // Function to view emergency token
    function viewEmergencyToken() public view returns (uint256) {
        require(emergencyAccess[msg.sender], "You do not have emergency access");
        return emergencyTokens[msg.sender];
    }

    function restrictAccess(uint drugId) public onlyRole(Role.Pharmacy) checkTemperature(drugId) {
        drugs[drugId].status = "checked";
    }

    // Special condition for distributor with temporary access
    function updateDeliveryStatus(uint drugId) public onlyRole(Role.Distributor) {
        require(block.timestamp > drugs[drugId].lastDeliveredAt, "Already delivered to Pharmacy");
        drugs[drugId].lastDeliveredAt = block.timestamp;
    }
    
    // Access restriction policy after drug delivery to pharmacy
    function restrictAfterDelivery(uint drugId) public {
        if(block.timestamp > drugs[drugId].lastDeliveredAt) {
            userRoles[msg.sender] = Role.Pharmacy; // Access restriction for distributor
        }
    }
}
