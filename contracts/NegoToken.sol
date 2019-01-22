pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract NegoToken is IERC20 {
    string public constant name = "NegoToken";
    string public constant symbol = "NEB";
    uint8 public constant decimals = 8;
    uint256 public constant INITIAL_SUPPLY = 150000000 * 10 **8;
    uint256 public totalSupply;
    mapping(address => uint) balances;

    constructor() public {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }

    // function transfer(address _to, uint256 _value) public returns (bool) {
    //     return super.transfer(_to, _value);
    // }

    // function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    //     return super.transferFrom(_from, _to, _value);
    // }

    // function approve(address _spender, uint256 _value) public returns (bool) {
    //     return super.approve(_spender, _value);
    // }

    // function allowance(address _owner, address _spender) public view returns ( uint256 ) {
    //     return super.allowance(_owner, _spender);
    // }

    
}