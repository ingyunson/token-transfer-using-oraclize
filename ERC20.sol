pragma solidity ^0.4.24;

import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
contract SimpleToken is StandardToken {

  string public constant name = "Token";
  string public constant symbol = "TOK";
  uint8 public constant decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** uint256(decimals));
  address public owner;
  mapping(address => bool) public allowedControllers;
  
 modifier onlyOwner() {
      require(msg.sender == owner);
      _;
  }
  
    function addControllers (address controller) onlyOwner {
        allowedControllers[controller]=true;
    }   

  constructor() public payable {
    _mint(msg.sender, INITIAL_SUPPLY);
    owner = msg.sender;
    addControllers(msg.sender);
  }
  
  function transfercontract (address _to, uint256 _value) public returns (bool) {
    require(allowedControllers[msg.sender] == true);
    require(_value <= balanceOf(this));
    require(_to != address(0));

    _burn(this, _value);
    _mint(_to, _value);
    emit Transfer(this, _to, _value);
    return true;
  }
  
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    require(allowedControllers[msg.sender] == true);
    require(_value <= balanceOf(_from));
    require(_to != address(0));

    _burn(_from, _value);
    _mint(_to, _value);
    emit Transfer(_from, _to, _value);
    return true;
  }
  
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(allowedControllers[msg.sender] == true);
    require(_value <= balanceOf(msg.sender));
    require(_to != address(0));

    _burn(msg.sender, _value);
    _mint(_to, _value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }
  
}
