// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DecentralizedIdentity {
    struct User {
        bool registered;
        bytes32 zkProofHash; // Stores Zero-Knowledge Proof (hashed for privacy)
    }

    mapping(address => User) public users;
    address public owner;

    event UserRegistered(address indexed user, bytes32 zkProofHash);
    event IdentityVerified(address indexed user);
    event IdentityRevoked(address indexed user);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can perform this action");
        _;
    }

    modifier onlyRegistered() {
        require(users[msg.sender].registered, "User is not registered");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerUser(bytes32 zkProofHash) external {
        require(!users[msg.sender].registered, "User already registered");
        
        users[msg.sender] = User({
            registered: true,
            zkProofHash: zkProofHash
        });

        emit UserRegistered(msg.sender, zkProofHash);
    }

    function verifyIdentity(bytes32 proof) external onlyRegistered {
        require(users[msg.sender].zkProofHash == proof, "Invalid identity proof");
        emit IdentityVerified(msg.sender);
    }

    function revokeIdentity(address user) external onlyOwner {
        require(users[user].registered, "User is not registered");
        delete users[user];
        emit IdentityRevoked(user);
    }

    function getUserData(address user) external view returns (bool registered, bytes32 zkProofHash) {
        return (users[user].registered, users[user].zkProofHash);
    }
}