# Roblox Hunting Game Script

صيد الضبان is a Roblox hunting-game script that adds animal ESP highlights and optional aim assist for animal targets in an experience you own or are authorized to develop. The Roblox script uses tagged or folder-organized animal models, shows visible highlights within a set distance, and smoothly guides the camera toward visible animals when aim assist is enabled and held.

## Install

1. In Roblox Studio, create a ModuleScript named `HuntAssistConfig` in `ReplicatedStorage` and paste in the configuration file contents.
2. Create a LocalScript named `HuntAssist` in `StarterPlayer > StarterPlayerScripts` and paste in the client script contents.
3. Tag animal Models with the CollectionService tag `HuntAnimal`, or put them directly inside a `Workspace` Folder named `HuntAnimals`. Each model needs at least one BasePart. A `HumanoidRootPart` or `PrimaryPart` provides the preferred aim point.
4. Make sure animal models are replicated to clients.

## Use

- Press `V` to toggle animal highlights. They are enabled by default.
- Press `B` to enable or disable aim assist. It is disabled by default.
- When aim assist is enabled, hold the right mouse button to use it. It selects visible animals within the configured range and on-screen field of view.
- Edit `HuntAssistConfig.lua` to adjust keys, ranges, highlight color, field of view, and responsiveness.

Highlights use occluded depth mode and do not reveal animals through walls. Aim assist moves the client camera; it does not fire weapons or change server-side hit detection. Keep hit and damage validation on the server.

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/37be15f4-0e47-4650-ada2-bfc416f307d0?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=37be15f4-0e47-4650-ada2-bfc416f307d0
