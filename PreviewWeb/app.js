"use strict";

const CARDS = Object.freeze([
  {
    id: "normal",
    rarity: "Normal",
    rarityShort: "N",
    name: "Flint Imp",
    subtitle: "石刃の小鬼",
    image: "assets/cards/normal.webp",
    attribute: "EARTH",
    attributeColor: "#596c46",
    level: 3,
    type: "[ Fiend / Guard ]",
    text: "岩鉄の鎧は、弱き者を守るたびに硬度を増す。",
    flavor: "欠けた刃でも、守る意志までは折れない。",
    attack: 1200,
    defense: 1500,
    rgb: "169, 178, 191",
    sound: "reveal-normal",
    particleCount: 10
  },
  {
    id: "rare",
    rarity: "Rare",
    rarityShort: "R",
    name: "Azure Gale Wyvern",
    subtitle: "蒼雷の飛竜",
    image: "assets/cards/rare.webp",
    attribute: "WIND",
    attributeColor: "#287aa8",
    level: 5,
    type: "[ Dragon / Volt ]",
    text: "蒼雷を翼に束ね、雲海を一息で切り裂く。",
    flavor: "その羽ばたきの後に、遅れて雷鳴が届く。",
    attack: 2100,
    defense: 1600,
    rgb: "79, 169, 255",
    sound: "reveal-rare",
    particleCount: 18
  },
  {
    id: "super",
    rarity: "Super Rare",
    rarityShort: "SR",
    name: "Selene of the Moon Mirror",
    subtitle: "月鏡のセレネ",
    image: "assets/cards/super-rare.webp",
    attribute: "MOON",
    attributeColor: "#6383b9",
    level: 7,
    type: "[ Spellblade / Oracle ]",
    text: "五面の月鏡が敵意を映し、銀の刃へと変える。",
    flavor: "未来は一つではない。鏡の数だけ選び直せる。",
    attack: 2600,
    defense: 2300,
    rgb: "130, 244, 255",
    sound: "reveal-super",
    particleCount: 28
  },
  {
    id: "ultra",
    rarity: "Ultra Rare",
    rarityShort: "UR",
    name: "Noctis Drakon",
    subtitle: "黒曜陽帝竜",
    image: "assets/cards/ultra-rare.webp",
    attribute: "DARK",
    attributeColor: "#3f2f61",
    level: 9,
    type: "[ Dragon / Emperor ]",
    text: "胸核に沈む黒い太陽が、戦場の光をすべて喰らう。",
    flavor: "夜を支配するのではない。夜そのものが彼に従う。",
    attack: 3300,
    defense: 2800,
    rgb: "247, 185, 68",
    sound: "reveal-ultra",
    particleCount: 38
  },
  {
    id: "ultimate",
    rarity: "Ultimate Rare",
    rarityShort: "ULT",
    name: "Astra Nova",
    subtitle: "天環機神アストラ・ノヴァ",
    image: "assets/cards/ultimate-rare.webp",
    attribute: "LIGHT",
    attributeColor: "#c89e47",
    level: 12,
    type: "[ Machine / Cosmic Deity ]",
    text: "十二天環が同期した時、星系は一度だけ新しく生まれ直す。",
    flavor: "終焉ではない。次の宇宙が起動する音だ。",
    attack: 4000,
    defense: 4000,
    rgb: "255, 239, 190",
    sound: "reveal-ultimate",
    particleCount: 56
  }
]);

const SOUND_PATHS = Object.freeze({
  charge: "assets/sfx/charge.wav",
  ready: "assets/sfx/ready.wav",
  tear: "assets/sfx/tear.wav",
  whoosh: "assets/sfx/whoosh.wav",
  "reveal-normal": "assets/sfx/reveal-normal.wav",
  "reveal-rare": "assets/sfx/reveal-rare.wav",
  "reveal-super": "assets/sfx/reveal-super.wav",
  "reveal-ultra": "assets/sfx/reveal-ultra.wav",
  "reveal-ultimate": "assets/sfx/reveal-ultimate.wav"
});

const STAGE_COPY = Object.freeze({
  idle: {
    label: "ENERGY DORMANT",
    instruction: "パックを長押しして、エネルギーを100%まで満たす",
    aria: "パックを長押ししてチャージ。EnterまたはSpaceキーでもチャージできます。"
  },
  charging: {
    label: "CHARGING",
    instruction: "そのまま押し続ける",
    aria: "チャージ中です。そのまま押し続けてください。"
  },
  readyToTear: {
    label: "SEAL UNLOCKED",
    instruction: "パック上部を右へスワイプして切り裂く",
    aria: "チャージ完了。右へスワイプして切り裂くか、EnterまたはSpaceキーを押してください。"
  },
  tearing: {
    label: "TEARING SEAL",
    instruction: "右へ滑らせてシールを切り裂く",
    aria: "パックのシールを切り裂いています。右へ動かしてください。"
  },
  opening: {
    label: "PACK OPEN",
    instruction: "封入カードを展開中",
    aria: "パックが開きました。カードを展開しています。"
  }
});

