// game.js — 单物品流 & 三分类
// 保留原有：音乐联动、徽章系统、计时器、气泡提示、SFX
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
const btnExit      = document.getElementById('btnExit') || document.getElementById('btnClose');

const endTitle   = document.getElementById('endTitle');
const finalScore = document.getElementById('finalScore');
const medalBlock = document.getElementById('medalBlock');
const medalEmoji = document.getElementById('medalEmoji');
const medalText  = document.getElementById('medalText');
const badgeChip  = document.getElementById('badgeChip');
const badgeName  = document.getElementById('badgeName');
const badgeEmoji = document.getElementById('badgeEmoji');

// 新增：单个物品容器
const currentHost = document.getElementById('currentItem');

// ---------- Background music (two linked buttons) ----------
const bgMusic = document.getElementById('bgMusic');
const musicButtons = Array.from(document.querySelectorAll('.js-music-toggle'));

// 默认静音（false）；读取本地偏好
let musicOn = localStorage.getItem('jj_music_on') === 'true';

function persistMusicPref() {
  localStorage.setItem('jj_music_on', String(musicOn));
}

function playMusic() {
  if (!bgMusic) return;
  try {
    if (bgMusic.paused) bgMusic.currentTime = 0;
    const p = bgMusic.play();
    if (p && typeof p.then === 'function') p.catch(() => {});
  } catch { /* ignore */ }
}

function pauseMusic() {
  if (!bgMusic) return;
  bgMusic.pause();
}

