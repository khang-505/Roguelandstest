# Roguelands — Game Design Document (Sections 1 → 6)

## 1. Tổng quan game
### 1.1. Thể loại
Roguelands là game 2D Action RPG kết hợp Roguelike / Roguelite:
Action + Exploration + RPG + Roguelike + Loot + Crafting

### 1.2. Mục tiêu của người chơi
- **Mục tiêu ngắn hạn**: Sống sót, tiêu diệt enemy, thu thập resource, tìm equipment tốt hơn, hoàn thành khu vực, đánh boss.
- **Mục tiêu trung hạn**: Xây dựng character build, mở khóa equipment, craft item, nâng cấp character, khám phá khu vực khó hơn.
- **Mục tiêu dài hạn**: Hoàn thành toàn bộ progression, mở khóa nội dung, xây dựng build mạnh, chinh phục các khu vực/boss khó nhất.

### 1.3. Core Gameplay Loop & Risk / Reward
Exploration -> Combat -> Gathering -> Loot -> Inventory (Equip / Craft) -> Stronger -> Explore Deeper -> Boss (Win / Death) -> Progression -> New Run.

### 1.4. Exploration & Decision Making
Bản đồ phân nhánh phi tuyến tính (Start -> Resource / Enemy / Chest / Secret -> Boss), buộc người chơi đưa ra quyết định đánh đổi giữa an toàn (Normal Area) và mạo hiểm để lấy phần thưởng cao hơn (Elite / Unknown Area).

### 1.5. Biomes & Biome Identity
- **Forest**: Nature theme, Beast/Plant monsters, Wood/Plant resources.
- **Desert**: Sand theme, Scorpion/Sand creatures, Ore/Crystal resources.
- **Ice**: Frozen theme, Ice creatures, Ice Crystal/Rare Ore resources.
- **Alien**: Sci-fi alien theme, Void Lurkers/Drones, Star Shard resources.

---

## 2. Player System
### 2.1. Movement & Controls
4 chiều di chuyển, nhảy, nhảy 2 lần (double jump), lướt (dash), rơi xuyên sàn (one-way platform drop down), chịu ảnh hưởng của va chạm, xô văng (knockback) và làm chậm (slow/stun).

### 2.2. State Machine (FSM)
- `IDLE`: Đứng yên.
- `MOVING`: Di chuyển.
- `ATTACKING`: Đang tấn công.
- `HURT`: Bị dính đòn.
- `DODGING`: Đang né tránh / lướt.
- `USING_ITEM`: Sử dụng vật phẩm tiêu hao.
- `DEAD`: Tử trận.

### 2.3. Health & Damage Calculation
`Final Damage = max(1, (Raw Damage * (CritMult if is_crit else 1.0) * ElementMod) - Defense)`

### 2.4. Leveling & XP Progression
Hạ gục quái nhận XP -> Tích lũy đủ XP -> Level Up (Hồi máu, tăng Max HP, tăng Sát thương cơ bản).

### 2.5. Equipment & Build Systems
- Vị trí trang bị: `Weapon`, `Helmet`, `Chest`, `Legs`, `Boots`, `Accessory`.
- Định hình Archetypes: `Tank`, `Assassin`, `Ranged`, `Mage`.

---

## 3. Combat System
### 3.1. Attack Phases (4 Giai đoạn đòn đánh)
1. **Wind-up**: Chuẩn bị vung đòn (0.1s).
2. **Active Frame**: Bật Hitbox va chạm (0.15s).
3. **Hit**: Gây sát thương, tính Crit roll & hiệu ứng giật lùi Knockback.
4. **Recovery**: Hồi đòn kết thúc animation (0.1s).

### 3.2. Damage Feedback & Game Feel
- Enemy Flash tinting khi trúng đòn.
- Floating Damage Text (Màu vàng cho Crit, Cam cho Lửa, Cyan cho Băng, Tím cho Vẫn đục, Xanh lá cho Hồi máu).
- Hit knockback impulse.

### 3.3. Status Effects
- `POISON`: Trừ HP theo thời gian.
- `BURN`: Thiêu đốt gây sát thương lửa.
- `SLOW`: Giảm tốc độ di chuyển.
- `FREEZE`: Đóng đông bất động.
- `BUFF_ATTACK`: Tăng 20% sát thương.
- `BUFF_SPEED`: Tăng 25% tốc độ di chuyển.

