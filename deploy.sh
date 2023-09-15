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
        record { account = record { 
            owner = principal "ao6hk-x5zgr-aa6y2-zq5ei-meewq-doeim-hwbws-zzxql-rjtcc-hmabt-xqe"; subaccount = null }; amount = 1000 } }; 
        minting_account = record { owner = principal "ao6hk-x5zgr-aa6y2-zq5ei-meewq-doeim-hwbws-zzxql-rjtcc-hmabt-xqe"; subaccount = null };
        token_name = "aVa Reputation Token"; 
        token_symbol = "AVAR"; 
        decimals = 6; 
        transfer_fee = 0 })' ledger

echo "Getting init balance branch 0: "
dfx canister call rep_token userBalanceByBranch '(0)'

echo "Getting init balance branch 1: "


dfx canister call rep_token userBalanceByBranch '(1)'
echo "Trasfer:"

dfx canister call ledger icrc1_transfer '(vec {
    record {
     "to": record { owner=principal "ao6hk-x5zgr-aa6y2-zq5ei-meewq-doeim-hwbws-zzxql-rjtcc-hmabt-xqe";
      subaccount=opt vec {0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0}};
    "amount" = 1;
     }
     })'

