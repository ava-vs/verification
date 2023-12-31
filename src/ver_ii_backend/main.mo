import dnft "canister:dnft";
import doctoken "canister:doctoken";
import rep "canister:rep";

import Buffer "mo:base/Buffer";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import List "mo:base/List";

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

  type DocTable = {
    docId : Nat;
    image : Text; //datalink
    author : Text; // owner
    reputation : Nat; // sum of all doc history
    history : Text; // link to history
  };

  type DocNumber = {
    doctoken : Nat64;
    reputation : Nat;
  };

  stable var doctokenNumbers = List.nil<DocNumber>();

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

  public func createDocToken(to: Principal, author: Text, content : Text, imageLink: Text, tag : Text) : async Types.Result<rep.Document, Text> {

    let res = await doctoken.mintNFT(to, author, content, tag, imageLink);
    let linkText = switch(res) {
      case(#Err(err)) { return #Err("Cannot create doctoken"); };
      case(#Ok(nft)) { Nat.toText(nft.id); };
    };
    let docDao : rep.DocDAO = {
      //TODO check is tag present to avoid duplicates
      tags = [ tag ];
      
      // Content is doctoken id for prototype
      content = linkText;
      imageLink = imageLink;
    };  
    let tagNat8 = Nat8.fromNat(Option.get(Nat.fromText(tag), 2));
    let setDocToReputation = await rep.setDocumentByUser(to, tagNat8, docDao);   
    let docReputation = switch(setDocToReputation) {
      case (#Err(text)) return #Err(text);
      case (#Ok(doc)) doc;
    };
    let doctokenNumber = Option.get(Nat.fromText(linkText), 0);
    let docNumber : DocNumber = { doctoken = Nat64.fromNat(doctokenNumber); reputation = docReputation.docId };
    doctokenNumbers := List.push(docNumber, doctokenNumbers);
    setDocToReputation;
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

  public func getTokenDAO() : async [ DocTable ] {
    let docs = await rep.getAllDocs();
    let res = Buffer.Buffer<DocTable>(0);
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

  public func getTokenDAOByUser(user : Principal) : async [ DocTable ] {
    let repDocs = await rep.getDocumentsByUser(user);
    let res = Buffer.Buffer<DocTable>(0);
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

  public func getDocHistory(docId : rep.DocId) : async [ DocumentHistory ] {
    return [{ 
              docId = docId;
              timestamp = 1000;
              changedBy = Principal.fromText("aaaaa-aa");
              value = 1;
              comment = "self_test_update"
          }]
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

  public func createRepDocument(user : Principal, branch : Text, content : Text, imageLink : Text) : async Document {
    let branches = [ Nat8.fromNat(Option.get(Nat.fromText(branch), 2))];
    await rep.createDocument(user, branches, content, imageLink);
  };

  public func getTags() : async [ (rep.Tag, Branch) ] {
    await rep.getTags();
  };
};
