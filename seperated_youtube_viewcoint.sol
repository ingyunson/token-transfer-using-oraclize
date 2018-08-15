pragma solidity ^0.4.24;

import "github.com/oraclize/ethereum-api/oraclizeAPI_0.5.sol";
import "github.com/ingyunson/token-transfer-using-orzclize/ERC20.sol";


interface Interface {
        function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
        function transfer(address _to, uint256 _value) public returns (bool);
        function transfercontract (address _to, uint256 _value) public returns (bool);
}

contract YoutubeViews is usingOraclize, StandardToken {

    string public viewsCount;
    bytes32 public oraclizeID;
    uint public amount;
    uint public balance;
    address public owner;
    address public beneficiary;
    uint public PayPerView;
    string public videoaddress;
    mapping(address => bool) public allowedControllers;
    address public tokenaddress = 0x7d6b3d2de542b7d3161141324a5c40afbef02339;

    event NewYoutubeViewsCount(string views);

    Interface Token = Interface(tokenaddress);

  modifier onlyOwner() {
      require(msg.sender == owner);
      _;
  }
  
    function addControllers (address controller) onlyOwner {
        allowedControllers[controller]=true;
    }   

    modifier byControllers() {
        require(allowedControllers[msg.sender] == true);
        _;
    }

    constructor() public payable {
        owner = msg.sender;
        addControllers(msg.sender);
    }

    function YoutubeViewInfo(string _videoaddress, address _beneficiary, uint _PayPerView) public payable {
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
    
    
    function autotransfer() public byControllers payable {
        Token.transferFrom(tokenaddress, beneficiary, amount);
    }
    
    function transferFromTo(address _from, address _to, uint _value) public byControllers payable {
        Token.transferFrom(_from, _to, _value);
    }
    
    function tokentransferTo(address _to, uint _value) public byControllers payable {
        Token.transfer(_to, _value);
    }
    
    function tokentransferFromContract(address _to, uint _value) public byControllers payable {
        Token.transfercontract(_to, _value);
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

