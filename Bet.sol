// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./PoolContract.sol";

contract BetContract {
    address public owner;
    bool betStart = false;
    uint public team1 = 1;
    uint public team2 = 2;
    uint public totalBetsOfTeam1; //Total betting amount of Team 1
    uint public totalBetsOfTeam2;//Total betting amount of Team 1
    uint public betDuration;// Betting duration 
    address[] public playesList;
    // Player structure
    struct Player {
        uint amount;
        uint selected;     
    }
    mapping(address => Player) public player;

  
    constructor() {
        owner = payable(msg.sender);
    }

    //Reusable function fon only player can access
    modifier PlayerOnly(){
        require(msg.sender != owner,"Owner can not bet");
        _;
    }
    //Reusable function fon only owner access 
    modifier OwnerOnly(){
        require(msg.sender == owner,"Only Owner can access");
        _;
    }
    // Check if player already participet or not
    function isPlayerExist(address player) public view returns (bool) {
        for(uint256 i = 0; i<playesList.length; i++) {
            if(playesList[i] == player) return true;
        }
        return false;
    }

    // Check tart bet and set duration of betting
    function startBet(uint _duration) public OwnerOnly {
        betStart = true;
        betDuration = block.timestamp + _duration;
    } 

    // Bet function is used of participents
    function bet(uint _selectedTeam) payable public PlayerOnly   {
        require(block.timestamp <= betDuration,"Bet time has been exceed");
        require(betStart==true,"Bet has been closed");
        require(!isPlayerExist(msg.sender), "You have already bet");
        require(msg.value >= 0.5 ether, "Bet amount should be greater then or equal to 0.5 ether");
        player[msg.sender].amount = msg.value;
        player[msg.sender].selected = _selectedTeam;
        playesList.push(msg.sender);
    
        if(_selectedTeam == 1) {    
            totalBetsOfTeam1 += msg.value;
        } else {
            totalBetsOfTeam2 += msg.value;
        }
    }

    // Select winner and distribute the prize money to playes, and send stack to pool contract and its used by contract owner only
    function selectWinner(uint _selectWinnerTeam, address _contractAddressOfPool) public OwnerOnly {
        // check if bet has been close then choose winner
        require(betStart != false, "You cant choose winner if betting is running");
        // store winners in fixed sized array
        address[1000]  memory winners;
        uint256 cnt = 0; 
        uint256 losingTeamTotal = 0; 
        uint256 winningTeamTotal = 0;
        betStart = false;
        // get wining team total and losing team total based on selected winner team
        if ( _selectWinnerTeam == 1){
            losingTeamTotal = totalBetsOfTeam2;
            winningTeamTotal = totalBetsOfTeam1;
        } else {
            losingTeamTotal = totalBetsOfTeam1;
            winningTeamTotal = totalBetsOfTeam2;
        }
        // store winners in winner of team 
        for(uint i = 0; i < playesList.length; i++){
            address addr = playesList[i];
            if(player[addr].selected == _selectWinnerTeam){
                winners[cnt] = addr;
                cnt++;
            }
        }
        // Stack the money to pool contract
        uint amountOfStake = (losingTeamTotal * 20)/100;
        losingTeamTotal -= amountOfStake;
        payable(_contractAddressOfPool).transfer(amountOfStake);
        PoolContract Pool = new PoolContract();
        Pool.distributePrize(amountOfStake);
        
        //Transfer the prize money to playesList
        for(uint k = 0; k < cnt; k++){
                address winnerAddress = winners[k];
                uint256 amount = player[winnerAddress].amount;
                payable(winners[k]).transfer(amount+(losingTeamTotal/winningTeamTotal));
                // Remove Player once prize mony transfer
                delete player[winnerAddress];
                delete playesList[k];
        }
        // Clear data after distribute the prize to player and contract
        losingTeamTotal = 0;
        winningTeamTotal = 0;
        totalBetsOfTeam1 = 0;
        totalBetsOfTeam2 = 0;  
    }
}