import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Error "mo:base/Error";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Bool "mo:base/Bool";
import Ledger "canister:ledger";
import Types "Types";

actor ReputationToken {
    let main_principal = Principal.fromText("ao6hk-x5zgr-aa6y2-zq5ei-meewq-doeim-hwbws-zzxql-rjtcc-hmabt-xqe");
    
    // null subaccount will be use as shared token wallet
    // 1 subaccount is incenitive subaccount
    // other subaccounts are branch ids
    let pre_mint_account = {
        owner = main_principal;
        subaccount = null;
    };

    // TODO get token consts from front-end
    let token_name = "aVa Shared reputation token";
    let token_symbol = "AVAS";
    let token_fee = 6;
    let max_supply = 1_000_000;
    let token_init_balance = 100_000;
    let min_burn_amount = 1;
    let decimals = 3; 

    func add_decimals(n: Nat): Nat{
        n * 10 ** decimals
    };

    //ledger part

  type Account = Ledger.Account; //{ owner : Principal; subaccount : ?Subaccount };
  type Subaccount = Ledger.Subaccount; //Blob;
  type Tokens = Ledger.Tokens; //Nat;
  type Memo = Ledger.Memo;
  type Timestamp = Ledger.Timestamp; //Nat64;
  type Duration = Nat64;
  type TxIndex = Ledger.TxIndex;
  type TxLog = Buffer.Buffer<Transaction>;

  type Value = Ledger.Value;

  let permittedDriftNanos : Duration = 60_000_000_000;
  let transactionWindowNanos : Duration = 24 * 60 * 60 * 1_000_000_000;
  let defaultSubaccount : Subaccount = Array.freeze<Nat8>(Array.init(32, 0 : Nat8));

  type Operation = {
    #Approve : Approve;
    #Transfer : Transfer;
    #Burn : Transfer;
    #Mint : Transfer;
  };

  type CommonFields = {
    memo : ?Memo;
    fee : ?Tokens;
    created_at_time : ?Timestamp;
  };

  type Approve = CommonFields and {
    from : Account;
    spender : Principal;
    amount : Int;
    expires_at : ?Nat64;
  };

  type TransferSource = {
    #Init;
    #Icrc1Transfer;
    #Icrc2TransferFrom;
  };

  type Transfer = CommonFields and {
    spender : Principal;
    source : TransferSource;
    to : Account;
    from : Account;
    amount : Tokens;
  };

  type Allowance = Ledger.Allowance;

  type Transaction = {
    operation : Operation;
    // Effective fee for this transaction.
    fee : Tokens;
    timestamp : Timestamp;
  };

  type DeduplicationError = {
    #TooOld;
    #Duplicate : { duplicate_of : TxIndex };
    #CreatedInFuture : { ledger_time : Timestamp };
  };

  type CommonError = {
    #InsufficientFunds : { balance : Tokens };
    #BadFee : { expected_fee : Tokens };
    #TemporarilyUnavailable;
    #GenericError : { error_code : Nat; message : Text };
  };

  type BurnError = CommonError or {
    #WrongBranch : { current_branch : Nat8; target_branch : Nat8};
    #WrongDocument : { current_branch : Nat8; document : Types.DocId };
    #InsufficientReputation : { current_branch : Nat8; balance : Tokens };
    #DocumentReputationReductionLimitReached : { document : Types.DocId };
  };

  type TransferError = Ledger.TransferError;

  type ApproveError = Ledger.ApproveError;

  type TransferFromError = Ledger.TransferFromError;

  public type Result<T, E> = { #Ok : T; #Err : E };

// Demo

public shared({ caller }) func demo() : async Text {
  var res = "Start. \n";
  let accWithsub = await addSubaccount(caller, 0);
  let sub = accWithsub.subaccount;
  let subText : Text = switch (sub) {
    case null "null";
    case (?s) {
      var t : Text = "";
      for (item in s.vals()) {
        t := t # Nat8.toText(item) # " ";
      };
      t;
    };
  };
  res := res # " owner: " # Principal.toText(accWithsub.owner) # " ; subaccount: " # subText # " \n";
  let minting_acc : ?Ledger.Account = await Ledger.icrc1_minting_account();
  let to : Account = accWithsub;
  let null_acc : Ledger.Account = { owner = Principal.fromText("aaaaa-aa"); subaccount = null}; 
  var m_sub : Ledger.Subaccount= [];
  let m_acc = switch (minting_acc) {
    case null null_acc;
    case (?acc) { 
      m_sub := switch (acc.subaccount) {
        case null [];
        case (?sub) sub;
      };
        acc;
    };
  };
  var m_sub_text = "";
  for(s in m_sub.vals()) {
    m_sub_text := m_sub_text # Nat8.toText(s);
  };
  // let respose : Bool = await awardToken({ owner = m_acc.owner; subaccount = sub }, to, 1);
  res := res # "From: owner: " # Principal.toText(m_acc.owner) # ", subacc: " # m_sub_text;
  let respose = await Ledger.icrc2_transfer_from({
      from = m_acc;
      to = to;
      amount = 1;
      fee = null;
      memo = null;
      created_at_time = null;     
    });
  let res_transfer : Text = switch (respose) {
    case (#Ok(id)) " Success. Transaction id " # Nat.toText(id);
    case (#Err(err)) {
      var error_msg = switch (err) {
        case (#BadBurn {min_burn_amount}) {
          "BadBurn with minimum burn amount: " # Nat.toText(min_burn_amount)
        };
        case (#BadFee {expected_fee}) {
          "BadFee with expected fee: " # Nat.toText(expected_fee)
        };
        case (#CreatedInFuture {ledger_time}) {
          "CreatedInFuture with ledger time: " # Nat64.toText(ledger_time)
        };
        case (#Duplicate {duplicate_of}) {
          "Duplicate of transaction index: " # Nat.toText(duplicate_of)
        };
        case (#GenericError {error_code; message}) {
          "GenericError with code: " # Nat.toText(error_code) # ", message: " # message
        };
        case (#InsufficientFunds {balance}) {
          "InsufficientFunds with balance: " # Nat.toText(balance)
        };
        case (#InsufficientAllowance {allowance:Nat}) {
          "InsufficientAllowance: " # Nat.toText(allowance);
        };
        case (#TemporarilyUnavailable) {
          "TemporarilyUnavailable"
        };
        case (#TooOld) {
          "TooOld"
        };
      };
      error_msg;
    };
  };
  res := res # " Result of transfer to subaccount: " # res_transfer;

  let new_balance = await Ledger.icrc1_balance_of(to);
  res := res # ". New balance = " # Nat.toText(new_balance);

  return res;
};

// Subaccounts

public func createSubaccountByBranch(branch: Nat8): async Ledger.Subaccount {
  Array.freeze<Nat8>(Array.init(32, branch : Nat8))
};

public func addSubaccount(user : Principal, branch : Nat8) : async Account {
  let sub = await createSubaccountByBranch(branch);
  let newAccount : Account = { owner = user; subaccount = ?sub };
};


// Logic part

  public shared ({ caller }) func getSupply() : async Tokens { await Ledger.icrc1_total_supply();};

  public shared ({ caller }) func getMetdata() : async [(Text, Value)]  { await Ledger.icrc1_metadata();};

  public shared ( { caller } ) func userBalanceByBranch(user : Principal, branch : Nat8) : async Nat {
    let sub = await createSubaccountByBranch(branch);
    let addSub = { owner = user; subaccount = ?sub };
    await Ledger.icrc1_balance_of(addSub);
};

  // Increase reputation
  // using pre_mint_account as from

  public func awardToken(to : Ledger.Account, amount : Ledger.Tokens) : async Result<TxIndex, TransferFromError> {
    let memo : ?Ledger.Memo = null;
    let fee : ?Ledger.Tokens = null;
    let created_at_time : ?Ledger.Timestamp = ?Nat64.fromIntWrap(Time.now());
    let res = await Ledger.icrc2_transfer_from({
      from =  pre_mint_account;
      to = to;
      amount = amount;
      fee = fee;
      memo = memo;
      created_at_time = created_at_time;     
    });
  };

  public func sendToken(from : Ledger.Account, to : Ledger.Account, amount : Ledger.Tokens) : async Result<TxIndex, TransferFromError> {
    let sender : ?Ledger.Subaccount = from.subaccount;
    let memo : ?Ledger.Memo = null;
    let fee : ?Ledger.Tokens = null;
    let created_at_time : ?Ledger.Timestamp = ?Nat64.fromIntWrap(Time.now());
    let a : Ledger.Tokens = amount;
    let acc : Ledger.Account = to;
    let res = await Ledger.icrc2_transfer_from({
      from = from;
      to = to;
      amount = amount;
      fee = fee;
      memo = memo;
      created_at_time = created_at_time;     
    });
    ignore await awardIncenitive(from, 1);
    res;
  };

  // Decrease reputation
  public func burnToken(from : Ledger.Account, amount : Ledger.Tokens) : async Result<TxIndex, TransferFromError> {
    let sender : ?Ledger.Subaccount = from.subaccount;
    let memo : ?Ledger.Memo = null;
    let fee : ?Ledger.Tokens = ?0;
    let created_at_time : ?Ledger.Timestamp = ?Nat64.fromIntWrap(Time.now());
    let a : Ledger.Tokens = amount;
    let res = await Ledger.icrc2_transfer_from({
      from = from;
      to = pre_mint_account;
      amount = amount;
      fee = fee;
      memo = memo;
      created_at_time = created_at_time;     
    });
  };

    public func askForBurn(
      requester : Ledger.Account, 
      from : Ledger.Account, 
      document : Types.DocId, 
      amount : Ledger.Tokens
      ) : async Result<TxIndex, TransferError> {
      // check requester's balance
      // check from balance
      // check document's tags for equity to requester's subaccount
      // burn requester's token
      // burn from token
      // create history log

      return #Err(#TemporarilyUnavailable);
    };

  // Incenitive
    public func awardIncenitive(to : Ledger.Account, amount : Ledger.Tokens) : async Result<TxIndex, TransferFromError>  {
    let memo : ?Ledger.Memo = null;
    let created_at_time : ?Ledger.Timestamp = ?Nat64.fromIntWrap(Time.now());
    let receiver : Ledger.Account = { owner = to.owner; subaccount = ?(await createSubaccountByBranch(1))};
    let res = await Ledger.icrc2_transfer_from({
      from =  pre_mint_account;
      to = receiver;
      amount = amount;
      fee = ?0;
      memo = memo;
      created_at_time = created_at_time;     
    });
  };

}