const elements = {
  body: document.body,
  brandHome: document.querySelector("#brand-home"),
  soundToggle: document.querySelector("#sound-toggle"),
  openPackButton: document.querySelector("#open-pack-button"),
  openingBackButton: document.querySelector("#opening-back-button"),
  openAgainButton: document.querySelector("#open-again-button"),
  selection: document.querySelector("#pack-selection"),
  opening: document.querySelector("#pack-opening"),
  results: document.querySelector("#results"),
  selectionTitle: document.querySelector("#selection-title"),
  openingTitle: document.querySelector("#opening-title"),
  resultsTitle: document.querySelector("#results-title"),
  openingTheater: document.querySelector("#opening-theater"),
  packInteraction: document.querySelector("#pack-interaction"),
  interactivePack: document.querySelector("#interactive-pack"),
  stageLabel: document.querySelector("#stage-label"),
  instruction: document.querySelector("#opening-instruction"),
  chargePercent: document.querySelector("#charge-percent"),
  chargeAssistButton: document.querySelector("#charge-assist-button"),
  tearAssistButton: document.querySelector("#tear-assist-button"),
  cardRevealStage: document.querySelector("#card-reveal-stage"),
  cardCounter: document.querySelector("#card-counter"),
  revealCard: document.querySelector("#reveal-card"),
  cardRotor: document.querySelector("#card-rotor"),
  cardFront: document.querySelector("#card-front"),
  rarityCopy: document.querySelector("#rarity-reveal-copy"),
  revealedRarity: document.querySelector("#revealed-rarity"),
  revealedName: document.querySelector("#revealed-name"),
  revealedSubtitle: document.querySelector("#revealed-subtitle"),
  nextCardButton: document.querySelector("#next-card-button"),
  revealProgress: document.querySelector("#reveal-progress"),
  resultList: document.querySelector("#result-list"),
  particleLayer: document.querySelector("#particle-layer"),
  screenFlash: document.querySelector("#screen-flash"),
  apexOverlay: document.querySelector("#apex-overlay"),
  liveStatus: document.querySelector("#live-status")
};

const mediaReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
const soundTemplates = new Map();
const soundBuffers = new Map();
const soundBufferPromises = new Map();
const activeAudio = new Set();
const activeWebAudio = new Set();
const pendingTimers = new Set();

let sessionId = 0;
let animationFrameId = 0;
let currentStage = "selection";
let currentCardIndex = -1;
let chargeProgress = 0;
let tearProgress = 0;
let pointerMode = null;
let activePointerId = null;
let pointerStartX = 0;
let tearThreshold = 96;
let chargeIsAutomatic = false;
let soundEnabled = readSoundPreference();
let audioContext = null;

function readSoundPreference() {
  try {
    return window.localStorage.getItem("arcana-burst-sound") !== "off";
  } catch (_error) {
    return true;
  }
}

function saveSoundPreference() {
  try {
    window.localStorage.setItem("arcana-burst-sound", soundEnabled ? "on" : "off");
  } catch (_error) {
    // The experience remains fully usable when storage is unavailable.
  }
}

function prepareAssets() {
  CARDS.forEach((card) => {
    const image = new Image();
    image.decoding = "async";
    image.src = card.image;
  });

  Object.entries(SOUND_PATHS).forEach(([name, path]) => {
    const audio = new Audio(path);
    audio.preload = "auto";
    soundTemplates.set(name, audio);
  });

  prepareWebAudioBuffers();
}

function getAudioContext() {
  if (audioContext && audioContext.state !== "closed") {
    return audioContext;
  }

  const AudioContextClass = window.AudioContext || window.webkitAudioContext;
  if (!AudioContextClass) {
    return null;
  }

  try {
    audioContext = new AudioContextClass();
    soundBuffers.clear();
    soundBufferPromises.clear();
    return audioContext;
  } catch (_error) {
    audioContext = null;
    return null;
  }
}

function decodeSoundBuffer(context, encodedAudio) {
  return new Promise((resolve, reject) => {
    let settled = false;
    const resolveOnce = (buffer) => {
      if (!settled) {
        settled = true;
        resolve(buffer);
      }
    };
    const rejectOnce = (error) => {
      if (!settled) {
        settled = true;
        reject(error);
      }
    };

    try {
      const decodeAttempt = context.decodeAudioData(encodedAudio.slice(0), resolveOnce, rejectOnce);
      if (decodeAttempt && typeof decodeAttempt.then === "function") {
        decodeAttempt.then(resolveOnce, rejectOnce);
      }
    } catch (error) {
      rejectOnce(error);
    }
  });
}

