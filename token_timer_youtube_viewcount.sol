pragma solidity ^0.4.24;

import "github.com/oraclize/ethereum-api/oraclizeAPI_0.5.sol";
import "./ERC20.sol";


interface Interface {
    function strConcat(string _a, string _b, string _c, string _d, string _e) returns (string);
    function strConcat(string _a, string _b, string _c, string _d) returns (string);
    function strConcat(string _a, string _b, string _c) returns (string);
    function strConcat(string _a, string _b) returns (string);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
}

contract YoutubeViews is usingOraclize, StandardToken {

    string viewsCount_1;
    string viewsCount_2;
    bytes32 oraclizeID_1;
    bytes32 oraclizeID_2;
    uint amount;
    uint amount_before;
    uint amount_after;
    uint balance;
    address owner;
    address beneficiary;
    uint PayPerView;
    string videoaddress;
    bool public timer = false;
    uint viewCount_1;
    uint viewCount_2;
    uint idx;
    address public tokenaddress = 0x2bbd69adf693dbcab658d473960d33d6b5525d4e;

    mapping(address => index_map[]) public index;
    mapping(uint => transaction) public transaction_rec;

    event transfer(uint blockinfo_num, uint blockinfo_time, uint viewrate, uint viewcounter, address receiver, uint amount, string url);
    
    struct index_map {
        uint idx_num;
    }
    
    struct transaction {
        uint blocknum;
        uint blocktime;
        uint viewrate;
        uint viewcounter;
        address receiver;
        uint amount_of_transfer;
        string targetaddress;
    } 

    Interface Token = Interface(tokenaddress);

    function YoutubeView_setup(string _videoaddress, address _beneficiary, uint _PayPerView) public payable {
        videoaddress = _videoaddress;
        beneficiary = _beneficiary;
        PayPerView = _PayPerView;
        string memory query_1 = strConcat('html(',videoaddress,').xpath(//*[contains(@class, "watch-view-count")]/text())');
        oraclizeID_1 = oraclize_query("URL", query_1);
        timer = false;
    }
    function YoutubeView_timer() public payable {
        require(timer == false);
        string memory query_2 = strConcat('html(',videoaddress,').xpath(//*[contains(@class, "watch-view-count")]/text())');
        oraclizeID_2 = oraclize_query(120, "URL", query_2);
        timer = true;
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) revert();
        if (timer == false) {
            viewsCount_1 = result;
            viewCount_1 = stringToUint(result);
            // do something with viewsCount. like tipping the author if viewsCount > X?
            amount_before = viewCount_1 * PayPerView * 1000000000;
            balance = address(msg.sender).balance;
        
            if (balance < amount) {
                amount = balance;
            }
        
        } if (timer == true) {
            viewsCount_2 = result;
            viewCount_2 = stringToUint(result);
            // do something with viewsCount. like tipping the author if viewsCount > X?
            amount_after = viewCount_2 * PayPerView * 1000000000;
            balance = address(msg.sender).balance;
            timer = false;
            amount = amount_after - amount_before;
            
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
    
    function tokentransfer() public payable {
        Token.transferFrom(tokenaddress, beneficiary, amount);
        emit transfer(block.number, block.timestamp, PayPerView, viewCount, beneficiary, amount, videoaddress);
        
        index[beneficiary].push(index_map(idx + 1));
        idx++;
        transaction_rec[idx].blocknum = block.number;
        transaction_rec[idx].blocktime = block.timestamp;
        transaction_rec[idx].viewrate = PayPerView;
        transaction_rec[idx].viewcounter = viewCount_2 - viewCount_1;
        transaction_rec[idx].receiver = beneficiary;
        transaction_rec[idx].amount_of_transfer = amount;
        transaction_rec[idx].targetaddress = videoaddress;
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
}

