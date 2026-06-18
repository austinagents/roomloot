export type Rarity = "common" | "uncommon" | "rare" | "epic" | "legendary";

export type Artifact = {
  name: string;
  description: string;
  rarity: Rarity;
  coinValue: number;
  xpValue: number;
};

const pools: Record<Rarity, Omit<Artifact, "rarity">[]> = {
  common: [
    { name: "Bronze Chest", description: "A weathered chest containing coins and relic fragments.", coinValue: 10, xpValue: 10 },
    { name: "Old Coin Purse", description: "A cracked leather purse with a few tarnished coins inside.", coinValue: 12, xpValue: 10 },
    { name: "Weathered Key", description: "An old brass key from a forgotten lock.", coinValue: 8, xpValue: 12 },
    { name: "Small Relic Box", description: "A palm-sized wooden box carved with expedition marks.", coinValue: 14, xpValue: 10 },
    { name: "Traveler's Token", description: "A stamped token carried by generations of travelers.", coinValue: 10, xpValue: 14 }
  ],
  uncommon: [
    { name: "Brass Pocket Watch", description: "A finely made watch with a scratched explorer's crest.", coinValue: 28, xpValue: 24 },
    { name: "Explorer's Flask", description: "A dented field flask wrapped in worn leather.", coinValue: 24, xpValue: 26 },
    { name: "Sealed Letter", description: "A wax-sealed letter whose route was lost to time.", coinValue: 22, xpValue: 28 },
    { name: "Map Fragment", description: "A torn piece of parchment showing an unknown coastline.", coinValue: 26, xpValue: 26 },
    { name: "Silver Ring", description: "A simple ring engraved with a mountain path.", coinValue: 30, xpValue: 24 }
  ],
  rare: [
    { name: "Captain's Compass", description: "A sturdy compass that still points with surprising confidence.", coinValue: 70, xpValue: 55 },
    { name: "Ancient Coin", description: "A heavy coin marked by a kingdom no modern atlas remembers.", coinValue: 64, xpValue: 60 },
    { name: "Jeweled Brooch", description: "A delicate brooch set with a dark green stone.", coinValue: 78, xpValue: 58 },
    { name: "Lost Journal", description: "A field journal filled with coded notes and route sketches.", coinValue: 60, xpValue: 70 },
    { name: "Merchant's Seal", description: "A carved seal once used to mark valuable cargo.", coinValue: 68, xpValue: 62 }
  ],
  epic: [
    { name: "Navigator's Astrolabe", description: "A brass astrolabe etched with precise star charts.", coinValue: 150, xpValue: 110 },
    { name: "Royal Signet", description: "A royal signet recovered far from any palace road.", coinValue: 165, xpValue: 105 },
    { name: "Golden Spyglass", description: "A polished spyglass carried on a famous expedition.", coinValue: 175, xpValue: 115 },
    { name: "Lost Expedition Badge", description: "A badge from an expedition that never returned.", coinValue: 140, xpValue: 125 },
    { name: "Ceremonial Dagger", description: "An ornate ceremonial blade, kept as a display relic.", coinValue: 155, xpValue: 120 }
  ],
  legendary: [
    { name: "Explorer's Compass", description: "A legendary compass said to reveal the path to every hidden place.", coinValue: 250, xpValue: 100 },
    { name: "Crown of the Forgotten King", description: "A tarnished crown from a ruler erased from official histories.", coinValue: 300, xpValue: 150 },
    { name: "Sunken Captain's Medallion", description: "A salt-worn medallion carried by a captain lost at sea.", coinValue: 275, xpValue: 140 },
    { name: "The Cartographer's Master Map", description: "A master map layered with routes, warnings, and secret marks.", coinValue: 325, xpValue: 160 },
    { name: "Ring of the First Expedition", description: "A ring awarded to the first explorer to chart the old frontier.", coinValue: 290, xpValue: 150 }
  ]
};

export function chooseRarity(): Rarity {
  const roll = Math.random();
  if (roll < 0.55) return "common";
  if (roll < 0.8) return "uncommon";
  if (roll < 0.93) return "rare";
  if (roll < 0.98) return "epic";
  return "legendary";
}

export function randomArtifact(rarity = chooseRarity()): Artifact {
  const list = pools[rarity];
  const item = list[Math.floor(Math.random() * list.length)];
  return { ...item, rarity };
}

