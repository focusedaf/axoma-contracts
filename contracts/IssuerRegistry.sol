// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract IssuerRegistry {

    address public admin;

    struct Issuer {
        bool approved;
        bool suspended;
        uint256 approvedAt;
    }

    mapping(address => Issuer) private issuers;

    event IssuerApproved(address indexed issuer);
    event IssuerSuspended(address indexed issuer);
    event IssuerReinstated(address indexed issuer);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function approveIssuer(address _issuer) external onlyAdmin {
        issuers[_issuer] = Issuer(true, false, block.timestamp);
        emit IssuerApproved(_issuer);
    }

    function suspendIssuer(address _issuer) external onlyAdmin {
        require(issuers[_issuer].approved, "Not approved");
        issuers[_issuer].suspended = true;
        emit IssuerSuspended(_issuer);
    }

    function reinstateIssuer(address _issuer) external onlyAdmin {
        require(issuers[_issuer].approved, "Not approved");
        issuers[_issuer].suspended = false;
        emit IssuerReinstated(_issuer);
    }

    function isIssuerApproved(address _issuer)
        external
        view
        returns (bool)
    {
        return issuers[_issuer].approved && !issuers[_issuer].suspended;
    }
}
