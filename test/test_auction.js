const Auction = artifacts.require("./Auction.sol");
const AuctionFactory = artifacts.require("./AuctionFactory.sol");
const Web3 = require('web3');
const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:9545'));


function timeout(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

contract('AuctionFactory', async(accounts) => {
    it('두명의 입찰자 중에서 낙찰자 선정', () => AuctionFactory.deployed()
    .then(async (instance) => {
    
    /**
     * 10초간 열려있는 경매 초기값 1ether
     * 
     */
        const accounts = await web3.eth.getAccounts();
        await instance.createAuction( 10, web3.utils.toWei('1','ether'));

        //경매 인스터스
        const auctionAddress = await instance.getAuctionAddresses();
        const auction = await Auction.at(auctionAddress[0]);

        console.log(`auctionAddress = > ${auctionAddress[0]}`);
       
        const owner = await auction.owner.call();
        assert.equal(accounts[0], owner);

        // 경매자, 입찰금액 등 초기화
        let bidders = [];
        let bidAmounts = [];
        let bidStakes = [];

    
        await timeout(3000);

        // 입찰금 
        await auction.stake({
            from: accounts[1],
            value:web3.utils.toWei('1','ether')
        });

        await auction.stake(
            {
                from: accounts[2],
                value:web3.utils.toWei('2','ether')
            }
        );

        // 첫번째 입찰자
        await auction.bid(web3.utils.toWei('1','ether'), {from:accounts[1]});
        let hasBidded = await auction.hasBidded(accounts[1]);
        bidders.push(accounts[1]);
        assert.equal(hasBidded, true);

        // 두번째 입찰자
        await auction.bid(web3.utils.toWei('2','ether'), {from:accounts[2]});
        hasBidded = await auction.hasBidded(accounts[2]);
        bidders.push(accounts[2]);
        assert.equal(hasBidded, true);

        let bidderValue1 = await auction.getBidValueForBidder(accounts[1]); 
        let bidderStake1 = await auction.getStakeOfBidder(accounts[1]);
        bidAmounts.push(bidderValue1); 
        bidStakes.push(bidderStake1);
        
        console.log(`첫번째 입찰자 ${web3.utils.fromWei(bidderValue1, 'ether')} ether`);
        console.log(`첫번째 입찰자 입찰금 ${web3.utils.fromWei(bidderStake1, 'ether')} ether`);

        let bidderValue2 = await auction.getBidValueForBidder(accounts[2]); 
        let bidderStake2 = await auction.getStakeOfBidder(accounts[2]); 
        bidAmounts.push(bidderValue2); 
        bidStakes.push(bidderStake2);
        
        console.log(`두번째 입찰자 ${web3.utils.fromWei(bidderValue2, 'ether')} ether`);
        console.log(`두번째 입찰자금 ${web3.utils.fromWei(bidderStake2, 'ether')} ether`);

        await timeout(3000);

        //경매 마감
        await auction.endAuction({ from:accounts[0]});
        let auctionStatus = await auction.state.call();
        console.log(`경매진행상태 ==> ${auctionStatus}`)
        assert.equal(auctionStatus, 1);

        //account
       
        console.log(`입찰자 => ${bidders}`);
        console.log(`입찰금 => ${bidAmounts}`);
        console.log(`입찰금 => ${bidStakes}`);
        
        //calculate winner
    //    let [winner, amount] = await auction.getHighestBidder(bidders, bidAmounts, bidStakes);

        let winner = bidders[1];
        let amount = bidAmounts[1];

        console.log(`낙찰자 ==> ${winner}`);
        console.log(`낙찰금액 ==> ${amount}`);

        // 낙찰자 수정
        await auction.updateWinner(winner, amount);
        auctionStatus = await auction.state.call();
        assert.equal(auctionStatus, 2);

        // 낙찰자 확인
        const checkWinner = await auction.getWinner();
        console.log(`checkWinner => ${checkWinner}`)
        assert.equal(winner, checkWinner);

        // 참여자 금액 되돌려주기
         await auction.withdraw({ from : accounts[1] } );
    //     // await auction.withdraw({ from : accounts[2] } );

    //     // //claim winngs 
      await auction.claimReward( { from: accounts[2] }) ;
    //    await auction.claimEther( { from: accounts[2] }) ;

          let balance = await web3.eth.getBalance( auctionAddress[0] );

          console.log(`balance ==> ${balance}`)
    //      assert.equal(balance.toNumber(), 0 ); 
    
    await timeout(3000);



        

    }))
});