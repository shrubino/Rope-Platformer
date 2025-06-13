This is my attempt at building a platformer that implements a rope swing system based on Worms:Armageddon's Ninja Rope

The original platformer controller was taken from the Ultimate Platformer Controller 2D:
https://github.com/Noah-Erz/Ultimate-Platformer-Controller-2D/blob/main/UltimatePlatformerController.gd

Rope swing is still very much in the works! Currently uses a half-Claude-written system of extending a Rope node that is built of segments of Area2D that then detect collisions and attach a Pin Joint node to them
...next I'll need to sort out my physics while swinging
