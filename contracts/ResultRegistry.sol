// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IExamRegistry {
    function getExam(uint256 _examId)
        external
        view
        returns (
            uint256 id,
            address issuer,
            string memory ipfsHash,
            uint256 publishedAt,
            bool active
        );
}

contract ResultRegistry {

    struct Result {
        uint256 id;
        uint256 examId;
        address issuer;
        string ipfsHash;
        uint256 publishedAt;
        bool active;
    }

    uint256 public nextResultId;
    mapping(uint256 => Result) public results;

    IExamRegistry public examRegistry;

    event ResultPublished(
        uint256 indexed resultId,
        uint256 indexed examId,
        address indexed issuer,
        string ipfsHash,
        uint256 timestamp
    );

    event ResultDeactivated(
        uint256 indexed resultId,
        address indexed issuer,
        uint256 timestamp
    );

    constructor(address _examRegistryAddress) {
        examRegistry = IExamRegistry(_examRegistryAddress);
    }

    modifier onlyExamIssuer(uint256 _examId) {
        (
            ,
            address issuer,
            ,
            ,
            bool active
        ) = examRegistry.getExam(_examId);

        require(active, "Exam inactive");
        require(issuer == msg.sender, "Not exam issuer");
        _;
    }

    function publishResult(
        uint256 _examId,
        string calldata _ipfsHash
    )
        external
        onlyExamIssuer(_examId)
    {
        require(bytes(_ipfsHash).length > 0, "Invalid IPFS hash");

        results[nextResultId] = Result({
            id: nextResultId,
            examId: _examId,
            issuer: msg.sender,
            ipfsHash: _ipfsHash,
            publishedAt: block.timestamp,
            active: true
        });

        emit ResultPublished(
            nextResultId,
            _examId,
            msg.sender,
            _ipfsHash,
            block.timestamp
        );

        nextResultId++;
    }

    function deactivateResult(uint256 _resultId)
        external
    {
        require(
            results[_resultId].issuer == msg.sender,
            "Not result issuer"
        );

        require(results[_resultId].active, "Already inactive");

        results[_resultId].active = false;

        emit ResultDeactivated(
            _resultId,
            msg.sender,
            block.timestamp
        );
    }

    function getResult(uint256 _resultId)
        external
        view
        returns (Result memory)
    {
        return results[_resultId];
    }
}
