pragma solidity ^0.4.24;

import "github.com/oraclize/ethereum-api/oraclizeAPI_0.5.sol";

interface Interface {
    function strConcat(string _a, string _b, string _c, string _d, string _e) returns (string);
    function strConcat(string _a, string _b, string _c, string _d) returns (string);
    function strConcat(string _a, string _b, string _c) returns (string);
    function strConcat(string _a, string _b) returns (string);
}

contract YoutubeCounter is usingOraclize {

    string viewsCount;
    bytes32 oraclizeID;
    uint amount;
    uint balance;
    address owner;
    address beneficiary;
    uint PayPerView;
    string videoaddress;
    uint viewCount;
    uint idx;
    
    mapping(address => index_map[]) public index;
    mapping(uint => transaction) public transaction_rec;

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
    
   constructor() {
       owner = msg.sender;
   }
   
    function YoutubeViews(string _videoaddress, address _beneficiary, uint _PayPerView) public payable {
        beneficiary = _beneficiary;
        PayPerView = _PayPerView;
        videoaddress = _videoaddress;
        string memory query = strConcat('html(',videoaddress,').xpath(//*[contains(@class, "watch-view-count")]/text())');
        oraclizeID = oraclize_query("URL", query);
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) revert();

        viewsCount = result;
        viewCount = stringToUint(result);
        amount = viewCount * PayPerView * 1000000000;
        balance = address(msg.sender).balance;
        
        if (balance < amount) {
            amount = balance;
        }
    }
    
    function ethertransfer() payable {
        beneficiary.transfer(amount);
        
        index[beneficiary].push(index_map(idx + 1));
        idx++;
        transaction_rec[idx].blocknum = block.number;
        transaction_rec[idx].blocktime = block.timestamp;
        transaction_rec[idx].viewrate = PayPerView;
        transaction_rec[idx].viewcounter = viewCount;
        transaction_rec[idx].receiver = beneficiary;
        transaction_rec[idx].amount_of_transfer = amount;
        transaction_rec[idx].targetaddress = videoaddress;
    }
    
    function () payable {
        
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
