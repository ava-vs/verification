import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Types "./Types";
import rep "canister:rep";

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

  let ver_canister_id = "4rouu-2iaaa-aaaal-qcahq-cai";//TODO  change to actual
  let rep_canister_id = "4wpsa-xqaaa-aaaal-qcaha-cai";//TODO  change to actual

  // local values

  let dnft_local = "bkyz2-fmaaa-aaaaa-qaaaq-cai";
  let doctoken_local = "bkyz2-fmaaa-aaaaa-qaaaq-cai";

  // verification part 

  // public func getBalance(user : Principal, branch : Branch) : async (Principal, Branch, Nat) {
  //   let balance_opt = await rep.getReputationByBranch(user : Principal, branch : Nat8);
  //   let balance = switch (balance_opt) {
  //     case null 0;
  //     case (?(br, bal)) bal;
  //   };
  //   // let ver = actor(ver_canister_id): actor { getBalance: (Text) -> async ?Int };
  //   //  await ver.getBalance(user);
    
  //   (user, branch, balance );
  // };

  //TODO uploadLink() 

  // reputation part

  // public func getUsers() : async [(Principal, Int)] {
  //   let rep = actor(rep_canister_id) : actor { getUsers: () -> async [(Principal, Int)]};
  //   return await rep.getUsers();
  // };

  // public func addUser(user: Principal) : async (Text, Int) {
  //   let rep = actor(rep_canister_id) : actor { publish: (Int, Text) -> async (Text, Int)};
  //   return await rep.publish(0, Principal.toText(user));
  // };

  // public func changeBalance(user: Principal, val : Int) : async (Principal, Int) {
  //   let rep = actor(rep_canister_id) : actor { incrementBalance: (Principal, Int) -> async (Principal, Int)};
  //   return await rep.incrementBalance(user, val);
  // };

  public func getUserReputation(user: Principal) : async [ (Branch, Nat)] {
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
  
  public func setUserReputation(user: Principal, branchId: Text, value: Int) : async Bool {
    // Implement logic to set reputation value for a given user in a specific branch
    return false; 
  };

  // dNFT part

  public func mintNFT(to: Principal, author: Text, description : Text, hashsum : Text, link: Text) : async Types.MintReceipt {
    let dNFT = actor(dnft_local) : actor { mintNFT: (Principal, Text, Text, Text, Text) -> async Types.MintReceipt };
    return await dNFT.mintNFT(to, author, description, hashsum, link);
  };

  public func getAllNft() : async [Types.Nft] {
    let dNFT = actor(dnft_local) : actor { getAllNft : () -> async [Types.Nft] };
    return await dNFT.getAllNft();
  };

  // doctoken part

  public func minDocToken(to: Principal, author: Text, description : Text, hashsum : Text, link: Text) : async Types.MintReceipt {
    let doc = actor(doctoken_local) : actor { mintNFT: (Principal, Text, Text, Text, Text) -> async Types.MintReceipt };
    return await doc.mintNFT(to, author, description, hashsum, link);
  };

  public func getAllDocTokens() : async [Types.Nft] {
    let doc = actor(doctoken_local) : actor { getAllNft : () -> async [Types.Nft] };
    return await doc.getAllNft();
  };

   public func getDocumentsByTag(tag: Text) : async [Document] {
    // Implement logic to fetch documents by tag
    return [];  // Placeholder
  };
  
  public func deleteDocument(user: Principal, docId: Nat8) : async Bool {
    // Implement logic to delete document if it belongs to the given user
    return false;  // Placeholder
  };
  
  public func updateDocument(user: Principal, docId: Nat8, newContent: Text) : async ?Document {
    // Implement logic to update document content
    return null;  // Placeholder
  };
   

  // Methods for working with document history:

  public func getDocumentHistory(docId: Nat8) : async [DocumentHistory] {
    // Implement logic to fetch all document history
    return [];  // Placeholder
  };

  public func getDocumentHistoryByUser(docId: Nat8, user: Principal) : async [DocumentHistory] {
    // Implement logic to fetch document history made by a specific user
    return [];  // Placeholder
  };
  

};
