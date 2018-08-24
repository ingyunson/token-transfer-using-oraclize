pragma solidity ^0.4.24;

import "github.com/oraclize/ethereum-api/oraclizeAPI_0.5.sol";
import "./ERC20.sol";


interface Interface {
        function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
        function transfer(address _to, uint256 _value) public returns (bool);
        function transfercontract (address _to, uint256 _value) public returns (bool);
}

contract YoutubeViews is usingOraclize, StandardToken {

    string public viewsCount_1;
    string public viewsCount_2;
    bytes32 public oraclizeID_1;
    bytes32 public oraclizeID_2;
    uint public amount;
    uint public amount_before;
    uint public amount_after;
    uint public balance;
    address public owner;
    address public beneficiary;
    uint public PayPerView;
    string public videoaddress_1;
    string public videoaddress_2;
    address public tokenaddress = 0x2bbd69adf693dbcab658d473960d33d6b5525d4e;
    bool public timer = false;
    

    event NewYoutubeViewsCount(string views);

    Interface Token = Interface(tokenaddress);

    function YoutubeView_before(string _videoaddress) public payable {
        videoaddress_1 = _videoaddress;
        string memory query_1 = strConcat('html(',videoaddress_1,').xpath(//*[contains(@class, "watch-view-count")]/text())');
        oraclizeID_1 = oraclize_query("URL", query_1);
    }
    
    function YoutubeView_after(string _videoaddress) public payable {
        require(timer == false);
        videoaddress_2 = _videoaddress;
        string memory query_2 = strConcat('html(',videoaddress_2,').xpath(//*[contains(@class, "watch-view-count")]/text())');
        oraclizeID_2 = oraclize_query("URL", query_2);
        timer = true;
    }

    function __callback(bytes32 myid, string result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        if(timer == false) {
            viewsCount_1 = result;
            NewYoutubeViewsCount(viewsCount_1);
            uint viewCount_1 = stringToUint(result);
            // do something with viewsCount. like tipping the author if viewsCount > X?
            amount_before = viewCount_1 * PayPerView * 1000000000;
            balance = address(msg.sender).balance;
        
            if (balance < amount) {
                amount = balance;
            }
        }
        if (timer == true) {
            viewsCount_2 = result;
            NewYoutubeViewsCount(viewsCount_2);
            uint viewCount_2 = stringToUint(result);
            // do something with viewsCount. like tipping the author if viewsCount > X?
            amount_after = viewCount_2 * PayPerView * 1000000000;
            balance = address(msg.sender).balance;
            
            if (balance < amount) {
                amount = balance;
            }
             
        }
    }
    
    function timerswitch() {
        require(msg.sender == owner);
        if(timer == true) timer = false;
        if(timer == false) timer = true;
    }
    
    function autotransfer() public payable {
        amount = amount_after - amount_before;
        Token.transferFrom(tokenaddress, beneficiary, amount);
    }
    
    function transferFromTo(address _from, address _to, uint _value) public payable {
        amount = amount_after - amount_before;
        Token.transferFrom(_from, _to, _value);
    }
    
    function tokentransferTo(address _to, uint _value) public payable {
        amount = amount_after - amount_before;
        Token.transfer(_to, _value);
    }
    
    function tokentransferFromContract(address _to, uint _value) public payable {
        amount = amount_after - amount_before;
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

