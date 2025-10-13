// game.js — 单物品流 & 三分类（带 Start Overlay）
// 依赖：data.js（POOL, BADGE_THRESHOLDS），scenes.js（SCENES），sfx.js（sfx）
import { POOL, BADGE_THRESHOLDS } from './data.js';
import { SCENES } from './scenes.js';
import { sfx } from './sfx.js';

// ---------- DOM references ----------
const scoreEl   = document.getElementById('score');
const timeEl    = document.getElementById('time');
const bubble    = document.getElementById('bubble');
const resetBtn  = document.getElementById('reset');

const startOverlay = document.getElementById('startOverlay');
const endOverlay   = document.getElementById('endOverlay');
const btnStart     = document.getElementById('btnStart');
const btnAgain     = document.getElementById('btnAgain');
const btnExit      = document.getElementById('btnExit');

const endTitle   = document.getElementById('endTitle');
const finalScore = document.getElementById('finalScore');
const medalBlock = document.getElementById('medalBlock');
const medalEmoji = document.getElementById('medalEmoji');
const medalText  = document.getElementById('medalText');
const badgeChip  = document.getElementById('badgeChip');
const badgeName  = document.getElementById('badgeName');
const badgeEmoji = document.getElementById('badgeEmoji');
const itemProgress = document.getElementById('itemProgress');

// 单个物品容器 & 舞台
const currentHost = document.getElementById('currentItem');
const stage = document.querySelector('.stage');

// ---------- Background music ----------
const bgMusic = document.getElementById('bgMusic');
const musicButtons = Array.from(document.querySelectorAll('.js-music-toggle'));

let musicOn = localStorage.getItem('jj_music_on') === 'true';
function persistMusicPref(){ localStorage.setItem('jj_music_on', String(musicOn)); }

function playMusic(){
  if (!bgMusic) return;
  try{
    if (bgMusic.paused) bgMusic.currentTime = 0;
    const p = bgMusic.play();
    if (p && typeof p.then === 'function') p.catch(() => {});
  }catch{2}
}
function pauseMusic(){ if (bgMusic) bgMusic.pause(); }

function refreshMusicButtonsUI(){
  // 开=绿色 + 🔊，关=灰色 + 🔇
  musicButtons.forEach(btn => {
    if (musicOn){
      btn.textContent = '🔊 Music';
      btn.style.background  = '#10b981';
      btn.style.borderColor = '#0b7a5e';
      btn.style.boxShadow   = '0 6px 0 #0b7a5e';
      btn.style.color       = '#fff';
    }else{
      btn.textContent = '🔇 Music';
      btn.style.background  = '#475569';
      btn.style.borderColor = '#1f2937';
      btn.style.boxShadow   = '0 6px 0 #1f2937';
      btn.style.color       = '#fff';
    }
  });
}
refreshMusicButtonsUI();

musicButtons.forEach(btn => {
  btn.addEventListener('click', () => {
    musicOn = !musicOn;
    persistMusicPref();
    refreshMusicButtonsUI();
    if (musicOn) playMusic(); else pauseMusic();
  });
});

// ---------- Ocean Hero scenes ----------
let sceneIdx = Math.floor(Math.random() * SCENES.length);
const sceneHost = document.getElementById('sceneHost');
function renderScene(i){ if (sceneHost) sceneHost.innerHTML = SCENES[i]; }
renderScene(sceneIdx);

// ---------- Game state ----------
let items = [];
let score = 0;
let remainingTime = 90;
let timerId = null;
let running = false;
let bestBadge = null;
let currentIndex = 0;

const shuffle = arr => arr.sort(() => Math.random() - 0.5);

// ---------- UI helpers ----------
function setBubble(msg, kind){
  if (!bubble) return;
  bubble.classList.remove('good','bad','show');
  if (kind) bubble.classList.add(kind);
  bubble.textContent = msg;
  void bubble.offsetWidth;
  bubble.classList.add('show');
  setTimeout(() => bubble.classList.remove('show'), 2200);
}

function renderNextItem(){
  if (!currentHost) return;
  currentHost.innerHTML = '';
  if (currentIndex >= items.length){
    running = false;
    clearInterval(timerId);
    showEnd('All items sorted!');
    return;
  }
  const it = items[currentIndex];
  const el = document.createElement('div');
  el.className = 'card big';
  el.draggable = true;
  el.dataset.id = it.id;
  el.dataset.type = it.type;
  el.innerHTML = `<div class="emoji">${it.emoji}</div><div class="label">${it.label}</div>`;
  attachDrag(el);
  currentHost.appendChild(el);

  if (itemProgress) itemProgress.textContent = `${currentIndex+1}/${items.length}`;
}

// —— 拖拽绑定（集成飞机 shake）——
function attachDrag(el){
  el.addEventListener('dragstart', e => {
    if (!running) return e.preventDefault();
    e.dataTransfer.setData('text/plain', JSON.stringify({
      id: el.dataset.id,
      type: el.dataset.type
    }));
    // 飞机抖动：dragstart 时添加 .shake
    const plane = document.querySelector('.plane');
    if (plane) plane.classList.add('shake');

    document.querySelectorAll('.bin').forEach(b => b.classList.remove('shake'));
  });

  el.addEventListener('dragend', () => {
    // 结束拖拽：移除 .shake
    const plane = document.querySelector('.plane');
    if (plane) plane.classList.remove('shake');

    document.querySelectorAll('.bin').forEach(b => b.classList.remove('hot'));
  });
}

