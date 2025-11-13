/*
	Crear MHQ con ACE Arsenal
	Uso: [vehiculo] execVM "AOW_System\AOW_MHQ\CreateMHQ.sqf";
*/

if (isServer) then {
	_veh = _this select 0;
	
	// Proteger vehículo
	_veh setVariable ["AOW_NoCleanUp", true];
	_veh setVariable ["zbe_cacheDisabled", true, true];
	
	// Añadir respawn
	_MHQrespawn = [missionNamespace, _veh] call BIS_fnc_addRespawnPosition;
	
	// Acción: Teleport a base (si existe marker respawn_west)
	if (getMarkerColor "respawn_west" != "") then {
		_veh addAction ["<t color='#ff1111'>📍 Teleport to Base</t>", {
			player setPos (getMarkerPos "respawn_west");
			hint "Teleported to base";
		}, [], 0, false, true, "", ""];
	};
	
	// Acción: ACE Arsenal
	_veh addAction ["<t color='#ff1111'>📦 Arsenal</t>", {
		[_this select 0] call AOW_fnc_openArsenal;
	}, [], 0, false, true, "", "vehicle _this == _this"];
	
	// Limpiar cuando se destruya
	waitUntil {!alive _veh};
	[_veh] call BIS_fnc_removeRespawnPosition;
	hint "MHQ destroyed!";
};
