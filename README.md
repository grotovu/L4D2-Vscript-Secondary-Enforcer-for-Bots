# L4D2 Bot Secondary Weapon Enforcer

An automated VScript for **Left 4 Dead 2** that forces Survivor Bots to carry custom secondary weapons (Melee weapons, Magnums, or Pistols) assigned per character model. 

Includes automatic file-based configuration, map-specific weapon blacklisting, and safety checks to prevent breaking bot animations or game states.

For the human player version: https://github.com/grotovu/L4D2-Vscript-Secondary-Enforcer-for-Players

## Motivation & Use Case

I frequently play with custom survivor and weapon skins. For aesthetic and thematic reasons, I want each character to start every map holding their signature weapon.

By default, Left 4 Dead 2 spawns survivor bots with standard pistols. If you use custom character or weapon skins, starting with default pistols may break visual immersion.

This script ensures that whenever a bot spawns, they automatically receive their assigned signature weapon from the very start of the round.

---

## Features

- **Per-Character Model Mapping:** Assign specific secondary weapons individually to Rochelle, Nick, Coach, Ellis, Bill, Zoey, Francis, and Louis.
- **Configuration:** Settings automatically load from `left4dead2/ems/secondary_weapon_enforcer/settings_bots.txt`.
- **Smart Map Blacklisting:** Automatically detects if a map lacks a specific melee spawn/precache (e.g., `electric_guitar` on non-supported maps) and safely falls back to default pistols without breaking.
- **State Protection:** Ignores incapacitated or ledge-hanging bots to prevent item-swap animation glitches or crashes.
- **Bot-Only:** Human players retain full freedom over their equipment.

---

## Example Config:
```
// Survivor Bot Secondary Weapon Configuration
// Format: key weapon_name
// Set to 'weapon_pistol' to allow bots to keep default guns.

interval 3.0
model_nick weapon_pistol
model_rochelle electric_guitar
model_coach tonfa
model_ellis baseball_bat
model_bill weapon_pistol
model_zoey baseball_bat
model_francis tonfa
model_louis electric_guitar
```
