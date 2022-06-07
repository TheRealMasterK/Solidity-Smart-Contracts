//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IdaoContract {
        function balanceOf(address, uint256) external view returns (uint256); // Interface made for smart contract
    }



contract Dao {

    address public owner;
    uint256 nextProposal;
    uint256[] public validTokens;

    constructor(){
        owner = msg.sender;
        nextProposal = 1;
        daoContract = IdaoContract (0x2953399124F0cBB46d2CbACD8A89cF0599974963); // contract address
        validTokens = [102684069616110510378230568040842325484906225825110848424343675699299203678209]; // this helps determine owner of the contract listing the first minted nft in the collection
    }

    struct proposal{
        uint256 id;
        bool exists;
        string description;
        uint deadline;
        uint votesUp;
        uint256 votesDown;
        address[] canVote;
        uint256 maxVotes;
        mapping(address => bool) voteStatus;
        bool countConducted;
        bool passed;

    }




    mapping(uint256 => proposal) public Proposals;

    // Allows community to create a new proposal & also contains info of the proposal
    event proposalCreated(
        uint256 id,
        string description,
        uint256 maxVotes,
        address proposer   
    );


    // increments the number of votes up or down - calculates the number of votes
    
    event proposalCreated(
        uint256 id,
        string description,
        uint256 maxVotes,
        address proposer
    );
    
    
    
    event newVote(
        uint256 votesUp,
        uint256 votesDown,
        address voter,
        uint256 proposal,
        bool votedFor
    );


    //This calculates the number of proposals put forward
    event proposalCount(
        uint256 id,
        bool passed
    );


    // creates a for loop to check if the holder posses any of the valid token IDS included in the array - owner must own 1 or more nfts
    function checkProposalEligibility(address _proposalist) private view returns (
        bool
    ){
        for(uint i = 0; i < validTokens.length; i++){
            if(daoContract.balanceOf(_proposalist, validTokens[i]) >= 1){
                return true;
            }
        }
        return false;
    }


    // Checks at the time of proposal if the user held one of the nfts - must be part of canvote array
    function checkVoteEligibility(uint256 _id, address _voter) private view returns (
        bool
    ){
        for (uint256 i = 0; i < Proposals[_id].canVote.length; i++) {
            if (Proposals[_id].canVote[i] == _voter) {
            return true;
            }
        }
        return false;
    }
    
    // function that creates proposal
    function createProposal(string memory _description, address[] memory _canVote) public {
        require(checkProposalEligibility(msg.sender), "Only NFT holders can put forth Proposals");

        proposal storage newProposal = Proposals[nextProposal];
        newProposal.id = nextProposal;
        newProposal.exists = true;
        newProposal.description = _description;
        newProposal.deadline = block.number + 100;
        newProposal.canVote = _canVote;
        newProposal.maxVotes = _canVote.length;

        emit proposalCreated(nextProposal, _description, _canVote.length, msg.sender);
        nextProposal++;
    }

    // Conditions for existing proposals + Catches users trying to vote multiple times
    function voteOnProposal(uint256 _id, bool _vote) public {
        require(Proposals[_id].exists, "This proposal does not exist!");
        require(checkVoteEligibility(_id, msg.sender), "You cannot vote on this proposal");
        require(!Proposals[_id].voteStatus[msg.sender], "You have already voted on this proposal");
        require(block.number <= Proposals[_id].deadline, "The deadline has passed for this proposal");
    

        proposal storage p = Proposals[_id];

        if(_vote) {
            p.votesUp++; // update and increments
        }else{
            p.votesDown++; // update and increments
        }

        p.voteStatus[msg.sender] = true;


        emit newVote(p.votesUp, p.votesDown, msg.sender, _id, _vote);

    }

    function countVotes(uint256 _id) public{
        require(msg.sender == owner, "Only owner can count votes ;) ");
        require(Proposals[_id].exists, "This Proposal does not exist");
        require(block.number > Proposals[_id].deadline, "Voting has not concluded");
        require(!Proposals[_id].countConducted, "Count already conducted");

        proposal storage p = Proposals[_id];
        if(Proposals[_id].votesDown < Proposals[_id].votesUp){
            p.passed = true;
        }

        p.countConducted = true;

        emit proposalCount(_id, p.passed);
    }

    // Allows only owner to add future tokens
    function addTokenId(uint256 _tokenId) public {
        require(msg.sender == owner, "Only owner can add tokens");

        validTokens.push(_tokenId);
    }


}

