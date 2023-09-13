import Nat8 "mo:base/Nat8";
import Principal "mo:base/Principal";
import Token "../../icrc1/src/ICRC1/Canisters/Token";
// import ICRC1 "../../icrc1/src/ICRC1"; 
import T "Token";

actor{
    let decimals = 3; // replace with your chosen number of decimals

    func add_decimals(n: Nat): Nat{
        n * 10 ** decimals
    };

    let pre_mint_account = {
        owner = Principal.fromText("ao6hk-x5zgr-aa6y2-zq5ei-meewq-doeim-hwbws-zzxql-rjtcc-hmabt-xqe");
        subaccount = null;
    };
    // let token = await initialize();

    public shared({ caller }) func initialize() : async () {
        let token_canister = Token.Token({
            name = "aVa Shared reputation token";
            symbol = "AVAS";
            decimals = Nat8.fromNat(decimals);
            fee = add_decimals(6);
            max_supply = add_decimals(1_000_000);

            // pre-mint 100,000 tokens for the account
            initial_balances = [(pre_mint_account, add_decimals(100_000))]; 

            min_burn_amount = add_decimals(10);
            minting_account = null; // defaults to the canister id of the caller
            advanced_settings = null; 
        });
        
    };

    public shared ({ caller }) func mint1(name : Text) : async (Principal, Text) {
        let token = T.Token({
             name = name;
            symbol = "AVAS";
            decimals = Nat8.fromNat(decimals);
            fee = add_decimals(6);
            max_supply = add_decimals(1_000_000);

            // pre-mint 100,000 tokens for the account
            initial_balances = [(pre_mint_account, add_decimals(100_000))]; 

            min_burn_amount = add_decimals(10);
            minting_account = null; // defaults to the canister id of the caller
            advanced_settings = null; 
        });
        (caller, name);
    };

    // //     /// Functions for the ICRC1 token standard
    // public shared query func icrc1_name() : async Text {
    //     ICRC1.name(token);
    // };

    // public shared query func icrc1_symbol() : async Text {
    //     ICRC1.symbol(token);
    // };

    // public shared query func icrc1_decimals() : async Nat8 {
    //     ICRC1.decimals(token);
    // };

    // public shared query func icrc1_fee() : async ICRC1.Balance {
    //     ICRC1.fee(token);
    // };

    // public shared query func icrc1_metadata() : async [ICRC1.MetaDatum] {
    //     ICRC1.metadata(token);
    // };

    // public shared query func icrc1_total_supply() : async ICRC1.Balance {
    //     ICRC1.total_supply(token);
    // };

    // public shared query func icrc1_minting_account() : async ?ICRC1.Account {
    //     ?ICRC1.minting_account(token);
    // };

    // public shared query func icrc1_balance_of(args : ICRC1.Account) : async ICRC1.Balance {
    //     ICRC1.balance_of(token, args);
    // };

    // public shared query func icrc1_supported_standards() : async [ICRC1.SupportedStandard] {
    //     ICRC1.supported_standards(token);
    // };

    // public shared ({ caller }) func icrc1_transfer(args : ICRC1.TransferArgs) : async ICRC1.TransferResult {
    //     await* ICRC1.transfer(token, args, caller);
    // };

    // public shared ({ caller }) func mint(args : ICRC1.Mint) : async ICRC1.TransferResult {
    //     await* ICRC1.mint(token, args, caller);
    // };

}