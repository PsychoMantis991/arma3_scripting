/*
	═══════════════════════════════════════════════════════════════════
	TAREA: RECUPERAR INTELIGENCIA
	Basado en DRO intel.sqf
	═══════════════════════════════════════════════════════════════════
	
	Crea una tarea para recuperar documentos de inteligencia de un edificio.
	
	Parámetros:
		_pos - Posición donde crear la tarea
		_side - Lado enemigo (default: east)
	
	Ejemplo:
		[getPos player, east] remoteExec ["FN_createTaskIntel", 2];
*/

params [
	["_pos", [0,0,0], [[]]],
	["_side", east, [sideUnknown]]
];

// ═════════════════════════════════════════════════════════════════════
// BUSCAR EDIFICIO
// ═════════════════════════════════════════════════════════════════════

private _building = [_pos, 200, true] call FN_findNearBuilding;

if (isNull _building) exitWith {
	hint "No se encontró edificio apropiado para Intel";
	diag_log "[TASK_SYSTEM] Intel: No se encontró edificio";
	["", objNull]
};

private _buildingPos = getPos _building;
private _buildingClass = typeOf _building;

// ═════════════════════════════════════════════════════════════════════
// GENERAR IDs
// ═════════════════════════════════════════════════════════════════════

private _taskID = [] call FN_generateTaskID;
private _markerName = format ["intelMarker%1", floor(random 10000)];
private _enemyFaction = [_side] call FN_getEnemyFactionName;

// ═════════════════════════════════════════════════════════════════════
// CREAR OBJETO DE INTEL
// ═════════════════════════════════════════════════════════════════════

private _intelClasses = [
	"Land_File1_F", "Land_File2_F", "Land_FilePhotos_F",
	"Land_Laptop_unfolded_F", "Land_Laptop_device_F",
	"Land_MobilePhone_smart_F"
];

private _intelClass = selectRandom _intelClasses;
private _intelPos = [_building] call FN_getBuildingPosition;

private _intelObject = createVehicle [_intelClass, _intelPos, [], 0, "CAN_COLLIDE"];
_intelObject setPosATL _intelPos;
_intelObject setDir (random 360);

// Añadir acción de recoger
_intelObject addAction [
	"<t color='#4444FF'>📄 Recoger Inteligencia</t>",
	{
		params ["_target", "_caller", "_actionId", "_arguments"];
		_arguments params ["_taskID", "_markerName"];
		
		// Animación
		_caller playAction "Gear";
		sleep 2;
		
		// Completar tarea
		[_taskID, true, true] call FN_completeTask;
		deleteMarker _markerName;
		deleteVehicle _target;
		
		hint parseText "<t size='1.5' color='#00FF00'>✓ INTEL RECUPERADO</t><br/><br/>Documentos clasificados obtenidos";
		
		[
			"TaskSucceeded",
			["Intel Recuperado", "Inteligencia clasificada obtenida"]
		] remoteExec ["BIS_fnc_showNotification", 0];
	},
	[_taskID, _markerName],
	10,
	true,
	true,
	"",
	"_this distance _target < 3"
];

// ═════════════════════════════════════════════════════════════════════
// CREAR GUARDIAS
// ═════════════════════════════════════════════════════════════════════

private _guards = [];
_guards pushBack ([_buildingPos, _side, [3, 5], true, 80] call FN_createObjectiveGuards);
_guards pushBack ([_buildingPos, _side, [2, 3], true, 120] call FN_createObjectiveGuards);

// ═════════════════════════════════════════════════════════════════════
// CREAR MARCADOR
// ═════════════════════════════════════════════════════════════════════

[_buildingPos, _markerName, "hd_pickup", "ColorRed", "", 1] call FN_createTaskMarker;

// ═════════════════════════════════════════════════════════════════════
// CREAR TAREA
// ═════════════════════════════════════════════════════════════════════

private _buildingName = getText (configFile >> "CfgVehicles" >> _buildingClass >> "displayName");
if (_buildingName == "") then {_buildingName = "edificio"};

private _intelName = getText (configFile >> "CfgVehicles" >> _intelClass >> "displayName");
if (_intelName == "") then {_intelName = "documentos"};

private _taskTitle = "Recuperar Intel";

private _taskDescriptions = [
	format ["Recupera los %1 de inteligencia de un %2 en el área marcada. Esta información contiene datos valiosos sobre las operaciones de %3 en la región.", _intelName, _buildingName, _enemyFaction],
	format ["Se ha localizado información clasificada de %1 en un %2. Recupera el material antes de que sea trasladado.", _enemyFaction, _buildingName],
	format ["Inteligencia indica que hay %1 con información sensible en un %2 cercano. Infiltra y recupera los documentos.", _intelName, _buildingName]
];

private _taskDesc = selectRandom _taskDescriptions;

[_taskID, _taskTitle, _taskDesc, _buildingPos, "documents", "", 1] call FN_createBISTask;

// ═════════════════════════════════════════════════════════════════════
// NOTIFICACIÓN
// ═════════════════════════════════════════════════════════════════════

hint parseText format [
	"<t size='1.5' color='#4444FF'>📄 NUEVA TAREA: INTEL</t><br/><br/>" +
	"<t size='1'>Objetivo:</t> <t size='1.1' color='#FFAA00'>Recuperar %1</t><br/>" +
	"<t size='1'>Ubicación:</t> <t size='1.1'>%2</t><br/>" +
	"<t size='1'>Enemigos:</t> <t size='1.1' color='#FF4444'>%3</t>",
	_intelName,
	_buildingName,
	_enemyFaction
];

diag_log format ["[TASK_SYSTEM] Tarea Intel creada en %1", _buildingPos];

// Retornar datos
[_taskID, _intelObject, _guards]

