// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    
    AggregatorV3Interface internal priceFeed;
    mapping (address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;

    constructor() {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    function getPrice() public view returns (uint256){
        (, int price,,,) = priceFeed.latestRoundData();
        return uint256(price * 10000000000);
    }

    function getVersion() public view returns (uint256){
        return priceFeed.version();
    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount)/1000000000000000000.00;
        return ethAmountInUsd;
    }

    function fund() public payable {
        uint256 miniUSD = 50*10**18;
        require (getConversionRate(msg.value) >= miniUSD, "You need to spend more than 50USD");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function withdraw() payable public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }   
}
