contract SimpleAuction {
    // Parameters of the auction. Times are either
    // absolute unix timestamps (seconds since 1970-01-01)
    // or time periods in seconds.
    address public beneficiary;
    uint public auctionStart;
    uint public biddingTime;

    // Current state of the auction.
    address public highestBidder;
    uint public highestBid;

    // Set to true at the end, disallows any change
    bool ended;

    // Events that will be fired on changes.
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    // The following is a so-called natspec comment,
    // recognizable by the three slashes.
    // It will be shown when the user is asked to
    // confirm a transaction.

    /// Create a simple auction with `_biddingTime`
    /// seconds bidding time on behalf of the
    /// beneficiary address `_beneficiary`.
    function SimpleAuction(uint _biddingTime,
                           address _beneficiary) {
        beneficiary = _beneficiary;
        auctionStart = now;
        biddingTime = _biddingTime;
    }

    /// Bid on the auction with the value sent
    /// together with this transaction.
    /// The value will only be refunded if the
    /// auction is not won.
    function bid() {
        // No arguments are necessary, all
        // information is already part of
        // the transaction.
        if (now > auctionStart + biddingTime)
            // Revert the call if the bidding
            // period is over.
            throw;
        if (msg.value <= highestBid)
            // If the bid is not higher, send the
            // money back.
            throw;
        if (highestBidder != 0)
            highestBidder.send(highestBid);
        highestBidder = msg.sender;
        highestBid = msg.value;
        HighestBidIncreased(msg.sender, msg.value);
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.
    function auctionEnd() {
        if (now <= auctionStart + biddingTime)
            throw; // auction did not yet end
        if (ended)
            throw; // this function has already been called
        AuctionEnded(highestBidder, highestBid);
        // We send all the money we have, because some
        // of the refunds might have failed.
        beneficiary.send(this.balance);
        ended = true;
    }

    function () {
        // This function gets executed if a
        // transaction with invalid data is sent to
        // the contract or just ether without data.
        // We revert the send so that no-one
        // accidentally loses money when using the
        // contract.
        throw;
    }
}
