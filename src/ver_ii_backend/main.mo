import Principal "mo:base/Principal";
import Types "./Types";

/*
  Controller for aVa project
*/
actor {
  public query (message) func greet() : async Text {
    return "Hello, " # Principal.toText(message.caller) # "!";
  };

  // default IC values

  let ver_canister_id = "4rouu-2iaaa-aaaal-qcahq-cai";
  let rep_canister_id = "4wpsa-xqaaa-aaaal-qcaha-cai";

  // local values

  let dnft_local = "bkyz2-fmaaa-aaaaa-qaaaq-cai";
  let doctoken_local = "bkyz2-fmaaa-aaaaa-qaaaq-cai";

  // verification part 

  public func getBalance(user : Text) : async ?Int {
    let ver = actor(ver_canister_id): actor { getBalance: (Text) -> async ?Int };
    return await ver.getBalance(user);
  };

  // reputation part

  public func getUsers() : async [(Principal, Int)] {
    let rep = actor(rep_canister_id) : actor { getUsers: () -> async [(Principal, Int)]};
    return await rep.getUsers();
  };

  public func addUser(user: Principal) : async (Text, Int) {
    let rep = actor(rep_canister_id) : actor { publish: (Int, Text) -> async (Text, Int)};
    return await rep.publish(0, Principal.toText(user));
  };

  public func changeBalance(user: Principal, val : Int) : async (Principal, Int) {
    let rep = actor(rep_canister_id) : actor { incrementBalance: (Principal, Int) -> async (Principal, Int)};
    return await rep.incrementBalance(user, val);
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

};
