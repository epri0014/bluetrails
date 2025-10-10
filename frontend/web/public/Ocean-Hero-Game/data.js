// Items and thresholds (pure data) — 改为 3 类：waste / recycle / rubbish
export const POOL = [
  // Recycle (yellow)
  { id:'r1', type:'recycle', emoji:'📰', label:'Newspaper' },
  { id:'r2', type:'recycle', emoji:'📦', label:'Cardboard' },
  { id:'r3', type:'recycle', emoji:'🍾', label:'Glass Bottle' },
  { id:'r4', type:'recycle', emoji:'🥫', label:'Tin Can' },
  { id:'r5', type:'recycle', emoji:'🧴', label:'Plastic Bottle' },

  // Waste (green) — 易腐/园林/食物
  { id:'w1', type:'waste',   emoji:'🍌', label:'Banana Peel' },
  { id:'w2', type:'waste',   emoji:'🍎', label:'Apple Core' },
  { id:'w3', type:'waste',   emoji:'🌿', label:'Leaves' },
  { id:'w4', type:'waste',   emoji:'🍞', label:'Bread Crust' },

  // Rubbish (red) — 不可回收/小型杂物
  { id:'b1', type:'rubbish', emoji:'🧷', label:'Sharp Pin' },
  { id:'b2', type:'rubbish', emoji:'🧻', label:'Tissue (Used)' },
  { id:'b3', type:'rubbish', emoji:'🧤', label:'Single Glove' }
];

export const BADGE_THRESHOLDS = { bronze:60, silver:90, gold:120 };
