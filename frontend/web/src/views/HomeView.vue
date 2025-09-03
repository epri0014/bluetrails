<template>
  <section class="hero">
    <div class="container">
      <div class="copy">
        <h1 class="title">Protect Our Ocean</h1>
        <p class="dek">
          Our ocean is home to amazing life. Pollution and climate change put it at risk.
          Learn what harms the sea and how small actions every day can protect it.
        </p>

        <div class="actions" role="navigation" aria-label="Main features">
          <RouterLink class="action" to="/animals">Animals at Risk</RouterLink>
          <RouterLink class="action" to="/severity">How Bad Is It?</RouterLink>
          <RouterLink class="action" to="/water-quality">Water Quality</RouterLink>
          <div class="action placeholder" aria-hidden="true" title="More coming soon">More coming soon</div>
        </div>
      </div>

      <div class="photo">
        <div class="frame">
          <img src="/hero/AnimalPic.jpg" alt="Sea life in the ocean" />
        </div>
      </div>
    </div>

    <div class="caption">
      <span>
        Be an Ocean Hero: reduce single-use plastic, recycle, save water, choose reef-safe products,
        and share what you learn.
      </span>
    </div>
  </section>
</template>

<script setup>
</script>

<style scoped>
.hero{
  position: relative;
  color:#fff;

  min-height: 100vh;
  padding-top: var(--nav-h);
  display: grid;
  align-items: center;
  padding-bottom: 28px;

  background-image:
    linear-gradient(90deg,
    rgba(0,30,60,.50) 0%,
    rgba(0,30,60,.34) 26%,
    rgba(0,30,60,.18) 48%,
    rgba(0,30,60,.06) 65%,
    rgba(0,0,0,0) 78%),
  url('/hero/background.jpg');
  background-position: center;
  background-size: cover;
}

@media (max-width: 900px){
  .hero{
    background-image:
      linear-gradient(90deg,
        rgba(0,0,0,.60) 0%,
        rgba(0,0,0,.46) 34%,
        rgba(0,0,0,.28) 58%,
        rgba(0,0,0,.10) 75%,
        rgba(0,0,0,0) 88%),
      url('/hero/background.jpg');
  }
}

.container{
  position:relative;
  max-width:1200px; margin:0 auto; padding:0 20px;
  display:grid; grid-template-columns: 1.1fr .9fr; gap:18px;
  align-items:center;
}
@media (max-width: 1000px){ .container{ grid-template-columns:1fr; } }

.copy{ padding:12px 4px; }
.title{
  margin:.2em 0 0;
  font-size:clamp(36px,6vw,72px);
  line-height:1;
  text-shadow:
    0 6px 22px rgba(0,0,0,.45),
    0 2px 10px rgba(0,0,0,.35);
  -webkit-text-stroke: 0.6px rgba(0,0,0,.35);
}
.dek{
  margin-top:10px; max-width: 720px;
  font-size:18px; font-weight:700;
  text-shadow:
    0 4px 16px rgba(0,0,0,.35),
    0 2px 8px rgba(0,0,0,.30);
}

.actions{
  margin-top: 18px;
  display:grid;
  grid-template-columns: repeat(2, minmax(180px, 1fr));
  gap: 12px;
  max-width: 560px;
}
@media (max-width: 520px){
  .actions{ grid-template-columns: 1fr; max-width: none; }
}
.action{
  display:flex; align-items:center; justify-content:center;
  height:64px; border-radius:14px; font-weight:900; letter-spacing:.2px;
  color:#fff; text-decoration:none;
  background: rgba(0,0,0,.35);
  border: 2px solid rgba(255,255,255,.55);
  backdrop-filter: blur(2px);
  box-shadow: 0 8px 20px rgba(0,0,0,.25);
  transition: transform .12s ease, box-shadow .12s ease, background .12s ease;
}
.action:hover{ transform: translateY(-2px); box-shadow:0 12px 24px rgba(0,0,0,.35); background: rgba(0,0,0,.45); }
.action:active{ transform: translateY(0); }
.placeholder{ opacity:.55; border-style: dashed; cursor: default; }

.photo{ position:relative; display:flex; justify-content:center; align-items:center; padding:20px; z-index:1; }
.frame{
  transform: rotate(-6deg);
  background:#6cc4ff; padding:10px; border-radius:12px;
  box-shadow:0 10px 24px rgba(0,0,0,.35);
  border:6px solid #2e6fb8;
}
.frame img{
  display:block; width:min(460px, 80vw); height:auto;
  border-radius:8px; border:6px solid #ffeb99;
}

.caption{
  position:absolute; left:50%; transform: translateX(-50%);
  bottom: 10px; width:100%; max-width:1200px; padding:0 20px;
  z-index:1; font-size:14px; display:flex; gap:10px; align-items:center;
  text-shadow:0 2px 10px rgba(0,0,0,.35);
}
</style>