function loadSoundBuffer(name, path, context) {
  if (soundBuffers.has(name)) {
    return Promise.resolve(soundBuffers.get(name));
  }

  if (soundBufferPromises.has(name)) {
    return soundBufferPromises.get(name);
  }

  const loadPromise = window.fetch(path, { cache: "force-cache" })
    .then((response) => {
      if (!response.ok) {
        throw new Error(`Unable to load ${path}: ${response.status}`);
      }
      return response.arrayBuffer();
    })
    .then((encodedAudio) => decodeSoundBuffer(context, encodedAudio))
    .then((buffer) => {
      if (context === audioContext && context.state !== "closed") {
        soundBuffers.set(name, buffer);
      }
      return buffer;
    })
    .catch(() => null)
    .finally(() => soundBufferPromises.delete(name));

  soundBufferPromises.set(name, loadPromise);
  return loadPromise;
}

function prepareWebAudioBuffers(context = getAudioContext()) {
  if (!context || typeof window.fetch !== "function") {
    return;
  }

  Object.entries(SOUND_PATHS).forEach(([name, path]) => {
    void loadSoundBuffer(name, path, context);
  });
}

function unlockWebAudio() {
  if (!soundEnabled) {
    return Promise.resolve(false);
  }

  const context = getAudioContext();
  if (!context) {
    return Promise.resolve(false);
  }

  prepareWebAudioBuffers(context);
  if (context.state === "running") {
    return Promise.resolve(true);
  }

  try {
    const resumeAttempt = context.resume();
    if (resumeAttempt && typeof resumeAttempt.then === "function") {
      return resumeAttempt.then(() => context.state === "running").catch(() => false);
    }
  } catch (_error) {
    return Promise.resolve(false);
  }

  return Promise.resolve(context.state === "running");
}

function cleanupWebAudioPlayback(playback) {
  if (!activeWebAudio.delete(playback)) {
    return;
  }

  playback.source.onended = null;
  try {
    playback.source.disconnect();
  } catch (_error) {
    // Already disconnected.
  }
  try {
    playback.gain.disconnect();
  } catch (_error) {
    // Already disconnected.
  }
}

function stopWebAudioPlayback(playback) {
  if (!activeWebAudio.has(playback)) {
    return;
  }

  try {
    playback.source.stop(0);
  } catch (_error) {
    // The source may have already reached its natural end.
  }
  cleanupWebAudioPlayback(playback);
}

function playBufferedSound(name, volume) {
  const context = audioContext;
  const buffer = soundBuffers.get(name);
  if (!context || context.state !== "running" || !buffer) {
    return null;
  }

  let playback = null;
  try {
    const source = context.createBufferSource();
    const gain = context.createGain();
    playback = {
      name,
      path: SOUND_PATHS[name] || "",
      source,
      gain
    };

    source.buffer = buffer;
    gain.gain.setValueAtTime(Math.max(0, Math.min(volume, 1)), context.currentTime);
    source.connect(gain);
    gain.connect(context.destination);
    source.onended = () => cleanupWebAudioPlayback(playback);
    activeWebAudio.add(playback);
    source.start(0);
    return playback;
  } catch (_error) {
    if (playback) {
      cleanupWebAudioPlayback(playback);
    }
    return null;
  }
}

function playHtmlAudio(name, volume) {
  const template = soundTemplates.get(name);
  if (!template) {
    return null;
  }

  const audio = template.cloneNode(true);
  audio.volume = Math.max(0, Math.min(volume, 1));
  activeAudio.add(audio);
  const cleanup = () => activeAudio.delete(audio);
  audio.addEventListener("ended", cleanup, { once: true });
  audio.addEventListener("error", cleanup, { once: true });
  const playAttempt = audio.play();
  if (playAttempt && typeof playAttempt.catch === "function") {
    playAttempt.catch(cleanup);
  }
  return audio;
}

function playSound(name, volume = 0.8) {
  if (!soundEnabled) {
    return null;
  }

  return playBufferedSound(name, volume) || playHtmlAudio(name, volume);
}

function stopAllAudio() {
  Array.from(activeWebAudio).forEach(stopWebAudioPlayback);

  activeAudio.forEach((audio) => {
    audio.pause();
    try {
      audio.currentTime = 0;
    } catch (_error) {
      // Some browsers reject seeking before media metadata is available.
    }
  });
  activeAudio.clear();
}

function stopSoundBySource(fragment) {
  Array.from(activeWebAudio).forEach((playback) => {
    if (playback.name === fragment || playback.path.includes(fragment)) {
      stopWebAudioPlayback(playback);
    }
  });

  activeAudio.forEach((audio) => {
    if (audio.src.includes(fragment)) {
      audio.pause();
      activeAudio.delete(audio);
    }
  });
}

function schedule(callback, delay, token = sessionId) {
  const timerId = window.setTimeout(() => {
    pendingTimers.delete(timerId);
    if (token === sessionId) {
      callback();
    }
  }, delay);
  pendingTimers.add(timerId);
  return timerId;
}

function cancelSession({ stopAudio = true } = {}) {
  sessionId += 1;
  pendingTimers.forEach((timerId) => window.clearTimeout(timerId));
  pendingTimers.clear();

  if (animationFrameId) {
    window.cancelAnimationFrame(animationFrameId);
    animationFrameId = 0;
  }

  pointerMode = null;
  activePointerId = null;
  chargeIsAutomatic = false;

  if (stopAudio) {
    stopAllAudio();
  }

  return sessionId;
}

