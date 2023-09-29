import dnft "canister:dnft";
import doctoken "canister:doctoken";
import rep "canister:rep";

import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
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

  type DocDAO = {
    docId : Nat;
    image : Text; //datalink
    author : Text; // owner
    reputation : Nat; // sum of all doc history
    history : Text; // link to history
  };

  public query (message) func user() : async Text {
    Principal.toText(message.caller);
  };

  public func getUserReputation(user: Principal) : async Nat {
    await rep.getUserReputation(user);       
  };
  
  public func getReputationByBranch(user: Principal, branch: Branch) : async (Principal, Branch, Nat) {
    let balance_opt = await rep.getReputationByBranch(user : Principal, branch : Nat8);
    let balance = switch (balance_opt) {
      case null 0;
      case (?(br, bal)) bal;
    };
    
    (user, branch, balance );
  };
  
  public func setUserReputation(user: Principal, branchId: Nat8, value: Nat) : async Types.Result<(rep.Account, Nat),rep.TransferBurnError> {
      let res = await rep.setUserReputation(user, branchId, value); 
  };

  // dNFT part

  public func mintdNFT(to: Principal, link: Text) : async dnft.MintReceipt {
    await dnft.mintNFTWithLink(to, link);
  };

  public func getAlldNft() : async [dnft.Nft] {
    await dnft.getAllNft();
  };

  // doctoken part

  public func createDocToken(to: Principal, author: Text, content : Text, imageLink: Text, tag : Nat8) : async Types.Result<rep.Document, Text> {
    let res = await doctoken.mintNFT(to, author, content, Nat8.toText(tag), imageLink);
    let linkText = switch(res) {
      case(#Err(err)) { return #Err("Cannot create doctoken"); };
      case(#Ok(nft)) { Nat.toText(nft.id); };
    };
    let docDao : rep.DocDAO = {
      //TODO check is tag present to avoid duplicates
      tags = [ Nat8.toText(tag) ];
      
      // Content is doctoken id for prototype
      content = linkText;
      imageLink = imageLink;
    };    
    let setDocToReputation = await rep.setDocumentByUser(to, tag, docDao);    
  };
  

  public func getAllDocTokens() : async [doctoken.Nft] {
    let nfts = await doctoken.getAllNft();    
  };

  public func getDocTokensByUser(user : Principal) : async [doctoken.Nft] {
    let nfts = await doctoken.getDocsByUser(user);
  };

  public func getDocTokenById(id : Nat64) : async Types.Result<doctoken.Nft, Text> {
    let resp = await doctoken.getDocById(id);   
  };

  public func getTokenDAO() : async [ DocDAO ] {
    let docs = await rep.getAllDocs();
    let res = Buffer.Buffer<DocDAO>(0);
    for(doc in docs.vals()) {
      let id = doc.docId;
      let doc_response = await doctoken.getDocById(Nat64.fromNat(id));
      let document = switch (doc_response) {
        case (#Err(t)) return [{docId = 0; image = "test_image"; author = "test_user"; reputation=0; history= "test_link"}];
        case (#Ok(d)) d;        
      };
      let docHistory = await rep.getDocHistory(id);
      let history = "link";
      let docDAO = {
        docId = id;
        image = doc.imageLink;
        author = Principal.toText(document.owner);
        reputation = await rep.getDocReputation(id);
        history = history; // TODO  link to rep.getDocHistory(docId : DocId)

      };
      res.add(docDAO);
    }; 
    Buffer.toArray(res);
  };

  public func getTokenDAOByUser(user : Principal) : async [ DocDAO ] {
    let repDocs = await rep.getDocumentsByUser(user);
    let res = Buffer.Buffer<DocDAO>(0);
    for(doc in repDocs.vals()) {
      let docDAO = {
        docId = doc.docId;
        image = doc.imageLink;
        author = Principal.toText(user);
        reputation = await rep.getDocReputation(doc.docId);
        history = "link"; // TODO array to text docHistory
      };
      res.add(docDAO);
    };
    Buffer.toArray(res);
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
  
  public func getDocumentsFromRepByUser(user : Principal) : async [ Document ] {
    await rep.getDocumentsByUser(user);
  };

  // public func getDocumentHistoryByUser(docId: Nat8, user: Principal) : async [DocumentHistory] {
  //   // Implement logic to fetch document history made by a specific user
  //   return [];  
  // };
  
  public func updateDocHistory(user : Principal, docId : rep.DocId, value : Nat8, comment: Text) : async Types.Result<rep.DocHistory, rep.CommonError> {
     await rep.updateDocHistory(user, docId, value, comment);
  };

  public func createRepDocument(user : Principal, branches : [ Nat8 ], content : Text, imageLink : Text) : async Document {
    await rep.createDocument(user, branches, content, imageLink);
  };

  public func getTags() : async [ (rep.Tag, Branch) ] {
    await rep.getTags();
  };
};
