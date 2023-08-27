import Principal "mo:base/Principal";

/*
  Controller for aVa project
*/
actor {
  public query (message) func greet() : async Text {
    return "Hello, " # Principal.toText(message.caller) # "!";
  };

  // default values

  let ver_canister_id = "4rouu-2iaaa-aaaal-qcahq-cai";
  let rep_canister_id = "4wpsa-xqaaa-aaaal-qcaha-cai";

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

};
