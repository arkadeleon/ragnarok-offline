# RagnarokGame Login Flow vs roBrowserLegacy Alignment Plan

## Scope

This document tracks implemented and remaining work needed to align the current `Packages/RagnarokGame` login flow with the old roBrowserLegacy UI flow.

Included:

- character slot paging and slot-indexed selection
- character deletion
- modern / chunked character-list packets
- failed-login recovery
- cancel and back navigation
- login and character-select BGM / button sounds
- character detail display
- character creation preview and selection details
- map-server unavailable handling
- loading-state coverage

Explicitly out of scope:

- PIN / second password
- broad login protocol compatibility such as HAN login, EXE hash, SSO, or web token
- visual redesign beyond matching old UI behavior
- newer roBrowserLegacy UI variants such as CharSelectV2/V3/V4 and CharCreatev2/v3/v4

## Goal

The goal is to make the existing SwiftUI login flow behave like the old roBrowserLegacy login UI, while keeping the current native SwiftUI architecture.

Pixel-perfect UI parity is not required. The important part is behavioral parity: correct slots, correct navigation, useful loading states, old-client-style audio cues, and robust recovery when servers reject or fail a request.

## Current Baseline

`GameSession` currently supports the happy path:

1. login server connection
2. account login
3. char server connection
4. character list
5. character creation
6. character selection
7. map server connection

The UI currently covers:

- `LoginView`
- `LoginLoadingView`
- `CharServerListView`
- `CharacterSelectView`
- `CharacterMakeView`
- shared message boxes through `LoginFlowView`

The main gap is that several screens only implement the simplest path and do not yet preserve the old UI semantics around slot paging, delete, cancel, protocol-level refusal recovery, and login-stage audio.

Phase 1 has added explicit loading phases for the main login transitions:

- login submit to login response
- char-server selection to character-list response
- character selection to map-server response

## Implementation Status

### Phase 1: Completed

Implemented in:

- `Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/UI/LoginFlowView.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/UI/LoginLoadingView.swift`

Current behavior:

- `GameSession.LoginPhase` now includes transient states:
  - `loggingIn`
  - `connectingCharServer(_:)`
  - `waitingForMapServer(_:)`
- `login(username:password:)` only submits from `.login(.login)`, then moves to `.loggingIn`.
- refused login and login-ban packets append localized errors and return to `.login(.login)`.
- a successful login with no returned char servers returns to `.login(.login)`.
- `selectCharServer(_:)` stops login keepalive, disconnects the login client, moves to `.connectingCharServer(_:)`, and starts the char client.
- `PACKET_HC_ACCEPT_ENTER` now clears the char-server loading state by moving to `.characterSelect`.
- `PACKET_HC_REFUSE_ENTER` returns to `.login(.login)`.
- `selectCharacter(slot:)` only submits from `.characterSelect`, then moves to `.waitingForMapServer`.
- `LoginFlowView` renders `LoginLoadingView` for `.loggingIn`, `.connectingCharServer`, and `.waitingForMapServer`.
- `LoginLoadingView` uses message string ID `121` in the existing `MessageBoxView` style.

Phase 1 intentionally does not complete:

- loading state for character deletion
- map-server unavailable handling
- common error-routing helpers
- cancel / back navigation

### Phase 2: Completed

Implemented in:

- `Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/UI/CharServerListView.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/UI/CharacterSelectView.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/UI/CharacterMakeView.swift`

Current behavior:

- `GameSession.exitCurrentPhase()` is the single phase-exit entry point for login-flow screens
- server-list cancel stops the login keepalive, disconnects the login client, clears login-flow state, and returns to login
- character-select cancel shows a confirmation message box before calling `GameSession.exitCurrentPhase()`, which stops the char keepalive, disconnects the char client, clears login-flow state, and returns to login
- character-creation cancel calls `GameSession.exitCurrentPhase()` and continues to return to character select
- login refusal, login ban, char refusal, char ban, map unavailable, and map refusal now append localized message-box errors consistently
- `GameSession.ErrorMessage` owns the OK button action, with dismissal as the default action
- refusal and unavailable errors keep the current phase visible until OK is clicked, then their message action performs the recovery transition
- char-server refusal stops the stale char connection and returns to login with a localized error
- map unavailable from the char server clears the map wait loading phase and returns to character select with a localized error
- map-server refusal after map handoff stops the map connection and returns to login, because the char connection has already been closed by that point

Completed acceptance:

