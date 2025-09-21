export const quizQuestions = [
  {
    id: 1,
    question: "Where does most plastic rubbish on the streets end up if it goes into drains?",
    correctAnswer: "The ocean",
    options: ["The ocean", "The forest", "The recycling factory"],
    funFact: "Stormwater drains lead straight to the sea, only rain should go down the drain!",
    category: "waste"
  },
  {
    id: 2,
    question: "Why should you avoid swimming at the beach right after heavy rain?",
    correctAnswer: "Rain washes rubbish and germs into the sea",
    options: ["Rain washes rubbish and germs into the sea", "The water might be too cold", "Fish don't like company"],
    funFact: "After heavy rain, it's safer to wait 24–48 hours before swimming.",
    category: "ocean"
  },
  {
    id: 3,
    question: "What do sea turtles sometimes mistake plastic bags for?",
    correctAnswer: "Jellyfish",
    options: ["Jellyfish", "Crabs", "Balloons"],
    funFact: "Sea turtles often mistake plastic for jellyfish. Use reusable bags to help keep them safe.",
    category: "waste"
  },
  {
    id: 4,
    question: "Where do Little Penguins live in Victoria?",
    correctAnswer: "St Kilda Pier",
    options: ["St Kilda Pier", "Melbourne Zoo", "The desert"],
    funFact: "St Kilda's Little Penguins are world-famous, clean beaches keep them healthy.",
    category: "animal"
  },
  {
    id: 5,
    question: "Which of these is the BEST way to protect the ocean?",
    correctAnswer: "All of the above",
    options: ["All of the above", "Pick up rubbish", "Bring a reusable bottle"],
    funFact: "Small actions add up, do all three and you're a true Ocean Hero!",
    category: "ocean"
  },
  {
    id: 6,
    question: "What do Burrunan dolphins in Victoria need to stay healthy?",
    correctAnswer: "Clean water",
    options: ["Clean water", "Plastic bottles", "Loud boat engines"],
    funFact: "Dolphins use sound to talk, noisy, polluted water makes life harder for them.",
    category: "animal"
  },
  {
    id: 7,
    question: "Which item belongs in the recycling bin?",
    correctAnswer: "Plastic water bottle",
    options: ["Plastic water bottle", "Banana peel", "Dirty tissue"],
    funFact: "Recycling keeps plastics out of the ocean and gives them a new life!",
    category: "waste"
  },
  {
    id: 8,
    question: "Why do seahorses need seagrass meadows?",
    correctAnswer: "To hide and stay safe",
    options: ["To hide and stay safe", "To play soccer", "To build nests"],
    funFact: "Healthy seagrass = happy seahorses. Pollution destroys their hiding spots.",
    category: "animal"
  },
  {
    id: 9,
    question: "Which of these should NEVER go down a sink or drain?",
    correctAnswer: "Cooking oil",
    options: ["Cooking oil", "Water", "Soap"],
    funFact: "Oil sticks to pipes and pollutes waterways. Pour into a container and bin it.",
    category: "waste"
  },
  {
    id: 10,
    question: "How long can a single plastic straw last in the ocean?",
    correctAnswer: "200 years",
    options: ["200 years", "5 weeks", "5 years"],
    funFact: "Say no to plastic straws, they can last 200 years in the ocean!",
    category: "waste"
  },
  {
    id: 11,
    question: "How fast can Little Penguins swim?",
    correctAnswer: "Faster than Olympic swimmers",
    options: ["Faster than Olympic swimmers", "Slower than people", "They can't swim"],
    funFact: "Penguins zoom through water at over 6 km/h, faster than many swimmers!",
    category: "animal"
  },
  {
    id: 12,
    question: "Which of these can hurt marine animals?",
    correctAnswer: "Too much underwater noise",
    options: ["Too much underwater noise", "Quiet oceans", "Gentle waves"],
    funFact: "Loud boats and sonar confuse whales and dolphins. Quiet oceans = safe oceans.",
    category: "ocean"
  },
  {
    id: 13,
    question: "What's the easiest way YOU can help at the beach?",
    correctAnswer: "Collect 3 pieces of rubbish",
    options: ["Collect 3 pieces of rubbish", "Dig a big hole in the sand", "Chase the seagulls"],
    funFact: "Take 3 for the Sea, every bit of rubbish collected helps marine life.",
    category: "ocean"
  },
  {
    id: 14,
    question: "Which of these animals can be found in Port Phillip Bay?",
    correctAnswer: "Burrunan dolphins",
    options: ["Burrunan dolphins", "Lions", "Elephants"],
    funFact: "Burrunan dolphins live only in Victoria & Tasmania, protecting their home is vital.",
    category: "animal"
  },
  {
    id: 15,
    question: "Why is plastic dangerous to seabirds?",
    correctAnswer: "They can eat it by mistake",
    options: ["They can eat it by mistake", "It makes them fly faster", "They can use it as a nest"],
    funFact: "Seabirds often think plastic looks like food. Keeping beaches clean keeps them safe.",
    category: "waste"
  }
]

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