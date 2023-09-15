dfx stop
trap 'echo "DONE"' EXIT

dfx start --background --clean
dfx canister create --all

dfx build

dfx canister install rep
dfx canister install rep_token
dfx canister install ver_ii_backend
dfx canister install ver_ii_frontend

dfx deploy --argument '(record { initial_mints = 
    vec { 
        record { account = record { owner = principal "aaaaa-aa"; subaccount = null }; amount = 1000 } }; 
        minting_account = record { owner = principal "aaaaa-aa"; subaccount = null };
        token_name = "aVa Reputation Token"; 
        token_symbol = "AVAR"; 
        decimals = 18; 
        transfer_fee = 0 })' ledger
