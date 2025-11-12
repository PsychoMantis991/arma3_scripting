/*
	TAREA: PROTEGER CIVIL
	Basado en DRO protectCiv.sqf
	
	Protege a un civil de amenazas enemigas. Similar a DRO, crea un civil
	que debe ser contactado y luego defendido de emboscadas.
*/

params [
	["_pos", [0,0,0], [[]]],
	["_side", east, [sideUnknown]]
];

// ═════════════════════════════════════════════════════════════════
// GENERAR IDs Y NOMBRES
// ═════════════════════════════════════════════════════════════════

private _taskID = [] call FN_generateTaskID;
private _subTaskContact = format ["subtask%1", floor(random 10000)];
private _subTaskProtect = format ["subtask%1", floor(random 10000)];
private _markerName = format ["protectMarker%1", floor(random 10000)];
private _enemyFaction = [_side] call FN_getEnemyFactionName;

// ═════════════════════════════════════════════════════════════════
// BUSCAR EDIFICIO Y CREAR CIVIL
// ═════════════════════════════════════════════════════════════════

private _building = [_pos, 200, true] call FN_findNearBuilding;

if (isNull _building) exitWith {
	hint "No se encontró edificio apropiado para civil";
	diag_log "[TASK_SYSTEM] ProtectCiv: No se encontró edificio";
	[_taskID, objNull]
};

private _buildingPos = [_building] call FN_getBuildingPosition;

// Crear civil
private _civGroup = createGroup west; // Lado aliado
private _civilian = _civGroup createUnit ["C_man_1", _buildingPos, [], 0, "NONE"];
_civilian setPosATL _buildingPos;
_civilian setCaptive true;
_civilian disableAI "PATH";
_civilian setUnitPos "DOWN"; // Agachado, asustado

// Nombre aleatorio
private _civNames = ["Ahmed", "Hassan", "Ali", "Omar", "Yusuf", "Ibrahim", "Mahmoud"];
_civilian setName (selectRandom _civNames);

// Variables para el civil
_civilian setVariable ["taskName", _taskID, true];
_civilian setVariable ["contacted", false, true];

diag_log format ["[TASK_SYSTEM] Civil creado: %1 en %2", name _civilian, _buildingPos];

// ═════════════════════════════════════════════════════════════════
// CREAR MARCADOR
// ═════════════════════════════════════════════════════════════════

[getPos _building, _markerName, "hd_unknown", "ColorCivilian", "", 1] call FN_createTaskMarker;

// ═════════════════════════════════════════════════════════════════
// CREAR TAREA Y SUB-TAREAS
// ═════════════════════════════════════════════════════════════════

private _taskTitle = format ["Proteger Civil: %1", name _civilian];

private _taskDescriptions = [
	format ["Hemos recibido comunicación de que un civil local está dispuesto a darnos información sobre movimientos de tropas de %1, pero su vida está amenazada. Encuéntralo y protégelo.", _enemyFaction],
	format ["%1 ha comenzado a reprimir manifestantes en la región. Un activista llamado %2 ha pedido ayuda tras recibir amenazas creíbles. Llega hasta él y protégelo.", _enemyFaction, name _civilian]
];

private _taskDesc = selectRandom _taskDescriptions;

[_taskID, _taskTitle, _taskDesc, getPos _building, "defend", "", 2] call FN_createBISTask;

// Sub-tarea 1: Contactar
[
	west,
	_subTaskContact,
	[format ["Haz contacto con %1", name _civilian], "Contactar", ""],
	getPos _building,
	"CREATED",
	1,
	true,
	"meet",
	true
] call BIS_fnc_taskCreate;

missionNamespace setVariable [format ["%1_taskType", _subTaskContact], "meet", true];

// ═════════════════════════════════════════════════════════════════
// LÓGICA DE COMPLETADO (Como DRO - spawn block)
// ═════════════════════════════════════════════════════════════════

