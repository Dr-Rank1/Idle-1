# Idle Restaurant Tycoon 3D

A 3D restaurant management simulation and idle tycoon game developed using the Godot 4 game engine, accompanied by a Flutter-based mobile architecture. The project simulates complete restaurant floor operations including real-time customer pathfinding, guest lifecycle state machines, dining room turnover, multi-tier equipment upgrades, staff hiring, and economy scaling.

---

## Table of Contents

- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Core Simulation Loops](#core-simulation-loops)
  - [Guest Lifecycle State Machine](#guest-lifecycle-state-machine)
  - [Customer Patience and Tip Mechanics](#customer-patience-and-tip-mechanics)
  - [VIP Michelin Food Critic System](#vip-michelin-food-critic-system)
  - [Table Turnover and Busboy Cleaning](#table-turnover-and-busboy-cleaning)
  - [Station Tiers and Visual Evolution](#station-tiers-and-visual-evolution)
- [Interior Design and Spatial Layout](#interior-design-and-spatial-layout)
- [Economy Balance and Formulas](#economy-balance-and-formulas)
  - [Station Upgrade Cost and Revenue](#station-upgrade-cost-and-revenue)
  - [Staff Scaling Formulas](#staff-scaling-formulas)
  - [Menu Pricing Tiers](#menu-pricing-tiers)
  - [Staff Roster](#staff-roster)
- [Audio Engineering](#audio-engineering)
- [Project Directory Structure](#project-directory-structure)
- [Installation and Execution](#installation-and-execution)
  - [Running the Godot 3D Simulation](#running-the-godot-3d-simulation)
  - [Running the Flutter Companion Application](#running-the-flutter-companion-application)
- [License](#license)

---

## Overview

Idle Restaurant Tycoon 3D places the player in control of a high-end culinary establishment. The gameplay challenges the player to balance kitchen throughput, floor service velocity, table capacity, and guest satisfaction. 

The game combines passive incremental progression with active operational decision-making:
- Unlocking and upgrading physical dining stations across distinct aesthetic tiers.
- Hiring and leveling specialized service and kitchen staff.
- Managing order routing through an asynchronous waiter dispatch queue.
- Handling dining room turnover by bussing dirty dishes before new parties can be seated.
- Pleasing periodic VIP food critics to build restaurant star ratings and earn high-tier bounties.

---

## System Architecture

The repository contains two coordinated project layers:

1. **Godot 4 Engine Simulation (`restaurant_tycoon_3d/`)**
   - Built on Godot 4.3 using GDScript 2.0.
   - Compatibility renderer (OpenGL 3.0 / WebGL 2.0) and Forward+ rendering pipeline support.
   - Vector-based path navigation using spatial waypoints for realistic room and aisle circulation.
   - Physics ray-casting and input handling on 3D collision bodies for direct player interaction.
   - Billboarded 3D user interface nodes dynamically aligned to the camera view frustum.
   - Component-based scene composition utilizing standard glTF and GLB asset formats.

2. **Flutter Mobile Companion Framework (`lib/`, `android/`, `ios/`, etc.)**
   - Layered architecture separating UI presentation, business logic, and local data persistence.
   - Cross-platform targeting for Android, iOS, Linux, Windows, macOS, and Web.
   - Material 3 design system with adaptive layout constraints.

---

## Core Simulation Loops

### Guest Lifecycle State Machine

Each customer entity transitions through a deterministic sequence of states managed by `scripts/customer.gd`:

1. **SPAWNING**: Instantiated at the exterior sidewalk arrival marker.
2. **WALKING_TO_HOST**: Navigates through the exterior doorway to the reception host desk.
3. **AT_HOST**: Pauses momentarily as the hostess performs a welcoming gesture, and target table availability is confirmed.
4. **WALKING_TO_TABLE**: Traverses the reception archway, central pedestrian aisle, and arrives at the assigned table.
5. **SEATED_ORDERING**: Seats on the chair facing directly into the tabletop, displays a thought bubble with the selected menu item, and activates the patience countdown.
6. **EATING**: Triggered upon food delivery by a waiter. Plays eating animations, displays satisfied emote bubbles, and transfers order revenue to the treasury.
7. **CHEERING**: Vacates the seat upon finishing, leaves dirty dishes on the table, and initiates the departure phase.
8. **WALKING_TO_EXIT**: Traverses the exit aisle back through the front doors, despawning upon reaching the street sidewalk.

### Customer Patience and Tip Mechanics

Seated customers display an active 3D billboarded patience bar directly above their avatars:
- **Patience Duration**: Baseline patience of 34 seconds (reduced to 26 seconds for VIP critics).
- **Visual Feedback**: Dynamic color shifts from emerald green (ratio > 0.55), to amber yellow (0.25 to 0.55), to crimson red (< 0.25).
- **Speedy Service Bonus**: Customers served with more than 50% patience remaining award a 30% cash tip on top of standard menu revenue, accompanied by celebratory floating text indicators.
- **Walkout Penalty**: If the patience timer reaches zero before service, the customer enters an angry walkout state, plays a sound effect, and leaves the restaurant immediately with zero revenue paid.

### VIP Michelin Food Critic System

A specialized VIP Food Critic visits the restaurant at periodic intervals (randomized between 38 and 52 seconds):
- **Visual Identifier**: Marked with a gold-bordered "MICHELIN CRITIC" crown badge.
- **Demanding Taste**: Automatically orders the highest-priced unlocked menu dish currently available.
- **Review Evaluation**: If served within their tighter patience window, the critic awards a 5-star review, increases the global restaurant reputation score, and pays a 3x cash bounty. If the critic walks out neglected, the establishment loses 0.1 star rating.

### Table Turnover and Busboy Cleaning

Tables cannot accept new customers immediately after a party finishes:
- When a customer finishes eating, they vacate the seat and leave dirty dishes (`plate_dirty.gltf`) with scattered crumbs on the table.
- The table enters an `is_dirty = true` state with a visible 3D "Dirty Table" status indicator.
- The restaurant dispatch system identifies unclaimed dirty tables and directs idle waiters to clear them.
- Waiters walk to the dirty station, play a table-wiping animation, clear the dish geometry, and restore the table to clean status.
- Players may also click or tap dirty tables directly to clear them instantly as an active gameplay fallback.

### Station Tiers and Visual Evolution

Dining tables and cooking stations undergo visual and mechanical transformations as their levels increase:
- **Tier 1 (Levels 1 to 4)**: Natural pine tabletop with matching wood dining chairs.
- **Tier 2 (Levels 5 to 9)**: Upgraded with an ivory linen tablecloth, crystal wine stemware, and tabletop menu holders. Generates a +45% revenue bonus per customer.
- **Tier 3 (Levels 10+)**: Upgraded with royal brass candelabras emitting warm dynamic illumination. Generates an +85% revenue bonus per customer.
- **Upgrade Feedback**: Upgrading triggers smooth spring-scale tweens (`Tween.TRANS_BACK`), gold sparkle particle explosions (`CPUParticles3D`), and floating revenue notifications.

---

## Interior Design and Spatial Layout

The restaurant floor plan spans a 22m x 16m interior divided into three distinct operational zones:

### 1. Grand Cocktail and Espresso Bar
Positioned along the back wall of the dining hall, filling the negative space between the tables and the rear perimeter:
- Built from 5 seamlessly connected wooden counter modules and rounded end caps.
- Fronted by 5 high-top wooden bar stools aligned with comfortable clearance from dining tables.
- Equipped with an espresso machine, high-speed cocktail blender, crystal stemware, and artisan syrup decanters.
- Back-bar credenzas providing storage and warm overhead ambient illumination.

### 2. Central Island Buffet Pavilion
Centrally located between the two primary dining columns:
- Dual interconnected service credenzas equipped with self-serve coffee and fresh produce display crates.
- Framed by lush boxwood planter partitions on the north and south ends.
- Establishes two parallel pedestrian lanes, ensuring clear customer and waiter routing.

### 3. VIP Window Banquettes and Cocktail Lounge
Arranged along the right exterior perimeter under large sunlit bay windows:
- Two full-length designer lounge sofas with accent side tables.
- Potted floor palms and warm table lamps establishing a premium lounge setting.

### 4. Waiter Service and Busboy Hub
Located adjacent to the kitchen pass-through window:
- Staging cabinet stocked with fresh plate dishracks, menu stacks, and decorative greenery.
- Serves as the origin and return staging point for the floor staff.

### 5. Reception Hall and Lobby
Enclosed reception room managing customer intake:
- A plush royal crimson carpet runner bordered with gold metallic trim spanning the entrance door to the host desk.
- Formal hostess podium equipped with reservation laptop and hostess greeting triggers.
- Waiting lounge with armchairs, sofa, coffee table, and coat rack.
- Exterior facade features a classic red-and-cream striped bistro awning with an illuminated pink-and-cyan acrylic neon entrance sign reading "CHEF'S BISTRO - OPEN".

---

## Economy Balance and Formulas

### Station Upgrade Cost and Revenue

Station upgrade costs scale exponentially based on level:

```
Cost(level) = round(BaseCost * 1.20^(level - 1))
```

- Base Cost (Tables): $90.00
- Base Cost (Kitchen Stoves): $140.00

Revenue generated per dining customer scales linearly with station level:

```
Revenue(level) = BaseRevenue + (level * RevenueIncrement)
```

- Base Revenue (Tables): $45.00 + (level * $14.00)
- Base Revenue (Stoves): $35.00 + (level * $12.00)

### Staff Scaling Formulas

Staff hiring costs and upgrade costs follow consistent geometric progression:

```
StaffUpgradeCost(level) = round(BaseHireCost * 1.25^(level - 1))
```

Staff movement and prep speed scales with each level:

```
SpeedMultiplier(level) = 1.0 + ((level - 1) * 0.15)
```

Each upgrade grants a flat +15% sprint speed or preparation rate bonus.

### Menu Pricing Tiers

| Item | Base Price | Unlock Cost | Description |
| :--- | :--- | :--- | :--- |
| Classic Bistro Burger | $45.00 | Free | Grilled beef patty with aged cheddar on toasted brioche |
| Truffle Tagliatelle | $115.00 | $180.00 | Handmade ribbon pasta with shaved black winter truffles |
| Wood-Fired Margherita | $240.00 | $420.00 | San Marzano tomato sauce, fresh buffalo mozzarella, and basil |
| Deluxe Dragon Roll Sushi | $480.00 | $850.00 | Premium sushi roll with avocado, tempura prawn, and eel glaze |

### Staff Roster

| Staff Member | Role | Base Cost | Operational Benefit |
| :--- | :--- | :--- | :--- |
| Marco | Frontline Waiter | Free | Default server managing initial order routing |
| Sophia | Speed Runner | $250.00 | High sprint speed, doubling floor turnover capacity |
| Lucas | VIP Concierge | $600.00 | Triple capacity server prioritizing urgent patience orders |
| Gordon | Master Chef | Free | Handles primary saute and flame cooking |
| Pierre | Prep Artisan | Free | Handles starter plating and assembly |
| Antoine | Sous Chef | $350.00 | Expedites kitchen preparation times across all stations by +40% |

---

## Audio Engineering

The audio subsystem (`scripts/audio_manager.gd`) provides persistent environmental feedback:
- **Atmospheric Ambience**: A continuous background loop of restaurant room murmur and kitchen dish clinking normalized at -12.0 dB.
- **Polyphonic SFX Channels**: An 8-channel player pool supporting simultaneous sound playback without audio clipping or interruption.
- **Pitch Randomization**: High-frequency sound effects (coin chimes, service bells) apply +/-5% random pitch variations per trigger to prevent auditory fatigue.
- **Key Sound Effects**:
  - `coin_payout.wav`: Dual-tone chime triggered upon customer payment and tip collection.
  - `order_bell.wav`: Brass service bell triggered when kitchen plating completes.
  - `upgrade_fanfare.wav`: Ascending fanfare triggered upon station upgrade or recipe unlock.
  - `angry_exit.wav`: Comical low thud triggered when an unattended customer departs.

---

## Project Directory Structure

```
idle-game-1/
|-- .gitignore                     # Root ignore rules for Flutter, Godot, and OS artifacts
|-- README.md                      # Primary project documentation
|-- analysis_options.yaml          # Dart static analysis configuration
|-- pubspec.yaml                   # Flutter dependency specifications
|-- lib/                           # Flutter mobile source code
|   |-- logic/                     # Game state and business controllers
|   |-- models/                    # Data models (staff, menu, upgrades)
|   |-- services/                  # Persistent storage and audio services
|   |-- ui/                        # Flutter presentation widgets and screens
|   `-- utils/                     # Formatting and numerical utilities
|-- android/                       # Android native project wrapper
|-- ios/                           # iOS native project wrapper
|-- linux/                         # Linux desktop native wrapper
|-- windows/                       # Windows desktop native wrapper
|-- macos/                         # macOS desktop native wrapper
|-- web/                           # Web application deployment files
`-- restaurant_tycoon_3d/          # Godot 4 3D Restaurant Game Project
    |-- .gitignore                 # Godot engine cache and export ignore rules
    |-- project.godot              # Godot project configuration and autoloads
    |-- assets/                    # 3D assets, textures, and audio files
    |   |-- audio/                 # 16-bit PCM WAV sound effects and ambience
    |   |-- kaykit_restaurant/     # Modular glTF restaurant furniture and food props
    |   |-- models/                # Characters, vehicles, and furniture models
    |   `-- textures/              # Procedural and hand-crafted diffuse/emission maps
    |-- scenes/                    # Godot 3D scene files (.tscn)
    |   |-- chef.tscn              # Animated chef character entity
    |   |-- cooking_station.tscn   # Stove station with steam/sizzle particle effects
    |   |-- customer.tscn          # Customer entity with patience meter
    |   |-- dining_table.tscn      # Multi-tier table with dirty plate turnover
    |   |-- floating_cash.tscn     # Floating text payout indicator
    |   |-- main.tscn              # Main restaurant simulation environment
    |   |-- waiter.tscn            # Waiter entity with tray and busboy AI
    |   `-- ui/
    |       `-- hud.tscn           # HUD overlays, recipe menu, and staff modals
    `-- scripts/                   # Core GDScript simulation logic
        |-- audio_manager.gd       # Audio playback controller (autoload)
        |-- camera_controller.gd   # Isometric camera pan, zoom, and framing
        |-- chef.gd                # Chef station interaction and animation
        |-- cooking_station.gd     # Cooking station state and upgrade logic
        |-- customer.gd            # Customer state machine and patience timer
        |-- dining_table.gd        # Table state, tier decor, and turnover
        |-- game_manager.gd        # Central game economy, staff, and menu manager
        |-- hostess.gd             # Hostess desk greeting controller
        |-- restaurant.gd          # Spawner, table allocation, and dispatch queue
        |-- ui_controller.gd       # HUD and modal window data bindings
        `-- waiter.gd              # Waiter service routing and busboy wiping AI
```

---

## Installation and Execution

### Running the Godot 3D Simulation

#### Prerequisites
- Godot Engine 4.3 (Standard or .NET build)
- GPU with OpenGL 3.3 / ES 3.0 support or Vulkan capability

#### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/Dr-Rank1/Idle-1.git
   cd Idle-1/restaurant_tycoon_3d
   ```
2. Open the Godot Project Manager:
   - Click **Import**.
   - Browse to `Idle-1/restaurant_tycoon_3d/` and select `project.godot`.
   - Click **Import & Edit**.
3. Press **F5** (or the Play button in the top-right corner) to launch `scenes/main.tscn`.
4. Command line execution:
   ```bash
   godot --path restaurant_tycoon_3d
   ```

### Running the Flutter Companion Application

#### Prerequisites
- Flutter SDK 3.19.0 or higher
- Dart SDK 3.3.0 or higher

#### Steps
1. Navigate to the project root:
   ```bash
   cd Idle-1
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run on your connected device or desktop target:
   ```bash
   flutter run
   ```

---

## License

This project is released under the MIT License. 3D models and audio assets are utilized under CC0 and appropriate royalty-free commercial licenses.
