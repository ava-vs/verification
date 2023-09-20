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
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import Option "mo:base/Option";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";
import Types "./Types";
import RToken "canister:rep_token";

actor {
  type Document = Types.Document;
  type Branch = Types.Branch;
  type DocId = Types.DocId;
  type Tag = Types.Tag;
  type DocHistory = Types.DocumentHistory;
  
  type DocDAO = {
    // main_branch : Tag;
    tags : [ Tag ];
    content : Text;
    imageLink : Text;
  };

    let hashBranch = func (x: Branch): Nat32 {
      return Nat32.fromNat(Nat8.toNat(x * 7)); 
    };

  stable var documents : [ Document ] = [];
  let emptyBuffer = Buffer.Buffer<(Principal, [DocId])>(0);
  stable var userDocuments : [(Principal, [DocId])] = Buffer.toArray(emptyBuffer);
  var userDocumentMap = Map.HashMap<Principal, [DocId]>(10, Principal.equal, Principal.hash);

  // map docId - docHistory 
  var docHistory = Map.HashMap<DocId, DocHistory>(10, Nat.equal, Hash.hash);
  // map userId - [ Reputation ] or map userId - Map (branchId : value)
  // TODO add stable storage for reputation
  var userReputation = Map.HashMap<Principal, Map.HashMap<Branch, Nat>>(1, Principal.equal, Principal.hash);
  // map tag : branchId
  var tagMap = TrieMap.TrieMap<Text, Branch>(Text.equal, Text.hash);
    // TODO add stable storage for shared reputation
  var userSharedReputation = Map.HashMap<Principal, Map.HashMap<Branch, Nat>>(1, Principal.equal, Principal.hash);

  public func getUserReputation(user: Principal) : async Nat {
    let balance = await RToken.getUserBalance(user);
    // let reputationMap = userReputation.get(user);
    // let map = switch (reputationMap) {
    //   case null return [];
    //   case (?reputationMap) reputationMap;
    // };
    // var buffer = Buffer.Buffer<(Branch, Nat)>(1);
    // for((br, item) in map.entries()) {
    //   buffer.add(br, item);
    // };

    // return Buffer.toArray(buffer);
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

  // set reputation value for a given user in a specific branch
  public func setUserReputation(user: Principal, branchId: Nat8, value: Nat) : async Types.Result<(Types.Account, Nat),Types.TransferBurnError> {
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

  // universal method for award/burn reputation
  public func changeReputation(user : Principal, branchId : Branch, value : Int) : async Types.ChangeResult {
      let res : Types.Change = (user, branchId, value);
    // TODO validation: check ownership

    // TODO get exist reputation : getUserReputation 

    // TODO change reputation:  setUserReputation

    // ?TODO save new state

    // return new state

    return #Ok( res );
  };

  // Shared part

  public func sharedReputationDistrube() : async Types.Result<Text, Types.TransferBurnError> {
    // let default_acc = { owner = Principal.fromText("aaaaa-aa"); subaccount = null };
    var res = #Ok("Shared ");
    var sum = 0;
    let mint_acc = await RToken.getMintingAccount();
    label one for((user, entry) in userReputation.entries()) {
      if (Principal.equal(mint_acc, user)) continue one;
      var balance = 0;
      for((branch, value) in entry.entries()) {
        balance += value;      
      };
      // switch on error, return #Err
      let result = await RToken.awardToken({ owner=user; subaccount= null }, balance);
      userSharedReputation.put(user, entry);
      res := switch (result) {
        case (#Ok(id)) { sum +=1;
          #Ok(" Shared");
        };
        case (#Err(err)) return #Err(err);
      };
    };
    return #Ok("Tokens were shared  to " # Nat.toText(sum) # " accounts");
  };

  // Doctoken part

  public func getDocumentsByUser(user : Principal) : async [ Document ] {
    let docIdList = Option.get(userDocumentMap.get(user), []);
    var result = Buffer.Buffer<Document>(1);
    label one for(documentId in docIdList.vals()) {
      let document = Array.find<Document>(documents, func doc = Nat.equal(documentId, doc.docId));
      switch (document) {
        case null continue one;
        case (?d) result.add(d);
      };   
    };  
    Buffer.toArray(result);
  };

  public func getDocumentById(id : DocId) : async Types.Result<Document, Text> {
    let document = Array.find<Document>(documents, func doc = Nat.equal(id, doc.docId));
    switch (document) {
      case null #Err("No documents found by id " # Nat.toText(id));
      case (?doc) #Ok(doc);
    }
  };

  public func getDocumentsByBranch(branch : Branch) : async [ Document ] {
    let document = Array.find<Document>(documents, func doc = Text.equal(getTagByBranch(branch), doc.tags[0]));

    switch(document) {
      case null [];
      case (?doc) [doc];
    };
  };

  public func setDocumentByUser(user : Principal, branch: Branch, document : DocDAO) : async Types.Result<Document, Text> {
    let nextId = documents.size();
    let docList = Option.get(userDocumentMap.get(user), []);
    let newTags = Buffer.Buffer<Tag>(1); 
    newTags.add(getTagByBranch(branch));
    let existBranches = Buffer.fromArray<Tag>(document.tags);
    newTags.append(existBranches);
    let newDoc = {
      docId = nextId;
      tags = Buffer.toArray(newTags);
      content = document.content;
      imageLink = document.imageLink;
    };   
    documents := Array.append(documents, [newDoc]);
    let newList =  Array.append(docList, [nextId]);
    userDocumentMap.put(user, newList);
    // TODO documents.add(newDoc) on postupgrade
    return #Ok(newDoc);
  };
  
  //Key method for update reputation based on document
  public func updateDocHistory(user : Principal, docId : DocId, value : Nat8, comment: Text) : async Types.Result<DocHistory, Types.CommonError> {
    let doc = switch(checkDocument(docId)) {
      case (#Err(err)) { return #Err(err) };
      case (#Ok(doc)) { doc; };
    };
    let newDocHistory : DocHistory = {
          docId = docId;
          timestamp = Time.now();
          changedBy = user;
          value = value;
          comment = comment;
      };
    docHistory.put(docId, newDocHistory);
    let branch = await getBranchByTagName(doc.tags[0]);
    ignore await setUserReputation(user, branch, Nat8.toNat(value));
    #Ok(newDocHistory);
  };

  func checkDocument(docId : DocId) : Types.Result<Document, Types.CommonError> {
    let checkDocument = Array.find<Document>(documents, func doc = Nat.equal(docId, doc.docId));
    let doc = switch(checkDocument) {
      case null { #Err(#NotFound { message="No document found by id "; docId=docId })};
      case (?doc) { #Ok(doc); };
    };
  };

  public func newDocument(user : Principal, doc : DocDAO) : async Types.Result<DocId, Types.CommonError> {
    let userDocs = userDocumentMap.get(user);
    // TODO choose branch: chooseTag(preferBranch, doc);
    let branch_opt = Nat.fromText(doc.tags[0]);
    let branch = switch (branch_opt) {
      case null return #Err(#NotFound { message= "Cannot find out the branch " # doc.tags[0]; docId = 0 } );
      case (?br) Nat8.fromNat(br);
    };
    let document = await setDocumentByUser(user, branch, doc);
    return #Err(#TemporarilyUnavailable);
  };

  public func createDocument(user : Principal, branchs : [ Nat8 ], content : Text, imageLink : Text) : async Document {
    var tags = Buffer.Buffer<Text>(1);
    for(item in branchs.vals()) {
      tags.add(getTagByBranch(item));
    };
    let newDoc = {
      docId = 0;
      tags = Buffer.toArray(tags);
      content = content;
      imageLink = imageLink;
    };  
  };

  // Tag part
  public func getBranchByTagName(tag : Tag) : async Branch {
    let res = switch (tagMap.get(tag)) {
      case null Nat8.fromNat(0);
      case (?br)  br;
    };
    res;
  };

  func getTagByBranch(branch : Branch) : Tag {
    for((key, value) in tagMap.entries()) {
      if (Nat8.equal(branch, value)) return key;
    };
    "0";
  };

  public func setNewTag(tag : Tag) : async Types.Result<(Tag, Branch), (Tag, Branch)> {
    switch (tagMap.get(tag)) {
      case null { 
        // TODO Create a hierarchical system of industries
        let newBranch = tagMap.size();
        tagMap.put(tag, Nat8.fromNat(newBranch));
        #Ok(tag, Nat8.fromNat(newBranch));
      };
      case (?br) #Err(tag, br);
    }
  };

  public func getTags() : async [ (Tag, Branch) ] {
    let res = Buffer.Buffer<(Tag, Branch)>(1);
    for((key, value) in tagMap.entries()) {
      res.add(key, value);
    };
    Buffer.toArray(res);
  };
}
