## 2. Belangrijke begrippen (de "waarom" achter de code)

### Vector2 — een richting/positie met X en Y
Een `Vector2` is gewoon **twee getallen samen: een X en een Y**. In 2D-games
gebruik je dat overal voor:
- een **positie** op het scherm: `Vector2(100, 50)` = 100 px naar rechts, 50 omlaag.
- een **richting**: `Vector2.DOWN` is `(0, 1)` → naar beneden.

Handige kant-en-klare waarden:
| Code | Betekenis | Waarde |
|------|-----------|--------|
| `Vector2.ZERO` | stilstaan | `(0, 0)` |
| `Vector2.UP` | omhoog | `(0, -1)` |
| `Vector2.DOWN` | omlaag | `(0, 1)` |
| `Vector2.LEFT` | naar links | `(-1, 0)` |
| `Vector2.RIGHT` | naar rechts | `(1, 0)` |

> Let op: in Godot is **Y omlaag positief**. `UP` is dus `-1`, niet `+1`.


### `_process(delta)` vs `_physics_process(delta)`
Dit zijn functies die Godot **automatisch elke frame** voor je aanroept:
- `_process(delta)` → elke beeld-frame (zo snel als de pc kan).
- `_physics_process(delta)` → vast ritme (60x per sec), gebruik je voor beweging/botsingen.

### `delta` — waarom dit zo belangrijk is
`delta` is **de tijd in seconden sinds de vorige frame** (bijv. 0,016 s).
Door snelheid met `delta` te vermenigvuldigen gaat alles **even snel op elke pc**,
of die nu 30 of 144 fps draait. Zonder `delta` zou het spel op een snelle pc
te snel gaan.

### `velocity` + `move_and_slide()`
`velocity` is een ingebouwde `Vector2` van een `CharacterBody2D`: het is de
**snelheid + richting** waarmee het lichaam beweegt. `move_and_slide()` neemt
die `velocity` en **verplaatst het object én stopt netjes tegen muren** (sliden
in plaats van vastlopen). Je hoeft `delta` hier niet zelf te gebruiken —
`move_and_slide()` doet dat intern.

### Nodes & scenes
Alles in Godot is een **node** (bouwsteen). Een **scene** is een groepje nodes
samen (bijv. de speler, of een auto). Soorten die ik gebruik:
- `CharacterBody2D` → de speler (botst tegen dingen aan).
- `Area2D` → de auto en het doel (detecteren "iets raakt mij", zonder fysieke botsing).
- `Control` / `Button` → de UI (menu, knoppen).

### Signals (`_on_...`)
Een **signal** is een melding: "er gebeurde iets!". Functies die met `_on_`
beginnen zijn aan zo'n signal gekoppeld in de editor. Voorbeeld:
`_on_body_entered` wordt aangeroepen zodra er iets de Area2D binnenkomt.

### Groups
Een **group** is een label dat je op een node plakt. Ik check
`body.is_in_group("player")` om te weten of het de **speler** is die de auto
raakt (en niet bijv. een andere auto). Zo reageert het spel alleen op de speler.

---

## 3. De scripts, regel voor regel

### `scripts/player.gd` — de speler besturen
```gdscript
extends CharacterBody2D

const SPEED = 300.0

func _physics_process(_delta: float) -> void:
    var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    if direction:
        velocity = direction * SPEED
    else:
        velocity = Vector2.ZERO
    move_and_slide()
```
**Wat het doet:**
- `extends CharacterBody2D` → dit script hoort bij een speler-node die kan botsen.
- `const SPEED = 300.0` → een vaste snelheid. `const` = constante (verandert nooit).
- `Input.get_vector(...)` → leest de 4 bewegingstoetsen en geeft **één `Vector2`
  terug** die de richting aangeeft. Druk je rechts → `(1, 0)`, druk je niets → `(0, 0)`.
  De toetsen `move_left` enz. heb ik in **Project Settings → Input Map** ingesteld op A/D/W/S.
- `if direction:` → is er een richting (toets ingedrukt)? Dan
  `velocity = direction * SPEED` → beweeg in die richting met snelheid 300.
- `else: velocity = Vector2.ZERO` → geen toets → stilstaan.
- `move_and_slide()` → voert de beweging uit en laat de speler langs muren glijden.

> **Coach-vraag die kan komen:** "Waarom `_physics_process` en niet `_process`?"
> → Omdat beweging en botsingen horen in de physics-loop, die op een vast ritme draait.

> De `_` voor `_delta` betekent: "ik gebruik deze variabele bewust niet"
> (`move_and_slide()` regelt de timing zelf).

---

