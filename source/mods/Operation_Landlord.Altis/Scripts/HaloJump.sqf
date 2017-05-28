_unit = _this select 1;

hint "Click on map to perform a Halo Insertion";
openMap true;
clicked = 0;
onMapSingleClick "player setpos [_pos select 0, _pos select 1, 2000]; clicked = 1; openMap false;; openmap false;onMapSingleClick ''; true;";
waitUntil {clicked == 1};

_backpackItems = backpackItems _unit;
{_unit removeItemFromBackpack _x} forEach _backpackItems;
_currentBackpack = backpack _unit;
removeBackpack _unit;
_unit addBackpack "B_Parachute";
waitUntil {(isTouchingGround _unit)};
if (isNil _currentBackpack) then {		// These three lines check to see if the unit had a backpack or not at the beginning of the jump
	removeBackpack _unit;   		// If they had a backpack it is restored in the code below these 3 lines
};					// If they had no backpack then these 3 lines remove the parachute so you are back to no backpack
removeBackpack _unit;
_unit addBackpack _currentBackpack;
_newBackpackItems = backpackItems _unit;
{_unit removeItemFromBackpack _x} forEach _newBackpackItems;
{_unit addItemToBackpack _x} forEach _backpackItems;
sleep 2;

{
	if (!isPlayer _x) then {
		_x setPos (getPos _unit);
	};
} forEach units group _unit;