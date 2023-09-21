import { doctoken_backend } from "../../declarations/doctoken_backend";
import { Principal } from "@dfinity/principal";

document.querySelector("form").addEventListener("submit", async (e) => {
  e.preventDefault();
  const button = e.target.querySelector("button");

  const author = document.getElementById("principal").value.toString();
  const description = document.getElementById("description").value.toString();
  const checksum = document.getElementById("image").value.toString();
  const link = document.getElementById("link").value.toString();

  
  // Set default values from placeholders if fields are empty
  if (author.value === "") {
    principalField.value = "aaaaa-aa";
  }
  if (description.value === "") {
    descriptionField.value = "New Document NFT (aVa Doctoken project)";
  }
  if (link.value === "") {
    linkField.value = "http://ava.captown/en";
  }
  if (image.value === "") {
    image.value = "1.jpg";
  }

  button.setAttribute("disabled", true);

  // Interact with the Dip721NFT actor, calling the mintNFT method
  const response = await doctoken_backend.mintNFT(Principal.fromText(author), author, description, checksum, link);
  console.log(response);
  const receipt = response.Ok;
  const owner_nft = receipt.owner; 
  button.removeAttribute("disabled");

  // After minting, display results in card
  document.getElementById("resultcontainer").innerText = `Your aVa Document NFT:\n\n`;

  const card = document.createElement('div');
  card.classList.add('card');
  const imageview = image.value;
  card.innerHTML = `
    
      <div class="card-image">
        <img src=${imageview} alt="img"> 
      </div>
      <div class="card-content">
        <h1 class="card-title">Minted NFT</h1>
        <div class="card-info">
          <div class="info-item">
            <span class="info-label">Token ID:</span>
            <span class="info-value">${receipt.token_id}</span> 
          </div>
          <div class="info-item">
            <span class="info-label">Owner:</span>
            <span class="info-value">${owner_nft}</span>
          </div>
          <div class="info-item">
            <span class="info-label">Link:</span>
            <span class="info-value" id="dip-link">${receipt.link}</span>
          </div>
        </div>
        <a href="http://ava.capetown/en" target="_blank"><button class="ava-button">aVa</button></a>
      </div>
  `;
  
  document.getElementById('result').appendChild(card);
 
  return false;
});

var buttonNft = document.getElementById("nftlink");
if (buttonNft) {
  buttonNft.addEventListener("click", function () {
    window.open = "http://127.0.0.1:8000/?canisterId=be2us-64aaa-aaaaa-qaabq-cai&id=bkyz2-fmaaa-aaaaa-qaaaq-cai";
  });
}; 