function announce(message) {
  elements.liveStatus.textContent = "";
  schedule(() => {
    elements.liveStatus.textContent = message;
  }, 20);
}

function showScreen(name) {
  const screens = {
    selection: elements.selection,
    opening: elements.opening,
    results: elements.results
  };

  Object.entries(screens).forEach(([screenName, screen]) => {
    screen.hidden = screenName !== name;
  });

  elements.body.dataset.stage = name;
}

function setChargeProgress(progress) {
  chargeProgress = Math.max(0, Math.min(progress, 1));
  const formatted = chargeProgress.toFixed(4);
  elements.packInteraction.style.setProperty("--charge", formatted);
  elements.chargePercent.textContent = `${Math.round(chargeProgress * 100)}%`;
}

function setTearProgress(progress) {
  tearProgress = Math.max(0, Math.min(progress, 1));
  elements.packInteraction.style.setProperty("--tear", tearProgress.toFixed(4));
}

function setStage(nextStage, { shouldAnnounce = true } = {}) {
  currentStage = nextStage;
  elements.body.dataset.stage = nextStage;

  const isCharging = nextStage === "charging";
  const isReady = nextStage === "readyToTear";
  const isTearing = nextStage === "tearing";
  const isOpened = nextStage === "opening";

  elements.interactivePack.classList.toggle("is-charging", isCharging);
  elements.interactivePack.classList.toggle("is-ready", isReady);
  elements.interactivePack.classList.toggle("is-tearing", isTearing);
  elements.interactivePack.classList.toggle("is-opened", isOpened);

  elements.chargeAssistButton.hidden = !(nextStage === "idle" || isCharging);
  elements.chargeAssistButton.disabled = isCharging;
  elements.tearAssistButton.hidden = !(isReady || isTearing);
  elements.tearAssistButton.disabled = isTearing;

  const copy = STAGE_COPY[nextStage];
  if (copy) {
    elements.stageLabel.textContent = copy.label;
    elements.instruction.textContent = copy.instruction;
    elements.interactivePack.setAttribute("aria-label", copy.aria);
    if (shouldAnnounce) {
      announce(copy.aria);
    }
  }
}

function resetVisualEffects() {
  elements.body.dataset.rarity = "none";
  elements.openingTheater.classList.remove("is-impacting");
  elements.screenFlash.classList.remove("is-active");
  elements.apexOverlay.classList.remove("is-primed", "is-bursting");
  elements.particleLayer.replaceChildren();
}

function resetOpeningProgress() {
  currentCardIndex = -1;
  setChargeProgress(0);
  setTearProgress(0);
  resetVisualEffects();
  elements.packInteraction.hidden = false;
  elements.cardRevealStage.hidden = true;
  elements.nextCardButton.hidden = true;
  elements.rarityCopy.classList.remove("is-visible");
  elements.rarityCopy.setAttribute("aria-hidden", "true");
  elements.cardFront.setAttribute("aria-hidden", "true");
  elements.revealProgress.querySelectorAll("li").forEach((item, itemIndex) => {
    item.classList.remove("is-current", "is-revealed");
    item.removeAttribute("data-rarity");
    item.querySelector("b").textContent = String(itemIndex + 1);
    item.setAttribute("aria-label", `${itemIndex + 1}枚目、未公開`);
  });
}

function beginOpeningFromUserGesture() {
  void unlockWebAudio();
  beginOpeningExperience();
}

function beginOpeningExperience() {
  cancelSession();
  resetOpeningProgress();
  showScreen("opening");
  setStage("idle", { shouldAnnounce: false });
  window.scrollTo({ top: 0, behavior: mediaReducedMotion.matches ? "auto" : "smooth" });
  elements.openingTitle.focus({ preventScroll: true });
  announce("First Contactパックを開封します。パックを長押ししてチャージしてください。");
}

function returnToSelection() {
  cancelSession();
  resetOpeningProgress();
  showScreen("selection");
  window.history.replaceState(null, "", "#pack-selection");
  window.scrollTo({ top: 0, behavior: mediaReducedMotion.matches ? "auto" : "smooth" });
  elements.openPackButton.focus({ preventScroll: true });
  announce("パック選択に戻りました。");
}

function beginCharge({ automatic }) {
  if (currentStage !== "idle") {
    return;
  }

  chargeIsAutomatic = automatic;
  const token = sessionId;
  const startedAt = performance.now();
  const duration = mediaReducedMotion.matches ? 360 : 1050;
  setStage("charging");
  playSound("charge", 0.58);

  const tick = (now) => {
    if (token !== sessionId || currentStage !== "charging") {
      return;
    }

    const progress = Math.min((now - startedAt) / duration, 1);
    const shapedProgress = 1 - Math.pow(1 - progress, 1.35);
    setChargeProgress(shapedProgress);

    if (progress >= 1) {
      animationFrameId = 0;
      completeCharge();
      return;
    }

    animationFrameId = window.requestAnimationFrame(tick);
  };

  animationFrameId = window.requestAnimationFrame(tick);
}

