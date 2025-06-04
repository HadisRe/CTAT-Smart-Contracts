// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AccessToken is ERC721 {
    enum AccessType { READ, WRITE, EXEC }
    
    // Access structure
    struct Access {
        uint256 id;
        string name;
        uint256 startDate;
        uint256 endDate;
        AccessType typeAccess;
    }

    address public owner;
    uint256 private currentAccessId; // Counter for creating new accesses
    mapping(uint256 => Access) public accesses; // Mapping for accesses

    // Events
    event DrugTracked(uint256 drugId, string status, uint256 timestamp, uint256 temperature, bool isSafe);
    event AccessGranted(uint256 accessId, address indexed grantedTo);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor() ERC721("AccessToken", "ATKN") {
        owner = msg.sender;
    }

    // Function to create access and issue new ERC721 token
    function createAccess(
        string memory _name,
        uint256 _startDate,
        uint256 _endDate,
        AccessType _typeAccess
    ) public onlyOwner returns (uint256) {
        currentAccessId += 1; // Increment counter
        uint256 newAccessId = currentAccessId;

        // Create access and store it in mapping
        accesses[newAccessId] = Access({
            id: newAccessId,
            name: _name,
            startDate: _startDate,
            endDate: _endDate,
            typeAccess: _typeAccess
        });

        // Issue ERC721 token to owner address
        _safeMint(msg.sender, newAccessId);

        // Send event
        emit AccessGranted(newAccessId, msg.sender);

        return newAccessId; // Return new access ID
    }

    // Function to check access information
    function getAccess(uint256 accessId) public view returns (Access memory) {
        return accesses[accessId];
    }
}
