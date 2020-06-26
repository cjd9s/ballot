/*
 * SPDX-License-Identifier: UNLICENSED
 * @file ballot.sol
 * @author Craig DuBose
 * @date created 3rd June 2020
 * @date last modified 23rd June 2020
 */

pragma solidity ^0.6.0;

contract ITSligoElection {

    struct votes{
        uint vote1;
        uint vote2;
    }

    struct voterInformation{
        bool voterRegistered;
        bool voterVoted;
        votes choices;
    }

    mapping(address => voterInformation) voterRegister;

    uint private countResult = 0;
    uint public finalResult = 0;
    uint public totalVoter = 0;
    uint public totalVote = 0;
    address public ballotOfficialAddress;
    string public ballotOfficialName;
    string public proposal;

    enum State { Created, Voting, Ended }
	State public state;

	//creates a new ballot contract
	constructor(string memory _ballotOfficialName,  string memory _proposal) public
    {
        ballotOfficialAddress = msg.sender;
        ballotOfficialName = _ballotOfficialName;
        proposal = _proposal;

        state = State.Created;
    }


	modifier condition(bool _condition) {
		require(_condition, "condition not met");
		_;
	}

	modifier onlyOfficial() {
		require(msg.sender == ballotOfficialAddress, "not an official");
		_;
	}

	modifier inState(State _state) {
		require(state == _state, "election not in appropriate state");
		_;
	}

    event voterAdded(address voter);
    event voteStarted();
    event voteEnded(uint finalResult);
    event voteDone(address voter);

    //add voter
    function addVoter(address _voterAddress)
        public
        inState(State.Created)
        onlyOfficial
    {
        voterRegister[_voterAddress].voterRegistered = true;
        voterRegister[_voterAddress].voterVoted = false;
        totalVoter++;
        emit voterAdded(_voterAddress);
    }

    //declare voting starts now
    function startVote()
        public
        inState(State.Created)
        onlyOfficial
    {
        state = State.Voting;
        emit voteStarted();
    }

    //voters vote by indicating their choice (true/false)
    function doVote(uint _vote1, uint _vote2)
        public
        inState(State.Voting)
        returns (bool voted)
    {
        bool found = false;

        if (voterRegister[msg.sender].voterRegistered && !voterRegister[msg.sender].voterVoted)
        {
            votes memory ballot;
            voterRegister[msg.sender].voterVoted = true;
            ballot.vote1 = _vote1;
            ballot.vote2 = _vote2;
            if (ballot.vote1 != 0 && ballot.vote1 > 0){
                countResult++;//counting on the go
            }
            if (ballot.vote2 != 0 && ballot.vote1 > 0){
                countResult++;
            }
            voterRegister[msg.sender].choices = ballot;
            totalVote++;
            found = true;
        }
        emit voteDone(msg.sender);
        return found;
    }

    //end votes
    function endVote()
        public
        inState(State.Voting)
        onlyOfficial
    {
        state = State.Ended;
        finalResult = countResult; //move result from private countResult to public finalResult
        emit voteEnded(finalResult);
    }
}