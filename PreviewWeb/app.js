const cards = [
  { name: "Spark Squire", rarity: "Common", power: 120, flavorText: "A bright first step into the arena." },
  { name: "Moss Guard", rarity: "Common", power: 140, flavorText: "Stands firm when the field gets loud." },
  { name: "River Scout", rarity: "Common", power: 150, flavorText: "Finds a path before the map catches up." },
  { name: "Amber Archer", rarity: "Rare", power: 230, flavorText: "Every shot carries a little sunrise." },
  { name: "Moonlit Sage", rarity: "Rare", power: 260, flavorText: "Reads tomorrow from a silver cup." },
  { name: "Crimson Duelist", rarity: "Rare", power: 280, flavorText: "Bows once, then ends the argument." },
  { name: "Storm Chimera", rarity: "Epic", power: 420, flavorText: "Three roars, one terrible answer." },
  { name: "Crystal Oracle", rarity: "Epic", power: 450, flavorText: "The future reflects whoever dares look." },
  { name: "Sunforged Dragon", rarity: "Legendary", power: 720, flavorText: "Its wings remember the first flame." },
  { name: "Eclipse Empress", rarity: "Legendary", power: 760, flavorText: "Night and day negotiate at her feet." }
];

const packs = [
  {
    name: "Starter Pack",
    subtitle: "A balanced 5-card opening for the first MVP test.",
    cardsPerOpening: 5
  },
  {
    name: "Rare Boost Pack",
    subtitle: "A simple local pack with the same dummy pool.",
    cardsPerOpening: 5
  }
];

const rarityColors = {
  Common: { background: "#e5e7eb", color: "#374151" },
  Rare: { background: "#dbeafe", color: "#1d4ed8" },
  Epic: { background: "#f3e8ff", color: "#7e22ce" },
  Legendary: { background: "#ffedd5", color: "#c2410c" }
};

let selectedPack = packs[0];
let openedCards = [];

const screens = {
  selection: document.querySelector("#pack-selection"),
  opening: document.querySelector("#pack-opening"),
  results: document.querySelector("#results")
};

const packList = document.querySelector("#pack-list");
const resultList = document.querySelector("#result-list");
const openingTitle = document.querySelector("#pack-opening-title");
const openingSubtitle = document.querySelector("#pack-opening-subtitle");
const openPackButton = document.querySelector("#open-pack-button");

function showScreen(screenName) {
  Object.values(screens).forEach((screen) => screen.classList.remove("is-active"));
  screens[screenName].classList.add("is-active");
}

function shuffle(items) {
  return [...items].sort(() => Math.random() - 0.5);
}

function openPack(pack) {
  selectedPack = pack;
  openedCards = [];
  openingTitle.textContent = pack.name;
  openingSubtitle.textContent = `Tap the button to open ${pack.cardsPerOpening} local dummy cards.`;
  openPackButton.textContent = "Open Pack";
  showScreen("opening");
}

function renderPacks() {
  packList.innerHTML = "";

  packs.forEach((pack) => {
    const button = document.createElement("button");
    button.className = "pack-card";
    button.type = "button";
    button.innerHTML = `
      <span class="pack-thumb" aria-hidden="true">*</span>
      <span>
        <h3>${pack.name}</h3>
        <p>${pack.subtitle}</p>
        <p>${pack.cardsPerOpening} cards</p>
      </span>
      <span class="chevron" aria-hidden="true">›</span>
    `;
    button.addEventListener("click", () => openPack(pack));
    packList.appendChild(button);
  });
}

function renderResults() {
  resultList.innerHTML = "";

  openedCards.forEach((card) => {
    const colors = rarityColors[card.rarity];
    const article = document.createElement("article");
    article.className = "result-card";
    article.innerHTML = `
      <div class="rarity-badge" style="background: ${colors.background}; color: ${colors.color};">
        ${card.rarity}
      </div>
      <div>
        <div class="result-meta">
          <h3>${card.name}</h3>
          <span class="power" style="color: ${colors.color};">${card.power}</span>
        </div>
        <p>${card.flavorText}</p>
      </div>
    `;
    resultList.appendChild(article);
  });
}

openPackButton.addEventListener("click", () => {
  openedCards = shuffle(cards).slice(0, selectedPack.cardsPerOpening);
  renderResults();
  showScreen("results");
});

document.querySelectorAll("[data-back-to]").forEach((button) => {
  button.addEventListener("click", () => showScreen("selection"));
});

renderPacks();
