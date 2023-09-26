import rep "canister:rep";
import dnft "canister:dnft";
import doctoken "canister:doctoken";

import Option "mo:base/Option";
import Principal "mo:base/Principal";

import Types "./Types";

/*
  Controller for aVa project
*/
actor {

  type Document = {
    docId : Nat;
    tags : [ Text ];
    content : Text;
    imageLink : Text; //(link to asset canister)

  };

  type Branch = Nat8;

  type DocumentHistory = {
    docId : Nat;
    timestamp : Nat;
    changedBy : Principal;
    value : Int;
    comment : Text;
  };

  public query (message) func greet() : async Text {
    return "Hello, " # Principal.toText(message.caller) # "!";
  };

  // default IC values

  let dnft_canister_id = "mmo7p-xaaaa-aaaan-qedda-cai";
  let doctoken_canister_id = "mzjoc-wiaaa-aaaan-qedaq-cai";

  // local values

  let dnft_local = "bkyz2-fmaaa-aaaaa-qaaaq-cai";
  let doctoken_local = "bkyz2-fmaaa-aaaaa-qaaaq-cai";


  // public func changeBalance(user: Principal, val : Int) : async (Principal, Int) {
  //   let rep = actor(rep_canister_id) : actor { incrementBalance: (Principal, Int) -> async (Principal, Int)};
  //   return await rep.incrementBalance(user, val);
  // };

  public func getUserReputation(user: Principal) : async Nat {
    await rep.getUserReputation(user);    
     
  };
  
  public func getReputationByBranch(user: Principal, branch: Branch) : async (Principal, Branch, Nat) {
    let balance_opt = await rep.getReputationByBranch(user : Principal, branch : Nat8);
    let balance = switch (balance_opt) {
      case null 0;
      case (?(br, bal)) bal;
    };
    // let ver = actor(ver_canister_id): actor { getBalance: (Text) -> async ?Int };
    //  await ver.getBalance(user);
    
    (user, branch, balance );
  };
  
  public func setUserReputation(user: Principal, branchId: Nat8, value: Nat) : async Types.Result<(rep.Account, Nat),rep.TransferBurnError> {
      let res = await rep.setUserReputation(user, branchId, value); 

  };

  // dNFT part

  public func mintNFT(to: Principal, link: Text) : async dnft.MintReceipt {
    await dnft.mintNFTWithLink(to, link);
  };

  public func getAllNft() : async [dnft.Nft] {
    await dnft.getAllNft();
  };

  // doctoken part

  public func mintDocToken(to: Principal, author: Text, description : Text, hashsum : Text, link: Text) : async doctoken.MintReceipt {
    await doctoken.mintNFT(to, author, description, hashsum, link);
  };

  public func getAllDocTokens() : async [doctoken.Nft] {
    let nfts = await doctoken.getAllNft();    
  };

  public func getDocsByUser(user : Principal) : async [doctoken.Nft] {
    let nfts = await doctoken.getDocsByUser(user);
  };

  public func getDocById(id : Nat64) : async Types.Result<doctoken.Nft, Text> {
    let resp = await doctoken.getDocById(id);   
  };

  //  public func getDocumentsByTag(tag: Text) : async [Document] {
  //   // Implement logic to fetch documents by tag
  //   return [];  
  // };
  
  // public func deleteDocument(user: Principal, docId: Nat8) : async Bool {
  //   // Implement logic to delete document if it belongs to the given user
  //   return false;  
  // };
  
  // public func updateDocument(user: Principal, docId: Nat8, newContent: Text) : async ?Document {
  //   // Implement logic to update document content
  //   return null;  
  // };
   

  // Methods for working with document history:

  // public func getDocumentHistory(docId: Nat8) : async [DocumentHistory] {
  //   // Implement logic to fetch all document history
  //   return [];  
  // };
  
  public func getDocumentsByUser(user : Principal) : async [ Document ] {
    await rep.getDocumentsByUser(user);
  };

  // public func getDocumentHistoryByUser(docId: Nat8, user: Principal) : async [DocumentHistory] {
  //   // Implement logic to fetch document history made by a specific user
  //   return [];  
  // };
  
  public func updateDocHistory(user : Principal, docId : rep.DocId, value : Nat8, comment: Text) : async Types.Result<rep.DocHistory, rep.CommonError> {
     await rep.updateDocHistory(user, docId, value, comment);
  };

  public func createDocument(user : Principal, branches : [ Nat8 ], content : Text, imageLink : Text) : async Document {
    await rep.createDocument(user, branches, content, imageLink);
  };

  public func getTags() : async [ (rep.Tag, Branch) ] {
    await rep.getTags();
  };
};
