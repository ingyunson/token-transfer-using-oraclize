pragma solidity ^0.4.0;

import "github.com/oraclize/ethereum-api/oraclizeAPI_0.5.sol";

contract YoutubeViews is usingOraclize {

    string public viewsCount;
    bytes32 public oraclizeID;

    event NewYoutubeViewsCount(string views);

    function YoutubeViews() public payable {
        oraclizeID = oraclize_query("URL", 'html(https://www.youtube.com/watch?v=9bZkp7q19f0).xpath(//*[contains(@class, "watch-view-count")]/text())');
    }

    function __callback(bytes32 myid, string result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        viewsCount = result;
        NewYoutubeViewsCount(viewsCount);
        // do something with viewsCount. like tipping the author if viewsCount > X?
    }
}