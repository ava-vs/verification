import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
// import T "Token";
import Time "mo:base/Time";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Error "mo:base/Error";
import Int "mo:base/Int";
// import ICRC1 "../../icrc1/src/ICRC1";
import Ledger "canister:ledger";

actor ReputationToken {
    let main_principal = Principal.fromText("ao6hk-x5zgr-aa6y2-zq5ei-meewq-doeim-hwbws-zzxql-rjtcc-hmabt-xqe");
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

  type TransferError = Ledger.TransferError;

  type ApproveError = Ledger.ApproveError;

  type TransferFromError = Ledger.TransferFromError;

  public type Result<T, E> = { #Ok : T; #Err : E };

// Subaccounts

public func createSubaccountByBranch(branch: Nat8): async Ledger.Subaccount {
  // let vararray : [var Nat8]= Array.init<Nat8>(1, branch);
  // let array = Array.freeze<Nat8>(vararray);
  // let res: Ledger.Subaccount = array;
  Array.freeze<Nat8>(Array.init(32, branch : Nat8))
};

public func addSubaccount(user : Principal, branch : Nat8) : async Account {
  let sub = await createSubaccountByBranch(branch);
  let newAccount : Account = { owner = user; subaccount = ?sub };
};


// Logic part

  public shared ({ caller }) func getSupply() : async Tokens { await Ledger.icrc1_total_supply();};

  public shared ({ caller }) func getMetdata() : async [(Text, Value)]  { await Ledger.icrc1_metadata();};

  public shared ( { caller } ) func userBalanceByBranch(branch : Nat8) : async Nat {
    let sub = await createSubaccountByBranch(branch);
    let checkSub = { owner = caller; subaccount = ?sub };
    await Ledger.icrc1_balance_of(checkSub);
};

  // Increase reputation
  public func awardToken(from : Ledger.Account, to : Ledger.Account, amount : Ledger.Tokens) : async Bool {
    let sender : ?Ledger.Subaccount = from.subaccount;
    let memo : ?Ledger.Memo = null;
    let fee : ?Ledger.Tokens = ?0;
    let created_at_time : ?Ledger.Timestamp = ?Nat64.fromIntWrap(Time.now());
    let a : Ledger.Tokens = amount;
    let acc : Ledger.Account = to;
    let res = await Ledger.icrc1_transfer({
      from_subaccount = sender;
      to = to;
      amount = amount;
      fee = fee;
      memo = memo;
      created_at_time = created_at_time;     
    });
    let b : Bool = switch (res) {
      case (#Ok(id)) true;
      case (#Err(err)) false;
    }
  };

  // Decrease reputation



}