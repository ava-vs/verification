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
import Iter "mo:base/Iter";
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

  type Account = Types.Account; //{ owner : Principal; subaccount : ?Subaccount };
  type Subaccount = Types.Subaccount; //Blob;
  type Tokens = Types.Tokens; //Nat;
  type Memo = Types.Memo;
  type Timestamp = Types.Timestamp; //Nat64;
  type Duration = Types.Duration;
  type TxIndex = Types.TxIndex;
  type TxLog = Buffer.Buffer<Types.Transaction>;

  type Value = Types.Value;

  let permittedDriftNanos : Duration = 60_000_000_000;
  let transactionWindowNanos : Duration = 24 * 60 * 60 * 1_000_000_000;
  let defaultSubaccount : [ Nat8 ] = Array.freeze<Nat8>(Array.init(32, 0 : Nat8));

  type Operation = Types.Operation;

  type CommonFields = Types.CommonFields;

  type Approve = Types.Approve;

  type TransferSource = Types.TransferSource;

  type Transfer = Types.Transfer;

  type Allowance = Types.Allowance;

  type Transaction = Types.Transaction;

  type DeduplicationError = Types.DeduplicationError;

  type CommonError = Types.CommonError;

  type BurnError = Types.BurnError;

  type TransferError = Ledger.TransferError;

  type ApproveError = Ledger.ApproveError;

  type TransferFromError = Ledger.TransferFromError;

  public type Result<T, E> = { #Ok : T; #Err : E };

// Demo

// public shared({ caller }) func demo() : async Text {
//   var res = "Start. \n";
//   let accWithsub = await addSubaccount(caller, 0);
//   let sub : ?Types.Subaccount = accWithsub.subaccount;
//   let subText : Text = switch (sub) {
//     case null "null";
//     case (?s) {
//       var t : Text = "";
//       for (item in s.vals()) {
//         t := t # Nat8.toText(item) # " ";
//       };
//       t;
//     };
//   };
//   res := res # " owner: " # Principal.toText(accWithsub.owner) # " ; subaccount: " # subText # " \n";
//   let minting_acc : ?Ledger.Account = await Ledger.icrc1_minting_account();
//   let to : Account = accWithsub;
//   let null_acc : Ledger.Account = { owner = Principal.fromText("aaaaa-aa"); subaccount = null}; 
//   var m_sub : Types.Subaccount= [];
//   let m_acc = switch (minting_acc) {
//     case null null_acc;
//     case (?acc) { 
//       m_sub := switch (acc.subaccount) {
//         case null [];
//         case (?sub) sub;
//       };
//         acc;
//     };
//   };
//   var m_sub_text = "";
//   for(s in m_sub.vals()) {
//     m_sub_text := m_sub_text # Nat8.toText(s);
//   };
//   res := res # "From: owner: " # Principal.toText(m_acc.owner) # ", subacc: " # m_sub_text;
//   let respose = await Ledger.icrc2_transfer_from({
//       from = m_acc;
//       to = to;
//       amount = 1;
//       fee = null;
//       memo = null;
//       created_at_time = null;     
//     });
//   let res_transfer : Text = switch (respose) {
//     case (#Ok(id)) " Success. Transaction id " # Nat.toText(id);
//     case (#Err(err)) {
//       var error_msg = switch (err) {
//         case (#BadBurn {min_burn_amount}) {
//           "BadBurn with minimum burn amount: " # Nat.toText(min_burn_amount)
//         };
//         case (#BadFee {expected_fee}) {
//           "BadFee with expected fee: " # Nat.toText(expected_fee)
//         };
//         case (#CreatedInFuture {ledger_time}) {
//           "CreatedInFuture with ledger time: " # Nat64.toText(ledger_time)
//         };
//         case (#Duplicate {duplicate_of}) {
//           "Duplicate of transaction index: " # Nat.toText(duplicate_of)
//         };
//         case (#GenericError {error_code; message}) {
//           "GenericError with code: " # Nat.toText(error_code) # ", message: " # message
//         };
//         case (#InsufficientFunds {balance}) {
//           "InsufficientFunds with balance: " # Nat.toText(balance)
//         };
//         case (#InsufficientAllowance {allowance:Nat}) {
//           "InsufficientAllowance: " # Nat.toText(allowance);
//         };
//         case (#TemporarilyUnavailable) {
//           "TemporarilyUnavailable"
//         };
//         case (#TooOld) {
//           "TooOld"
//         };
//       };
//       error_msg;
//     };
//   };
//   res := res # " Result of transfer to subaccount: " # res_transfer;

//   let new_balance = await Ledger.icrc1_balance_of(to);
//   res := res # ". New balance = " # Nat.toText(new_balance);

//   return res;
// };

// Subaccounts

public func createSubaccountByBranch(branch: Nat8): async Subaccount {
  Blob.fromArray(Array.freeze<Nat8>(Array.init(32, branch : Nat8)))
};

public func addSubaccount(user : Principal, branch : Nat8) : async Account {
  let sub = await createSubaccountByBranch(branch);
  let newAccount : Account = { owner = user; subaccount = ?sub };
};

func subaccountToNat( subaccount : ?Subaccount) : Nat {
  var result : Nat = 0;
  result := switch (subaccount) {
    case null 0;
    case (?sub) {
      
      for (i in sub.vals()) {
        let byte = Nat8.toNat(i);
        result := result * 256; // Shift left by 8 bits
        result := result + byte; 
      };
    result;
    };
  };
  result;
};

func subaccountToNatArray(subaccount : Subaccount) : [ Nat8 ] {
  var buffer = Buffer.Buffer<Nat8>(0);
  for(item in subaccount.vals()) {
    buffer.add(item);
  };
  Buffer.toArray(buffer);
};

// Logic part

  // public shared ({ caller }) func getSupply() : async Tokens { await Ledger.icrc1_total_supply();};

  // public shared ({ caller }) func getMetdata() : async [(Text, Types.Value)]  { await Ledger.icrc1_metadata();};

  public func userBalanceByBranch(user : Principal, branch : Nat8) : async Nat {
    let sub = await createSubaccountByBranch(branch);
    let addSub : Ledger.Account = { owner = user; subaccount = ?subaccountToNatArray(sub) };
    await Ledger.icrc1_balance_of(addSub);
};

  // Increase reputation
  // using pre_mint_account as from

  public func awardToken(to : Types.Account, amount : Ledger.Tokens) : async Result<TxIndex, TransferFromError> {
    let memo : ?Ledger.Memo = null;
    let fee : ?Ledger.Tokens = null;
    let created_at_time : ?Ledger.Timestamp = ?Nat64.fromIntWrap(Time.now());
    let new_sub = switch (to.subaccount) {
      case null {[]};
      case (?sub) { subaccountToNatArray(sub) };
    };
    let acc :Ledger.Account = { owner = to.owner; subaccount = ?new_sub };
    let res = await Ledger.icrc2_transfer_from({
      from =  pre_mint_account;
      to = acc;
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
    // TODO caller validation
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
      requester : Account, 
      from : Account, 
      document : Types.DocId, 
      tags : [ Types.Tag ],
      amount : Ledger.Tokens
      ) : async Result<TxIndex, Types.TransferBurnError> {
      // check requester's balance
      let branch = subaccountToNat(requester.subaccount);
      let balance_requester = await userBalanceByBranch(requester.owner, Nat8.fromNat(branch));
      // check from balance
      let branch_author = subaccountToNat(from.subaccount);
      if (not Nat.equal(branch, branch_author)) return #Err(#WrongBranch { current_branch = Nat8.fromNat(branch); target_branch = Nat8.fromNat(branch_author) });
      let balance_author = await userBalanceByBranch(from.owner, Nat8.fromNat(branch));
      if (balance_requester < balance_author) return #Err(#InsufficientReputation { current_branch = Nat8.fromNat(branch); balance = balance_author });
      // check document's tags for equity to requester's subaccount
      // let checkTag = Array.find<Types.Tag>(tags, func x = (x == branch));
      
      // burn requester's token
      // burn from token
      // create history log

      return #Err(#TemporarilyUnavailable);
    };

  // Incenitive
    public func awardIncenitive(to : Ledger.Account, amount : Ledger.Tokens) : async Result<TxIndex, TransferFromError>  {
    let memo : ?Ledger.Memo = null;
    let created_at_time : ?Ledger.Timestamp = ?Nat64.fromIntWrap(Time.now());
    let receiver : Ledger.Account = { owner = to.owner; subaccount = ?(subaccountToNatArray(await createSubaccountByBranch(1)))};
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