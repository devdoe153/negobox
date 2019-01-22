pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

 */
contract Auction is ERC721{
  
//   경매과정 => 0 경매중, 1 계산중, 2 경매마감
    enum AuctionState { IN_PROGRESS, CALCULATING, COMPLETED }

// 참여자 구조체 
// 참여여부, 입찰금액
    struct Bidder {
        bool hasBidded;
        uint bidValue;
    }

    address public owner;
    uint public startTime;
    uint public endTime;
    address public winner;
    uint public startingPrice;
    uint public winningPrice;
    mapping (address=>Bidder) public bidders;
    mapping (address=>uint) public stakeAmounts;
    address[] public bidderAddresses;
    AuctionState public state;
    bool public rewardClaimed;
    
    constructor (address _owner, uint _auctionLength, uint _startingPrice)
    public 
    {
        owner = _owner;
        startingPrice = _startingPrice;
        startTime = now;
        endTime = startTime + _auctionLength * 1 seconds;
        state = AuctionState.IN_PROGRESS;

    }

// 이벤트 로그 표시
    event Bid(address bidder);
    event Winner(address winner, uint bidValue);

    modifier onlyNego() {
        require(msg.sender == address(0));
        _;
    }

    modifier isOwner() {
        require(msg.sender == owner) ;
        _;
    }

    function mintToken(address _to, uint _tokenId) public {
        super._mint(_to, _tokenId) ;
    }

// 계정별 입찰금액
    function stake() payable external {
        require(state == AuctionState.IN_PROGRESS) ;
        stakeAmounts[msg.sender] += msg.value;
    }

  /** 참여자 금액 되돌려주기
  */
    function withdraw() external {
        require(state == AuctionState.COMPLETED);
        require(stakeAmounts[msg.sender] > 0);
        uint amount = stakeAmounts[msg.sender];
        stakeAmounts[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

// 경매 참여하기
    function bid(uint _bidValue) public {
        require(now < endTime) ;
        require(stakeAmounts[msg.sender] >= startingPrice);
        bidders[msg.sender].bidValue = _bidValue;
        if(!(bidders[msg.sender].hasBidded)) {
            bidders[msg.sender].hasBidded  = true;
        }
        emit Bid(msg.sender);
    }

// 경매 마감 처리 
    function endAuction() external isOwner {
        require(state == AuctionState.IN_PROGRESS);
        // require(now >= endTime);
        state = AuctionState.CALCULATING;
    }

//  호출기준 가장 높은 금액 비교 ==> 오류로 실행안됨 iterator 오류
    function getHighestBidder(address[]  memory _bidders, uint[] memory  _bidAmounts, uint[]  memory _stakeAmounts)
    public pure returns (address, uint ) 
    {
        address highestBidder;
        uint highestBidAmount;
        for(uint i=0; i < _bidders.length; i++ ) {
            if((_bidAmounts[i] > highestBidAmount) && (_bidAmounts[i] <= _stakeAmounts[i])) {
                highestBidAmount = _bidAmounts[i];
                highestBidder = _bidders[i];
            }
        }
        return (highestBidder, highestBidAmount);
    }

// 낙찰자 수정
    function updateWinner(address _highestBidder, uint _highestBidAmount) public 
    {
        winner = _highestBidder ; 
        winningPrice = _highestBidAmount;
        state = AuctionState.COMPLETED;
        stakeAmounts[_highestBidder] -= winningPrice;
        emit Winner(_highestBidder, _highestBidAmount);
    }

// 낙찰금 청구
    function claimReward() external {
        require(state == AuctionState.COMPLETED);
        require(msg.sender == winner );
        require(!rewardClaimed);
        rewardClaimed = true;
        this.mintToken(msg.sender, endTime) ;
    }

// ether 청구
    function claimEther() external isOwner {
        require(state == AuctionState.COMPLETED);
        msg.sender.transfer(winningPrice);
    }
/*
* 사용자가 입찰했는지 확인.
*/
    function hasBidded(address _bidder) public view returns ( bool ) {
        return bidders[_bidder].hasBidded;
    }
/*
*  경매 참여 입찰가.
*/
    function getBidValueForBidder(address _bidder) public view returns (uint ) {
        require(hasBidded(_bidder), "사용자가 아직 입찰하지 않았습니다.");
        return bidders[_bidder].bidValue;
    }
/*
*  입찰자에게 걸린 ETHER 금액
*/
    function getStakeOfBidder(address _bidder) public view returns(uint) {
        return stakeAmounts[_bidder];
    }
/*
* 경매 우승자.
*/
    function getWinner() public view returns(address) {
        require(state == AuctionState.COMPLETED);
        return winner ;
    }

}