### `scripts/car.gd` — de auto's die heen en weer rijden
```gdscript
extends Area2D

var SPEED = 300.0

@export var move_down: bool

@onready var initial_position = position

func _process(delta: float) -> void:
    if move_down:
        position += Vector2.DOWN * SPEED * delta
    if !move_down:
        position += Vector2.UP * SPEED * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
    position = initial_position

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        $"../CanvasLayer/GameOverUI".show()
        get_tree().paused = true
```
**Wat het doet:**
- `@export var move_down: bool` → `@export` maakt deze variabele **zichtbaar in
  de Godot-editor**. Zo kan ik per auto met een vinkje kiezen of die omhoog of
  omlaag rijdt, **zonder de code aan te passen**. Heel handig: één script,
  meerdere auto's met ander gedrag.
- `@onready var initial_position = position` → `@onready` betekent: vul dit in
  **zodra de auto in het spel klaarstaat**. Ik onthoud hier de **startpositie**.
- In `_process` beweegt de auto elke frame: `position += richting * SPEED * delta`.
  Door `* delta` gaat de auto overal even snel (zie uitleg hierboven).
- `_on_..._screen_exited()` → een signal van de **VisibleOnScreenNotifier2D**:
  zodra de auto **het scherm verlaat**, zet ik hem terug op `initial_position`.
  Zo blijft het verkeer eindeloos doorlopen (recyclen).
- `_on_body_entered(body)` → een signal: er komt iets de auto-area binnen.
  - `if body.is_in_group("player")` → is het de speler?
  - `$"../CanvasLayer/GameOverUI".show()` → toon het **Game Over**-scherm.
    De `$"../..."` is een **pad naar een andere node** (`..` = ga een niveau omhoog).
  - `get_tree().paused = true` → **pauzeer het hele spel**.

> **Coach-vraag:** "Wat is het verschil tussen `Area2D` en `CharacterBody2D`?"
> → `Area2D` botst niet fysiek, maar **detecteert overlap** (perfect om te zien of
> de auto de speler raakt). `CharacterBody2D` is bedoeld om mee te bewegen/botsen.

---

### `scripts/aim_area.gd` — het doel (win-zone)
```gdscript
extends Area2D

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        $"../CanvasLayer/YouWinUI".show()
        get_tree().paused = true
```
**Wat het doet:** precies dezelfde truc als bij de auto, maar dan positief.
Komt de **speler** in deze zone → toon **You Win** en pauzeer het spel.

---

### `scripts/menu.gd` — het startmenu
```gdscript
extends Control

func _on_play_button_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/main.tscn")
```
**Wat het doet:** `extends Control` → een UI-node. Als op de **Play-knop** wordt
gedrukt (signal `pressed`), wordt met `change_scene_to_file(...)` **de hele scene
gewisseld** naar `main.tscn` (het echte spel). `res://` is het pad naar de
projectmap.

---

### `scripts/restart_button.gd` — opnieuw spelen
```gdscript
extends Button

func _on_pressed() -> void:
    get_tree().paused = false
    get_tree().reload_current_scene()
```
**Wat het doet:** als de Restart-knop wordt ingedrukt:
- `get_tree().paused = false` → **haal de pauze eraf** (anders blijft alles stil).
- `reload_current_scene()` → **laad het level opnieuw**, dus alles begint vers.

---

## 4. Rode draad — hoe alles samenwerkt

1. **Menu** (`menu.gd`) → Play → laadt `main.tscn`.
2. In het spel bestuur ik de **speler** (`player.gd`) met WASD via `velocity`.
3. **Auto's** (`car.gd`) rijden rond met `_process` + `delta`, en recyclen zodra
   ze het scherm verlaten.
4. Raakt een auto de speler → **Game Over** + pauze.
   Bereikt de speler het **doel** (`aim_area.gd`) → **You Win** + pauze.
5. **Restart** (`restart_button.gd`) → pauze eraf + level herladen.

---

## 5. Begrippen die ik zeker wil kunnen uitleggen

- **Vector2** = X + Y samen; gebruikt voor positie én richting.
- **velocity** = snelheid-vector van een `CharacterBody2D`.
- **delta** = tijd per frame; zorgt dat alles overal even snel gaat.
- **`_process` / `_physics_process`** = functies die elke frame draaien.
- **Signal** (`_on_...`) = "er gebeurde iets"-melding vanuit een node.
- **Group** = label op een node; ik check `is_in_group("player")`.
- **`@export`** = variabele instelbaar in de editor (auto omhoog/omlaag).
- **`@onready`** = waarde invullen zodra de node klaarstaat (startpositie onthouden).
- **`get_tree().paused`** = het hele spel pauzeren/hervatten.
- **`Area2D` vs `CharacterBody2D`** = detecteren vs. echt botsen/bewegen.

---

## 6. Mogelijke verbeterpunten (laat zien dat ik kritisch ben)

- In `car.gd` is `SPEED` een `var`; het mag een `const` zijn want hij verandert nooit.
- `if move_down:` / `if !move_down:` kan netter met `else`.
- De vaste node-paden zoals `$"../CanvasLayer/GameOverUI"` zijn gevoelig als ik de
  scene-structuur verander; een `signal` naar boven of een `@export`-node zou robuuster zijn.
- Speler-snelheid is een `const` (goed!), maar zou ik ook via `@export` instelbaar kunnen maken.