function cancelManualCharge() {
  if (currentStage !== "charging" || chargeIsAutomatic) {
    return;
  }

  if (animationFrameId) {
    window.cancelAnimationFrame(animationFrameId);
    animationFrameId = 0;
  }
  stopSoundBySource("charge.wav");
  setChargeProgress(0);
  setStage("idle");
}

function completeCharge() {
  const shouldMoveFocus = chargeIsAutomatic;
  const shouldContinuePointerGesture = !chargeIsAutomatic && pointerMode === "charge" && activePointerId !== null;
  setChargeProgress(1);
  chargeIsAutomatic = false;
  stopSoundBySource("charge.wav");
  setStage("readyToTear");
  playSound("ready", 0.72);
  createAmbientParticles("ready", 12);
  vibrate([16, 35, 22]);
  if (shouldContinuePointerGesture) {
    beginTear(pointerStartX);
  } else if (shouldMoveFocus) {
    schedule(() => elements.tearAssistButton.focus({ preventScroll: true }), 30);
  }
}

function beginTear(clientX) {
  if (currentStage !== "readyToTear" && currentStage !== "tearing") {
    return;
  }

  pointerMode = "tear";
  pointerStartX = clientX;
  const width = elements.interactivePack.getBoundingClientRect().width;
  tearThreshold = Math.max(72, Math.min(106, width * 0.44));
  setStage("tearing", { shouldAnnounce: false });
}

function updateTearFromPointer(clientX) {
  if (pointerMode !== "tear" || currentStage !== "tearing") {
    return;
  }

  const nextProgress = Math.max(0, (clientX - pointerStartX) / tearThreshold);
  setTearProgress(nextProgress);

  if (tearProgress >= 1) {
    completeTear();
  }
}

function cancelPartialTear() {
  if (currentStage !== "tearing" || tearProgress >= 1) {
    return;
  }
  setTearProgress(0);
  setStage("readyToTear");
}

function performAssistedTear() {
  if (currentStage !== "readyToTear" && currentStage !== "tearing") {
    return;
  }

  setStage("tearing");
  const token = sessionId;
  const startedAt = performance.now();
  const duration = mediaReducedMotion.matches ? 120 : 420;

  const tick = (now) => {
    if (token !== sessionId || currentStage !== "tearing") {
      return;
    }
    const progress = Math.min((now - startedAt) / duration, 1);
    setTearProgress(1 - Math.pow(1 - progress, 2.3));
    if (progress >= 1) {
      animationFrameId = 0;
      completeTear();
      return;
    }
    animationFrameId = window.requestAnimationFrame(tick);
  };

  animationFrameId = window.requestAnimationFrame(tick);
}

function completeTear() {
  if (currentStage === "opening") {
    return;
  }

  pointerMode = null;
  setTearProgress(1);
  setStage("opening");
  playSound("tear", 0.92);
  flashScreen(0.38);
  vibrate([24, 28, 34]);
  schedule(() => playSound("whoosh", 0.68), mediaReducedMotion.matches ? 30 : 230);
  schedule(showFirstCard, mediaReducedMotion.matches ? 180 : 920);
}

function showFirstCard() {
  elements.packInteraction.hidden = true;
  elements.cardRevealStage.hidden = false;
  revealCardAt(0);
}

function cardFaceMarkup(card) {
  const levelPips = Array.from({ length: card.level }, () => "<i></i>").join("");
  return `
    <article class="tcg-card tcg-card--${card.id}">
      <header class="tcg-card__header">
        <h3>${card.name}</h3>
        <span class="tcg-card__attribute" style="--attribute:${card.attributeColor}">${card.attribute}</span>
      </header>
      <div class="tcg-card__level" aria-hidden="true">${levelPips}</div>
      <div class="tcg-card__art">
        <img src="${card.image}" alt="" width="1024" height="1536">
      </div>
      <p class="tcg-card__type">${card.type}</p>
      <div class="tcg-card__text">
        <p>${card.text}</p>
        <div class="tcg-card__stats"><span>ATK/${card.attack}</span><span>DEF/${card.defense}</span></div>
      </div>
    </article>
  `;
}

