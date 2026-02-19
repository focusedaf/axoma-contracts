// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IIssuerRegistry {
    function isIssuerApproved(address _issuer)
        external
        view
        returns (bool);
}

contract ExamRegistry {

    struct Exam {
        uint256 id;
        address issuer;
        string ipfsHash;
        uint256 publishedAt;
        bool active;
    }

    uint256 public nextExamId;
    mapping(uint256 => Exam) public exams;

    IIssuerRegistry public issuerRegistry;

    event ExamPublished(
        uint256 indexed examId,
        address indexed issuer,
        string ipfsHash,
        uint256 timestamp
    );

    event ExamDeactivated(
        uint256 indexed examId,
        address indexed issuer,
        uint256 timestamp
    );

    constructor(address _issuerRegistryAddress) {
        issuerRegistry = IIssuerRegistry(_issuerRegistryAddress);
    }

    modifier onlyApprovedIssuer() {
        require(
            issuerRegistry.isIssuerApproved(msg.sender),
            "Not approved or suspended"
        );
        _;
    }

    modifier onlyExamIssuer(uint256 _examId) {
        require(
            exams[_examId].issuer == msg.sender,
            "Not exam issuer"
        );
        _;
    }

    function publishExam(string calldata _ipfsHash)
        external
        onlyApprovedIssuer
    {
        require(bytes(_ipfsHash).length > 0, "Invalid IPFS hash");

        exams[nextExamId] = Exam({
            id: nextExamId,
            issuer: msg.sender,
            ipfsHash: _ipfsHash,
            publishedAt: block.timestamp,
            active: true
        });

        emit ExamPublished(
            nextExamId,
            msg.sender,
            _ipfsHash,
            block.timestamp
        );

        nextExamId++;
    }

    function deactivateExam(uint256 _examId)
        external
        onlyExamIssuer(_examId)
    {
        require(exams[_examId].active, "Already inactive");

        exams[_examId].active = false;

        emit ExamDeactivated(
            _examId,
            msg.sender,
            block.timestamp
        );
    }

    function getExam(uint256 _examId)
        external
        view
        returns (Exam memory)
    {
        return exams[_examId];
    }
}
