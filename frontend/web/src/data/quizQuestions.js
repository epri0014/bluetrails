export const getCategoryBackground = (category) => {
  const backgrounds = {
    waste: 'linear-gradient(135deg, #f87171 0%, #dc2626 100%)',
    ocean: 'linear-gradient(135deg, #0ea5e9 0%, #0369a1 100%)',
    animal: 'linear-gradient(135deg, #10b981 0%, #059669 100%)'
  }
  return backgrounds[category] || backgrounds.ocean
}

export const getCategoryIcon = (category) => {
  const icons = {
    waste: '♻️',
    ocean: '🌊',
    animal: '🐠'
  }
  return icons[category] || icons.ocean
}