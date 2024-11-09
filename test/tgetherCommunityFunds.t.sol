// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/src/Test.sol";
import "../src/tgetherCommunityFunds.sol";
import "tgether-communities/tgetherCommunities.sol";
import "tgether-communities/LaneRegistry.sol";
import "tgether-communities/CommunitiesLane.sol";
import "tgether-communities/MOCKFundContract.sol"; // Mock Fund Contract
import "tgether-communities/tgetherMembers.sol";   // Member management contract
import "chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";

contract TgetherCommunityFundsTest is Test {
    tgetherCommunities public communityContract;
    tgetherCommunityFunds public communityFunds;
    LaneRegistry public laneRegistry;
    CommunitiesLane public lane;
    MOCKFundContract public mockFund;
    tgetherMembers public memberContract;

    address owner = address(this);
    address addr1 = address(0x1);
    address addr2 = address(0x2);
    uint256 communityFee = 1 ether;
    string communityName = "Blockchain";

function setUp() public {
    vm.startPrank(owner, owner); // Temporarily set `tx.origin` to `owner` for deployment

    // Step 1: Deploy Mock Fund Contract
    mockFund = new MOCKFundContract();

    // Step 2: Deploy tgetherCommunities contract with a fee
    communityContract = new tgetherCommunities(communityFee);

    // Step 3: Deploy LaneRegistry as the `owner`
    laneRegistry = new LaneRegistry(address(communityContract));


    // Step 4: Deploy CommunitiesLane with fund, communities, and lane registry contracts
    lane = new CommunitiesLane(address(mockFund), address(communityContract), address(laneRegistry));

    // Step 5: Set LaneRegistry contract in the tgetherCommunities contract
    communityContract.setLaneRegistryContract(address(laneRegistry));

    // Step 6: Deploy tgetherMembers contract
    memberContract = new tgetherMembers();

    // Step 7: Configure the tgetherMembers and tgetherCommunities contracts with ownership enforced
    memberContract.settgetherCommunities(address(communityContract));
    
    communityContract.settgetherMembersContract(address(memberContract));

    // Step 8: Set up a community
    communityContract.createCommunity(
        communityName,
        0,        // Initial setup value
        0,        // Initial setup value
        0,        // Initial setup value
        1,        // Min credentials
        address(0),
        2630000,  // Proposal time
        0,   // Proposal delay
        false     // isInviteOnly
    );
    vm.stopPrank(); // Revert `tx.origin` back to `address(this)`


    // Step 9: Add members to the community
    vm.prank(owner);
    memberContract.addSelfAsMember(communityName);
    vm.prank(addr1);
    memberContract.addSelfAsMember(communityName);
    vm.prank(addr2);
    memberContract.addSelfAsMember(communityName);

}


    function testSetParams() public {
        // Deploy tgetherCommunityFunds with the community contract and community name
        communityFunds = new tgetherCommunityFunds(address(communityContract), communityName);

        // Set the treasurer and budget
        communityFunds.setParams(addr1, 100 ether);
        
        // Verify FundParams are set correctly
        (address treasurer, uint256 budget, bool isSet) = communityFunds.getParams();
        assertEq(treasurer, addr1, "Treasurer address should be addr1");
        assertEq(budget, 100 ether, "Budget should be 100 ether");
        assertTrue(isSet, "FundParams should be set");
    }

    function testCreateProposal() public {
        // Deploy `tgetherCommunityFunds` with the required arguments
        communityFunds = new tgetherCommunityFunds(address(communityContract), communityName);

        // Step 1: Set up the initial fund parameters as the contract owner
        vm.startPrank(owner, owner);  // Set `msg.sender` and `tx.origin` to `owner`
        communityFunds.setParams(addr1, 100 ether);  // Set `addr1` as the treasurer with a 100 ether budget
        vm.stopPrank();

        // Step 2: Check the required fee for creating a proposal
        uint256 proposalFee = communityFunds.communityFee();

        // Step 3: Fund `addr1` with the required proposal fee
        vm.deal(addr1, proposalFee);  // Give `addr1` enough balance to cover the proposal fee

        // Step 4: Create the proposal with `addr1` as both `msg.sender` and `tx.origin`
        vm.startPrank(addr1, addr1);  // Make `addr1` the caller and originator of the transaction
        uint256 proposalId = communityFunds.createProposal{value: proposalFee}(
            tgetherCommunityFunds.ProposalType.TreasurerUpdate,  // Proposal type
            addr2,                                               // New treasurer address
            0,                                                   // Budget increase (none for this proposal type)
            "Propose new treasurer"                              // Proposal message
        );
        vm.stopPrank();

        // Step 5: Check that the proposal was created correctly
        (address proposer, , , , , , bool upkeeped) = communityFunds.proposals(proposalId);
        assertEq(proposer, addr1, "Proposer should be addr1");
        assertFalse(upkeeped, "Proposal should not be upkeeped initially");
    }

    receive() external payable {}

    function testTransferFunds() public {
        // Step 1: Deploy and set up the `communityFunds` contract with an initial budget and treasurer
        communityFunds = new tgetherCommunityFunds(address(communityContract), communityName);

        vm.startPrank(owner, owner);
        communityFunds.setParams(addr1, 50 ether); // Set `addr1` as treasurer with initial budget
        vm.stopPrank();

        // Step 2: Fund `communityFunds` with sufficient Ether for transfers
        vm.deal(address(communityFunds), 500 ether);  // Add funds to `communityFunds` contract

        // Step 3: Create a proposal to increase the budget
        uint256 proposalFee = communityFunds.communityFee();
        vm.deal(addr1, proposalFee); // Ensure `addr1` has enough balance for proposal fee
        vm.startPrank(addr1, addr1);
        uint256 proposalId = communityFunds.createProposal{value: proposalFee}(
            tgetherCommunityFunds.ProposalType.BudgetIncrease,
            address(0),    // Not updating treasurer, so use zero address
            50 ether,      // Proposed budget increase
            "Increase budget"
        );
        vm.stopPrank();

        // Step 4: Cast a vote to approve the proposal
        vm.startPrank(addr2, addr2);  // Assume `addr2` is a member who can vote
        communityContract.vote(proposalId, true);  // Vote in favor of the proposal
        vm.stopPrank();

        // Step 5: Fast-forward time to simulate the end of the proposal voting period
        vm.warp(block.timestamp + 2630000);  // Adjust timestamp by the proposal time duration

        // Step 6: Perform upkeep in `Lane` to finalize the proposal
        vm.startPrank(owner, owner);
        bytes memory performData = abi.encode(proposalId);  // Encode proposal ID for upkeep
        lane.performUpkeep(performData);  // Trigger the upkeep in `Lane` which applies it to `communityFunds`
        vm.stopPrank();

        // Step 7: Perform upkeep in communityFunds
        vm.startPrank(owner, owner);
        communityFunds.performUpkeep(performData);  // Trigger the upkeep in `Lane` which applies it to `communityFunds`
        vm.stopPrank();


        // Step 8: Verify that the budget has increased as expected in `communityFunds`
        (, uint256 newBudget, ) = communityFunds.getParams();
        assertEq(newBudget, 100 ether, "Budget should have increased by the proposal amount");

        // Step 9: Transfer half of the budget as the treasurer
        uint256 initialBalance = address(this).balance;
        uint256 transferAmount = 50 ether;  // Transfer half of the current budget

        vm.startPrank(addr1, addr1);  // Treasurer `addr1` initiates the transfer
        communityFunds.transferFunds(payable(address(this)), transferAmount, "Half budget transfer");
        vm.stopPrank();

        // Step 10: Check if the fund transfer reduced the budget as expected
        (, uint256 finalBudget, ) = communityFunds.getParams();
        assertEq(finalBudget, newBudget - transferAmount, "Budget should be reduced by half after transfer");

        // Step 11: Verify the recipient received the transferred funds
        assertEq(address(this).balance, initialBalance + transferAmount, "Recipient should receive transferred funds");
    }

    function testCheckLog() public {
        uint256 fakeProposalId = 1;
        communityFunds = new tgetherCommunityFunds(address(communityContract), communityName);

        // Define the fields for the Log struct based on the requirements in checkLog function
        Log memory log;
        log.index = 1;
        log.timestamp = block.timestamp;
        log.txHash = bytes32(uint256(0x1234));
        log.blockNumber = block.number;
        log.blockHash = bytes32(uint256(0x5678));
        log.source = address(communityFunds);  // Set the correct source address

        // Set up topics with the correct addresses and fakeProposalId
        log.topics = new bytes32[](4);
        log.topics[0] = bytes32(0);
        log.topics[1] = bytes32(uint256(uint160(address(communityFunds)))); // Correct contract address for `communityFunds`
        log.topics[2] = bytes32(fakeProposalId);
        log.topics[3] = bytes32(0);

        log.data = bytes("0x");  // Empty data


        // Call checkLog with the complete Log struct
        (bool upkeepNeeded, bytes memory performData) = communityFunds.checkLog(log, bytes("0x"));

        // Assertions to check if upkeep is needed for the given log
        assertFalse(upkeepNeeded, "Upkeep should be needed for valid proposal log");
        assertEq(abi.decode(performData, (uint256)), fakeProposalId, "Perform data should contain the correct proposal ID");

        uint256 proposalFee = communityFunds.communityFee();
        vm.deal(addr1, proposalFee); // Ensure `addr1` has enough balance for proposal fee
        vm.startPrank(addr1, addr1);
        uint256 proposalId = communityFunds.createProposal{value: proposalFee}(
            tgetherCommunityFunds.ProposalType.BudgetIncrease,
            address(0),    // Not updating treasurer, so use zero address
            50 ether,      // Proposed budget increase
            "Increase budget"
        );
        vm.stopPrank();

        log.topics[2] = bytes32(proposalId);


        // Call checkLog with the complete Log struct
        (upkeepNeeded, performData) = communityFunds.checkLog(log, bytes("0x"));

        // Assertions to check if upkeep is needed for the given log
        assertTrue(upkeepNeeded, "Upkeep should be needed for valid proposal log");
        assertEq(abi.decode(performData, (uint256)), proposalId, "Perform data should contain the correct proposal ID");



    }

}
