pragma solidity ^0.5.0;

contract AuctionPricer {

    struct Pricer {
        bool hasPriced;
        bytes price;
    }

    mapping(address => Pricer) public pricers;
    uint public expireTime;
    uint public startingPrice;
 

    constructor(uint _length) public {
        expireTime = now + _length;
    }


    function sendPrice(bytes memory _price) public {
        require(!pricers[msg.sender].hasPriced);
        pricers[msg.sender].price = _price;
    }

    function getAveragePrice(uint[] memory _prices) public pure returns (uint) {
        uint sum;
        for( uint i = 0; i < _prices.length; i++ ) {
            sum += _prices[i];
        }

        return sum / _prices.length;
    }

    function updateStartingPrice(uint _price) public onlyNego {
        startingPrice = _price ;
    }

    function getPriceforUser(address _user) public view returns (bytes memory) {
        require(pricers[_user].hasPriced);
        return pricers[_user].price;
    }

    modifier onlyNego(){
        require(msg.sender == address(0));
        _;
    }
}