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
import Types "./Types";
import RToken "canister:rep_token";

actor {
  type Document = Types.Document;
  type Branch = Types.Branch;
  type DocId = Types.DocId;
  type Tag = Types.Tag;
  type DocHistory = Types.DocumentHistory;

  stable var documents : [ Document ] = [];
  stable var userDocuments : ?[(Principal, [DocId])] = null;
  var userDocumentMap = Map.HashMap<Principal, [DocId]>(10, Principal.equal, Principal.hash);

  // map docId - docHistory 
  var docHistory = Map.HashMap<DocId, DocHistory>(10, Nat.equal, Hash.hash);
// map userId - [ Reputation ] or map userId - Map (branchId : value)
  var userReputation = Map.HashMap<Principal, Map.HashMap<Branch, Int>>(1, Principal.equal, Principal.hash);
// map tag : branchId
  var tagMap = TrieMap.TrieMap<Text, Branch>(Text.equal, Text.hash);


    public func getUserReputation(user: Principal) : async [ (Branch, Int)] {
      RToken.getBalance(user);
    return [];
    };

    public func getReputationByBranch(user: Principal, branchId: Text) : async ?(Branch, Int) {
    // Implement logic to get reputation value in a specific branch
    return null;  
  };

    public func setUserReputation(user: Principal, branchId: Text, value: Int) : async Bool {
    // Implement logic to set reputation value for a given user in a specific branch
    return false; 
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