[_civilian, _taskID, _subTaskContact, _subTaskProtect, _side, _markerName] spawn {
	params ["_civilian", "_taskID", "_subTaskContact", "_subTaskProtect", "_side", "_markerName"];
	
	// Esperar a que un jugador se acerque al civil
	waitUntil {
		sleep 3;
		if (!alive _civilian) exitWith {true};
		if ([_taskID] call BIS_fnc_taskCompleted) exitWith {true};
		(player distance _civilian < 8)
	};
	
	// Verificar si murió o tarea completada
	if (!alive _civilian || [_taskID] call BIS_fnc_taskCompleted) exitWith {};
	
	// ═════════════════════════════════════════════════════════════
	// CONTACTO REALIZADO
	// ═════════════════════════════════════════════════════════════
	
	hint parseText format ["<t size='1.2' color='#00FF00'>CONTACTO ESTABLECIDO</t><br/><br/>%1 está a salvo por ahora...", name _civilian];
	
	_civilian setCaptive false;
	_civilian setVariable ["contacted", true, true];
	
	// Completar sub-tarea de contacto
	[_subTaskContact, "SUCCEEDED", true] call BIS_fnc_taskSetState;
	missionNamespace setVariable [format ["%1Completed", _subTaskContact], 1, true];
	
	// Crear sub-tarea de protección
	[
		west,
		_subTaskProtect,
		[format ["Protege a %1 de cualquier daño", name _civilian], "Proteger", ""],
		getPos _civilian,
		"ASSIGNED",
		1,
		true,
		"defend",
		true
	] call BIS_fnc_taskCreate;
	
	missionNamespace setVariable [format ["%1_taskType", _subTaskProtect], "defend", true];
	
	sleep 5;
	
	// ═════════════════════════════════════════════════════════════
	// GENERAR EMBOSCADAS (Como DRO)
	// ═════════════════════════════════════════════════════════════
	
	private _allAttackers = [];
	private _numWaves = [1, 3] call BIS_fnc_randomInt;
	
	for "_i" from 1 to _numWaves do {
		if (!alive _civilian || [_taskID] call BIS_fnc_taskCompleted) exitWith {};
		
		hint parseText format ["<t size='1.2' color='#FF4444'>⚠️ EMBOSCADA</t><br/><br/>¡Enemigos atacando a %1!", name _civilian];
		
		// Crear grupo atacante
		private _spawnPos = _civilian getPos [50 + (random 50), random 360];
		private _attackers = [_spawnPos, _side, [3, 5], false, 0] call FN_createObjectiveGuards;
		
		if (!isNull _attackers) then {
			_allAttackers pushBack _attackers;
			
			// Hacer que ataquen al civil
			{
				_x doTarget _civilian;
				_x reveal [_civilian, 4];
			} forEach units _attackers;
		};
		
		sleep 40; // 40 segundos entre oleadas
	};
	
	// ═════════════════════════════════════════════════════════════
	// ESPERAR A QUE SE ELIMINEN LOS ATACANTES
	// ═════════════════════════════════════════════════════════════
	
	if (count _allAttackers > 0) then {
		waitUntil {
			sleep 5;
			if (!alive _civilian) exitWith {true};
			if ([_taskID] call BIS_fnc_taskCompleted) exitWith {true};
			
			// Contar enemigos vivos
			private _aliveCount = 0;
			{
				_aliveCount = _aliveCount + ({alive _x} count units _x);
			} forEach _allAttackers;
			
			(_aliveCount == 0)
		};
	};
	
	// ═════════════════════════════════════════════════════════════
	// COMPLETADO CON ÉXITO
	// ═════════════════════════════════════════════════════════════
	
	if (alive _civilian && !([_taskID] call BIS_fnc_taskCompleted)) then {
		hint parseText format ["<t size='1.5' color='#00FF00'>✓ CIVIL PROTEGIDO</t><br/><br/>%1 está a salvo", name _civilian];
		
		[_subTaskProtect, "SUCCEEDED", true] call BIS_fnc_taskSetState;
		missionNamespace setVariable [format ["%1Completed", _subTaskProtect], 1, true];
		
		[_taskID, "SUCCEEDED", true] call BIS_fnc_taskSetState;
		missionNamespace setVariable [format ["%1Completed", _taskID], 1, true];
		
		deleteMarker _markerName;
		
		// Liberar al civil después de 30 segundos
		sleep 30;
		_civilian enableAI "PATH";
		_civilian setUnitPos "AUTO";
	};
};

// ═════════════════════════════════════════════════════════════════
// EVENT HANDLER: MUERTE DEL CIVIL = FALLO
// ═════════════════════════════════════════════════════════════════

_civilian addEventHandler ["Killed", {
	params ["_unit"];
	private _taskID = _unit getVariable ["taskName", ""];
	
	if (_taskID != "") then {
		[_taskID, "FAILED", true] call BIS_fnc_taskSetState;
		missionNamespace setVariable [format ["%1Completed", _taskID], -1, true];
		
		hint parseText "<t size='1.5' color='#FF0000'>✗ TAREA FALLIDA</t><br/><br/>El civil ha muerto";
	};
}];

// ═════════════════════════════════════════════════════════════════
// NOTIFICACIÓN
// ═════════════════════════════════════════════════════════════════

hint parseText format [
	"<t size='1.5' color='#00FF00'>👤 NUEVA TAREA: PROTEGER CIVIL</t><br/><br/>" +
	"<t size='1'>Civil:</t> <t size='1.1' color='#FFAA00'>%1</t><br/>" +
	"<t size='1'>Amenaza:</t> <t size='1.1' color='#FF4444'>%2</t><br/><br/>" +
	"<t size='0.9' color='#888888'>1. Llega hasta el civil<br/>2. Protégelo de emboscadas</t>",
	name _civilian,
	_enemyFaction
];

diag_log format ["[TASK_SYSTEM] Tarea ProtectCiv creada: %1 en %2", name _civilian, getPos _building];

// Retornar datos
[_taskID, _civilian]

