						ALiVE Demo Mission
						by: SpyderBlack723:
			
						Operation Landlord | ALiVE
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
This mission demonstrates the Large-Scale warfare capabilities of ALiVE. You are spawned in on an airfield on the northwestern corner of Altis.
Other NATO forces are spread throughout the AO at various military bases and cities on the western half of Altis. CSAT forces are spread out over the eastern side of Altis.
The starting forces are defined by these markers: http://gyazo.com/b368aba8532e01a065969146c90c4ab9  (NATO in the blue marker, CSAT in the red marker). Both sides will
begin to invade eachother at mission start.

						---------------------------------------------
					               |HOW TO SWITCH CSAT FACTION|
						---------------------------------------------

Switching the faction of NATO to a different one is really simple. All you need to do is change a few text fields. First, you need to change which faction the Military AI commander will control.
You can do this by going into the CSAT Military AI Commander module and setting the" Faction: CSAT" to "Faction: None". Next you need to enter the OPFOR faction classname in the
"Override Factions" field. This will insure that the Military AI Commander will now control whatever faction of units you placed instead of the CSAT faction that the mission comes with.
If you wish to have multiple insurgent factions then you can separate the faction classnames with a comma -->   for example:   rhs_faction_msv,rhs_faction_vdv

Next all you need to do is change the "Force Faction" field to the same classname that you used in the above step in the synced Military Placement (Civ Obj) and Military Placement (Mil Obj)
modules. Once this step is done, preview your mission and make sure that the OPFOR units are of the faction that you specified in each module. As a further step, you can change 
the "Auto Task BLU Enemy" in the C2ISTAR module to the new OPFOR faction. This makes sure that mission created by ALiVE will be based off of the new OPFOR faction you switched in.

A list of ALiVE compatible factions can be found here:
http://alivemod.com/wiki/index.php/Supported_Factions

						--------------------------------------------
					               |HOW TO SWITCH NATO FACTION|
						--------------------------------------------

The exact same steps as above can be used to change the BLUFOR faction.  Simply enter in a blufor side faction classname on the modules on the left side of the editor map screen.


