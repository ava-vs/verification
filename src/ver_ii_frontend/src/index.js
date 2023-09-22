import { createActor, ver_ii_backend } from "../../declarations/ver_ii_backend";
import { AuthClient } from "@dfinity/auth-client"
import { HttpAgent } from "@dfinity/agent";

let actor = ver_ii_backend;

const balanceButton = document.getElementById("getBalanceButton");
balanceButton.onclick = async (e) => {
    e.preventDefault();
    const principalName = document.getElementById("name");

    balanceButton.setAttribute("disabled", true);

    // Interact with backend actor, calling the getBalance method
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

const userReputationButton = document.getElementById("userReputation");
userReputationButton.onclick = async (e) => {
    e.preventDefault();
    const principalName = document.getElementById("user");

    userReputationButton.setAttribute("disabled", true);

    // Interact with backend actor, calling the getUserReputation method
    const getBalance = await actor.getUserReputation(principalName);

    userReputationButton.removeAttribute("disabled");updateDocHistory

    document.getElementById("reputationResult").innerText = getBalance;

    return false;
};

const branchReputationButton = document.getElementById("branchReputation");
branchReputationButton.onclick = async (e) => {
    e.preventDefault();
    const principalName = document.getElementById("name");
    const branch = document.getElementById("branch");

    branchReputationButton.setAttribute("disabled", true);

    // Interact with backend actor, calling the getReputationByBranch method
    const getBalance = await actor.getReputationByBranch(principalName, branch);

    branchReputationButton.removeAttribute("disabled");

    document.getElementById("branchResult").innerText = getBalance;

    return false;
};

const updateDocHistoryButton = document.getElementById("updateDocHistory");
updateDocHistoryButton.onclick = async (e) => {
    e.preventDefault();
    const principalName = document.getElementById("name");
    const docId = document.getElementById("docid");
    const value = document.getElementById("value");
    const comment = document.getElementById("comment");


    updateDocHistoryButton.setAttribute("disabled", true);

    // Interact with backend actor, calling the setUserReputation method
    const docHistory = await actor.updateDocHistory(principalName, docId, value, comment);

    updateDocHistoryButton.removeAttribute("disabled");

    document.getElementById("updateDocHistoryResult").innerText = docHistory;

    return false;
};

const getDocumentsByUserButton = document.getElementById("getDocumentsByUser");
getDocumentsByUserButton.onclick = async (e) => {
    e.preventDefault();
    const principalName = document.getElementById("username");

    getDocumentsByUserButton.setAttribute("disabled", true);

    // Interact with backend actor, calling the setUserReputation method
    const docList = await actor.getDocumentsByUser(principalName);

    getDocumentsByUserButton.removeAttribute("disabled");
    const usersTableBody = document.getElementById("usersTableBody");
    usersTableBody.innerHTML = "";
    for (let doc of docList) {
        const row = document.createElement("tr");
        const docCell = document.createElement("td");
        const contentCell = document.createElement("td");
        const imageLinkCell = document.createElement("td");
        const tagCell = document.createElement("td");

        imageLinkCell.textContent = doc.imageLink;
        docCell.textContent = doc.docId; 
        contentCell.textContent = doc.content; 
        tagCell.textContent = doc.tags; 

        row.appendChild(docCell);
        row.appendChild(imageLinkCell);
        row.appendChild(contentCell);
        row.appendChild(tagCell);
        usersTableBody.appendChild(row);
      };

    // document.getElementById("documentsByUserResult").innerText = docList;

    return false;
};