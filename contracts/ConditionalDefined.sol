// Manufacturer Smart Contract
pragma solidity ^0.8.0;

contract Manufacturer {
    mapping(address => bool) public approvedManufacturers;
    address public regulatoryAuthority;

    constructor(address _regulatoryAuthority) {
        regulatoryAuthority = _regulatoryAuthority;
    }

    modifier onlyRegulatoryAuthority() {
        require(msg.sender == regulatoryAuthority, "Not authorized");
        _;
    }

    function approveManufacturer(address manufacturer) external onlyRegulatoryAuthority {
        approvedManufacturers[manufacturer] = true;
    }

    function revokeManufacturer(address manufacturer) external onlyRegulatoryAuthority {
        approvedManufacturers[manufacturer] = false;
    }

    function registerDrug(string memory drugName) external {
        require(approvedManufacturers[msg.sender], "Not an approved manufacturer");
        // Logic to register the drug
    }
}

// Storage Facilities Smart Contract
pragma solidity ^0.8.0;

contract StorageFacilities {
    mapping(address => bool) public approvedStorageFacilities;

    modifier onlyApprovedStorage() {
        require(approvedStorageFacilities[msg.sender], "Not an approved storage facility");
        _;
    }

    function approveStorageFacility(address facility) external {
        approvedStorageFacilities[facility] = true;
    }

    function revokeStorageFacility(address facility) external {
        approvedStorageFacilities[facility] = false;
    }

    function storeDrug(string memory drugID) external onlyApprovedStorage {
        // Logic to store drugs in approved storage
    }
}

// Drug Distributor Registry
pragma solidity ^0.8.0;

contract DrugDistributorsRegistry {
    mapping(address => bool) public approvedDistributors;
    address public manufacturer;

    modifier onlyManufacturer() {
        require(msg.sender == manufacturer, "Not authorized");
        _;
    }

    constructor(address _manufacturer) {
        manufacturer = _manufacturer;
    }

    function approveDistributor(address distributor) external onlyManufacturer {
        approvedDistributors[distributor] = true;
    }

    function revokeDistributor(address distributor) external onlyManufacturer {
        approvedDistributors[distributor] = false;
    }

    function distributeDrug(string memory drugID) external {
        require(approvedDistributors[msg.sender], "Not an approved distributor");
        // Logic to distribute drugs
    }
}

// Pharmacy and Health Center Registry
pragma solidity ^0.8.0;

contract PharmaciesAndHealthCentersRegistry {
    mapping(address => bool) public approvedPharmacies;
    address public regulatoryAuthority;

    modifier onlyRegulatoryAuthority() {
        require(msg.sender == regulatoryAuthority, "Not authorized");
        _;
    }

    constructor(address _regulatoryAuthority) {
        regulatoryAuthority = _regulatoryAuthority;
    }

    function approvePharmacy(address pharmacy) external onlyRegulatoryAuthority {
        approvedPharmacies[pharmacy] = true;
    }

    function revokePharmacy(address pharmacy) external onlyRegulatoryAuthority {
        approvedPharmacies[pharmacy] = false;
    }

    function dispenseDrug(string memory drugID) external {
        require(approvedPharmacies[msg.sender], "Not an approved pharmacy");
        // Logic to dispense drugs
    }
}

// Regulatory Authority Registry
pragma solidity ^0.8.0;

contract RegulatoryAuthoritiesRegistry {
    mapping(address => bool) public regulatoryAuthorities;

    function registerAuthority(address authority) external {
        regulatoryAuthorities[authority] = true;
    }

    function deregisterAuthority(address authority) external {
        regulatoryAuthorities[authority] = false;
    }

    function checkAuthority(address authority) external view returns (bool) {
        return regulatoryAuthorities[authority];
    }
}

// Patients Registry
pragma solidity ^0.8.0;

contract PatientsRegistry {
    mapping(address => string) public patientInfo;
    address public pharmacy;

    modifier onlyPharmacy() {
        require(msg.sender == pharmacy, "Not an authorized pharmacy");
        _;
    }

    constructor(address _pharmacy) {
        pharmacy = _pharmacy;
    }

    function registerPatient(address patient, string memory info) external onlyPharmacy {
        patientInfo[patient] = info;
    }

    function getPatientInfo(address patient) external view returns (string memory) {
        return patientInfo[patient];
    }
}