---

## 4. Advanced Action Combat System
### 4.1. Core Combat Loop
Observe Enemy Telegraph -> React / Dodge / Move -> Attack Window -> Deal Damage -> Adapt to Enemy Behavior Changes.

### 4.2. Enemy Telegraphing
Mọi kẻ địch trước khi xuất hiện đòn đánh sẽ phát ra tín hiệu cảnh báo `TELEGRAPH` (Nháy sáng màu vàng/đỏ 0.4s) để người chơi nhận biết và lướt né (`Dash`) hoặc né đòn.

### 4.3. Dodge & Active Defense (i-Frames)
Phim Dash cung cấp khung hình bất tử (`is_invulnerable = true`) giúp né tránh 100% sát thương.

### 4.4. Class Active Skills (Phím Q / L)
- **Vanguard Class**: `Shield Charge` (Ủi khiên gây 40 sát thương AoE + Giật lùi mạnh, 30 Energy, 4s CD).
- **Scout Class**: `Frost Nova` (Xung băng gây làm chậm/đóng đông quái vật xung quanh, 25 Energy, 3.5s CD).
- **Mystic Class**: `Flame Burst` (Bắn 3 quả cầu lửa tỏa 3 hướng, 20 Energy, 3.0s CD).

### 4.5. Enemy AI Adaptation
Khi quái bị tụt máu dưới 50% HP, AI chuyển sang trạng thái Nổi giận (Enrage): Tăng 30% tốc độ di chuyển và rút ngắn thời gian hồi đòn.

---

## 5. Weapon System & Attack Patterns
### 5.1. Thuộc tính Vũ khí
- **Damage, Attack Speed, Range, Elemental Effect, Special Ability, Rarity**.
- **Attack Patterns**:
  - `SWORD_SWEEP`: Chém nón cận chiến.
  - `SPEAR_THRUST`: Đâm giáo đường thẳng dài.
  - `RANGED_PROJECTILE`: Bắn đạn tầm xa (Thả diều / Kite).
  - `AOE_BURST`: Phát xung nổ diện rộng.

---

## 6. Armor System & Character Build Archetypes
### 6.1. 5 Slot Trang bị
`Helmet`, `Chest`, `Legs`, `Boots`, `Accessory`.

### 6.2. Stat Trade-offs & Character Archetypes
- **Melee Tank**: Giáp ngực Titan Chestplate (+50 HP, +12 Def, -5% Speed) + Titan Spear.
- **Glass Cannon**: Thấu kính Crit Lens (+15 Atk, +20% Crit Dmg, -20 HP).
- **Assassin**: Giày Hyperion Swift Boots (+40 Speed, +10% Crit, -15 HP) + Dagger.
- **Ranged DPS**: Súng Frost Rifle (+Băng làm chậm) + Tốc độ di chuyển.

## 7. Loot System
### 7.1. Loot Flow
Enemy Defeated -> Drop Roll -> Gold / Material / Equipment. Loot là cầu nối giữa Combat và Progression.

### 7.2. Các loại Loot
- **Gold**: Dùng cho economy, shop.
- **Material**: Dùng cho crafting (Ore, Wood, Crystal, Monster Material).
- **Equipment**: Trang bị vũ khí, áo giáp.

### 7.3. Rarity (Độ hiếm)
Common -> Uncommon -> Rare -> Epic -> Legendary.
Độ hiếm càng cao -> Chỉ số càng mạnh, có Special Effects.

### 7.4. Loot tạo sự bất ngờ
Random loot (RNG) trong các lần chơi khác nhau. Mạo hiểm sâu hơn -> Tỉ lệ ra loot xịn cao hơn (Risk / Reward).

### 7.5. Loot và Build
Loot có thể bẻ lái định hướng Build của người chơi trong Run.

---

## 8. Inventory System
### 8.1. Inventory Flow
Loot -> Inventory -> Equip / Use / Keep / Discard.

### 8.2. Inventory Limit & Decision Making
Inventory có giới hạn. Khi đầy, người chơi phải quyết định giữ lại Item nào (Giữ Weapon vs Material vs Potion). Đòi hỏi tính chiến thuật quản lý tài nguyên.

