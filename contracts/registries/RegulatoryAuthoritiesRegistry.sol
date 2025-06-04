// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RegulatoryAuthoritiesRegistry {
    // Regulatory authority structure
    struct Authority {
        uint256 id;
        string name;
        string jurisdiction;
        bool isApproved;
        address authorityAddress;
    }

    // Mapping for storing regulatory authority information
    mapping(address => Authority) public authorities;

    // Authority IDs
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

    // Register new regulatory authority
    function registerAuthority(string memory _name, string memory _jurisdiction) public {
        require(authorities[msg.sender].authorityAddress == address(0), "Authority already registered");

        currentId++;
        
        // Store regulatory authority information
        authorities[msg.sender] = Authority({
            id: currentId,
            name: _name,
            jurisdiction: _jurisdiction,
            isApproved: false,  // Initially membership is not approved
            authorityAddress: msg.sender
        });
    }

    // Approve regulatory authority membership by contract owner
    function approveAuthority(address _authorityAddress) public onlyOwner {
        require(authorities[_authorityAddress].authorityAddress != address(0), "Authority not registered");

        authorities[_authorityAddress].isApproved = true;
    }

    // Revoke regulatory authority membership by contract owner
    function revokeAuthority(address _authorityAddress) public onlyOwner {
        require(authorities[_authorityAddress].authorityAddress != address(0), "Authority not registered");

        authorities[_authorityAddress].isApproved = false;
    }

    // Check regulatory authority membership approval status
    function isApprovedAuthority(address _authorityAddress) public view returns (bool) {
        return authorities[_authorityAddress].isApproved;
    }

    // Access regulatory authority information (only by contract owner)
    function getAuthorityInfo(address _authorityAddress) public view onlyOwner returns (string memory, string memory, bool) {
        require(authorities[_authorityAddress].authorityAddress != address(0), "Authority not registered");

        Authority memory authority = authorities[_authorityAddress];
        return (authority.name, authority.jurisdiction, authority.isApproved);
    }
}
