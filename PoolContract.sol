// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

contract PoolContract{
    // investor list
    address[] public investorsList;
    
    // map investor with address and investment value
    mapping(address => uint) public investor;
    
    // Total investment
    uint public total;
   
    address public poolContractOwnerAddress;

    // set owner
    constructor() {
        poolContractOwnerAddress = payable(msg.sender);
    }
    
    // Reusable function 
    modifier OwnerOnly(){
        require(msg.sender == poolContractOwnerAddress,"Only Owner can access");
        _;
    }

    //Add Investor in contract
    function addInvestor(address _addressOfInvestor, uint _amount ) public {
        investor[_addressOfInvestor] = _amount;
        total += _amount;
        investorsList.push(_addressOfInvestor);
    }
    
    //Add Investor in contract distribute Stack between investor based on their investment percentage,

    function distributePrize(uint _stack) virtual public OwnerOnly{
        uint noOfInvestors = investorsList.length;
        require(noOfInvestors<1, "No investors found");
        for(uint i=0; i<noOfInvestors; i++){
            uint investmentShare = (investor[investorsList[i]] * 100)/total;
            uint perInvestorStack = (_stack * investmentShare)/100;
            // Transfer stack value to investor account
            payable(investorsList[i]).transfer(perInvestorStack);
        }
    }
}

