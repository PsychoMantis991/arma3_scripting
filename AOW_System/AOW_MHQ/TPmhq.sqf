/*
	Teleport a MHQ
	Uso: [] execVM "AOW_System\AOW_MHQ\TPmhq.sqf";
	Nota: Requiere que DialogMHQ.sqf se haya ejecutado antes
*/

if (lbSize 4603 == 0) exitwith {
	hintSilent "No MHQ available";
};

_lbPos = lbCurSel 4603;
_selectedMHQ = lbData [4603, _lbPos];
_MHQ = missionNamespace getVariable [_selectedMHQ, objNull];

if (alive _MHQ) then {
	closeDialog 0;
	[player, _MHQ] call BIS_fnc_moveToRespawnPosition;
	
	// Teleportar AIs del grupo (opcional)
	if (leader group player == player) then {
		{
			if (!isPlayer _x && _x distance player < 100) then {
				[_x, _MHQ] call BIS_fnc_moveToRespawnPosition;
			};
		} forEach units (group player);
	};
	
	hint "Teleported to MHQ";
} else {
	hintSilent "MHQ destroyed";
};
