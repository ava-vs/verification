import {createActor, ver_ii_backend} from "../../declarations/ver_ii_backend";
import {AuthClient} from "@dfinity/auth-client"
import {HttpAgent} from "@dfinity/agent";
import { Principal } from "@dfinity/principal";

let actor = ver_ii_backend;
let user = await ver_ii_backend.user();

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
    const home_icon = `<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M31 17C30.8684 17.0008 30.738 16.9755 30.6161 16.9258C30.4943 16.876 30.3835 16.8027 30.29 16.71L16 2.41001L1.71003 16.71C1.51873 16.8738 1.27265 16.9594 1.02097 16.9497C0.769298 16.94 0.530559 16.8357 0.352464 16.6576C0.17437 16.4795 0.0700372 16.2407 0.0603161 15.9891C0.0505949 15.7374 0.136201 15.4913 0.300027 15.3L15.3 0.300009C15.4874 0.113758 15.7408 0.00921631 16.005 0.00921631C16.2692 0.00921631 16.5227 0.113758 16.71 0.300009L31.71 15.3C31.8476 15.4404 31.9408 15.6182 31.9779 15.8113C32.015 16.0043 31.9944 16.204 31.9186 16.3854C31.8429 16.5668 31.7153 16.7218 31.552 16.8312C31.3886 16.9405 31.1966 16.9992 31 17Z" fill="#EE4817"/>
    <path d="M16 5.78998L4 17.83V30C4 30.5304 4.21071 31.0391 4.58579 31.4142C4.96086 31.7893 5.46957 32 6 32H13V22H19V32H26C26.5304 32 27.0391 31.7893 27.4142 31.4142C27.7893 31.0391 28 30.5304 28 30V17.76L16 5.78998Z" fill="#EE4817"/>
    </svg>`;
    user = currentUser;
    console.log(currentUser);
    document.getElementById("user").innerHTML = home_icon;
    document.getElementById("login").style.display = "none";

    return false;
};

async function displayDocumentCard(tokenId) {
    try {
        const result = await ver_ii_backend.getDocTokenById(tokenId);
        console.log("Result = ", result);
        const res = result.Ok;

        const card = document.createElement('div');
        card.classList.add('card');

        const imageview = "image_rep.svg";  

        let cardInfoContent = '';
        res.metadata[0].key_val_data.forEach(item => {
            const value = item.val.LinkContent || item.val.TextContent || item.val.IntContent || 'N/A';
            cardInfoContent += `
                <div class="info-item">
                    <span class="info-label">${item.key}:</span>
                    <span class="info-value">${value}</span>
                </div>
            `;
        });

        card.innerHTML = `
            <div class="card-image">
                <img src=${imageview} alt="img"> 
            </div>
            <div class="card-content">
                <h1 class="card-title">Doctoken # ${tokenId}</h1>
                <div class="card-info">
                    ${cardInfoContent}
                </div>
                <button class="ava-button">Increase reputation</button>
            </div>
        `;
        const avaButton = card.querySelector(".ava-button");

        avaButton.onclick = async function() {
            const rep = await ver_ii_backend.updateDocHistory(Principal.fromText(user), tokenId, 1, "test_increase +1");
            console.log("New rep: ", rep.Ok);
        };

        const container = document.getElementById("documentResult");
        container.innerHTML = '';  
        container.appendChild(card);

    } catch (error) {
        console.error("Error displaying document card:", error);
    }
};

const myDocsButton = document.getElementById("docs");
myDocsButton.onclick = async (e) => {
    e.preventDefault();

    myDocsButton.setAttribute("disabled", true);

    try {       
        console.log(user);
        const docTokens = await ver_ii_backend.getTokenDAOByUser(Principal.fromText(user));
        const tableBody = document.getElementById('resultDocuments');
        tableBody.innerHTML = ''; 
        let clearCard = document.getElementById('documentResult');
        clearCard.innerHTML = ''; 

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
                displayDocumentCard(token.docId);
                // ver_ii_backend.getDocTokenById(token.docId).then(result => {
                //     console.log("Result = ", result);
                //     const res = result.Ok;
                    
                //     const card = document.createElement('div');
                //     card.classList.add('card');
                    
                //     const imageview = "image_rep.svg";  

                //     let cardInfoContent = '';
                //     res.metadata[0].key_val_data.forEach(item => {
                //         const value = item.val.LinkContent || item.val.TextContent || item.val.IntContent || 'N/A';
                //         cardInfoContent += `
                //             <div class="info-item">
                //                 <span class="info-label">${item.key}:</span>
                //                 <span class="info-value">${value}</span>
                //             </div>
                //         `;
                //     });
                   
                //     const tokenId = token.docId;
                //     card.innerHTML = `
                //         <div class="card-image">
                //             <img src=${imageview} alt="img"> 
                //         </div>
                //         <div class="card-content">
                //             <h1 class="card-title">Doctoken # ${tokenId}</h1>
                //             <div class="card-info">
                //                 ${cardInfoContent}
                //             </div>
                //             <button class="ava-button">Increase reputation</button>
                //         </div>
                //     `;
                //     const avaButton = card.querySelector(".ava-button");
        
                //     avaButton.onclick = async function() {
                //         const rep = await ver_ii_backend.updateDocHistory(Principal.fromText(user), tokenId, 1, "test_increase +1");
                //         console.log("New rep: ", rep.Ok);
                //     };

                //     const container = document.getElementById("documentResult");
                //     container.innerHTML = '';  
                //     container.appendChild(card);
                    
                // });
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

        });
    } catch (error) {
        console.error("Error loading documents:", error);
    };

    myDocsButton.removeAttribute("disabled");

    return false;
};
