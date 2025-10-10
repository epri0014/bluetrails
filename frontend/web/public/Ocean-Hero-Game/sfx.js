// Web Audio SFX helpers
let actx;

export function tone(freq=440, duration=0.12, type='sine', gain=0.06){
  try{
    actx = actx || new (window.AudioContext||window.webkitAudioContext)();
    const o = actx.createOscillator(), g = actx.createGain();
    o.type = type; o.frequency.value = freq;
    g.gain.value = gain; o.connect(g); g.connect(actx.destination);
    o.start();
    g.gain.exponentialRampToValueAtTime(0.0001, actx.currentTime + duration);
    o.stop(actx.currentTime + duration);
  }catch (e) { void e; }
}

export const sfx = {
  start(){ tone(880,.12,'triangle'); tone(1320,.12,'triangle'); },
  correct(){ tone(740,.08,'sine'); setTimeout(()=>tone(1040,.08,'sine'),80); },
  wrong(){ tone(220,.16,'sawtooth',0.07); },
  done(){ tone(660,.12,'triangle'); setTimeout(()=>tone(990,.12,'triangle'),110); setTimeout(()=>tone(1320,.12,'triangle'),220); }
};
