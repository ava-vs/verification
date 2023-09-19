import Principal "mo:base/Principal";
import Int "mo:base/Int";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import TrieMap "mo:base/TrieMap";
import Map "mo:base/HashMap";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Error "mo:base/Error";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import Option "mo:base/Option";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Types "./Types";
import RToken "canister:rep_token";

actor {
  type Document = Types.Document;
  type Branch = Types.Branch;
  type DocId = Types.DocId;
  type Tag = Types.Tag;
  type DocHistory = Types.DocumentHistory;

    let hashBranch = func (x: Branch): Nat32 {
      return Nat32.fromNat(Nat8.toNat(x * 7)); 
    };

  stable var documents : [ Document ] = [];
  stable var userDocuments : ?[(Principal, [DocId])] = null;
  var userDocumentMap = Map.HashMap<Principal, [DocId]>(10, Principal.equal, Principal.hash);

  // map docId - docHistory 
  var docHistory = Map.HashMap<DocId, DocHistory>(10, Nat.equal, Hash.hash);
  // map userId - [ Reputation ] or map userId - Map (branchId : value)
  var userReputation = Map.HashMap<Principal, Map.HashMap<Branch, Nat>>(1, Principal.equal, Principal.hash);
  // map tag : branchId
  var tagMap = TrieMap.TrieMap<Text, Branch>(Text.equal, Text.hash);


  public func getUserReputation(user: Principal) : async [(Branch, Nat)] {
    let reputationMap = userReputation.get(user);
    let map = switch (reputationMap) {
      case null return [];
      case (?reputationMap) reputationMap;
    };
    var buffer = Buffer.Buffer<(Branch, Nat)>(1);
    for((br, item) in map.entries()) {
      buffer.add(br, item);
    };

    return Buffer.toArray(buffer);
  };

  public func getReputationByBranch(user: Principal, branchId: Nat8) : async ?(Branch, Nat) {
  // Implement logic to get reputation value in a specific branch
  let res = await RToken.userBalanceByBranch(user, branchId);
  return ?(branchId, res);  
  };

  func subaccountToNatArray(subaccount : Types.Subaccount) : [ Nat8 ] {
  var buffer = Buffer.Buffer<Nat8>(0);
  for(item in subaccount.vals()) {
    buffer.add(item);
  };
  Buffer.toArray(buffer);
};


  public func setUserReputation(user: Principal, branchId: Nat8, value: Nat) : async Types.Result<(Types.Account, Nat),Types.TransferBurnError> {
  // set reputation value for a given user in a specific branch
  let sub = await RToken.createSubaccountByBranch(branchId);
  
  let res = await RToken.awardToken({ owner=user; subaccount= ?Blob.fromArray(subaccountToNatArray(sub)) }, value);
  switch (res) {
    case (#Ok(id)) { 
      ignore saveReputationChange(user, branchId, value);
      let bal = await getReputationByBranch(user, branchId);
      let res = switch(bal) {
        case null { 0 };
        case (?(branch, value)) { value; };
      };
      return #Ok({ owner=user; subaccount=?sub }, res);
      };
      case (#Err(err)) {
        return #Err(err);
      }
    }
  };

  func saveReputationChange(user: Principal, branchId: Nat8, value : Nat) : Map.HashMap<Branch, Nat> {
    let state = userReputation.get(user);
    let map = switch(state) {
      case null { Map.HashMap<Branch, Nat>(0, Nat8.equal, hashBranch); };
      case(?map) { 
        map.put(branchId, value);
        map };
    };
  };


  public func changeReputation(user : Principal, branchId : Branch, value : Int) : async Types.ChangeResult {
      let res : Types.Change = (user, branchId, value);
    // TODO validation: check ownership

    // TODO get exist reputation : getUserReputation 

    // TODO change reputation:  setUserReputation

    // ?TODO save new state

    // return new state

    return #Ok( res );
  }
}
