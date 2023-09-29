import {createActor, ver_ii_backend} from "../../declarations/ver_ii_backend";
import {AuthClient} from "@dfinity/auth-client"
import {HttpAgent} from "@dfinity/agent";
import { Principal } from "@dfinity/principal";

let actor = ver_ii_backend;

const docsButton = document.getElementById("reaction");
docsButton.onclick = async (e) => {
    e.preventDefault();

    docsButton.setAttribute("disabled", true);

    try {
        const docTokens = await ver_ii_backend.getTokenDAO();

        const tableBody = document.getElementById('resultDocuments');
        tableBody.innerHTML = '';  // Clear the current content

        docTokens.forEach(token => {
            const row = tableBody.insertRow();

            // № column
            const numberCell = row.insertCell(0);
            numberCell.textContent = token.docId;

            // Title column
            const titleCell = row.insertCell(1);
            titleCell.textContent = token.image;

            // Category column
            const categoryCell = row.insertCell(2);
            categoryCell.textContent = "IT";

            // Author column
            const authorCell = row.insertCell(3);
            authorCell.textContent = token.author;

            // Reputation column
            const reputationCell = row.insertCell(4);
            // const docRep = ver_ii_backend.getDocTokenById(token.id);
            reputationCell.textContent = "-";

            // History column
            // const historyCell = row.insertCell(5);
            // historyCell.textContent = "link";

        });
    } catch (error) {
        console.error("Error loading documents:", error);
    };

    docsButton.removeAttribute("disabled");

    // document.getElementById("resultDocuments").innerText = getDocs;

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
    const currentUser = await actor.user();
    document.getElementById("user").innerText = currentUser;
    document.getElementById("login").style.display = "none";

    return false;
};

const myDocsButton = document.getElementById("docs");
myDocsButton.onclick = async (e) => {
    e.preventDefault();

    myDocsButton.setAttribute("disabled", true);

    try {
        const user = await ver_ii_backend.user();
        console.log(user);
        const docTokens = await ver_ii_backend.getTokenDAOByUser(Principal.fromText(user));
        const tableBody = document.getElementById('resultDocuments');
        tableBody.innerHTML = '';  // Clear the current content

        docTokens.forEach(token => {
            console.log(token);
            const row = tableBody.insertRow();

            // № column
            const numberCell = row.insertCell(0);
            const numberLink = document.createElement("a");
            numberLink.href = "#"; 
            numberLink.textContent = token.docId;
            numberLink.onclick = (e) => {
                e.preventDefault(); 
                // TODO 
                ver_ii_backend.getDocTokenById(token.docId).then(result => {
                    document.getElementById("documentResult").innerHTML = result;
                });
            };
            numberCell.appendChild(numberLink);

            // Title column
            const titleCell = row.insertCell(1);
            titleCell.textContent = token.image;

            // Category column
            const categoryCell = row.insertCell(2);
            categoryCell.textContent = "IT";

            // Author column
            const authorCell = row.insertCell(3);
            authorCell.textContent = token.author;

            // Reputation column
            const reputationCell = row.insertCell(4);
            reputationCell.textContent = token.reputation;

            // History column
            // const historyCell = row.insertCell(5);
            // const addHistoryButton= document.createElement("button");
            // historyCell.textContent = token.history;
            // addHistoryButton.onclick = () => {
            //     const res = ver_ii_backend.getDocHistory(token.docId);
            //     console.log(res);
            // };
            // historyCell.appendChild(addHistoryButton);

        });
    } catch (error) {
        console.error("Error loading documents:", error);
    };

    myDocsButton.removeAttribute("disabled");

    // document.getElementById("resultDocuments").innerText = getDocs;

    return false;
};