- server-list, character-select, and character-creation cancel buttons now have deterministic behavior
- canceling login or character-select phases leaves no active stale client for that phase
- refusal and unavailable responses show message-box errors consistently

## Confirmed Gaps

### 1. Character selection is fixed to the first three array entries - Fixed in Phase 3

### 2. Character deletion is not wired through - Fixed in Phase 5

The current delete button is disabled in `CharacterSelectView`.

`GameSession.deleteCharacter(charID:)` can send `PACKET_CH_DELETE_CHAR3`, but the accepted, refused, reserved, and cancelled responses do not update state or UI.

roBrowserLegacy supports:

- delete confirmation
- birthdate or email prompt depending on packet version
- delayed deletion countdown for older packet versions
- delete reservation
- delete cancellation
- removing the character from the selected slot on success
- displaying failure messages

Impact:

- users cannot delete characters from the game UI
- server-side deletion responses are ignored
- the character list can become stale after delete attempts

Priority: P0

### 3. Chunked / modern character-list packets are ignored - Not applicable

The current flow primarily handles `PACKET_HC_ACCEPT_ENTER`.

roBrowserLegacy also handles:

- `HC_ACCEPT_ENTER_NEO_UNION_HEADER`
- `HC_ACCEPT_ENTER_NEO_UNION_LIST`
- `HC_ACCEPT_ENTER_NEO_UNION_LIST2`
- `HC_CHARLIST_NOTIFY`
- client-side `CH_CHARLIST_REQ`

Impact:

- servers that send a header plus list chunks may never populate the character selection screen
- large character lists may be incomplete
- max slot metadata may be missing or guessed incorrectly

Priority: P0

### 4. Protocol-level refusal recovery is incomplete

Current refused login and login-ban packets append error messages and return to the login screen. Char-server refusal also clears the loading screen by returning to login.

Phase 2 now covers the main recovery paths by showing localized message-box errors for char-server refusal, map-server unavailable packets, and map-server refusal.

roBrowserLegacy re-appends the appropriate UI after refused login and unavailable map responses.

Impact:

- the user may not see why the request was rejected
- map-server unavailable responses can leave the loading UI visible
- refusal handling is duplicated and inconsistent

Priority: P1

### 5. Cancel and back navigation is incomplete

Current empty handlers:

- server list cancel
- character select cancel

roBrowserLegacy behavior:

- server list cancel closes the network connection and returns to login
- character select cancel asks for confirmation, exits the char flow, and returns to login
- character creation cancel returns to character select

Impact:

- users cannot cleanly back out of partial login flow states
- stale login or char connections can remain alive

Priority: P1

### 6. Login and character-select BGM / button sounds are missing

Map BGM already exists in the Metal and Reality map backends.

The login flow does not yet play:

- `01.mp3` during login / character-select flow
- button click sound used by old roBrowserLegacy interactions
- selection sounds when choosing a server or character

Impact:

- the old login UI feels incomplete
- map audio and login audio are handled by different concepts, so there is no single login-stage audio owner

Priority: P2

### 7. Character detail display is incomplete

Current character select displays:

- name
- numeric job ID
- level
- exp
- HP
- SP
- six stats

roBrowserLegacy old UI displays:

- localized / table-backed job name
- last map display name
- slot count and max slots
- page current / total

Impact:

- users see numeric job IDs instead of useful names
- last map is not visible
- page and slot context are missing

Priority: P1

### 8. Character creation details differ from old UI behavior

Current character creation:

- hair style is clamped to `0...12`
- hair color cycles through `0...8`
- preview uses a static first frame
- initial hair style is `0`

roBrowserLegacy old UI:

- hair style wraps through `2...26`
- hair color wraps modulo `10`
- preview continuously renders and rotates direction
- initial hair style is `2`

Impact:

- the available character appearance options do not match the old UI
- preview feedback is weaker and can imply the character sprite failed to animate

Priority: P2

### 9. Map-server unavailable packets are ignored

Current `PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME` handling is empty.

roBrowserLegacy displays an error, removes loading, and returns to character selection.

Impact:

- selecting a character on an unavailable map can appear to hang
- users receive no actionable message

Priority: P1

### 10. Loading states are only partially represented across the full flow

Current login flow has explicit SwiftUI phases for loading between:

- login submit and login response
- char server selection and character list
- character select and map-server response

Remaining loading coverage is missing between:

- character deletion request and response

roBrowserLegacy uses `WinLoading` while waiting for these transitions.

