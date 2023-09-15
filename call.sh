dfx canister call ledger icrc1_transfer '(
  record {
    "to" = record {
        owner=principal "ao6hk-x5zgr-aa6y2-zq5ei-meewq-doeim-hwbws-zzxql-rjtcc-hmabt-xqe";
        subaccount=opt vec {0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0}};
    "amount" = 1;
  })'
