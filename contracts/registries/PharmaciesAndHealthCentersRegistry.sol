// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PharmaciesAndHealthCentersRegistry {
    // Pharmacy and health center structure
    struct HealthCenter {
        uint256 id;
        string name;
        string location;
        bool isApproved;
        address centerAddress;
    }

    // Mapping for storing pharmacy and health center information
    mapping(address => HealthCenter) public healthCenters;

    // Pharmacy and health center IDs
    uint256 private currentId;

    // Contract owner for membership management
    address public owner;

    constructor() {
        owner = msg.sender; // Set contract owner
    }

    // Modifier to ensure only owner can perform specific operations
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Register new pharmacy or health center
    function registerHealthCenter(string memory _name, string memory _location) public {
        require(healthCenters[msg.sender].centerAddress == address(0), "Health Center already registered");

        currentId++;
        
        // Store health center information
        healthCenters[msg.sender] = HealthCenter({
            id: currentId,
            name: _name,
            location: _location,
            isApproved: false,  // Initially membership is not approved
            centerAddress: msg.sender
        });
    }

    // Approve pharmacy or health center membership by contract owner
    function approveHealthCenter(address _centerAddress) public onlyOwner {
        require(healthCenters[_centerAddress].centerAddress != address(0), "Health Center not registered");

        healthCenters[_centerAddress].isApproved = true;
    }

    // Revoke pharmacy or health center membership by contract owner
    function revokeHealthCenter(address _centerAddress) public onlyOwner {
        require(healthCenters[_centerAddress].centerAddress != address(0), "Health Center not registered");

        healthCenters[_centerAddress].isApproved = false;
    }

    // Check pharmacy or health center membership approval status
    function isApprovedHealthCenter(address _centerAddress) public view returns (bool) {
        return healthCenters[_centerAddress].isApproved;
    }
}
