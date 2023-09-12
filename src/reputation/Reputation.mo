import Principal "mo:base/Principal";
import Int "mo:base/Int";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import TrieMap "mo:base/TrieMap";
import Map "mo:base/HashMap";
import Iter "mo:base/Iter";

actor {

    type DocId = Nat;

    type Document = {
    docId : DocId;
    tags : [ Text ];
    content : Text;
    imageLink : Text; //(link to asset canister)

  };

  type UserDocuments = Map.HashMap<Principal, [DocId]>;

  type Branch = Nat8;

  type DocumentHistory = {
    docId : DocId;
    timestamp : Nat;
    changedBy : Principal;
    value : Int;
    comment : Text;
  };

  stable var documents : [ Document ] = [];
  stable var userDocuments : ?[(Principal, [DocId])] = null;

  var userDocumentMap : UserDocuments = Map.HashMap<Principal, [DocId]>(10, Principal.equal, Principal.hash);
// map docId - docHistory 
// map userId - [ Reputation ] or map userId - Map (branchId : value)
// map tag : branchId
 public func getUserReputation(user: Principal) : async [ (Branch, Int)] {

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



// stable example for tags

  var map = Map.HashMap<Text, Map.HashMap<Text, Nat>>(10, Text.equal, Text.hash);
stable var upgradeMap : [var (Text, [(Text, Nat)])] = [var];

system func preupgrade() {
    upgradeMap := Array.init(map.size(), ("", []));
    var i = 0;
    for ((x, y) in map.entries()) {
      upgradeMap[i] := (x, Iter.toArray(y.entries()));
      i += 1;
    };
};
}