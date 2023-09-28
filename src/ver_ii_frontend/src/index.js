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

const docsButton = document.getElementById("docs");
docsButton.onclick = async (e) => {
    e.preventDefault();
    // const principalName = document.getElementById("name");

    docsButton.setAttribute("disabled", true);

    try {
        const docTokens = await ver_ii_backend.getAllDocTokens();

        const tableBody = document.getElementById('resultDocuments');
        tableBody.innerHTML = '';  // Clear the current content

        docTokens.forEach(token => {
            const row = tableBody.insertRow();

            // № column
            const numberCell = row.insertCell(0);
            numberCell.textContent = token.id;

            // Title column
            const titleCell = row.insertCell(1);
            titleCell.textContent = "document #";

            // Category column
            const categoryCell = row.insertCell(2);
            categoryCell.textContent = "IT";

            // Author column
            const authorCell = row.insertCell(3);
            authorCell.textContent = token.owner;

            // Reputation column
            const reputationCell = row.insertCell(4);
            reputationCell.textContent = "-";

            // History column
            const historyCell = row.insertCell(5);
            historyCell.textContent = "-";

            // Date column
            const dateCell = row.insertCell(6);
            dateCell.textContent = "-";
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

    return false;
};

// Assuming you have a way to call the canister's methods, e.g., using the DFINITY agent
async function loadDocuments() {
    // try {
    //     const docTokens = await ver_ii_backend.getAllDocTokens();

    //     const tableBody = document.getElementById('resultDocuments');
    //     tableBody.innerHTML = '';  // Clear the current content

    //     docTokens.forEach(token => {
    //         token.metadata.forEach(part => {
    //             part.key_val_data.forEach(kv => {
    //                 if (kv.val.LinkContent) {
    //                     const row = tableBody.insertRow();
    //                     const cell = row.insertCell(0);
    //                     cell.textContent = kv.val.LinkContent;
    //                 }
    //             });
    //         });
    //     });
    // } catch (error) {
    //     console.error("Error loading documents:", error);
    // }
}

// Call the function to load the documents when the page loads
// window.onload = loadDocuments;
