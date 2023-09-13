import Nat8 "mo:base/Nat8";
import Principal "mo:base/Principal";
import Token "../../icrc1/src/ICRC1/Canisters/Token";

actor{
    let decimals = 3; // replace with your chosen number of decimals

    func add_decimals(n: Nat): Nat{
        n * 10 ** decimals
    };

    let pre_mint_account = {
        owner = Principal.fromText("ao6hk-x5zgr-aa6y2-zq5ei-meewq-doeim-hwbws-zzxql-rjtcc-hmabt-xqe");
        subaccount = null;
    };

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
    }
}