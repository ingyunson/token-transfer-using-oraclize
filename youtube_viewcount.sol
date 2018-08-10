pragma solidity ^0.4.24;

import "github.com/oraclize/ethereum-api/oraclizeAPI_0.5.sol";
import "github.com/ingyunson/token-transfer-using-orzclize/ERC20.sol";

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
contract OraclizeTestToken is usingOraclize, StandardToken {

    string public name; // solium-disable-line uppercase
    string public symbol; // solium-disable-line uppercase
    uint8 public decimals; // solium-disable-line uppercase
    uint256 public INITIAL_SUPPLY;
    string public viewsCount;
    bytes32 public oraclizeID;
    uint public amount;
    uint public balance;
    address public owner;
    address public beneficiary;
    uint public PayPerView;
    string public videoaddress;

    event NewYoutubeViewsCount(string views);

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  function OraclizeTestToken(string _name, string _symbol, uint8 _decimals, uint256 _initial_supply) public {
      name = _name;
      symbol = _symbol;
      decimals = _decimals;
      INITIAL_SUPPLY = _initial_supply * (10 ** uint256(decimals));
    totalSupply_ = INITIAL_SUPPLY;
    balances[this] = INITIAL_SUPPLY;
    emit Transfer(0x0, this, INITIAL_SUPPLY);
  }
    
    function YoutubeViews(string _videoaddress, address _beneficiary, uint _PayPerView) public payable {
        owner = msg.sender;
        beneficiary = _beneficiary;
        PayPerView = _PayPerView;
        videoaddress = _videoaddress;
        string memory query = strConcat('html(',videoaddress,').xpath(//*[contains(@class, "watch-view-count")]/text())');
        oraclizeID = oraclize_query("URL", query);
    }

    function __callback(bytes32 myid, string result) public {
        if (msg.sender != oraclize_cbAddress()) revert();

        viewsCount = result;
        NewYoutubeViewsCount(viewsCount);
        uint viewCount = stringToUint(result);
        // do something with viewsCount. like tipping the author if viewsCount > X?
        amount = viewCount * PayPerView * 1000000000;
        balance = address(msg.sender).balance;
        
        if (balance < amount) {
            amount = balance;
        }
    }
    
    function () public payable {
        require(beneficiary != address(0));
        require(amount <= balances[this]);
    
        // SafeMath.sub will throw if there is not enough balance.
        balances[this] = balances[this].sub(amount);
        balances[beneficiary] = balances[beneficiary].add(amount);
        emit Transfer(this, beneficiary, amount);
    }
    

    function refund() public {
        require(msg.sender == owner);
        
        uint balance = address(this).balance;
        if (balance > 0) {
            owner.transfer(balance);
        }
    }



    function stringToUint(string s) internal pure returns (uint result) {
        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }
    
    function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }
    function strConcat(string _a, string _b, string _c) internal pure returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }
    function strConcat(string _a, string _b) internal pure returns (string) {
        return strConcat(_a, _b, "", "", "");
    }
  }
