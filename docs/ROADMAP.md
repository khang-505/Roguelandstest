# Development Roadmap - Starfall Frontier

## Phase 1 — Foundation & First Playable Slice
- 1.1 Project setup & documentation core
- 1.2 GameManager state machine & EventBus
- 1.3 Player controller physics, movement, dash & combat input
- 1.4 Enemy AI prototype (Ash Beetle FSM)
- 1.5 Seeded procedural room generator
- 1.6 Loot drop system & player inventory pickup
- 1.7 HUD & Game Over loop

## Phase 2 — Weapon & Combat Expansion
- 2.1 Weapon categories: Melee, Ranged, Energy, Special
- 2.2 Random affixes & modifier generation engine
- 2.3 Item rarity tier system (Common -> Mythic)
- 2.4 Armor equipment slots & stat calculation engine
- 2.5 Dynamic damage status effects (Fire, Ice, Void, Poison, Shock)

## Phase 3 — Procedural Planet & Biome Engine
- 3.1 Biome 1: Emberwild (Volcanic Jungle)
- 3.2 Biome 2: Frostgrave (Frozen Wasteland)
- 3.3 Biome 3: Verdant Abyss (Alien Ecosystem)
- 3.4 Biome 4: Rust Horizon (Industrial Ruins)
- 3.5 Biome 5: Void Marsh (Quantum Swamp)
- 3.6 Biome 6: Astral Ruins (Floating Sanctum)
- 3.7 Environmental hazards & interactive objects

## Phase 4 — Hub World & Meta-Progression
- 4.1 Persistent Expedition Base (Hub World)
- 4.2 Research Lab & Technology Tree
- 4.3 Forge & Recipe Crafting Station
- 4.4 Companion Station (Miners, Harvesters, Combat Drones)
- 4.5 Origin Archetypes (Vanguard, Scout, Engineer, Mystic, Nomad)

## Phase 5 — Boss Encounters & Extraction System
- 5.1 Biome Guardians (Multi-phase boss fights)
- 5.2 World Instability meter mechanic
- 5.3 Extraction beacon & defend channel timer (10s extraction challenge)
- 5.4 Expedition Contracts system

## Phase 6 — Co-op Multiplayer & Save Architecture
- 6.1 Server-authoritative network sync (1-4 players)
- 6.2 Player revive / downed state logic
- 6.3 Versioned save system with atomic backups (`save.json`, `save.backup.json`)

## Phase 7 — Polish, Audio, VFX & Release
- 7.1 Visual particle effects (hit sparks, critical flash, dash trails)
- 7.2 Dynamic audio controller & music state machine
- 7.3 Balance tuning & telemetry logger
- 7.4 Final release build packaging
