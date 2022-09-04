# Overview

This is based on the [SCP 106 articles here](https://scp-wiki.wikidot.com/scp-106). 

My version of SCP 106 has a slightly higher skill floor and a much higher skill ceiling than most other SCP 106 workshop addons. Everything it does fits the lore pretty well. This addon will also set a configuration file, so you can tweak it to fit your needs. I'll be releasing some functionality updates and bug fixes over the next couple months, and then probably just bug fixes after that. 

## It has the following abilities, which all come from the lore:
### Active Abilities:
- Set an exit point in a wall, floor, or ceiling. You'll use this to get back from your pocket dimension.
- Lunge into a wall/floor/ceiling to get to your pocket dimension after setitng the exit point, will also allow you to "teleport" forward a short distance

### Passive Abilities:

- Due to SCP 106's aversion to sudden light, spamming your flashlight at SCP 106 from close enough will send it to the Pocket Dimension, but don't get too close because...
- SCP 106 automatically pulls in anyone who gets close enough to his pocket dimension, also does 25 damage to them. 
- Can walk through doors and props without lunging. 



Currently it will not work in sandbox mode, it's something I'll add later but it isn't a priority. 

# Configuration

### Concommands

When you first load the addon to your server, you'll need to set a spawn point and a point for SCP 106's pocket dimension. These commands need to be used client side, just noclip to the center of the areas you want to mark as spawn or pocket dimension. 
 
-  Set the Spawn Point with: set_scp106_spawn
-  Set the Pocket dimension with: set_scp106_pd


### Config File
Below will be saved in your garrysmod/data/scp106_redux folder. Distances are squared, except "bc_dist".  So pd_dist is actually 800 map units, 800 * 800 = 640000. It's faster that way, don't ask  me why. The point is, if you want to change anything ending in "_dist" to something like 100 units, you need to multiply 100 * 100 and put 10000 in that spot. bc_dist is the one exception, 80 is 80 map units. For anything with "_delay" at the end, it's measured in seconds. If you edit this file wrong, you'll get a lot of errors, so don't unless you know how to validate json. If you do mess it up, just delete the "scp106_config.json" file, kill anyone currently using the swep, and it'll recreate the default one the next time someone spawns in as SCP 106. 

```
{
	"bc_dist": 80.0,
	"pd_dist": 640000.0,
	"flashlight_dist": 10000.0,
	"cs_delay": 1.0,
	"primaryattack_delay": 4.0,
	"lunge_delay": 1.0,
	"secondaryattack_delay": 0.25,
	"bc_delay": 0.1,
	"spawn_dist": 90000.0
}
```

- **bc_dist** is how far around SCP 106 he'll pull people in. 80 is about the size of an average player. Refer to one of the videos above to see how that works.
- **pd_dist** is used to limit what powers SCP 106 can use within a certain distance of his Pocket Dimension point that you set with the concommand above.
- **flashlight_dist** is how close someone need to be to SCP 106 to be able to send it to it's Pocket Dimension. The 10000 here is 100 map units, and bc_dist is 80, meaning people have a very small window to make this work.
- **cs_delay** limits how often SCP 106 will cause sounds when pasing through objects. When he goes through a door the door will emit a corrosion sound, if he stays in the doorway this limits the ound to once per second. Any more than that and he could pass through multiple doors and only the first might make a sound. 
- **primaryattack_delay** is a cooldown for when SCP 106 can teleport back from his pocket dimension to the exit point. The timer starts when SCP 106 uses RMB to set an exit point, SCP 106 then has 2 seconds to lunge into a wall, at the end of that 2 seconds SCP 106 is teleported to the Pocket Dimension and still has 2 seconds out of the 4 second delay before he can use his LMB ('primary attack') to exit through the point he set.
- **lunge_delay** cooldown for how often SCP 106 can use Lunge, keeping it at 1 means he'll be about as fast as regular walking speed when holding down the button while moving forward with W.
- **secondaryattack_delay** limits how quickly new exit points can be set. 
- **bc_delay** limits how quickly SCP 106's passive ability checks for players close enough to him to pull them into his pocket dimension. Do not set this any higher than 0.5 seconds. 
- **spawn_dist** similar to pd_dist, this limits SCP 106's powers within this distance of his spawn point. If you stand in the very center of his containment when using the concommand above, he won't be able to use any of his abilities within or on his containment.