Impact:

- users can still double-submit unsupported actions such as delete once deletion is wired
- refusal recovery still has no consistent loading state to clear for map-server unavailable responses
- future deletion UI needs the same loading semantics as the implemented login transitions

Priority: P1

## Recommended Plan

### Phase 1: Introduce explicit login-flow state - Complete

Objective:

- make loading, retry, and back navigation reliable before adding more UI behavior

Implemented:

- extended `GameSession.LoginPhase` with transient states for logging in, connecting to the selected char server, and waiting for the map-server response
- added `LoginLoadingView` as the shared loading window for implemented transient states
- updated `LoginFlowView` to show loading for `.loggingIn`, `.connectingCharServer`, and `.waitingForMapServer`
- guarded login submit, character select, and character delete entry points so they only fire from the expected interactive phase
- restored the login screen after login refusal, login ban, empty char-server list, and char-server refusal

Files:

- `Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/UI/LoginFlowView.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/UI/LoginLoadingView.swift`

Completed acceptance:

- login submit shows loading until success or failure
- char server selection shows loading until character list or failure
- character select shows loading until map transition or failure

Deferred to later phases:

- deletion-specific loading
- shared handling for protocol-level refusal messages
- cleanup of stale login or char clients on cancel paths

### Phase 2: Fix cancel, back, and failure recovery - Complete

Objective:

- make every screen reversible and avoid stale connections

Changes:

- implement server-list cancel:
  - stop login keepalive
  - disconnect login client
  - return to login screen
- implement character-select cancel:
  - show confirmation
  - disconnect char client
  - return to login screen
- keep character-creation cancel returning to character select
- route login refused, char refused, and map unavailable responses through a common error presentation path

Likely files:

- `GameSession.swift`
- `CharServerListView.swift`
- `CharacterSelectView.swift`
- `MessageBoxView.swift`

Acceptance:

- every cancel button does something deterministic
- ESC/back-equivalent behavior can be layered on top without changing session semantics
- canceling a phase leaves no active stale client for that phase

Implemented:

- added `GameSession.exitCurrentPhase()` as the unified phase-exit entry point
- added client-stop helpers in `GameSession`
- routed server-list, character-select, and character-creation cancel buttons through `GameSession.exitCurrentPhase()`
- kept character-select confirmation in the view before calling `GameSession.exitCurrentPhase()`
- routed login refusal, login ban, char refusal, char ban, map unavailable, and map refusal to consistent message-box errors
- preserved character-creation cancel returning to character select

### Phase 3: Replace fixed three-character storage with slot paging - Complete

Objective:

- match old UI slot behavior while preserving SwiftUI structure

Implemented in:

- `Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/UI/CharacterSelectView.swift`

Current behavior:

- `GameSession` stores `maxCharacterSlots` (from `PACKET_HC_ACCEPT_ENTER.total`, inferred from highest slot, or defaulted to 9) and `selectedCharacterSlot` (session-level selection persisted across character-make/back)
- `GameSession.characterAnimation(forSlot:)` now looks up by `charNum` instead of array index
- `CharacterSelectView` builds a `[Int: CharacterInfo]` dictionary keyed by `charNum` and computes 3-slot pages from `maxCharacterSlots`
- Left/right page arrows appear when `totalPages > 1`; changing page resets the selection to the first slot of the new page
- Animations are loaded lazily per page and cached in `animationsBySlot`; the cache updates when the page changes or characters are added
- After `PACKET_HC_ACCEPT_MAKECHAR`, `selectedCharacterSlot` is set to the new character's slot and the view jumps to the correct page via `onChange`
- `resetLoginPhase()` resets both `selectedCharacterSlot` and `maxCharacterSlots`

Acceptance:

- sparse slots display correctly
- slots beyond the first page can be selected
- creating a character uses the selected empty slot
- selected character persists across returning to character select

### Phase 4: Support chunked character-list packets - Dropped

Investigation of the embedded rAthena server (PACKETVER 20211103) showed this phase is not applicable:

- `HC_ACCEPT_ENTER` (0x6b) still carries all character data even on PACKETVER >= 20130000
- `HC_ACCEPT_ENTER2` (0x82d) sends slot metadata only and does not change the character list path
- `HC_CHARLIST_NOTIFY` (0x9a0) sends `char_slots / 3` as a page count; it is informational and requires no reply
- `HC_ACK_CHARINFO_PER_PAGE` (0xb72) is only sent in response to an explicit `CH_CHARLIST_REQ` from the client and is not part of the initial login sequence

