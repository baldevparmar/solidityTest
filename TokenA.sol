
// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract TokenA is ERC20{
    address public admin;
    
    constructor() ERC20("Token A","TKA"){// ERC20 TOKEN A
        admin = msg.sender;
        _mint(msg.sender, 10000*10**18);

    }
    
    function mint(address to, uint amount) external{
        require(msg.sender == admin, "Only admin");
        _mint(to, amount);
    }

    function burn(uint amount) external{
        _burn(msg.sender,amount);
    }
}



