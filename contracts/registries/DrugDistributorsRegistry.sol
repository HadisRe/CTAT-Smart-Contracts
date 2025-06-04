// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DrugDistributorsRegistry {
    // Drug distributor structure
    struct Distributor {
        uint256 id;
        string name;
        string location;
        bool isApproved;
        address distributorAddress;
    }

    // Mapping for storing distributor information
    mapping(address => Distributor) public distributors;

    // Distributor IDs
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

    // Register new distributor
    function registerDistributor(string memory _name, string memory _location) public {
        require(distributors[msg.sender].distributorAddress == address(0), "Distributor already registered");

        currentId++;
        
        // Store distributor information
        distributors[msg.sender] = Distributor({
            id: currentId,
            name: _name,
            location: _location,
            isApproved: false,  // Initially membership is not approved
            distributorAddress: msg.sender
        });
    }

    // Approve distributor membership by contract owner
    function approveDistributor(address _distributorAddress) public onlyOwner {
        require(distributors[_distributorAddress].distributorAddress != address(0), "Distributor not registered");

        distributors[_distributorAddress].isApproved = true;
    }

    // Revoke distributor membership by contract owner
    function revokeDistributor(address _distributorAddress) public onlyOwner {
        require(distributors[_distributorAddress].distributorAddress != address(0), "Distributor not registered");

        distributors[_distributorAddress].isApproved = false;
    }

    // Check distributor membership approval status
    function isApprovedDistributor(address _distributorAddress) public view returns (bool) {
        return distributors[_distributorAddress].isApproved;
    }
}