// ---------- Bins setup ----------
function setupBins(){
  document.querySelectorAll('.bin').forEach(bin => {
    bin.addEventListener('dragover', e => {
      if (!running) return;
      e.preventDefault();
      bin.classList.add('hot');
    });
    bin.addEventListener('dragleave', () => bin.classList.remove('hot'));
    bin.addEventListener('drop', e => {
      if (!running) return;
      e.preventDefault();
      bin.classList.remove('hot');

      // 兜底：无论如何移除飞机抖动
      const plane = document.querySelector('.plane');
      if (plane) plane.classList.remove('shake');

      const dataText = e.dataTransfer.getData('text/plain');
      if (!dataText) return;
      const data = JSON.parse(dataText);

      const correct = data.type === bin.dataset.type;

      if (correct){
        score += 20;
        if (scoreEl) scoreEl.textContent = String(score);
        sfx.correct();
        const facts = {
          waste:   "Food scraps go back to nature",
          recycle: "Recycling makes new things",
          rubbish: "This one just goes to the bin."
        };
        setBubble('✅ ' + (facts[bin.dataset.type] || 'Correct!'), 'good');
        updateBadge();
      }else{
        score = Math.max(0, score - 10);
        if (scoreEl) scoreEl.textContent = String(score);
        setBubble('❌ Almost! Try again', 'bad');
        sfx.wrong();
        bin.classList.add('shake');
        setTimeout(()=>bin.classList.remove('shake'), 300);
        // ❌ 让物品自身回弹
        const card = currentHost?.querySelector('.card.big');
        if (card){
          card.classList.add('shake');
          setTimeout(()=>card.classList.remove('shake'), 240);
        }
      }

      currentIndex += 1;
      renderNextItem();
    });
  });
}

// ---------- Badges ----------
function updateBadge(){
  let badge = null, name='', emoji='';
  if (score >= BADGE_THRESHOLDS.gold){ badge='gold'; name='Gold'; emoji='🥇'; }
  else if (score >= BADGE_THRESHOLDS.silver){ badge='silver'; name='Silver'; emoji='🥈'; }
  else if (score >= BADGE_THRESHOLDS.bronze){ badge='bronze'; name='Bronze'; emoji='🥉'; }

  if (badge && badge !== bestBadge){
    bestBadge = badge;
    if (badgeChip)  badgeChip.style.display = 'inline-flex';
    if (badgeName)  badgeName.textContent = name;
    if (badgeEmoji) badgeEmoji.textContent = emoji;
    setBubble(`${emoji} ${name} badge unlocked!`, 'good');
  }
}

// ---------- Timer / end ----------
function startTimer(){
  clearInterval(timerId);
  timerId = setInterval(() => {
    remainingTime -= 1;
    if (timeEl) timeEl.textContent = String(remainingTime);
    if (remainingTime <= 0){
      clearInterval(timerId);
      running = false;
      sfx.done();
      showEnd('Time’s Up!');
    }
  }, 1000);
}

function showEnd(title){
  if (finalScore) finalScore.textContent = String(score);

  let emoji='', text='';
  if (score >= BADGE_THRESHOLDS.gold){ emoji='🥇'; text='Gold Ocean Hero'; }
  else if (score >= BADGE_THRESHOLDS.silver){ emoji='🥈'; text='Silver Ocean Hero'; }
  else if (score >= BADGE_THRESHOLDS.bronze){ emoji='🥉'; text='Bronze Ocean Hero'; }

  if (medalBlock) medalBlock.style.display = emoji ? 'block':'none';
  if (medalEmoji) medalEmoji.textContent = emoji;
  if (medalText)  medalText.textContent  = text;
  if (endTitle)   endTitle.textContent   = title || 'Time’s Up!';
  if (endOverlay) endOverlay.classList.remove('hide');

  pauseMusic();
}

function hideOverlays(){
  if (startOverlay) startOverlay.classList.add('hide');
  if (endOverlay)   endOverlay.classList.add('hide');
  if (stage) stage.classList.remove('hide');   // 显示游戏舞台
}

// ---------- Game lifecycle ----------
function startGame(){
  score = 0; if (scoreEl) scoreEl.textContent = '0';
  remainingTime = 90; if (timeEl) timeEl.textContent = String(remainingTime);

  items = shuffle([...POOL]);
  currentIndex = 0;

  bestBadge = null;
  if (badgeChip)  badgeChip.style.display = 'none';
  if (badgeName)  badgeName.textContent = '';
  if (badgeEmoji) badgeEmoji.textContent = '';
  if (itemProgress) itemProgress.textContent = `0/${items.length}`;

  renderNextItem();
  setBubble("Let’s go! Sort the trash!");
  running = true;
  startTimer();
  sfx.start();

  if (musicOn) playMusic();
}

// ---------- Events ----------
if (btnStart){
  btnStart.addEventListener('click', () => { hideOverlays(); startGame(); });
}

if (resetBtn){
  resetBtn.addEventListener('click', () => {
    pauseMusic();
    startGame();
    if (musicOn) playMusic();
  });
}

if (btnAgain){
  btnAgain.addEventListener('click', () => {
    if (endOverlay) endOverlay.classList.add('hide');
    startGame();
    if (musicOn) playMusic();
  });
}

// Exit → 回到 Start Overlay + 重置 HUD
if (btnExit){
  btnExit.addEventListener('click', () => {
    pauseMusic();
    if (endOverlay) endOverlay.classList.add('hide');
    if (stage) stage.classList.add('hide');
    if (startOverlay) startOverlay.classList.remove('hide');
    // 重置 HUD
    score = 0; if (scoreEl) scoreEl.textContent = '0';
    remainingTime = 90; if (timeEl) timeEl.textContent = '90';
    if (itemProgress) itemProgress.textContent = '0/0';
  });
}

// 初始化拖拽
setupBins();
