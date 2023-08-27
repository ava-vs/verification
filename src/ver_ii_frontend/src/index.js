import {createActor, ver_ii_backend} from "../../declarations/ver_ii_backend";
import {AuthClient} from "@dfinity/auth-client"
import {HttpAgent} from "@dfinity/agent";

let actor = ver_ii_backend;

const greetButton = document.getElementById("greet");
greetButton.onclick = async (e) => {
    e.preventDefault();

    greetButton.setAttribute("disabled", true);

    // Interact with backend actor, calling the greet method
    const greeting = await actor.greet();

    greetButton.removeAttribute("disabled");

    document.getElementById("greeting").innerText = greeting;

    return false;
};

const balanceButton = document.getElementById("getBalanceButton");
balanceButton.onclick = async (e) => {
    e.preventDefault();
    const principalName = document.getElementById("name");

    balanceButton.setAttribute("disabled", true);

    // Interact with backend actor, calling the greet method
    const getBalance = await actor.getBalance(principalName);

    balanceButton.removeAttribute("disabled");

    document.getElementById("balanceResult").innerText = getBalance;

    return false;
};

const loginButton = document.getElementById("login");
loginButton.onclick = async (e) => {
    e.preventDefault();

    // create an auth client
    let authClient = await AuthClient.create();

    // start the login process and wait for it to finish
    await new Promise((resolve) => {
        authClient.login({
            identityProvider: process.env.II_URL,
            onSuccess: resolve,
        });
    });

    // At this point we're authenticated, and we can get the identity from the auth client:
    const identity = authClient.getIdentity();
    // Using the identity obtained from the auth client, we can create an agent to interact with the IC.
    const agent = new HttpAgent({identity});
    // Using the interface description of our webapp, we create an actor that we use to call the service methods.
    actor = createActor(process.env.VER_II_BACKEND_CANISTER_ID, {
        agent,
    });

    return false;
};