### 8.3. Risk / Reward & Death
- Temporary Progression: Inventory thu thập trong Run là tạm thời. Nếu chết, toàn bộ Loot tạm thời sẽ biến mất. Cần đưa về Base (Stash) để bảo lưu dài hạn.

---

## 9. Crafting System
### 9.1. Biến Resource thành sức mạnh
Ore + Crystal + Monster Material -> Crafting -> Vũ khí/Áo giáp mới.

### 9.2. Crafting tạo động lực Exploration
Người chơi phải để ý nhặt Resource trên bản đồ, chứ không chỉ đánh quái lấy vàng.

### 9.3. Crafting và Decision-making
Tài nguyên có hạn. Người chơi phải lựa chọn ưu tiên Craft Weapon hay Armor tùy theo định hướng Build.

## 10. Resource Gathering System
### 10.1. Các loại Resource
- Phân loại: Ore, Crystal, Plant, Wood, Monster Parts, Rare Materials.
- Thu thập qua khám phá: Đánh đổi thời gian thám hiểm lấy nguyên liệu craft (Risk/Reward).
### 10.2. Vai trò Resource
Nguyên liệu cốt lõi để Crafting, Upgrade, Consumables -> Tiến trình sức mạnh (Progression).

## 11. Procedural World System
### 11.1. Mục đích
Tạo Replayability. Mỗi Run sẽ có Layout, Enemy, Resource, và Encounter ngẫu nhiên nhưng theo quy tắc.
### 11.2. Building Blocks
Bản đồ được ghép từ các khu vực (Area A, Area B...) được thiết kế sẵn để đảm bảo logic.
### 11.3. Biến thiên theo Biome
- Enemy Pool thay đổi theo Biome.
- Resource Pool thay đổi theo Biome.
- Cấu trúc: Start -> Area -> Area -> Boss.

## 12. Biomes / Worlds System
### 12.1. 4 Biome chính
1. **Forest**: Theme thiên nhiên. Resource: Wood/Plant. Enemy: Beast/Plant Monster.
2. **Desert**: Theme khô cằn. Resource: Ore/Crystal. Enemy: Sand Creature/Scorpion.
3. **Ice**: Theme băng giá. Resource: Ice Crystal. Enemy: Frozen Creature.
4. **Alien / Space**: Theme viễn tưởng. Resource: Alien Material. Enemy: Alien Monster.
### 12.2. Difficulty Scaling
Độ khó tăng dần qua từng khu vực (Zone 1 -> Zone 2 -> Zone 3 -> Boss). Biome càng khó -> Quái mạnh hơn -> Resource hiếm hơn -> Loot xịn hơn.

## 13. Enemy System
### 13.1. Các chỉ số cơ bản
HP, Damage, Defense, Speed, Attack Range.
### 13.2. AI và Behavior
- **Melee Enemy**: Tiếp cận -> Đánh -> Cooldown -> Lặp lại.
- **Ranged Enemy**: Giữ khoảng cách -> Bắn -> Đổi vị trí.
- **Elite Enemy**: Biến thể mạnh hơn với HP cao, Damage cao, Pattern đánh khác và Rớt đồ ngon hơn.
### 13.3. Drop Table & Difficulty
Gắn với Biome. Quái ở Depth cao hơn sẽ trâu hơn và phức tạp hơn.

## 14. Boss System
### 14.1. Boss Phases (Các giai đoạn)
Boss không chỉ là cục máu to. Boss phải có nhiều Phase. Chuyển Phase khi tụt máu -> Ra đòn mới (Attack Pattern thay đổi).
### 14.2. Enrage (Nổi giận)
Khi Boss gần chết, vào trạng thái Enrage -> Đánh nhanh hơn, ép người chơi phải kết thúc sớm.
### 14.3. Kiểm tra Build
Boss là bài test bắt buộc. Build thủ (Tank) đánh lâu nhưng sống dai. Build công (Glass Cannon) đánh nhanh nhưng dễ chết.

## 15. Death System
### 15.1. Temporary vs Permanent
- **Mất (Temporary)**: Loot, Vũ khí tạm, Balo trong Run.
- **Giữ (Permanent)**: Upgrade, Đồ trong Stash, Recipe, Progression.
### 15.2. Learning Loop
Chết không phải Game Over mà là cơ hội học Attack Pattern của quái, thay đổi Build, và bắt đầu Run mới mạnh hơn.

