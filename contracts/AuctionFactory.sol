pragma solidity ^0.5.0;

import "./Auction.sol";

contract AuctionFactory {

    address[] public auctions;
    event newAuction(address auction);

    constructor() public {

    }
       
    //  경매 생성 함수 
    function createAuction(uint _auctionLength, uint _startingPrice)  public returns(address)
    {
        address auction = address(new Auction(msg.sender, _auctionLength, _startingPrice));
        auctions.push(auction);
        emit newAuction(auction);
      
    }

    function getAuctionAddresses() public view returns ( address[] memory) {
        return auctions;
    }
}