Arena Battler RPS GameJam Scope Sheet
Working Title
Untitled Arena RPS Battler
Possible placeholder names:
•	Streak Fist 
•	Mindstrike 
•	Clash Count 
•	RPS Arena 
•	Momentum Breaker 
________________________________________
1. Core Concept
A fast-paced arcade battler presented like a fighting game, but mechanically driven by Rock / Paper / Scissors exchanges.
Each round, the player and enemy choose Rock, Paper, or Scissors. Winning builds a streak, and higher streaks increase the damage of follow-up attacks. The goal is to outplay the opponent, build momentum, and KO them before they do the same to you.
________________________________________
2. Core Player Fantasy
The player should feel like they are:
•	reading the opponent 
•	building momentum 
•	cashing in streaks for heavier blows 
•	surviving tense back-and-forth swings 
•	landing a satisfying finisher after several successful calls 
This should feel like a mind-game duel with fighting-game presentation, not a literal fighter with movement and combo inputs.
________________________________________
3. Design Pillars
1. Fast
Rounds should resolve quickly. The player should always be doing something.
2. Readable
The player must instantly understand:
•	what they picked 
•	what the enemy picked 
•	who won 
•	how much damage happened 
•	what the current streak is 
3. Escalating
Each successful streak should raise tension and increase payoff.
4. Punchy
Even with simple mechanics, attacks should feel impactful through UI, sound, animation, and hit feedback.
5. Finishable
The project must remain small enough to finish during a jam.
________________________________________
4. Minimum Viable Product Goal
The MVP is:
•	one battle scene 
•	one player 
•	one enemy 
•	rock/paper/scissors input 
•	streak-based damage 
•	HP bars 
•	win/loss condition 
•	simple feedback for attacks and results 
•	restartable match 
If this works and feels good, the game is viable.
________________________________________
5. Core Gameplay Loop
1.	Match begins 
2.	Player chooses Rock, Paper, or Scissors 
3.	Enemy chooses Rock, Paper, or Scissors 
4.	Round resolves 
5.	Winner gains streak and deals damage based on streak 
6.	UI updates 
7.	Attack feedback plays 
8.	KO check occurs 
9.	Repeat until one fighter reaches 0 HP 
________________________________________
6. Ruleset v1
Starting values
•	Player HP: 100 
•	Enemy HP: 100 
•	Player streak: 0 
•	Enemy streak: 0 
Move set
•	Rock 
•	Paper 
•	Scissors 
Outcome rules
•	Rock beats Scissors 
•	Scissors beats Paper 
•	Paper beats Rock 
•	Matching choices result in a draw 
Streak rules
•	If player wins: 
o	player streak += 1 
o	enemy streak = 0 
•	If enemy wins: 
o	enemy streak += 1 
o	player streak = 0 
•	If draw: 
o	no damage 
o	streaks unchanged for v1 
Damage rules
Damage is based on the attacker’s current streak after the win is counted.
Suggested damage table:
•	streak 1 = 6 damage 
•	streak 2 = 10 damage 
•	streak 3 = 15 damage 
•	streak 4+ = 22 damage 
Match end
•	If player HP <= 0: enemy wins 
•	If enemy HP <= 0: player wins 
________________________________________
7. MVP Feature List
Must Have
•	main battle scene 
•	3 input buttons for Rock / Paper / Scissors 
•	random enemy move selection 
•	round resolution logic 
•	streak tracking 
•	HP tracking 
•	visible round result text 
•	visible move display for both sides 
•	win/loss state 
•	restart button 
Should Have
•	simple fighter placeholders facing each other 
•	HP bars instead of only numbers 
•	attack reaction animation or tween 
•	hit flash or hit text 
•	basic sound effects 
•	title screen 
Nice to Have
•	enemy personality/pattern bias 
•	announcer text 
•	simple screen shake 
•	streak VFX 
•	different enemy portraits 
•	best-of-three or survival mode 
________________________________________
8. Explicit Non-Goals
These are out of scope for MVP:
•	character movement 
•	jumping/dashing 
•	hitboxes/hurtboxes 
•	online play 
•	local versus multiplayer 
•	complex combo systems 
•	large roster 
•	progression systems 
•	multiple stages with unique rules 
•	advanced AI mind-reading behavior 
•	narrative mode 
This protects scope and keeps the project finishable.
________________________________________
9. Visual Presentation Strategy
The game should visually resemble a dramatic duel, even if mechanically it is simple.
Presentation approach
•	two fighters facing each other 
•	clear center-stage arena framing 
•	result banner like “WIN / LOSS / DRAW” 
•	attack feedback when damage is dealt 
•	streak indicator that grows in intensity 
•	heavier feedback on 3+ streak attacks 
Placeholder art acceptable for MVP
Use:
•	colored rectangles 
•	simple silhouettes 
•	static portraits 
•	icon-based move display 
Art can be improved later. Functionality comes first.
________________________________________
10. Audio Strategy
Sound can massively improve feel even with placeholder visuals.
Minimum audio needs
•	button click/select 
•	round resolve stinger 
•	hit sound 
•	bigger hit sound for high streaks 
•	win/loss stinger 
Music is optional at first, but a looping battle track would help a lot if time permits.
________________________________________
11. Enemy AI Scope
v1 AI
•	chooses randomly from Rock, Paper, Scissors 
v2 AI, only if time allows
•	weighted preference 
•	tendency to counter player’s last move 
•	“personality” bias 
For MVP, randomness is enough.
________________________________________
12. Technical Scope for Godot
Recommended architecture
Keep things modular but not overengineered.
Suggested scenes
•	main_menu.tscn 
•	battle_scene.tscn 
Suggested scripts
•	battle_controller.gd 
•	round_resolver.gd 
•	fighter_data.gd 
•	enemy_ai.gd 
•	battle_ui.gd 
Suggested responsibilities
battle_controller.gd
•	owns battle flow 
•	receives player input 
•	gets enemy move 
•	resolves round 
•	updates fighters 
•	checks win/loss 
•	signals UI updates 
round_resolver.gd
•	pure combat rules 
•	compares player move vs enemy move 
•	returns win/loss/draw 
fighter_data.gd
•	HP 
•	streak 
•	move history if needed later 
•	helper functions for damage/reset 
enemy_ai.gd
•	returns enemy move 
•	random for v1 
battle_ui.gd
•	updates HP bars 
•	move labels 
•	result labels 
•	end screen/restart button 
________________________________________
13. Project Milestones
Milestone 1: Combat Logic Prototype
Goal:
•	prove the loop works 
Deliverables:
•	3 buttons 
•	enemy random move 
•	win/loss/draw resolution 
•	HP values update 
•	streak values update 
•	debug labels or console output 
Success condition:
•	full match playable, even ugly 
________________________________________
Milestone 2: Scene and UI Pass
Goal:
•	make the prototype feel like an actual game 
Deliverables:
•	proper battle scene 
•	fighter placeholders 
•	HP bars 
•	move/result display 
•	restart flow 
Success condition:
•	complete match loop with readable UI 
________________________________________
Milestone 3: Juice Pass
Goal:
•	make the game satisfying 
Deliverables:
•	tweened attack lunge or flash 
•	hit effect 
•	stronger feedback on streak thresholds 
•	sound effects 
Success condition:
•	game feels punchy and presentable 
________________________________________
Milestone 4: Submission Pass
Goal:
•	ship a coherent jam build 
Deliverables:
•	title screen 
•	instructions 
•	final balancing 
•	export test 
•	bug cleanup 
Success condition:
•	submission-ready build 
________________________________________
14. Primary Design Risks
Risk 1: Too random
Plain RPS can feel luck-based.
Mitigation:
•	use streak escalation 
•	strong feedback 
•	later add enemy bias/patterns if needed 
Risk 2: Too ambitious
Trying to make it a real fighting game will kill the schedule.
Mitigation:
•	keep it to menu-driven duel logic 
•	fake depth with presentation 
Risk 3: Feels visually flat
Simple mechanics can feel dry without feedback.
Mitigation:
•	prioritize hit reaction, screen shake, sounds, and UI clarity early 
________________________________________
15. MVP Success Definition
The game is successful for jam purposes if:
•	a player can understand it within seconds 
•	each round resolves clearly and quickly 
•	streaks create tension and payoff 
•	attacks feel satisfying 
•	a full match can be played and restarted cleanly 
•	the project is complete, stable, and exportable