## 16. Progression System
### 16.1. Temporary vs Permanent
- **Temporary Progression**: Đồ trong Balo (Backpack), Vũ khí nhặt tạm, Buff tạm thời. Sẽ mất khi chết.
- **Permanent Progression**: Total Credits, Mở khóa công thức (Unlock), Đồ lưu trong kho (Stash). Giữ lại mãi mãi.

## 17. Character Build System
### 17.1. Các Archetype chính
Sự kết hợp giữa Weapon + Armor + Origin tạo ra các trường phái:
- **Melee Tank**: HP cao, Defense cao, Vũ khí Melee -> Lối chơi áp sát, chịu đòn.
- **Assassin**: Burst Damage, Crit cao, Speed cao, Defense thấp -> Lối chơi Hit and Run.
- **Ranged**: Tầm đánh xa, Mobility cao -> Lối chơi thả diều (Kiting).

## 18. Consumables System
### 18.1. Vật phẩm tiêu hao
- **Health Potion**: Hồi HP. Decision-making: Dùng ngay hay giữ lại đánh Boss?
- **Mana/Energy Potion**: Hồi Mana/Energy để dùng kỹ năng.
- **Buffs/Food**: Tăng tạm thời các chỉ số (Attack, Speed, Defense) trong một khoảng thời gian của Run.
- **Quản lý Inventory**: Consumable chiếm chỗ trong Balo -> Người chơi phải đánh đổi giữa việc mang Máu/Buff và việc nhặt Nguyên liệu/Trang bị.

## 19. NPC / Hub
### 19.1. Vai trò của Hub
Hub là khu vực an toàn (Preparation Phase) giữa các Run. Có 3 chức năng chính:
- **Shop**: Mua sắm bằng Gold.
- **Craft**: Chế tạo đồ bằng Materials (Đã có Forge).
- **Upgrade**: Nâng cấp vĩnh viễn (Permanent Progression).

## 20. Shop System
### 20.1. Mua bán
Người chơi dùng Gold (Credit) thu thập được trong các Run để mua:
- **Equipment**: Vũ khí, giáp mạnh hơn (Tăng sức mạnh tức thì).
- **Consumables**: Máu, Energy, Buff (Chuẩn bị cho Run sau).
- **Materials**: Nguyên liệu để bù đắp nếu đi thám hiểm không rớt ra.
### 20.2. Lựa chọn (Decision-making)
Vì Gold có hạn, người chơi phải chọn: Mua đồ để mạnh ngay (Equipment/Consumable) hay Mua Nguyên liệu để Craft (Material Economy) hay Nâng cấp (Upgrade).

## 21. Economy System
### 21.1. Gold Economy
Combat (Đánh quái) -> Rớt Gold -> Vào Shop -> Mua đồ -> Mạnh hơn.
### 21.2. Material Economy
Exploration (Nhặt tài nguyên) -> Rớt Material -> Vào Forge -> Craft đồ -> Mạnh hơn.
Hai luồng này bổ trợ cho nhau và cùng giải quyết bài toán Progression.

## 22. Difficulty System
### 22.1. Scaling
Độ khó tăng theo chiều sâu (Depth/Zone). 
- HP và Damage của quái tăng.
- Complexity: Quái Elite xuất hiện nhiều hơn.
- Loot Quality: Tỷ lệ rớt đồ hiếm tăng lên.

## 23. Risk vs Reward
### 23.1. Lựa chọn Sinh tử
- **Continue**: Đi tiếp -> Độ khó tăng (Risk) -> Cơ hội nhặt đồ xịn (Reward).
- **Return**: Quay về Hub -> Mất cơ hội đồ xịn -> Giữ toàn bộ tài nguyên đã farm an toàn.
- Nếu chết, mất trắng túi đồ (Backpack).

## 24 - 27. Hệ thống liên kết & Replayability
- **Core Loop**: Combat -> Loot -> Craft -> Build -> Stronger -> Harder Area.
- Tính chơi lại (Replayability) đến từ: Map ngẫu nhiên, Loot ngẫu nhiên, Build đa dạng, và Risk/Reward decision making.
- Tổng kết: Roguelands là sự kết hợp của 10 hệ thống (Movement, Combat, Procedural World, AI, Loot, Inventory, Crafting, Build, Progression, Risk/Reward).
