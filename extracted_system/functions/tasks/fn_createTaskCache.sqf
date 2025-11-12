/*
	TAREA: DESTRUIR CACHÉ DE ARMAS
	Basado en DRO cache.sqf
*/

params [
	["_pos", [0,0,0], [[]]],
	["_side", east, [sideUnknown]]
];

private _taskID = [] call FN_generateTaskID;
private _markerName = format ["cacheMarker%1", floor(random 10000)];
private _enemyFaction = [_side] call FN_getEnemyFactionName;

// Crear cajas de armas
private _cacheClasses = ["Box_East_Ammo_F", "Box_East_Wps_F", "Box_East_WpsLaunch_F", "Box_East_Support_F"];
private _spawnedCaches = [];

for "_i" from 1 to ([2,4] call BIS_fnc_randomInt) do {
	private _cachePos = _pos findEmptyPosition [2, 20, (_cacheClasses select 0)];
	if (count _cachePos > 0) then {
		private _cache = createVehicle [selectRandom _cacheClasses, _cachePos, [], 0, "CAN_COLLIDE"];
		_cache setDir (random 360);
		_spawnedCaches pushBack _cache;
		
		// Acción de sabotaje
		_cache addAction [
			"<t color='#FF4444'>💣 Plantar Explosivo</t>",
			{
				params ["_target", "_caller"];
				_caller playAction "PutDown";
				sleep 3;
				_target setDamage 1;
				hint "Explosivo colocado";
			},
			[],
			10,
			true,
			true,
			"",
			"_this distance _target < 5 && alive _target"
		];
	};
};

if (count _spawnedCaches == 0) exitWith {
	hint "Error al crear caché";
	[_taskID, objNull]
};

// Guardias
private _guards = [_pos, _side, [4, 6], true, 100] call FN_createObjectiveGuards;

// Marcador
[_pos, _markerName, "hd_destroy", "ColorRed", "", 1] call FN_createTaskMarker;

// Tarea
private _taskTitle = "Destruir Caché";
private _taskDesc = format ["%1 está ocultando un caché de armas en la región. Destruye el caché para cortar su suministro.", _enemyFaction];

[_taskID, _taskTitle, _taskDesc, _pos, "destroy", "", 1] call FN_createBISTask;

// Trigger de completado
private _trigger = createTrigger ["EmptyDetector", _pos, true];
_trigger setTriggerArea [0, 0, 0, false];
_trigger setTriggerActivation ["ANY", "PRESENT", false];
_trigger setTriggerStatements [
	"{alive _x} count (thisTrigger getVariable 'caches') == 0",
	format ["
		['%1', true, true] call FN_completeTask;
		deleteMarker '%2';
		hint parseText '<t size=''1.5'' color=''#00FF00''>✓ CACHÉ DESTRUIDO</t>';
	", _taskID, _markerName],
	""
];
_trigger setVariable ["caches", _spawnedCaches, true];

hint parseText format ["<t size='1.5' color='#FF4444'>💣 NUEVA TAREA: DESTRUIR CACHÉ</t><br/><br/>Destruye %1 cajas de armas", count _spawnedCaches];

[_taskID, _spawnedCaches]