function revealCardAt(index) {
  if (index < 0 || index >= CARDS.length) {
    return;
  }

  currentCardIndex = index;
  const card = CARDS[index];
  const token = sessionId;
  const isUltimate = card.id === "ultimate";
  const duration = mediaReducedMotion.matches ? 100 : (isUltimate ? 1220 : 900);
  const preDelay = mediaReducedMotion.matches ? 12 : (isUltimate ? 540 : 80);

  currentStage = "revealing";
  elements.body.dataset.stage = "revealing";
  elements.body.dataset.rarity = "none";
  elements.cardCounter.textContent = `CARD ${index + 1} / ${CARDS.length}`;
  elements.cardFront.innerHTML = cardFaceMarkup(card);
  elements.cardFront.setAttribute("aria-hidden", "true");
  elements.revealCard.classList.remove("is-revealed");
  elements.revealCard.setAttribute("aria-label", `${index + 1}枚目のカードを反転中`);
  elements.revealCard.focus({ preventScroll: true });
  elements.cardRotor.classList.remove("is-flipping");
  elements.cardRotor.style.setProperty("--flip-duration", `${duration}ms`);
  elements.rarityCopy.classList.remove("is-visible");
  elements.rarityCopy.setAttribute("aria-hidden", "true");
  elements.nextCardButton.hidden = true;
  elements.nextCardButton.disabled = true;
  updateProgress(index, false);
  announce(`${index + 1}枚目のカードを反転します。`);

  if (isUltimate && !mediaReducedMotion.matches) {
    elements.apexOverlay.classList.add("is-primed");
    playSound("whoosh", 0.38);
  }

  schedule(() => {
    elements.apexOverlay.classList.remove("is-primed");
    // Reflow ensures every card begins its flip from the back face.
    void elements.cardRotor.offsetWidth;
    elements.cardRotor.classList.add("is-flipping");
    playSound("whoosh", isUltimate ? 0.82 : 0.48);

    schedule(() => revealAtMidpoint(card, index), duration * 0.5, token);
    schedule(() => finishCardReveal(card, index), duration + (mediaReducedMotion.matches ? 50 : 280), token);
  }, preDelay, token);
}

function revealAtMidpoint(card, index) {
  elements.body.dataset.rarity = card.id;
  elements.cardFront.setAttribute("aria-hidden", "false");
  elements.revealCard.classList.add("is-revealed");
  elements.revealCard.setAttribute(
    "aria-label",
    `${card.rarity}、${card.name}、${card.subtitle}。攻撃力${card.attack}、守備力${card.defense}。${card.text}`
  );

  elements.revealedRarity.textContent = card.rarity;
  elements.revealedName.textContent = card.name;
  elements.revealedSubtitle.textContent = card.subtitle;
  elements.rarityCopy.classList.add("is-visible");
  elements.rarityCopy.setAttribute("aria-hidden", "false");
  updateProgress(index, true);
  createRevealParticles(card);
  playSound(card.sound, card.id === "ultimate" ? 1 : 0.88);

  if (card.id === "super") {
    flashScreen(0.24);
    vibrate(22);
  } else if (card.id === "ultra") {
    flashScreen(0.42);
    impactTheater();
    vibrate([26, 24, 45]);
  } else if (card.id === "ultimate") {
    runUltimateApex();
    vibrate([35, 30, 50, 35, 80]);
  }

  announce(`${card.rarity}。${card.name}、${card.subtitle}を獲得しました。`);
}

function finishCardReveal(card, index) {
  currentStage = "revealReady";
  elements.body.dataset.stage = "revealReady";
  elements.nextCardButton.disabled = false;
  elements.nextCardButton.hidden = false;
  const buttonText = elements.nextCardButton.querySelector("span");
  buttonText.textContent = index === CARDS.length - 1 ? "開封結果を見る" : "次のカード";
  elements.nextCardButton.focus({ preventScroll: true });
  announce(`${card.name}の公開が完了しました。${buttonText.textContent}ボタンを押してください。`);
}

function updateProgress(index, revealed) {
  elements.revealProgress.querySelectorAll("li").forEach((item, itemIndex) => {
    const isCurrent = itemIndex === index && !revealed;
    const isRevealed = itemIndex < index || (itemIndex === index && revealed);
    const label = item.querySelector("b");
    item.classList.toggle("is-current", isCurrent);
    item.classList.toggle("is-revealed", isRevealed);

    if (isRevealed) {
      const card = CARDS[itemIndex];
      item.dataset.rarity = card.id;
      label.textContent = card.rarityShort;
      item.setAttribute("aria-label", `${itemIndex + 1}枚目、${card.rarity}、公開済み`);
    } else {
      item.removeAttribute("data-rarity");
      label.textContent = String(itemIndex + 1);
      item.setAttribute("aria-label", `${itemIndex + 1}枚目、${isCurrent ? "反転中、レア度未公開" : "未公開"}`);
    }
  });
}

function createAmbientParticles(kind, count) {
  if (mediaReducedMotion.matches) {
    return;
  }

  const color = kind === "ready" ? "#f2c66d" : "#ffffff";
  for (let index = 0; index < count; index += 1) {
    const particle = document.createElement("span");
    const angle = (Math.PI * 2 * index) / count + Math.random() * 0.35;
    const distance = 90 + Math.random() * 130;
    particle.className = `particle${index % 4 === 0 ? " particle--diamond" : ""}`;
    particle.style.setProperty("--particle-color", color);
    particle.style.setProperty("--size", `${2 + Math.random() * 4}px`);
    particle.style.setProperty("--x", `${Math.cos(angle) * 25}px`);
    particle.style.setProperty("--y", `${Math.sin(angle) * 25 + 20}px`);
    particle.style.setProperty("--tx", `${Math.cos(angle) * distance}px`);
    particle.style.setProperty("--ty", `${Math.sin(angle) * distance + 20}px`);
    particle.style.setProperty("--duration", `${720 + Math.random() * 580}ms`);
    particle.style.setProperty("--delay", `${Math.random() * 140}ms`);
    elements.particleLayer.appendChild(particle);
    schedule(() => particle.remove(), 1600);
  }
}

