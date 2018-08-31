pragma solidity ^0.4.24;

import "github.com/oraclize/ethereum-api/oraclizeAPI_0.5.sol";
import "./ERC20.sol";


interface Interface {
        function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
}

contract YoutubeViews is usingOraclize, StandardToken {

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
    
    address public tokenaddress = 0xee9c3a618d8786c6343fc079a75462839b3a673b;

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

    Interface Token = Interface(tokenaddress);
    
    constructor() {
        owner = msg.sender;
    }

    function YoutubeViewInfo(string _videoaddress, address _beneficiary, uint _PayPerView) public payable {
        require(owner == msg.sender);
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

    function tokentransfer() public {
        require(msg.sender == owner);
        Token.transferFrom(tokenaddress, beneficiary, amount);

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

