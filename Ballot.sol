pragma solidity ^0.7.0;

contract Ballot {
    struct Voter {
        uint weight;
        bool voted;
        uint vote;
    }
    struct Proposal {
        uint voteCount;
    }
    
    address chairperson;
    mapping(address => Voter) voters;
    Proposal[] proposals;
    
    enum Phase {Init, Regs, Vote, Done}
    // Phase can take only 0, 1, 2, 3 values: others invalid
    Phase public state = Phase.Init;
    
    // modifiers
    modifier validPhase(Phase reqPhase) {
        require(state == reqPhase);
        _;
    }
    
    modifier onlyChair() {
        require(msg.sender == chairperson);
        _;
    }
    
    constructor (uint numProposals) {
        chairperson = msg.sender;
        voters[chairperson].weight = 2;
        for (uint prop = 0; prop < numProposals; prop ++) {
            proposals.push(Proposal(0));
            state = Phase.Regs;
        }
    }
    
    // function for changing Phase: can be done only by chairperson
    function changeState(Phase x) onlyChair public {
        // if (msg.sender != chairperson) {
          //   revert();
        //}
        require(x > state);
        state = x;
    }
    
    function register(address voter) public validPhase(Phase.Regs) onlyChair {
        // if (msg.sender != chairperson || voters[voter].voted) revert();
        require(!voters[voter].voted);
        voters[voter].weight = 1;
        voters[voter].voted = false;
    }
    
    function vote(uint toProposal) public validPhase(Phase.Vote) {
        Voter memory sender = voters[msg.sender];
        // if(sender.voted || toProposal >= proposals.length) revert();
        require(!sender.voted);
        require(toProposal < proposals.length);
        sender.voted = true;
        sender.vote = toProposal;
        proposals[toProposal].voteCount += sender.weight;
    }
    
    function reqWinner() public validPhase(Phase.Done) 
            view returns (uint winningProposal) {
                uint winningVoteCount = 0;
                for(uint prop = 0; prop < proposals.length; prop++) {
                    if (proposals[prop].voteCount > winningVoteCount) {
                        winningVoteCount = proposals[prop].voteCount;
                        winningProposal = prop;
                    }
                }
                assert(winningVoteCount>=3);
    }
    
}