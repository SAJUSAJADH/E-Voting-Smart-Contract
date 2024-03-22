// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

error Election_NottheElectionAuthority();
error Election_CandidateAlreadyExists();

contract ElectionFact {
    
    struct ElectionDetails {
        address deployedAddress;
        string election_name;
        string election_description;
    }
    
    mapping(address=>ElectionDetails) elections;
    
    function createElection(address metamask,string memory election_name, string memory election_description) public{
        address newElectionAddress = address(new Election(msg.sender , election_name, election_description));
        
        elections[metamask].deployedAddress = newElectionAddress;
        elections[metamask].election_name = election_name;
        elections[metamask].election_description = election_description;
    }
    
    function getDeployedElection(address metamask) public view returns (address,string memory,string memory) {
        address deployed_election_address =  elections[metamask].deployedAddress;
        if(deployed_election_address == address(0)) 
            return (address(0), "", "Create an election.");
        else
            return (elections[metamask].deployedAddress,elections[metamask].election_name,elections[metamask].election_description);
    }
}

contract Election {

    //election_authority's address
    address election_authority;
    string election_name;
    string election_description;
    bool status;
    
    //election_authority's address taken when it deploys the contract
    constructor(address authority , string memory name, string memory description)  {
        election_authority = authority;
        election_name = name;
        election_description = description;
        status = true;
    }

    //Only election_authority can call this functions
    modifier owner() {
        if(msg.sender != election_authority){
            revert Election_NottheElectionAuthority();
        }
        _;
    }
    //Check if election is still active. If not it prevents calling owner functions
    modifier checkStatus() {
        require(status, "Error: Election has ended.");
        _;
    }
    //candidate election_description

    struct Candidate {
        string candidate_name;
        string candidate_description;
        string imgHash;
        uint8 voteCount;
        string voterId;
    }

    //candidate mapping

    mapping(uint8=>Candidate) public candidates;

    //voter election_description

    struct Voter {
        uint8 id_of_voted_Candidate;
        bool voted;
    }

    //voter mapping

    mapping(address=>Voter) voters;

    //counter of number of candidates

    uint8 numCandidates;

    //counter of number of voters

    uint8 numVoters;

    //function to add candidate to mapping

    function addCandidate(string memory candidate_name, string memory candidate_description, string memory imgHash,string memory voterId) public owner checkStatus {
        for (uint8 i = 0; i < numCandidates; i++) {
            if (keccak256(abi.encodePacked(candidates[i].voterId)) == keccak256(abi.encodePacked(voterId))) {
            // candidate already exists, so revert with error
            revert Election_CandidateAlreadyExists();
        }
        }
        uint8 candidateID = numCandidates++; //assign id of the candidate
        candidates[candidateID] = Candidate(candidate_name,candidate_description,imgHash,0,voterId); //add the values to the mapping
    }

    //function to vote and check for double voting

    function vote(uint8 candidateID,address voterAddress) public checkStatus {

        //if false the vote will be registered
        require(!voters[voterAddress].voted, "Error:You cannot double vote");
        
        voters[voterAddress] = Voter (candidateID,true); //add the values to the mapping
        numVoters++;
        candidates[candidateID].voteCount++; //increment vote counter of candidate
        
    }

    //Close the Election
    function endElection() public owner checkStatus {
        status = false;
    }

    //function to get count of candidates

    function getNumOfCandidates() public view returns(uint8) {
        return numCandidates;
    }

    //function to get count of voters

    function getNumOfVoters() public view returns(uint8) {
        return numVoters;
    }

    //function to get candidate information

    function getCandidate(uint8 candidateID) public view returns (string memory, string memory, string memory, uint8,string memory) {
        return (candidates[candidateID].candidate_name, candidates[candidateID].candidate_description, candidates[candidateID].imgHash, candidates[candidateID].voteCount, candidates[candidateID].voterId);
    } 

    //Announce the Winners
    function getWinners() public view owner returns (uint8[] memory) {
        uint8 largestVotes = 0;
        for(uint8 i = 0; i < numCandidates; i++) {
            if(largestVotes < candidates[i].voteCount) {
                largestVotes = candidates[i].voteCount;
            }
        }
        uint8 numWinners = 0;
        for(uint8 i = 0; i < numCandidates; i++) {
            if(candidates[i].voteCount == largestVotes) {
                numWinners++;
            }
        }
        uint8[] memory winners = new uint8[](numWinners);
        uint8 index = 0;
        for(uint8 i = 0; i < numCandidates; i++) {
            if(candidates[i].voteCount == largestVotes) {
                winners[index] = i;
                index++;
            }
        }
        uint8[] memory winnerIds = new uint8[](numWinners);
        for(uint8 i = 0; i < numWinners; i++) {
            winnerIds[i] = winners[i];
        }
        return winnerIds;
    }
    //get election data
    function getElectionDetails() public view returns(string memory, string memory) {
        return (election_name,election_description);    
    }
}