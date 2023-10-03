import {createActor, ver_ii_backend} from "../../declarations/ver_ii_backend";
import {AuthClient} from "@dfinity/auth-client"
import {HttpAgent} from "@dfinity/agent";
import { Principal } from "@dfinity/principal";

let actor = ver_ii_backend;
let user = await ver_ii_backend.user();

function clearAll() {
    // Clear the current content
    const tableBody = document.getElementById('resultDocuments');    
    if (tableBody) {
        tableBody.innerHTML = '';  
    };

    let clearCard = document.getElementById('documentResult');
    if (clearCard) {
        clearCard.innerHTML = ''; 
    };

    let resultCard = document.getElementById('resultCard');
    if (resultCard) {
        resultCard.innerHTML = ''; 
    };
    
};


const docsButton = document.getElementById("reaction");
docsButton.onclick = async (e) => {
    e.preventDefault();

    docsButton.setAttribute("disabled", true);

    try {
        const docTokens = await ver_ii_backend.getTokenDAO();

        const tableBody = document.getElementById('resultDocuments');
        // Clear the current content
        clearAll();

        docTokens.forEach(token => {
            const row = tableBody.insertRow();

            // № column
            const numberCell = row.insertCell(0);
            const numberLink = document.createElement("a");
            numberLink.href = "#"; 
            numberLink.textContent = token.docId;
            numberLink.onclick = (e) => {
                e.preventDefault(); 
                displayDocumentCard(token.docId);

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

    docsButton.removeAttribute("disabled");

    return false;
};

const loginButton = document.getElementById("login");
loginButton.title = user;
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
    const user_icon =`<svg class="svg-icon" style="width: 2em; height: 2em;vertical-align: middle;fill: currentColor;overflow: hidden;" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg"><path d="M843.282963 870.115556c-8.438519-140.515556-104.296296-257.422222-233.908148-297.14963C687.881481 536.272593 742.4 456.533333 742.4 364.088889c0-127.241481-103.158519-230.4-230.4-230.4S281.6 236.847407 281.6 364.088889c0 92.444444 54.518519 172.183704 133.12 208.877037-129.611852 39.727407-225.46963 156.634074-233.908148 297.14963-0.663704 10.903704 7.964444 20.195556 18.962963 20.195556l0 0c9.955556 0 18.299259-7.774815 18.962963-17.73037C227.745185 718.506667 355.65037 596.385185 512 596.385185s284.254815 122.121481 293.357037 276.195556c0.568889 9.955556 8.912593 17.73037 18.962963 17.73037C835.318519 890.311111 843.946667 881.019259 843.282963 870.115556zM319.525926 364.088889c0-106.287407 86.186667-192.474074 192.474074-192.474074s192.474074 86.186667 192.474074 192.474074c0 106.287407-86.186667 192.474074-192.474074 192.474074S319.525926 470.376296 319.525926 364.088889z" fill="#EE4817" /></svg>`;
    user = currentUser;
    console.log(currentUser);
    document.getElementById("user").innerHTML = user_icon;
    document.getElementById("user").title = currentUser;
    document.getElementById("login").style.display = "none";
    const balance = await actor.getUserReputation(user);
    console.log("Current User Reputation is ", balance);

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
            // TODO reputation value check - access will be granted to experts with reputaion >=5 only
            const rep = await ver_ii_backend.updateDocHistory(Principal.fromText(user), tokenId, 1, "test_increase +1");
            let new_rep = token.reputation + rep.Ok.value;
            
            avaButton.textContent = "Reputation increased! New rep: " + new_rep;
            console.log("New rep: ", rep.Ok);
            const balance = await actor.getUserReputation(user);
            console.log("Current User Reputation is ", balance);
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
        clearAll();

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

document.getElementById("s").addEventListener("click", handleReputationClick);

function handleReputationClick() {
    // Clear the table content
    document.getElementById("table-title").innerHTML = "";
    document.getElementById("table").innerHTML = "";

    // Create new content
    const container = document.createElement('div');
    container.innerHTML = `
        <div id="form-container">
            <form id="nft-form">
                <h2 id="form-title">Create aVa Doctoken</h1>
               
                <div class="field">
                    <label for="content">Content:</label>
                    <input type="text" id="content" name="content" placeholder="Short content">
                </div>
                
                <div class="field">
                    <label for="image">Image:</label>
                    <input type="text" id="image" name="image" placeholder="Image link">
                </div>
                
                <div class="field">
                    <label for="branch">Branch*:</label>
                    <input type="number" id="branch" name="branch" placeholder="Branch Number">
                </div>
                
                <button type="submit">Create Doctoken</button>
            </form>
        </div>
        <div class="card-container">
            <section id="result"></section>
        </div>
    `;

    document.getElementById("documentResult").appendChild(container);

    // Add the form event listener
    document.querySelector("form").addEventListener("submit", async (e) => {
        e.preventDefault();
        const button = e.target.querySelector("button");

        const author = user; 
        const content = document.getElementById("content").value.toString();
        const image = document.getElementById("image").value.toString();
        const branch = document.getElementById("branch").value;

        // Set default values from placeholders if fields are empty
        if (content === "") {
            content.value = "New Doctoken (aVa Doctoken )";
        }
        if (image === "") {
            image.value = "image_rep.svg";
        }

        button.setAttribute("disabled", true);

        // Interact with the Dip721NFT actor, calling the mintNFT method
        const resp = await ver_ii_backend.createDocToken(Principal.fromText(author), author, content, image,  branch);
        const response = resp.Ok;
        console.log(response);
        button.removeAttribute("disabled");

        // After minting, display results in card
        const resultcontainer = document.createElement('div');
        resultcontainer.classList.add('resultcontainer');
        
        // document.getElementById("resultcontainer").innerText = `Your aVa Doctoken: \n\n`;

        const card = document.createElement('div');
        console.log("Response card container created");
        card.classList.add('card');
        card.innerHTML = `
            <div class="card-image">
                <img src=${response.imageLink} alt="image"> 
            </div>
            <div class="card-content">
                <h1 class="card-title">Doctoken # ${response.docId}</h1>
                <div class="card-info">
                    <div class="info-item">
                        <span class="info-label">Owner:</span>
                        <span class="info-value">${user}</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Tags:</span>
                        <span class="info-value">${response.tags}</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Content:</span>
                        <span class="info-value">${response.content}</span> 
                    </div>
                   
                    <div class="info-item">
                        <span class="info-label">Image:</span>
                        <span class="info-value" id="dip-link">${response.imageLink}</span>
                    </div>
                </div>
                <a href="http://ava.capetown/en" target="_blank"><button class="ava-button">aVa</button></a>
            </div>
        `;
        console.log("Response card formed");

        document.getElementById('resultCard').appendChild(card);
        return false;
    });
}
