# 🎮 GodotVMF Entities Library

> A comprehensive library of Source Engine entities for Godot projects using [GodotVMF](https://github.com/H2xDev/GodotVMF) v2.2+

[![License](https://img.shields.io/github/license/H2xDev/GodotVMF-Entities)](LICENSE)
[![Issues](https://img.shields.io/github/issues/H2xDev/GodotVMF-Entities)](https://github.com/H2xDev/GodotVMF-Entities/issues)

---

## 📖 Overview

This library provides pre-implemented Source Engine entities that seamlessly integrate with your Godot projects through the GodotVMF plugin. Import VMF maps with full entity support out of the box!

**Found a bug?** Feel free to [open an issue](https://github.com/H2xDev/GodotVMF-Entities/issues) 🐛

## 📦 Installation

1. Download or clone this repository
2. Copy the `entities` folder into your Godot project's root directory
3. Ensure [GodotVMF](https://github.com/H2xDev/GodotVMF) v2.2+ is installed
4. Start using entities in your VMF maps!

## 📋 Supported Entities

### 🌍 Environment
- **env_physexplosion** - Physical explosion effects
- **env_sprite** - Sprite3D
- **env_entity_maker** - spawns godot scenes (put the name of godot scene in targetname Point_template To Spawn) (default scene folder path is set to res://Scenes)

### 🔍 Filters
- **filter_activator_name** - Filter entities by name
- **filter_multi** - Multiple filter logic

### 🎯 Func Entities
- **func_physbox** - Physical boxes with collision
- **func_rotating** - Rotating brushes

### 🔧 Logic
- **logic_relay** - Logic relay for I/O system
- **logic_case** - stores I/O outputs in a array up to 16 times
- **logic_branch** - fires outputs based on true\false values
- **math_counter** - Counter with mathematical operations

### 🚪 Triggers
- **trigger_once** - Single-use trigger
- **trigger_multiple** - Reusable trigger
- **trigger_push** - Push entities in a direction
- **trigger_teleport** - teleport entity on touch

### ℹ️ Info
- **info_overlay** - Texture overlays
- **info_teleport_destination** - destination and angles for teleported entitiy

## 🤝 Contributing

We welcome contributions! If you've implemented entities from the default FGD files:

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/new-entity`)
3. Commit your changes (`git commit -m 'Add new entity'`)
4. Push to the branch (`git push origin feature/new-entity`)
5. Open a Pull Request

All contributions should follow the existing code style and include proper documentation.

---

## 📄 License

See [LICENSE](LICENSE) file for details.

## 🔗 Related Projects

- [GodotVMF](https://github.com/H2xDev/GodotVMF) - The main VMF importer plugin for Godot

---

<div align="center">
Made with ❤️ for the Godot and Source Engine community!
</div>
