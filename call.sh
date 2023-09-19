dfx canister call ledger icrc1_transfer '(
  record {
    "to" = record {
        owner=principal "ao6hk-x5zgr-aa6y2-zq5ei-meewq-doeim-hwbws-zzxql-rjtcc-hmabt-xqe";
        subaccount=opt vec {0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 1}};
    "amount" = 1;
  })'
# dfx canister call rep_token demo

# dfx canister call ledger icrc1_balance_of '(  record {
#         owner=principal "ao6hk-x5zgr-aa6y2-zq5ei-meewq-doeim-hwbws-zzxql-rjtcc-hmabt-xqe";
#         subaccount=opt vec {0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 1};
# })'
dfx canister call rep_token awardToken '( record {
        owner=principal "ao6hk-x5zgr-aa6y2-zq5ei-meewq-doeim-hwbws-zzxql-rjtcc-hmabt-xqe";
        subaccount=opt vec {0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 1};
}, 1)'

dfx canister call ledger icrc1_balance_by_principal '(  record {
        owner=principal "ao6hk-x5zgr-aa6y2-zq5ei-meewq-doeim-hwbws-zzxql-rjtcc-hmabt-xqe";
        subaccount=opt vec {0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0};
})'

# echo "Old balance branch 2: "
# dfx canister call rep getReputationByBranch '( 
#         principal "ao6hk-x5zgr-aa6y2-zq5ei-meewq-doeim-hwbws-zzxql-rjtcc-hmabt-xqe",
#         2
# )'
# echo "Set reputation to branch 2: "
# dfx canister call rep setUserReputation '( 
#         principal "ao6hk-x5zgr-aa6y2-zq5ei-meewq-doeim-hwbws-zzxql-rjtcc-hmabt-xqe",
#         2,
#         1
# )'
# echo "New balance branch 2: "
# dfx canister call rep getReputationByBranch '( 
#         principal "ao6hk-x5zgr-aa6y2-zq5ei-meewq-doeim-hwbws-zzxql-rjtcc-hmabt-xqe",
#         2
# )'
