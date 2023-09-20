dfx stop
trap 'echo "DONE"' EXIT

dfx start --background --clean
dfx canister create --all

dfx build
