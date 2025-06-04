// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DrugManufacturersRegistry {
    // Drug manufacturer structure
    struct Manufacturer {
        uint256 id;
        string name;
        string location;
        bool isApproved;
        address manufacturerAddress;
    }

    // Mapping for storing manufacturer information
    mapping(address => Manufacturer) public manufacturers;
 
    // Manufacturer IDs
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

    // Register new manufacturer
    function registerManufacturer(string memory _name, string memory _location) public {
        require(manufacturers[msg.sender].manufacturerAddress == address(0), "Manufacturer already registered");

        currentId++;
        
        // Store manufacturer information
        manufacturers[msg.sender] = Manufacturer({
            id: currentId,
            name: _name,
            location: _location,
            isApproved: false,  // Initially membership is not approved
            manufacturerAddress: msg.sender
        });
    }

    // Approve manufacturer membership by contract owner
    function approveManufacturer(address _manufacturerAddress) public onlyOwner {
        require(manufacturers[_manufacturerAddress].manufacturerAddress != address(0), "Manufacturer not registered");

        manufacturers[_manufacturerAddress].isApproved = true;
    }

    // Revoke manufacturer membership by contract owner
    function revokeManufacturer(address _manufacturerAddress) public onlyOwner {
        require(manufacturers[_manufacturerAddress].manufacturerAddress != address(0), "Manufacturer not registered");

        manufacturers[_manufacturerAddress].isApproved = false;
    }

    // Check manufacturer membership approval status
    function isApprovedManufacturer(address _manufacturerAddress) public view returns (bool) {
        return manufacturers[_manufacturerAddress].isApproved;
    }
}
