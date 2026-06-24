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
let revealedCards = [];
let stage = "idle";
let pressTimer = null;
let isPointerDown = false;
let pointerStartX = 0;
let tearProgress = 0;

const screens = {
  selection: document.querySelector("#pack-selection"),
  opening: document.querySelector("#pack-opening"),
  results: document.querySelector("#results")
};

const packList = document.querySelector("#pack-list");
const resultList = document.querySelector("#result-list");
const interactivePack = document.querySelector("#interactive-pack");
const stageLabel = document.querySelector("#stage-label");
const openingTitle = document.querySelector("#pack-opening-title");
const openingSubtitle = document.querySelector("#pack-opening-subtitle");
const revealStrip = document.querySelector("#reveal-strip");
const viewResultsButton = document.querySelector("#view-results-button");

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
  revealedCards = [];
  tearProgress = 0;
  openingTitle.textContent = pack.name;
  setStage("idle");
  renderRevealStrip();
  viewResultsButton.hidden = true;
  showScreen("opening");
}

function setStage(nextStage, payload = {}) {
  stage = nextStage;

  interactivePack.classList.toggle("is-charging", stage === "charging");
  interactivePack.classList.toggle("is-tearing", stage === "tearing");
  interactivePack.style.setProperty("--tear-progress", `${Math.round(tearProgress * 100)}%`);

  const index = payload.index ?? 0;
  const messages = {
    idle: ["Hold to charge", "Long press the pack to build energy."],
    charging: ["Charging", "Keep holding until the pack is ready."],
    readyToTear: ["Ready to tear", "Swipe right across the pack to tear it open."],
    tearing: ["Tearing", `Tearing ${Math.round(tearProgress * 100)}%. Keep swiping right.`],
    opening: ["Opening", "The pack is opening. Cards will reveal one by one."],
    revealing: ["Revealing", `Revealing card ${index + 1} of ${selectedPack.cardsPerOpening}.`],
    completed: ["Completed", "All cards are revealed. You can inspect the full result list."]
  };

  const [label, message] = messages[stage];
  stageLabel.textContent = label;
  openingSubtitle.textContent = message;
  interactivePack.setAttribute("aria-label", message);
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
      <span class="chevron" aria-hidden="true">&gt;</span>
    `;
    button.addEventListener("click", () => openPack(pack));
    packList.appendChild(button);
  });
}

function renderRevealStrip(highlightedIndex = -1) {
  revealStrip.innerHTML = "";

  revealedCards.forEach((card, index) => {
    const colors = rarityColors[card.rarity];
    const item = document.createElement("article");
    item.className = `mini-card${index === highlightedIndex ? " is-highlighted" : ""}`;
    item.style.background = colors.background;
    item.style.color = colors.color;
    item.innerHTML = `
      <span>${card.rarity}</span>
      <strong>${card.name}</strong>
      <small>${card.power}</small>
    `;
    revealStrip.appendChild(item);
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

function beginOpening() {
  if (stage === "opening" || stage === "revealing" || stage === "completed") {
    return;
  }

  openedCards = shuffle(cards).slice(0, selectedPack.cardsPerOpening);
  revealedCards = [];
  setStage("opening");
  window.setTimeout(() => revealCardAtIndex(0), 650);
}

function revealCardAtIndex(index) {
  if (index >= openedCards.length) {
    setStage("completed");
    viewResultsButton.hidden = false;
    return;
  }

  revealedCards = openedCards.slice(0, index + 1);
  setStage("revealing", { index });
  renderRevealStrip(index);
  window.setTimeout(() => revealCardAtIndex(index + 1), 420);
}

function updateTearProgress(clientX) {
  if (stage !== "readyToTear" && stage !== "tearing") {
    return;
  }

  tearProgress = Math.min(Math.max((clientX - pointerStartX) / 120, 0), 1);
  setStage("tearing");

  if (tearProgress >= 1) {
    beginOpening();
  }
}

interactivePack.addEventListener("pointerdown", (event) => {
  if (stage !== "idle" && stage !== "readyToTear" && stage !== "tearing") {
    return;
  }

  event.preventDefault();
  isPointerDown = true;
  pointerStartX = event.clientX;
  interactivePack.setPointerCapture(event.pointerId);

  if (stage === "idle") {
    setStage("charging");
    pressTimer = window.setTimeout(() => setStage("readyToTear"), 750);
  }
});

interactivePack.addEventListener("pointermove", (event) => {
  if (!isPointerDown) {
    return;
  }

  updateTearProgress(event.clientX);
});

interactivePack.addEventListener("pointerup", (event) => {
  isPointerDown = false;
  window.clearTimeout(pressTimer);

  if (stage === "charging") {
    setStage("idle");
  } else if (stage === "tearing" && tearProgress < 1) {
    setStage("readyToTear");
  }

  interactivePack.releasePointerCapture(event.pointerId);
});

interactivePack.addEventListener("pointercancel", () => {
  isPointerDown = false;
  window.clearTimeout(pressTimer);
  if (stage === "charging" || stage === "tearing") {
    setStage("readyToTear");
  }
});

interactivePack.addEventListener("contextmenu", (event) => {
  event.preventDefault();
});

viewResultsButton.addEventListener("click", () => {
  renderResults();
  showScreen("results");
});

document.querySelectorAll("[data-back-to]").forEach((button) => {
  button.addEventListener("click", () => {
    window.clearTimeout(pressTimer);
    showScreen("selection");
  });
});

renderPacks();