No code changes are needed. The existing `HC_ACCEPT_ENTER` handler already handles the complete character list correctly.

### Phase 5: Implement character deletion - Complete

Objective:

- make deletion usable and keep local state consistent with the char server

Implemented in:

- `Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/UI/CharacterSelectView.swift`
- `Packages/RagnarokNetwork/Sources/RagnarokNetwork/PacketFactory.swift`
- `Packages/RagnarokNetwork/Sources/RagnarokNetwork/Sessions/CharSession.swift`

Current behavior:

- `PacketFactory` adds `CH_DELETE_CHAR3_RESERVED(charID:)`, `CH_DELETE_CHAR3(charID:birthdate:)`, and `CH_DELETE_CHAR3_CANCEL(charID:)` factory methods; `CharSession.deleteCharacter` updated accordingly
- `GameSession.pendingDeleteCharID: UInt32?` tracks the character awaiting birthdate confirmation; reset in `resetLoginPhase()`
- `deleteCharacter(charID:)` now sends `CH_DELETE_CHAR3_RESERVED` (the initial two-step request)
- `confirmDeleteCharacter(birthdate:)` sends `CH_DELETE_CHAR3` using the stored `pendingDeleteCharID`
- `cancelDeleteCharacter()` sends `CH_DELETE_CHAR3_CANCEL` and clears `pendingDeleteCharID`
- `HC_DELETE_CHAR3_RESERVED` result=1 sets `pendingDeleteCharID` triggering the birthdate dialog; other results show localized error messages (IDs 0x718–0x71b)
- `HC_DELETE_CHAR3` result=1 removes the character from `characters` and refreshes character select; other results clear `pendingDeleteCharID` and show localized error messages (IDs 0x718–0x71e)
- `HC_DELETE_CHAR3_CANCEL` result=1 clears `pendingDeleteCharID`
- `CharacterSelectView` delete button is enabled for occupied slots; disabled while `pendingDeleteCharID` is non-nil
- First overlay shows delete confirmation (message ID 18); after server reservation succeeds, second overlay shows birthdate `TextField` (YYMMDD) with OK/Cancel
- Animation cache for deleted slot is removed on character list change

Changes:

- enable delete button for occupied slots
- add confirmation dialog using old UI message-box style
- support direct delete response handling:
  - accepted removes character from local list
  - refused shows localized error
- support reservation and cancellation packets where applicable:
  - `CH_DELETE_CHAR3_RESERVED`
  - `HC_DELETE_CHAR3_RESERVED`
  - `CH_DELETE_CHAR3_CANCEL`
  - `HC_DELETE_CHAR3_CANCEL`
- add birthdate or key input only if the target server path requires it
- show loading while waiting for delete response

Likely files:

- `GameSession.swift`
- `CharacterSelectView.swift`
- `MessageBoxView.swift`
- possibly new `CharacterDeleteConfirmationView.swift`

Acceptance:

- deleting a character removes it from the visible slot on success
- deletion refusal leaves the character intact and shows a message
- deletion reservation and cancellation do not leave the UI disabled

### Phase 6: Improve character detail display - Complete

Objective:

- match the old UI information density

Implemented in:

- `Packages/RagnarokLocalization/Sources/RagnarokLocalization/MessageStringTable+JobName.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/UI/CharacterSelectView.swift`

Current behavior:

- `MessageStringTable+JobName.swift` moved from the app target to `RagnarokLocalization`, making `localizedJobName(for:)` available as a `public` API
- `GameSession` now holds `mapNameTable: MapNameTable` initialized alongside the other localization tables
- `CharacterSelectView` displays the localized job name via `messageStringTable.localizedJobName(for:)`, falling back to the raw job ID if the job is unknown
- `CharacterSelectView` displays the localized map name via `mapNameTable.localizedMapName(forMapName:)`, falling back to the raw map name if the map is unknown; the field is empty for characters with no map

Acceptance:

- selected character shows readable job name
- selected character shows last known map name when available
- empty slots clear character details

### Phase 7: Align character creation behavior - Complete

Objective:

- make the old create-character UI behavior feel complete

Implemented in:

- `Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/UI/CharacterMakeView.swift`

Current behavior:

