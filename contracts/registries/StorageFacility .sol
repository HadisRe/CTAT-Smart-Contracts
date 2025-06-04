// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StorageFacilities {
    // Storage center structure
    struct StorageCenter {
        uint256 id;
        string name;
        string location; // Storage center location
        bool isApproved; // Center approval status
        address centerAddress; // Storage center address
    }

    // Mapping for storing storage center information
    mapping(address => StorageCenter) public storageCenters;

    // Storage center IDs
    uint256 private currentId;

    // Contract owner for management
    address public owner;

    constructor() {
        owner = msg.sender; // Set contract owner
    }

    // Modifier to ensure operations by owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Register new storage center
    function registerStorageCenter(
        string memory _name,
        string memory _location
    ) public {
        require(
            storageCenters[msg.sender].centerAddress == address(0),
            "Storage center already registered"
        );

        currentId++;

        storageCenters[msg.sender] = StorageCenter({
            id: currentId,
            name: _name,
            location: _location,
            isApproved: false, // Unapproved status by default
            centerAddress: msg.sender
        });
    }

    // Approve storage center
    function approveStorageCenter(address _centerAddress) public onlyOwner {
        require(
            storageCenters[_centerAddress].centerAddress != address(0),
            "Storage center not registered"
        );

        storageCenters[_centerAddress].isApproved = true;
    }

    // Revoke storage center approval
    function revokeStorageCenter(address _centerAddress) public onlyOwner {
        require(
            storageCenters[_centerAddress].centerAddress != address(0),
            "Storage center not registered"
        );

        storageCenters[_centerAddress].isApproved = false;
    }

    // Check storage center approval status
    function isApprovedStorageCenter(address _centerAddress)
        public
        view
        returns (bool)
    {
        return storageCenters[_centerAddress].isApproved;
    }
}
