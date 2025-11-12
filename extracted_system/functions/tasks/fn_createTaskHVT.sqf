/*
	═══════════════════════════════════════════════════════════════════
	TAREA: ELIMINAR/CAPTURAR HVT (High Value Target)
	Basado en DRO hvt.sqf
	═══════════════════════════════════════════════════════════════════
	
	Crea una tarea para eliminar o capturar un objetivo de alto valor.
	
	Parámetros:
		_pos - Posición donde crear la tarea [x,y,z]
		_side - Lado del objetivo (default: east)
		_style - Estilo: "INSIDE" (edificio) o "OUTSIDE" (campamento)
	
	Ejemplo:
		[getPos player, east, "INSIDE"] remoteExec ["FN_createTaskHVT", 2];
*/

params [
	["_pos", [0,0,0], [[]]],
	["_side", east, [sideUnknown]],
	["_style", "INSIDE", [""]]
];

diag_log format ["[TASK_SYSTEM] === INICIANDO CREACIÓN DE TAREA HVT ==="];
diag_log format ["[TASK_SYSTEM] HVT Parámetros: pos=%1, side=%2, style=%3", _pos, _side, _style];

// ═════════════════════════════════════════════════════════════════════
// GENERAR IDs Y NOMBRES
// ═════════════════════════════════════════════════════════════════════

private _taskID = [] call FN_generateTaskID;
private _markerName = format ["hvtMarker%1", floor(random 10000)];
private _enemyFaction = [_side] call FN_getEnemyFactionName;

// Nombres de código para HVT
private _hvtCodenames = [
	"Viper", "Scorpion", "Eagle", "Wolf", "Bear", "Tiger", "Cobra", 
	"Falcon", "Panther", "Dragon", "Raven", "Shark"
];
private _hvtCodename = selectRandom _hvtCodenames;

// ═════════════════════════════════════════════════════════════════════
// CREAR HVT Y ESCENA
// ═════════════════════════════════════════════════════════════════════

private _hvtChar = objNull;
private _hvtGroup = grpNull;
private _hvtPos = _pos;
private _guards = [];