// 反转样式（保持你原来的逻辑）：
//   - 静音 (musicOn=false)  => 绿色 + 🔊 Music
//   - 播放 (musicOn=true)   => 灰色 + 🔇 Music
function refreshMusicButtonsUI() {
  musicButtons.forEach(btn => {
    btn.textContent = musicOn ? '🔇 Music' : '🔊 Music';
    if (musicOn) {
      btn.style.background  = '#475569';    // gray
      btn.style.borderColor = '#1f2937';
      btn.style.boxShadow   = '0 6px 0 #1f2937';
      btn.style.color       = '#fff';
    } else {
      btn.style.background  = '#10b981';    // green
      btn.style.borderColor = '#0b7a5e';
      btn.style.boxShadow   = '0 6px 0 #0b7a5e';
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
function renderScene(i){ sceneHost.innerHTML = SCENES[i]; }
renderScene(sceneIdx);

// 可选左右键（容错）
const prevBtn = document.getElementById('prevScene');
const nextBtn = document.getElementById('nextScene');
if (prevBtn && nextBtn){
  prevBtn.onclick = () => { sceneIdx = (sceneIdx + SCENES.length - 1) % SCENES.length; renderScene(sceneIdx); };
  nextBtn.onclick = () => { sceneIdx = (sceneIdx + 1) % SCENES.length; renderScene(sceneIdx); };
}

// ---------- Game state ----------
let items = [];
let score = 0;
let remainingTime = 90;
let timerId = null;
let running = false;
let bestBadge = null;

// 单物品索引
let currentIndex = 0;

const shuffle = arr => arr.sort(() => Math.random() - 0.5);

// ---------- UI helpers ----------
function setBubble(msg, kind){
  bubble.classList.remove('good','bad','show');
  if(kind) bubble.classList.add(kind);
  bubble.textContent = msg;
  void bubble.offsetWidth;
  bubble.classList.add('show');
  setTimeout(() => bubble.classList.remove('show'), 2200);
}

// ✅ 渲染“下一个单个物品”
function renderNextItem(){
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
}

function attachDrag(el){
  el.addEventListener('dragstart', e => {
    if(!running) return e.preventDefault();
    e.dataTransfer.setData('text/plain', JSON.stringify({
      id: el.dataset.id,
      type: el.dataset.type
    }));
    document.querySelectorAll('.bin').forEach(b => b.classList.remove('shake'));
  });
  el.addEventListener('dragend', () => {
    document.querySelectorAll('.bin').forEach(b => b.classList.remove('hot'));
  });
}

// ---------- Bins DnD setup ----------
function setupBins(){
  document.querySelectorAll('.bin').forEach(bin => {
    bin.addEventListener('dragover', e => {
      if(!running) return;
      e.preventDefault();
      bin.classList.add('hot');
    });
    bin.addEventListener('dragleave', () => bin.classList.remove('hot'));
    bin.addEventListener('drop', e => {
      if(!running) return;
      e.preventDefault();
      bin.classList.remove('hot');

      const dataText = e.dataTransfer.getData('text/plain');
      if(!dataText) return;
      const data = JSON.parse(dataText);

      const correct = data.type === bin.dataset.type;

      if(correct){
        score += 20;
        scoreEl.textContent = score;
        sfx.correct();
        const facts = {
          waste:   "Organics become compost that helps dune plants.",
          recycle: "Recyclables can be made into new products.",
          rubbish: "Some items do not belong in recycling bins."
        };
        setBubble('✅ ' + (facts[bin.dataset.type] || 'Correct!'), 'good');
        updateBadge();
      }else{
        score = Math.max(0, score - 10);
        scoreEl.textContent = score;
        setBubble('❌ Oops! One try only—watch the label!', 'bad');
        sfx.wrong();
        bin.classList.add('shake');
        setTimeout(()=>bin.classList.remove('shake'), 300);
      }

      // 移动到下一个物品
      currentIndex += 1;
      renderNextItem();
    });
  });
}

// ---------- Badges / medals ----------
function updateBadge(){
  let badge = null, name='', emoji='';
  if(score >= BADGE_THRESHOLDS.gold){ badge='gold'; name='Gold'; emoji='🥇'; }
  else if(score >= BADGE_THRESHOLDS.silver){ badge='silver'; name='Silver'; emoji='🥈'; }
  else if(score >= BADGE_THRESHOLDS.bronze){ badge='bronze'; name='Bronze'; emoji='🥉'; }

  if(badge && badge !== bestBadge){
    bestBadge = badge;
    badgeChip.style.display = 'inline-flex';
    badgeName.textContent = name;
    badgeEmoji.textContent = emoji;
    setBubble(`${emoji} ${name} badge unlocked!`, 'good');
  }
}

// ---------- Timer / end screens ----------
function startTimer(){
  clearInterval(timerId);
  timerId = setInterval(() => {
    remainingTime -= 1;
    timeEl.textContent = remainingTime;
    if(remainingTime <= 0){
      clearInterval(timerId);
      running = false;
      sfx.done();
      showEnd('Time’s Up!');
    }
  }, 1000);
}

function showEnd(title){
  finalScore.textContent = score;

  let emoji='', text='';
  if(score >= BADGE_THRESHOLDS.gold){ emoji='🥇'; text='Gold Ocean Hero'; }
  else if(score >= BADGE_THRESHOLDS.silver){ emoji='🥈'; text='Silver Ocean Hero'; }
  else if(score >= BADGE_THRESHOLDS.bronze){ emoji='🥉'; text='Bronze Ocean Hero'; }

  medalBlock.style.display = emoji ? 'block':'none';
  medalEmoji.textContent = emoji;
  medalText.textContent = text;
  endTitle.textContent = title || 'Time’s Up!';
  endOverlay.classList.remove('hide');

  // 结束时只暂停音乐
  pauseMusic();
}

function hideOverlays(){
  startOverlay.classList.add('hide');
  endOverlay.classList.add('hide');
}

// ---------- Game lifecycle ----------
function startGame(){
  score = 0; scoreEl.textContent = '0';
  remainingTime = 90; timeEl.textContent = remainingTime;

  // 打乱后，单物品索引归零
  items = shuffle([...POOL]);
  currentIndex = 0;

  bestBadge = null;
  badgeChip.style.display = 'none';
  badgeName.textContent = '';
  badgeEmoji.textContent = '';

  renderNextItem();
  setBubble("Let’s go! Sort the trash!");
  running = true;
  startTimer();
  sfx.start();

  if (musicOn) playMusic();
}

// ---------- Wire up UI events ----------
btnStart.addEventListener('click', () => { hideOverlays(); startGame(); });

resetBtn.addEventListener('click', () => {
  pauseMusic();
  startGame();
  if (musicOn) playMusic();
});

btnAgain.addEventListener('click', () => {
  endOverlay.classList.add('hide');
  startGame();
  if (musicOn) playMusic();
});

if (btnExit) {
  btnExit.addEventListener('click', () => {
    pauseMusic();
    window.location.href = "/";
  });
}

// Initialize drag-and-drop targets
setupBins();

// Keep start overlay visible until player presses "Let’s Go!"