- initial hair style is `2` (first available style in old UI range)
- hair style left/right arrows wrap through `2...26` with no disabled state
- hair palette up arrow wraps modulo `10` (0–9)
- `GameSession.characterAnimation(for:direction:)` now accepts an optional `SpriteDirection` parameter (default `.south`)
- character preview uses `TimelineView` to cycle through animation frames at the animation's native `frameInterval`
- the `.task(id:)` loop rotates through all 8 directions every 1 second, reloading the animation and resetting the frame timer on each direction change
- the preview canvas anchors the character's feet using the animation's `pivot` offset so the character stays stable when direction or frame size changes across directions
- stat arrows guard both the upper limit (`< 9`) and the lower limit of the decremented stat (`> 1`) to prevent any stat from dropping below 1

Acceptance:

- all old UI hair styles and colors are reachable
- preview visibly animates and rotates direction
- cancel returns to the same selected empty slot

### Phase 8: Add login-flow audio - Complete

Objective:

- provide login-stage BGM and old UI sound cues without coupling them to map render backends

Implemented in:

- `Packages/RagnarokGame/Sources/RagnarokGame/Core/Sound/LoginFlowAudioPlayer.swift` (new)
- `Packages/RagnarokGame/Sources/RagnarokGame/GameSession.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/UI/LoginView.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/UI/CharServerListView.swift`
- `Packages/RagnarokGame/Sources/RagnarokGame/UI/CharacterSelectView.swift`

Current behavior:

- `LoginFlowAudioPlayer` extends `GameAudioPlayer`; owns a looping `AVAudioPlayer` for BGM and caches button sound data to avoid repeated resource loads
- `playBGM()` loads `BGM/01.mp3` and starts looping; returns immediately if already playing, so error-recovery transitions within the login flow do not restart the music
- `stopBGM()` stops and clears the BGM player
- `playButtonSound()` loads `data/wav/버튼소리.wav` on first use (cached thereafter) and plays a one-shot instance; active players are tracked in a `Set<AVAudioPlayer>` and removed after playback finishes via a Task
- `GameSession` owns a `LoginFlowAudioPlayer` initialized at construction and starts BGM immediately via an unstructured Task
- `GameSession.resetLoginPhase()` calls `playBGM()` so BGM resumes after returning from map or error recovery
- `GameSession.playLoginButtonSound()` is the public entry point for views
- Login BGM stops in the map-server packet handler before `phase = .map(.loading(progress))`, preventing overlap with map BGM
- Connect button in `LoginView`, OK button in `CharServerListView`, and OK button in `CharacterSelectView` call `gameSession.playLoginButtonSound()` matching roBrowserLegacy's `onConnectionRequest`, `onCharServerSelected`, and `onConnectRequest` trigger points

Acceptance:

- login screen starts `01.mp3`
- audio does not overlap with map BGM after map load
- repeated button clicks do not leak audio players

### Phase 9: Handle map-server unavailable

Objective:

- avoid hanging after selecting a character whose map server is unavailable

Changes:

- handle `PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME`
- show a localized message matching old behavior where possible
- clear loading state
- return to character select
- keep the char client connected if the server expects the user to choose another character

Likely files:

- `GameSession.swift`
- `MessageBoxView.swift`

Acceptance:

- unavailable map response shows an error
- the user returns to character select
- selecting another character remains possible

## Suggested Implementation Order

1. Phase 1: explicit loading state - complete
2. Phase 2: cancel and failure recovery
3. Phase 3: slot paging
4. Phase 4: chunked character list
5. Phase 5: deletion
6. Phase 6: character details
7. Phase 7: character creation details
8. Phase 9: map-server unavailable
9. Phase 8: login-flow audio

Audio is intentionally later because the loading and navigation phases define when login BGM should start and stop.

## Verification

Use the smallest relevant validation for each phase:

- `swift build --package-path Packages/RagnarokGame` after UI/session changes
- targeted packet tests in `Packages/RagnarokPackets` if new packet helpers are added
- manual login flow against the embedded rAthena stack for end-to-end behavior

Manual scenarios:

1. login succeeds and displays a loading state until the next screen - covered by Phase 1
2. login refused returns to the login window with an error - covered by Phase 1
3. server list cancel returns to login
4. character select cancel returns to login after confirmation
5. characters in slots 0, 3, and 8 render on the correct pages
6. empty slot on page 2 can create a character in the correct `charNum`
7. character delete success removes the character from the slot
8. character delete refusal keeps the character visible
9. chunked character lists populate all available slots
10. map unavailable returns to character select with a message
11. `01.mp3` plays during login flow and stops before map BGM starts
