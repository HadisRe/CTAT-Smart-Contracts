// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AccessToken.sol"; // Make sure to set the correct path for AccessToken.sol file
import "./AccessType.sol"; // Make sure to set the correct path for AccessType.sol file
 
contract PolicyToken {
    // Structure for storing patient drug access policy
    struct Policy {
        uint256 id;
        address patientAddress;
        uint256 drugId;
        AccessType accessType;
    }

    uint256 private currentPolicyId;
    mapping(uint256 => Policy) public policies;

    // Contract owner for general management
    address public owner;

    // Set owner in constructor
    constructor() {
        owner = msg.sender;
    }

    // Modifier to ensure only owner can perform specific operations
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Function to create a new policy
    function createPolicy(address _patientAddress, uint256 _drugId, AccessType _accessType) public onlyOwner returns (uint256) {
        currentPolicyId++;
        uint256 newPolicyId = currentPolicyId;

        // Create new policy and store it in mapping
        policies[newPolicyId] = Policy({
            id: newPolicyId,
            patientAddress: _patientAddress,
            drugId: _drugId,
            accessType: _accessType
        });

        return newPolicyId; // Return new policy ID
    }

    // Function to check policy information
    function getPolicy(uint256 policyId) public view returns (Policy memory) {
        return policies[policyId];
    }

    // Function to check whether patient has access to drug or not
    function hasAccess(address _patientAddress, uint256 _drugId, AccessType _requiredAccessType) public view returns (bool) {
        for (uint256 i = 1; i <= currentPolicyId; i++) {
            Policy memory policy = policies[i];
            if (policy.patientAddress == _patientAddress && policy.drugId == _drugId && policy.accessType == _requiredAccessType) {
                return true;
            }
        }
        return false;
    }
}
