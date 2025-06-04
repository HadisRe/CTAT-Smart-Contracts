// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AccessToken.sol"; // Make sure to set the correct path for AccessToken.sol file
import "./AccessType.sol";

contract PatientsRegistry {
    // Patient structure
    struct Patient {
        uint256 id;
        string name;
        uint256 age;
        string medicalCondition;
        address patientAddress;
        bool isRegistered;

        uint256 accessToken;
        uint256 policyToken;
    }

    // Mapping for storing patient information
    mapping(address => Patient) public patients;

    // Patient IDs
    uint256 private currentId;

    // Contract owner for general management
    address public owner;

    // AccessToken contract address
    AccessToken private accessTokenContract;

    // Set owner and AccessToken contract address in constructor
    constructor(address _accessTokenAddress) {
        owner = msg.sender;
        accessTokenContract = AccessToken(_accessTokenAddress);
    }

    // Modifier to ensure only owner can perform specific operations
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Register new patient
    function registerPatient(string memory _name, uint256 _age, string memory _medicalCondition) public {
        require(!patients[msg.sender].isRegistered, "Patient already registered");

        currentId++;
        
        // Store patient information
        patients[msg.sender] = Patient({
            id: currentId,
            name: _name,
            age: _age,
            medicalCondition: _medicalCondition,
            patientAddress: msg.sender,
            isRegistered: true,
            accessToken: 0,
            policyToken: 0
        });
    }

    // Function to assign access token to patient
    function assignAccessToken(address _patientAddress, uint256 _accessTokenId) public onlyOwner {
        require(patients[_patientAddress].isRegistered, "Patient not registered");

        // Ensure that the ERC721 token owner is the same as the contract owner
        require(accessTokenContract.ownerOf(_accessTokenId) == msg.sender, "You are not the owner of this access token");

        // Assign accessToken to patient
        patients[_patientAddress].accessToken = _accessTokenId;
    }

    // Function to update patient's medical condition (only patient can update)
    function updateMedicalCondition(string memory _newCondition) public {
        require(patients[msg.sender].isRegistered, "Patient not registered");
        
        // Update medical condition
        patients[msg.sender].medicalCondition = _newCondition;
    }

    // Check patient registration status
    function isRegisteredPatient(address _patientAddress) public view returns (bool) {
        return patients[_patientAddress].isRegistered;
    }

    // Access patient information (only by contract owner)
    function getPatientInfo(address _patientAddress) public view onlyOwner returns (string memory, uint256, string memory) {
        require(patients[_patientAddress].isRegistered, "Patient not registered");

        Patient memory patient = patients[_patientAddress];
        return (patient.name, patient.age, patient.medicalCondition);
    }

    // Function to burn access token when expiration date is reached
    function burnExpiredAccessToken(address _patientAddress) public onlyOwner {
        require(patients[_patientAddress].isRegistered, "Patient not registered");
        uint256 accessTokenId = patients[_patientAddress].accessToken;
        require(accessTokenId != 0, "No access token assigned");

        // Get access information
        AccessToken.Access memory access = accessTokenContract.getAccess(accessTokenId);
        require(block.timestamp > access.endDate, "Access token is not expired yet");

        // Burn token by transferring it to zero address
        accessTokenContract.safeTransferFrom(msg.sender, address(0), accessTokenId);

        // Remove access token from patient
        patients[_patientAddress].accessToken = 0;
    }
}
