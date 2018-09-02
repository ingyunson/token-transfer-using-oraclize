pragma solidity ^0.4.24;

import "github.com/oraclize/ethereum-api/oraclizeAPI_0.5.sol";

contract YoutubeViews is usingOraclize {

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
    
  constructor()  {
    owner = msg.sender;
    }

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
    
    function ethertransfer() {
        beneficiary.transfer(amount);
        
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
    
    function timerswitch() {
        require(msg.sender == owner);
        if (timer == false) timer = true;
        if (timer == true) timer = false; 
    }
    
    function () private {

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

