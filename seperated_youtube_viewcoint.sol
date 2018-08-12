pragma solidity ^0.4.24;

import "github.com/oraclize/ethereum-api/oraclizeAPI_0.5.sol";
import "github.com/ingyunson/token-transfer-using-orzclize/ERC20.sol";

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
contract YoutubeViews is usingOraclize, StandardToken {

    ERC _token;

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
   
    function my_contract(address tokenAddress) public {
        _token = ERC(tokenAddress);
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
    
    function tokentransfer() public payable {
        require(beneficiary != address(0));
        require(amount <= balances[this]);
    
        // SafeMath.sub will throw if there is not enough balance.
        balances[this] = balances[this].sub(amount);
        balances[beneficiary] = balances[beneficiary].add(amount);
        _token.transfer(beneficiary, amount);
        // emit Transfer(this, beneficiary, amount);       
    }
    
    function () public payable {

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
  
contract ERC {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function mul(uint256 a, uint256 b) internal pure returns (uint256);
    
  event Transfer(address indexed from, address indexed to, uint256 value);
  
}
