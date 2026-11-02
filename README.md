# RALLY — Pong

**Name:** Mohammad Abulibeh  
**Class / Section:** 8-10 (Monday / Wednesday)

RALLY is a polished two-player Pong game built with Love2D. It uses a dark arcade court, clear player colors, a centered scoreboard, responsive paddles, and a first-to-seven match. Paddle and ball movement use delta time so motion stays consistent across different frame rates. The ball bounces from the court walls and paddles, and paddle hits adjust its angle based on where it lands.

## Run

Install Love2D, open a terminal in this project folder, and run:

```sh
love .
```

## Controls

- Player 1: **W / S**
- Player 2: **Up / Down arrows**
- **Space:** Start, serve, resume, or rematch
- **Esc:** Pause / resume (or quit from the title screen)
- **R:** Restart the match

## My change

The ball speeds up by 5.5% after every paddle hit, up to a safe maximum. The rally counter displays the number of consecutive paddle returns, making longer exchanges feel more exciting.

## Gameplay screenshot and demo

Click the gameplay screenshot to open the video:

[![RALLY gameplay — click to watch](screenshots/gameplay.png)](demo/pong.mov)

[Open or download the full gameplay video (MOV)](demo/pong.mov)
