type token_id = nat

type auction = {
    startTime : timestamp;
    endTime : timestamp;
    owner : address;
    bidIncrement : nat;
    highestBid : tez;
    highestBidOwner : address;
    canceled : bool;
    fundsByBidder : (address, tez) map;
}

type proposal_param = {
    token_id : token_id;
    delay : nat;
    bidIncrement : nat
}

type bid_param = {
    token_id : token_id;
    bid : tez
}

type withdraw_param = {
    token_id : token_id;
}

type cancel_param = {
    token_id : token_id;
}

type param_auction = 
| Propose of proposal_param
| Bid of bid_param
| Withdraw of withdraw_param
| Cancel of cancel_param

type auction_storage =  {
    ledger : (token_id, address) big_map;
    auctions : (token_id, auction) big_map;
}

let propose (param, store : proposal_param * auction_storage) : (operation list) * auction_storage = 
    match Big_map.find_opt param.token_id store.ledger with
    | None -> (failwith("token not owned") : (operation list) * auction_storage)
    | Some o -> 
        if o = Tezos.sender then
            let new_auctions = Big_map.add param.token_id {
                startTime=Tezos.now;
                endTime=Tezos.now + int(param.delay);
                owner=Tezos.sender;
                bidIncrement=param.bidIncrement;
                highestBid=0mutez;
                highestBidOwner=Tezos.sender;
                canceled=false;
                fundsByBidder=(Map.empty :(address, tez) map ) 
                } store.auctions in 
            ([] : operation list), { store with auctions=new_auctions }
        else
            (failwith("token not owned by sender") : (operation list) * auction_storage)

let bid (param, store : bid_param * auction_storage) : (operation list) * auction_storage = 
// TODO must verify not owner
// TODO verify timestamp
// TODO verify canceled
// TODO use ? bidincrement
    let new_auction = match Big_map.find_opt param.token_id store.auctions with
    | None -> (failwith("this token id is not for sale") : auction)
    | Some a -> 
        if (Tezos.amount = param.bid) then 
            let new_bid = match Map.find_opt Tezos.sender a.fundsByBidder with
            | None -> param.bid
            | Some v -> v + param.bid
            in
            if new_bid <= a.highestBid then
                (failwith("bid too small, not taken into account") : auction)
            else
                let new_fundsByBidder = Map.update Tezos.sender (Some(new_bid)) a.fundsByBidder in
                // let new_fundsByBidder = match Map.find_opt Tezos.sender a.fundsByBidder with
                // | None -> Map.add Tezos.sender param.bid a.fundsByBidder
                // | Some v -> Map.update Tezos.sender (Some(v+param.bid)) a.fundsByBidder
                // in
                { a with fundsByBidder=new_fundsByBidder; highestBid=new_bid; highestBidOwner=Tezos.sender;  }
        else
            (failwith("amount different bid") : auction)
    in
    let new_auctions = Big_map.update param.token_id (Some(new_auction)) store.auctions in
    ([] : operation list), { store with auctions=new_auctions }

let withdraw (param, store : withdraw_param * auction_storage) : (operation list) * auction_storage = 
// TODO verify ended 
// TODO verify canceled
    let new_auction, bal : auction * tez = match Big_map.find_opt param.token_id store.auctions with
    | None -> (failwith("this token id is not for sale") :  auction * tez)
    | Some a -> 
        if a.highestBidOwner = Tezos.sender then
            (failwith("Highest bidder cannot withdraw his bid"): auction * tez)
        else
            let bal : tez = match Map.find_opt Tezos.sender a.fundsByBidder with
            | None -> (failwith("Sender did not bid") : tez)
            | Some v -> v
            in
            let new_fundsByBidder = Map.remove Tezos.sender a.fundsByBidder in
            ({ a with fundsByBidder=new_fundsByBidder; }, bal)
    in
    let receiver : unit contract = match (Tezos.get_contract_opt Tezos.sender: unit contract option) with
    | Some (contract) -> contract
    | None -> (failwith ("Not a contract") : unit contract)
    in
    let op : operation = Tezos.transaction unit bal receiver in
    let new_auctions = Big_map.update param.token_id (Some(new_auction)) store.auctions in
    [op], {store with auctions=new_auctions }

let cancel (param, store : cancel_param * auction_storage) : (operation list) * auction_storage = 
// TODO verify only owner
// TODO verify before end
    let new_auction : auction = match Big_map.find_opt param.token_id store.auctions with
    | None -> (failwith("this token id is not for sale") :  auction)
    | Some a -> { a with canceled=true }
    in
    let new_auctions = Big_map.update param.token_id (Some(new_auction)) store.auctions in
    ([] : operation list), {store with auctions=new_auctions }

let auction_main (p,s : param_auction * auction_storage) : (operation list) * auction_storage =
    match p with
    | Propose m -> propose(m, s)
    | Bid m -> bid(m, s)
    | Withdraw m -> withdraw(m, s)
    | Cancel m -> cancel(m, s)



// ligo compile-contract auction.mligo auction_main
// ligo compile-storage auction.mligo auction_main '{ ledger=(Big_map.empty : (token_id, address) big_map); auctions=(Big_map.empty : (token_id, auction) big_map) }'

