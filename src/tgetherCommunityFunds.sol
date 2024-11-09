// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";
import "forge-std/src/console.sol";
interface tgetherCommunitiesInterface {
    function getCommunityOwner(string memory _communityName) external view returns (address);
    function CustomProposal(string memory _communityName, address _contractAddress) external payable returns (uint256);
    function getProposalResults(uint256 _proposalId) external view returns (bool isActive, bool passed);
    function getFee() external view returns (uint256);
}

contract tgetherCommunityFunds is ILogAutomation {

    struct FundParams {
        address treasurer;
        uint256 budget;
        bool isSet;
    }

    enum ProposalType { TreasurerUpdate, BudgetIncrease }

    struct Proposal {
        address proposer;
        ProposalType proposalType;
        address newTreasurer;
        uint256 budgetIncrease;
        string message;
        bool upkeeped;
        bool passed;
    }

    struct TransferRecord {
        address treasurer;
        address recipient;
        uint256 amount;
        string message;
    }

    FundParams public communityFund;
    mapping(uint256 => Proposal) public proposals; // Maps proposalId to Proposal struct
    TransferRecord[] public transferRecords; // Array to store transfer records
    uint256 public transferRecordCount; // Counter to keep track of transfer records

    tgetherCommunitiesInterface public communityContract;
    string public communityName;
    uint256 public communityFee;
    address private owner;

    event FundParamsSet(address treasurer, uint256 budget);
    event ProposalCreated(uint256 proposalId, address proposer, ProposalType proposalType, address newTreasurer, uint256 budgetIncrease, string message);
    event FundParamsUpdated(address treasurer, uint256 budget);
    event TransferRecorded(address treasurer, address recipient, uint256 amount, string message);

    constructor(address _communityContractAddress, string memory _communityName) {
        owner = msg.sender;
        communityContract = tgetherCommunitiesInterface(_communityContractAddress);
        communityName = _communityName;
        communityFee = communityContract.getFee();
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyTreasurer() {
        require(msg.sender == communityFund.treasurer, "Not the treasurer");
        _;
    }

    // Set initial fund parameters for the community
    function setParams(address _treasurer, uint256 _budget) external onlyOwner {
        require(!communityFund.isSet, "Fund parameters already set");

        communityFund = FundParams({
            treasurer: _treasurer,
            budget: _budget,
            isSet: true
        });

        emit FundParamsSet(_treasurer, _budget);
    }

    // Get current fund parameters
    function getParams() external view returns (address, uint256, bool) {
        return (communityFund.treasurer, communityFund.budget, communityFund.isSet);
    }

    // Create a proposal for either updating the treasurer or increasing the budget
    function createProposal(ProposalType _proposalType, address _newTreasurer, uint256 _budgetIncrease, string calldata _message) external payable returns (uint256) {
        require(msg.value == communityFee, "Incorrect community fee");

        uint256 proposalId = communityContract.CustomProposal{value: communityFee}(communityName, address(this));
        require(proposalId > 0, "Proposal not created");

        Proposal memory newProposal = Proposal({
            proposer: msg.sender,
            proposalType: _proposalType,
            newTreasurer: _proposalType == ProposalType.TreasurerUpdate ? _newTreasurer : address(0),
            budgetIncrease: _proposalType == ProposalType.BudgetIncrease ? _budgetIncrease : 0,
            message: _message,
            upkeeped: false,
            passed: false
        });

        proposals[proposalId] = newProposal;
        emit ProposalCreated(proposalId, msg.sender, _proposalType, _newTreasurer, _budgetIncrease, _message);

        return proposalId;
    }

    // Check log for Chainlink automation
    function checkLog(
        Log calldata log,
        bytes memory
    ) external view returns (bool upkeepNeeded, bytes memory performData) {
        address _contractAddress = bytes32ToAddress(log.topics[1]);
        uint256 _proposalId = uint256(log.topics[2]);

        if (_contractAddress == address(this) && proposals[_proposalId].proposer != address(0)) {
            upkeepNeeded = true;
        }
        
        return (upkeepNeeded, abi.encode(_proposalId));
    }

    // Perform upkeep for Chainlink automation
    function performUpkeep(bytes calldata _performData) external {

        uint256 _proposalId = abi.decode(_performData, (uint256));
        Proposal storage proposal = proposals[_proposalId];
        // Once we know the proposal does indeed exist we can check if it is active. 
        require(proposal.proposer != address(0), "Proposal does not exist");

        (bool isActive, bool passed) = communityContract.getProposalResults(_proposalId);
        if (!isActive) {
            proposal.upkeeped = true;
            proposal.passed = passed;

            if (passed) {
                if (proposal.proposalType == ProposalType.TreasurerUpdate) {
                    communityFund.treasurer = proposal.newTreasurer;
                } else if (proposal.proposalType == ProposalType.BudgetIncrease) {
                    communityFund.budget += proposal.budgetIncrease;
                }

                emit FundParamsUpdated(communityFund.treasurer, communityFund.budget);
            }
        }
    }

    // Function to get and update the latest community fee from the community contract
    function getCommunityFee() external {
        communityFee = communityContract.getFee();
    }

    // Returns the current community fee without updating it, for front-end access
    function viewCommunityFee() external view returns (uint256) {
        return communityFee;
    }

    // Transfer funds from the community budget, callable only by the treasurer
    function transferFunds(address payable _to, uint256 _amount, string calldata _message) external onlyTreasurer {

        require(communityFund.budget >= _amount, "Amount exceeds budget");

        communityFund.budget -= _amount;
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Transfer failed");

        // Record the transfer details
        transferRecords.push(TransferRecord({
            treasurer: msg.sender,
            recipient: _to,
            amount: _amount,
            message: _message
        }));

        transferRecordCount += 1;

        emit TransferRecorded(msg.sender, _to, _amount, _message);
    }

    // Returns the contract balance
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // View transfer records with pagination
    function getTransferRecords(uint256 _startIndex, uint256 _endIndex) external view returns (TransferRecord[] memory) {
        require(_endIndex >= _startIndex && _endIndex < transferRecords.length, "Invalid indices");
        uint256 recordCount = _endIndex - _startIndex + 1;

        TransferRecord[] memory records = new TransferRecord[](recordCount);
        for (uint256 i = 0; i < recordCount; i++) {
            records[i] = transferRecords[_startIndex + i];
        }

        return records;
    }

    // Helper function to convert bytes32 to address
    function bytes32ToAddress(bytes32 _address) public pure returns (address) {
        return address(uint160(uint256(_address)));
    }
}