switch (_style) do {
	// ─────────────────────────────────────────────────────────────────
	// ESTILO: DENTRO DE EDIFICIO
	// ─────────────────────────────────────────────────────────────────
	case "INSIDE": {
		// Buscar edificio cercano con posiciones
		private _buildings = nearestObjects [_pos, ["House"], 200];
		_buildings = _buildings select {
			count ([_x] call BIS_fnc_buildingPositions) > 0
		};
		
		if (count _buildings == 0) exitWith {
			hint "No se encontró edificio apropiado para HVT - Cambiando a estilo OUTSIDE";
			diag_log "[TASK_SYSTEM] HVT: No se encontró edificio, forzando estilo OUTSIDE";
			_style = "OUTSIDE"; // Cambiar a estilo exterior
		};
		
		if (_style == "INSIDE") then {
			private _building = _buildings select 0;
			_hvtPos = getPos _building;
			
			// Obtener posición dentro del edificio
			private _buildingPositions = [_building] call BIS_fnc_buildingPositions;
			private _buildingPos = _pos; // Default a posición original
			
			if (count _buildingPositions > 0) then {
				_buildingPos = _buildingPositions select 0;
				diag_log format ["[TASK_SYSTEM] HVT: Usando posición de edificio %1", typeOf _building];
			} else {
				diag_log "[TASK_SYSTEM] HVT: Edificio sin posiciones, usando posición exterior";
			};
			
			// Crear HVT
			private _factionClasses = [_side] call SPAWN_getFactionClasses;
			private _infantryClasses = _factionClasses get "infantry";
			private _hvtClass = "O_officer_F"; // Default
			
			// Usar clase de facción si está disponible
			if (count _infantryClasses > 0) then {
				_hvtClass = selectRandom _infantryClasses;
			} else {
				diag_log "[TASK_SYSTEM] HVT: Usando clase vanilla por falta de clases de facción";
			};
			
			_hvtGroup = createGroup _side;
			_hvtChar = _hvtGroup createUnit [_hvtClass, _buildingPos, [], 0, "CAN_COLLIDE"];
			
			// Esperar a que se cree
			waitUntil {!isNull _hvtChar};
			
			_hvtChar setPosATL _buildingPos;
			_hvtChar setRank "COLONEL";
			_hvtChar setName _hvtCodename;
			
			diag_log format ["[TASK_SYSTEM] HVT %1 creado en %2", _hvtCodename, _buildingPos];
			
			// Añadir waypoints entre edificios cercanos
			private _nearBuildings = _hvtPos nearObjects ["House", 60];
			_nearBuildings = _nearBuildings select {[_x] call BIS_fnc_isBuildingEnterable};
			
			if (count _nearBuildings > 0) then {
				for "_i" from 1 to 3 do {
					private _nextBuilding = selectRandom _nearBuildings;
					private _positions = [_nextBuilding] call BIS_fnc_buildingPositions;
					
					if (count _positions > 0) then {
						private _wp = _hvtGroup addWaypoint [getPos _nextBuilding, 0];
						_wp setWaypointHousePosition (floor random count _positions);
						_wp setWaypointType "MOVE";
						_wp setWaypointBehaviour "SAFE";
						_wp setWaypointSpeed "LIMITED";
						_wp setWaypointTimeout [30, 60, 90];
					};
				};
				
				// Waypoint final - ciclo
				private _wpCycle = _hvtGroup addWaypoint [_hvtPos, 0];
				_wpCycle setWaypointType "CYCLE";
			};
			
			// Guardias en el edificio y alrededores
			_guards pushBack ([_hvtPos, _side, [4, 6], true, 50] call FN_spawnInfantryGroup);
			_guards pushBack ([_hvtPos, _side, [2, 4], true, 80] call FN_spawnInfantryGroup);
		};
	};
	
	// ─────────────────────────────────────────────────────────────────
	// ESTILO: FUERA (CAMPAMENTO/REUNIÓN)
	// ─────────────────────────────────────────────────────────────────
	case "OUTSIDE": {
		_hvtPos = _pos;
		
		// Crear pequeño campamento manualmente
		private _tent = createVehicle ["Land_TentDome_F", _hvtPos, [], 0, "NONE"];
		private _table = createVehicle ["Land_CampingTable_F", _hvtPos getPos [2, 90], [], 0, "NONE"];
		_table setDir 90;
		private _chair1 = createVehicle ["Land_CampingChair_V2_F", _hvtPos getPos [2.5, 135], [], 0, "NONE"];
		_chair1 setDir 180;
		private _chair2 = createVehicle ["Land_CampingChair_V2_F", _hvtPos getPos [1.5, 90], [], 0, "NONE"];
		_chair2 setDir 180;
		private _camonet = createVehicle ["CamoNet_BLUFOR_F", _hvtPos getPos [3, 45], [], 0, "NONE"];
		_camonet setDir 45;
		
		// Crear HVT
		private _factionClasses = [_side] call SPAWN_getFactionClasses;
		private _infantryClasses = _factionClasses get "infantry";
		private _hvtClass = "O_officer_F"; // Default
		
		// Usar clase de facción si está disponible
		if (count _infantryClasses > 0) then {
			_hvtClass = selectRandom _infantryClasses;
		} else {
			diag_log "[TASK_SYSTEM] HVT OUTSIDE: Usando clase vanilla por falta de clases de facción";
		};
		
		_hvtGroup = createGroup _side;
		_hvtChar = _hvtGroup createUnit [_hvtClass, _hvtPos, [], 5, "CAN_COLLIDE"];
		
		// Esperar a que se cree
		waitUntil {!isNull _hvtChar};
		
		_hvtChar setRank "COLONEL";
		_hvtChar setName _hvtCodename;
		
		diag_log format ["[TASK_SYSTEM] HVT %1 (OUTSIDE) creado en %2", _hvtCodename, _hvtPos];
		
		// Hacer que se siente en la silla
		_hvtChar setPos (getPos _chair1);
		_hvtChar switchMove "HubSittingChairUA_idle1";
		
		// Guardias alrededor
		_guards pushBack ([_hvtPos, _side, [6, 8], true, 80] call FN_spawnInfantryGroup);
		_guards pushBack ([_hvtPos, _side, [3, 5], true, 120] call FN_spawnInfantryGroup);
	};
};