// PROPOSE
// ligo compile-storage auction.mligo auction_main '{ ledger=Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); auctions=(Big_map.empty : (token_id, auction) big_map) }'
// ligo compile-parameter auction.mligo auction_main 'Propose({token_id=1n; delay=86400n; bidIncrement=1n})'
// ligo dry-run auction.mligo auction_main 'Propose({token_id=1n; delay=86400n; bidIncrement=1n})' '{ ledger=Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); auctions=(Big_map.empty : (token_id, auction) big_map) }'
// ligo dry-run --sender=tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv auction.mligo auction_main 'Propose({token_id=1n; delay=86400n; bidIncrement=1n})' '{ ledger=Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); auctions=(Big_map.empty : (token_id, auction) big_map) }'

// BID
// ligo compile-storage auction.mligo auction_main '{ ledger=Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); auctions=Big_map.literal([(1n,{startTime=("2020-09-30t12:16:00Z" : timestamp); endTime=("2020-10-01t12:16:00Z" : timestamp); owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); bidIncrement=2n; highestBid=0n; highestBidOwner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); canceled=false; fundsByBidder=(Map.empty :(address, tez) map )})]) }'
// ligo compile-parameter auction.mligo auction_main 'Bid({token_id=1n;bid=3000mutez})'
// ligo dry-run auction.mligo auction_main 'Bid({token_id=1n;bid=3000mutez})' '{ ledger=Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); auctions=Big_map.literal([(1n,{startTime=("2020-09-30t12:16:00Z" : timestamp); endTime=("2020-10-01t12:16:00Z" : timestamp); owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); bidIncrement=2n; highestBid=0n; highestBidOwner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); canceled=false; fundsByBidder=(Map.empty :(address, tez) map )})]) }'
// ligo dry-run --amount=0.003 auction.mligo auction_main 'Bid({token_id=1n;bid=3000mutez})' '{ ledger=Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); auctions=Big_map.literal([(1n,{startTime=("2020-09-30t12:16:00Z" : timestamp); endTime=("2020-10-01t12:16:00Z" : timestamp); owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); bidIncrement=2n; highestBid=0n; highestBidOwner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); canceled=false; fundsByBidder=(Map.empty :(address, tez) map )})]) }'

// WITHDRAW
// ligo compile-storage auction.mligo auction_main '{ ledger=Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); auctions=Big_map.literal([(1n,{startTime=("2020-09-30t12:16:00Z" : timestamp); endTime=("2020-10-01t12:16:00Z" : timestamp); owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); bidIncrement=2n; highestBid=0mutez; highestBidOwner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); canceled=false; fundsByBidder=Map.literal([(("tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v":address), 2000mutez); (("tz1L738ifd66ah69PrmKAZzckvvHnbcSeqjf":address), 3000mutez)]) })]) }'
// ligo compile-parameter auction.mligo auction_main 'Withdraw({token_id=1n})'
// ligo dry-run auction.mligo auction_main 'Withdraw({token_id=1n})' '{ ledger=Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); auctions=Big_map.literal([(1n,{startTime=("2020-09-30t12:16:00Z" : timestamp); endTime=("2020-10-01t12:16:00Z" : timestamp); owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); bidIncrement=2n; highestBid=0mutez; highestBidOwner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); canceled=false; fundsByBidder=Map.literal([(("tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v":address), 2000mutez); (("tz1L738ifd66ah69PrmKAZzckvvHnbcSeqjf":address), 3000mutez)]) })]) }'
// ligo dry-run --sender=tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v auction.mligo auction_main 'Withdraw({token_id=1n})' '{ ledger=Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); auctions=Big_map.literal([(1n,{startTime=("2020-09-30t12:16:00Z" : timestamp); endTime=("2020-10-01t12:16:00Z" : timestamp); owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); bidIncrement=2n; highestBid=0mutez; highestBidOwner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); canceled=false; fundsByBidder=Map.literal([(("tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v":address), 2000mutez); (("tz1L738ifd66ah69PrmKAZzckvvHnbcSeqjf":address), 3000mutez)]) })]) }'


// CANCEL
// ligo compile-storage auction.mligo auction_main '{ ledger=Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); auctions=Big_map.literal([(1n,{startTime=("2020-09-30t12:16:00Z" : timestamp); endTime=("2020-10-01t12:16:00Z" : timestamp); owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); bidIncrement=2n; highestBid=0mutez; highestBidOwner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); canceled=false; fundsByBidder=Map.literal([(("tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v":address), 2000mutez); (("tz1L738ifd66ah69PrmKAZzckvvHnbcSeqjf":address), 3000mutez)]) })]) }'
// ligo compile-parameter auction.mligo auction_main 'Cancel({token_id})'
// ligo dry-run auction.mligo auction_main 'Cancel({token_id=1n})' '{ ledger=Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); auctions=Big_map.literal([(1n,{startTime=("2020-09-30t12:16:00Z" : timestamp); endTime=("2020-10-01t12:16:00Z" : timestamp); owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); bidIncrement=2n; highestBid=0mutez; highestBidOwner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); canceled=false; fundsByBidder=Map.literal([(("tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v":address), 2000mutez); (("tz1L738ifd66ah69PrmKAZzckvvHnbcSeqjf":address), 3000mutez)]) })]) }'
// ligo dry-run --sender="tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv"  auction.mligo auction_main 'Cancel({token_id=1n})' '{ ledger=Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); auctions=Big_map.literal([(1n,{startTime=("2020-09-30t12:16:00Z" : timestamp); endTime=("2020-10-01t12:16:00Z" : timestamp); owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); bidIncrement=2n; highestBid=0mutez; highestBidOwner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); canceled=false; fundsByBidder=Map.literal([(("tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v":address), 2000mutez); (("tz1L738ifd66ah69PrmKAZzckvvHnbcSeqjf":address), 3000mutez)]) })]) }'