function createRevealParticles(card) {
  if (mediaReducedMotion.matches) {
    return;
  }

  const colors = {
    normal: ["#d3d8df", "#8993a1"],
    rare: ["#b4e2ff", "#438dff", "#ffffff"],
    super: ["#9ff7ff", "#f2a9ff", "#fff5a8", "#ffffff"],
    ultra: ["#fff0a8", "#f7a927", "#ffffff"],
    ultimate: ["#ffffff", "#ffe9a4", "#a6d9ff", "#f3b7ff"]
  }[card.id];
  const count = card.particleCount;

  for (let index = 0; index < count; index += 1) {
    const particle = document.createElement("span");
    const angle = Math.random() * Math.PI * 2;
    const distance = 120 + Math.random() * (card.id === "ultimate" ? 320 : 230);
    const startRadius = 18 + Math.random() * 50;
    const shapeClass = index % 5 === 0 ? " particle--streak" : (index % 3 === 0 ? " particle--diamond" : "");
    particle.className = `particle${shapeClass}`;
    particle.style.setProperty("--particle-color", colors[index % colors.length]);
    particle.style.setProperty("--size", `${2 + Math.random() * (card.id === "ultimate" ? 6 : 4)}px`);
    particle.style.setProperty("--x", `${Math.cos(angle) * startRadius}px`);
    particle.style.setProperty("--y", `${Math.sin(angle) * startRadius - 20}px`);
    particle.style.setProperty("--tx", `${Math.cos(angle) * distance}px`);
    particle.style.setProperty("--ty", `${Math.sin(angle) * distance - 20}px`);
    particle.style.setProperty("--duration", `${700 + Math.random() * 900}ms`);
    particle.style.setProperty("--delay", `${Math.random() * 180}ms`);
    particle.style.setProperty("--spin", `${90 + Math.random() * 540}deg`);
    elements.particleLayer.appendChild(particle);
    schedule(() => particle.remove(), 2100);
  }
}

function flashScreen(opacity) {
  if (mediaReducedMotion.matches) {
    return;
  }
  elements.screenFlash.classList.remove("is-active");
  elements.screenFlash.style.setProperty("--flash-opacity", String(opacity));
  void elements.screenFlash.offsetWidth;
  elements.screenFlash.classList.add("is-active");
  schedule(() => elements.screenFlash.classList.remove("is-active"), 700);
}

function impactTheater() {
  if (mediaReducedMotion.matches) {
    return;
  }
  elements.openingTheater.classList.remove("is-impacting");
  void elements.openingTheater.offsetWidth;
  elements.openingTheater.classList.add("is-impacting");
  schedule(() => elements.openingTheater.classList.remove("is-impacting"), 600);
}

function runUltimateApex() {
  if (mediaReducedMotion.matches) {
    return;
  }
  elements.apexOverlay.classList.remove("is-primed");
  elements.apexOverlay.classList.add("is-bursting");
  flashScreen(0.76);
  impactTheater();
  schedule(() => elements.apexOverlay.classList.remove("is-bursting"), 1250);
}

function vibrate(pattern) {
  if (typeof navigator.vibrate === "function") {
    navigator.vibrate(pattern);
  }
}

function renderResults() {
  elements.resultList.replaceChildren();

  CARDS.forEach((card, index) => {
    const article = document.createElement("article");
    article.className = "result-card";
    article.style.setProperty("--card-rgb", card.rgb);
    article.style.setProperty("--result-delay", mediaReducedMotion.matches ? "0ms" : `${index * 80}ms`);
    article.innerHTML = `
      <div class="result-card__art">
        <span class="result-card__index">0${index + 1}</span>
        <img src="${card.image}" alt="${card.name}、${card.subtitle}のカードアート" width="1024" height="1536" ${index > 1 ? "loading=\"lazy\"" : ""}>
      </div>
      <div class="result-card__body">
        <p class="result-card__rarity">${card.rarity}</p>
        <h3>${card.name}</h3>
        <p class="result-card__subtitle">${card.subtitle}</p>
        <p class="result-card__flavor">${card.flavor}</p>
        <div class="result-card__stats"><span>ATK ${card.attack}</span><span>DEF ${card.defense}</span></div>
      </div>
    `;
    elements.resultList.appendChild(article);
  });
}

function showResults() {
  cancelSession();
  resetVisualEffects();
  renderResults();
  showScreen("results");
  window.history.replaceState(null, "", "#results");
  window.scrollTo({ top: 0, behavior: mediaReducedMotion.matches ? "auto" : "smooth" });
  elements.resultsTitle.focus({ preventScroll: true });
  announce("開封完了。5枚すべての結果を表示しました。");
}