// Verificar que se creó el HVT
if (isNull _hvtChar) exitWith {
	hint "Error al crear HVT";
	diag_log "[TASK_SYSTEM] Error: HVT no creado";
};

// ═════════════════════════════════════════════════════════════════════
// CREAR MARCADOR
// ═════════════════════════════════════════════════════════════════════

[_hvtPos, _markerName, "hd_destroy", "ColorRed", _hvtCodename, 1] call FN_createTaskMarker;

// ═════════════════════════════════════════════════════════════════════
// CREAR TAREA
// ═════════════════════════════════════════════════════════════════════

private _taskTitle = format ["Eliminate HVT: %1", _hvtCodename];

private _taskDescriptions = [
	format ["Intelligence reports indicate that %1 officer codenamed '%2' is operating in this area. Locate and eliminate or capture the target. The target is considered extremely dangerous and is likely protected by guards.", _enemyFaction, _hvtCodename],
	format ["High command has identified a high-value %1 target in the region. The target, known as '%2', is believed to be coordinating enemy operations. Your mission is to eliminate this threat.", _enemyFaction, _hvtCodename],
	format ["SIGINT has located %1 commander '%2' in the area. This is a priority target. Eliminate or capture the HVT to disrupt enemy command structure.", _enemyFaction, _hvtCodename]
];

private _taskDesc = selectRandom _taskDescriptions;

[_taskID, _taskTitle, _taskDesc, _hvtPos, "kill", "", 2] call FN_createBISTask;

// ═════════════════════════════════════════════════════════════════════
// CREAR TRIGGER DE COMPLETADO
// ═════════════════════════════════════════════════════════════════════

private _trigger = createTrigger ["EmptyDetector", _hvtPos, true];
_trigger setTriggerArea [0, 0, 0, false];
_trigger setTriggerActivation ["ANY", "PRESENT", false];
_trigger setTriggerStatements [
	"!alive (thisTrigger getVariable 'hvtUnit')",
	format ["
		['%1', true, true] call FN_completeTask;
		deleteMarker '%2';
		hint parseText '<t size=''1.5'' color=''#00FF00''>✓ HVT ELIMINADO</t><br/><br/>%3 neutralizado';
	", _taskID, _markerName, _hvtCodename],
	""
];
_trigger setVariable ["hvtUnit", _hvtChar, true];
_trigger setVariable ["taskID", _taskID, true];

TASK_ActiveTriggers pushBack _trigger;

// ═════════════════════════════════════════════════════════════════════
// NOTIFICACIÓN
// ═════════════════════════════════════════════════════════════════════

[
	"TaskAssigned",
	[
		format ["HVT: %1", _hvtCodename],
		format ["Eliminar objetivo de alto valor: %1", _hvtCodename]
	]
] remoteExec ["BIS_fnc_showNotification", 0];

hint parseText format [
	"<t size='1.5' color='#FF4444'>🎯 NUEVA TAREA: HVT</t><br/><br/>" +
	"<t size='1'>Objetivo:</t> <t size='1.1' color='#FFAA00'>%1</t><br/>" +
	"<t size='1'>Facción:</t> <t size='1.1'>%2</t><br/>" +
	"<t size='1'>Ubicación:</t> <t size='1.1'>%3</t><br/><br/>" +
	"<t size='0.9' color='#888888'>Revisa tu mapa para más detalles</t>",
	_hvtCodename,
	_enemyFaction,
	if (_style == "INSIDE") then {"Interior de edificio"} else {"Campamento exterior"}
];

diag_log format ["[TASK_SYSTEM] Tarea HVT creada: %1 en %2", _hvtCodename, _hvtPos];

// Retornar datos de la tarea
[_taskID, _hvtChar, _guards]