function handlePackPointerDown(event) {
  if (event.pointerType === "mouse" && event.button !== 0) {
    return;
  }

  if (currentStage !== "idle" && currentStage !== "readyToTear" && currentStage !== "tearing") {
    return;
  }

  event.preventDefault();
  void unlockWebAudio();
  activePointerId = event.pointerId;
  try {
    elements.interactivePack.setPointerCapture(event.pointerId);
  } catch (_error) {
    // Pointer capture is an enhancement; window-level events still end the gesture.
  }

  if (currentStage === "idle") {
    pointerMode = "charge";
    pointerStartX = event.clientX;
    beginCharge({ automatic: false });
  } else {
    beginTear(event.clientX);
  }
}

function handlePackPointerMove(event) {
  if (event.pointerId !== activePointerId) {
    return;
  }

  if (pointerMode === "charge") {
    event.preventDefault();
    pointerStartX = event.clientX;
    return;
  }

  if (pointerMode !== "tear") {
    return;
  }

  event.preventDefault();
  updateTearFromPointer(event.clientX);
}

function endPointerGesture(event) {
  if (activePointerId !== null && event.pointerId !== activePointerId) {
    return;
  }

  if (pointerMode === "charge") {
    cancelManualCharge();
  } else if (pointerMode === "tear") {
    cancelPartialTear();
  }

  if (activePointerId !== null) {
    try {
      elements.interactivePack.releasePointerCapture(activePointerId);
    } catch (_error) {
      // The pointer may already have been released by the browser.
    }
  }
  activePointerId = null;
  pointerMode = null;
}

function handlePackKeyDown(event) {
  const activationKeys = ["Enter", " "];
  if (activationKeys.includes(event.key)) {
    event.preventDefault();
    void unlockWebAudio();
    if (currentStage === "idle") {
      beginCharge({ automatic: true });
    } else if (currentStage === "readyToTear" || currentStage === "tearing") {
      performAssistedTear();
    }
    return;
  }

  if (event.key === "ArrowRight" && (currentStage === "readyToTear" || currentStage === "tearing")) {
    event.preventDefault();
    void unlockWebAudio();
    if (currentStage === "readyToTear") {
      setStage("tearing", { shouldAnnounce: false });
    }
    setTearProgress(tearProgress + 0.25);
    if (tearProgress >= 1) {
      completeTear();
    }
  }
}

function updateSoundButton() {
  elements.soundToggle.setAttribute("aria-pressed", String(soundEnabled));
  elements.soundToggle.setAttribute("aria-label", soundEnabled ? "効果音をオフにする" : "効果音をオンにする");
}

function toggleSound() {
  soundEnabled = !soundEnabled;
  saveSoundPreference();
  updateSoundButton();
  if (soundEnabled) {
    void unlockWebAudio();
    playSound("ready", 0.38);
    announce("効果音をオンにしました。");
  } else {
    stopAllAudio();
    announce("効果音をオフにしました。");
  }
}

function bindEvents() {
  elements.openPackButton.addEventListener("click", beginOpeningFromUserGesture);
  elements.openAgainButton.addEventListener("click", beginOpeningFromUserGesture);
  elements.openingBackButton.addEventListener("click", returnToSelection);
  elements.brandHome.addEventListener("click", (event) => {
    event.preventDefault();
    returnToSelection();
  });
  elements.soundToggle.addEventListener("click", toggleSound);

  elements.chargeAssistButton.addEventListener("click", () => {
    void unlockWebAudio();
    beginCharge({ automatic: true });
  });
  elements.tearAssistButton.addEventListener("click", () => {
    void unlockWebAudio();
    performAssistedTear();
  });
  elements.nextCardButton.addEventListener("click", () => {
    void unlockWebAudio();
    if (currentStage !== "revealReady") {
      return;
    }
    if (currentCardIndex >= CARDS.length - 1) {
      showResults();
    } else {
      revealCardAt(currentCardIndex + 1);
    }
  });

  elements.interactivePack.addEventListener("pointerdown", handlePackPointerDown);
  elements.interactivePack.addEventListener("pointermove", handlePackPointerMove);
  elements.interactivePack.addEventListener("pointerup", endPointerGesture);
  elements.interactivePack.addEventListener("pointercancel", endPointerGesture);
  elements.interactivePack.addEventListener("lostpointercapture", (event) => {
    if (activePointerId === event.pointerId) {
      endPointerGesture(event);
    }
  });
  elements.interactivePack.addEventListener("keydown", handlePackKeyDown);
  elements.interactivePack.addEventListener("contextmenu", (event) => event.preventDefault());

  window.addEventListener("pagehide", () => cancelSession());
}

function initialize() {
  prepareAssets();
  bindEvents();
  updateSoundButton();
  resetOpeningProgress();
  showScreen("selection");
}

initialize();
