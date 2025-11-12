/*
	═══════════════════════════════════════════════════════════════════
	FUNCIONES DE UTILIDADES PARA TAREAS
	Basado en Dynamic Recon Ops
	═══════════════════════════════════════════════════════════════════
	
	Este archivo contiene funciones comunes usadas por todas las tareas.
*/

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Crear tarea BIS con formato estándar
// ═════════════════════════════════════════════════════════════════════

FN_createBISTask = {
	params [
		"_taskID",
		"_taskTitle", 
		"_taskDesc",
		"_taskPos",
		"_taskType",
		["_parent", ""],
		["_priority", 1]
	];
	
	// Crear tarea para todos los jugadores
	[
		west,
		_taskID,
		[_taskDesc, _taskTitle, ""],
		_taskPos,
		"CREATED",
		_priority,
		true,
		_taskType,
		true
	] call BIS_fnc_taskCreate;
	
	// Registrar en variables globales
	if (isNil "TASK_AllObjectives") then {
		TASK_AllObjectives = [];
	};
	TASK_AllObjectives pushBack _taskID;
	publicVariable "TASK_AllObjectives";
	
	// Marcar como no completada
	missionNamespace setVariable [format ["%1Completed", _taskID], 0, true];
	missionNamespace setVariable [format ["%1_taskType", _taskID], _taskType, true];
	
	diag_log format ["[TASK_SYSTEM] Tarea creada: %1 - %2", _taskTitle, _taskID];
	
	_taskID
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Crear marcador de tarea
// ═════════════════════════════════════════════════════════════════════

FN_createTaskMarker = {
	params [
		"_pos",
		"_markerName",
		["_markerType", "mil_objective"],
		["_markerColor", "ColorRed"],
		["_markerText", ""],
		["_markerAlpha", 1]
	];
	
	private _marker = createMarker [_markerName, _pos];
	_marker setMarkerShape "ICON";
	_marker setMarkerType _markerType;
	_marker setMarkerColor _markerColor;
	_marker setMarkerAlpha _markerAlpha;
	
	if (_markerText != "") then {
		_marker setMarkerText _markerText;
	};
	
	diag_log format ["[TASK_SYSTEM] Marcador creado: %1 en %2", _markerName, _pos];
	
	_marker
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Completar tarea automáticamente
// ═════════════════════════════════════════════════════════════════════

FN_completeTask = {
	params [
		"_taskID",
		["_success", true],
		["_showNotification", true]
	];
	
	private _state = if (_success) then {"SUCCEEDED"} else {"FAILED"};
	
	[_taskID, _state, _showNotification] call BIS_fnc_taskSetState;
	missionNamespace setVariable [format ["%1Completed", _taskID], 1, true];
	
	diag_log format ["[TASK_SYSTEM] Tarea completada: %1 - Estado: %2", _taskID, _state];
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Buscar edificio apropiado cerca de posición
// ═════════════════════════════════════════════════════════════════════

FN_findNearBuilding = {
	params [
		"_pos",
		["_radius", 200],
		["_requireEnterable", true]
	];
	
	private _buildings = _pos nearObjects ["House", _radius];
	private _validBuildings = [];
	
	{
		if (_requireEnterable) then {
			if ([_x] call BIS_fnc_isBuildingEnterable) then {
				private _positions = [_x] call BIS_fnc_buildingPositions;
				if (count _positions > 0) then {
					_validBuildings pushBack _x;
				};
			};
		} else {
			_validBuildings pushBack _x;
		};
	} forEach _buildings;
	
	if (count _validBuildings == 0) exitWith {
		diag_log format ["[TASK_SYSTEM] No se encontraron edificios válidos cerca de %1", _pos];
		objNull
	};
	
	private _building = selectRandom _validBuildings;
	diag_log format ["[TASK_SYSTEM] Edificio encontrado: %1 en %2", typeOf _building, getPos _building];
	
	_building
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Obtener posición aleatoria dentro de edificio
// ═════════════════════════════════════════════════════════════════════

FN_getBuildingPosition = {
	params ["_building"];
	
	private _positions = [_building] call BIS_fnc_buildingPositions;
	
	if (count _positions == 0) exitWith {
		getPos _building
	};
	
	selectRandom _positions
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Generar nombre de facción enemiga
// ═════════════════════════════════════════════════════════════════════

FN_getEnemyFactionName = {
	params [["_side", east]];
	
	private _factionID = switch (_side) do {
		case east: {SPAWN_SelectedFaction_OPFOR};
		case west: {SPAWN_SelectedFaction_BLUFOR};
		case resistance: {SPAWN_SelectedFaction_INDEP};
		default {"Unknown"};
	};
	
	// Buscar nombre legible
	private _factionName = "Enemy";
	{
		_x params ["_id", "_name", "_flag", "_sideNum"];
		if (_id == _factionID) exitWith {
			_factionName = _name;
		};
	} forEach SPAWN_availableFactionsData;
	
	_factionName
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Crear trigger de condición personalizada
// ═════════════════════════════════════════════════════════════════════

FN_createTaskTrigger = {
	params [
		"_pos",
		"_condition",
		"_onComplete",
		["_area", [10, 10]]
	];
	
	private _trigger = createTrigger ["EmptyDetector", _pos, true];
	_trigger setTriggerArea [_area select 0, _area select 1, 0, false];
	_trigger setTriggerActivation ["ANY", "PRESENT", false];
	_trigger setTriggerStatements [_condition, _onComplete, ""];
	
	_trigger
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Crear grupo de guarda para objetivo
// ═════════════════════════════════════════════════════════════════════

FN_createObjectiveGuards = {
	params [
		"_pos",
		"_side",
		["_numGuards", [3, 6]],
		["_patrolRadius", 100]
	];
	
	// Crear grupo de infantería
	private _group = [_pos, _side, _numGuards, true, _patrolRadius] call FN_spawnInfantryGroup;
	
	diag_log format ["[TASK_SYSTEM] Guardias creados: %1 unidades de %2", count units _group, _side];
	
	_group
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Generar ID único
// ═════════════════════════════════════════════════════════════════════

FN_generateTaskID = {
	params [["_prefix", "task"]];
	
	format ["%1%2", _prefix, floor(random 100000)]
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Añadir acción de sabotaje a objetos
// ═════════════════════════════════════════════════════════════════════

FN_addSabotageAction = {
	params ["_objects", "_taskID"];
	
	{
		_x addAction [
			"<t color='#FF4444'>💣 Sabotear</t>",
			{
				params ["_target", "_caller", "_actionId", "_arguments"];
				_arguments params ["_taskID"];
				
				// Animación de colocación de explosivo
				_caller playAction "PutDown";
				
				// Esperar 3 segundos
				sleep 3;
				
				// Destruir objeto
				_target setDamage 1;
				
				hint "Explosivo colocado - alejarse";
			},
			[_taskID],
			10,
			true,
			true,
			"",
			"_this distance _target < 5"
		];
	} forEach _objects;
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Añadir acción de recoger intel a objeto
// ═════════════════════════════════════════════════════════════════════

FN_addIntelAction = {
	params ["_object", "_taskID"];
	
	_object addAction [
		"<t color='#4444FF'>📄 Recoger Intel</t>",
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
			_arguments params ["_taskID"];
			
			// Animación de búsqueda
			_caller playAction "Gear";
			
			// Esperar 2 segundos
			sleep 2;
			
			// Remover acción
			_target removeAction _actionId;
			
			// Notificar
			hint "Intel recuperado";
			
			// Marcar intel como recogido
			missionNamespace setVariable [format ["%1_intelCollected", _taskID], true, true];
		},
		[_taskID],
		10,
		true,
		true,
		"",
		"_this distance _target < 3"
	];
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Crear composición de objetos
// ═════════════════════════════════════════════════════════════════════

FN_createComposition = {
	params [
		"_pos",
		"_objects",
		["_dir", 0]
	];
	
	private _spawnedObjects = [];
	
	{
		_x params ["_class", "_relPos", "_relDir"];
		
		private _worldPos = _pos vectorAdd _relPos;
		private _worldDir = _dir + _relDir;
		
		private _object = createVehicle [_class, _worldPos, [], 0, "CAN_COLLIDE"];
		_object setDir _worldDir;
		_object setPosATL _worldPos;
		
		_spawnedObjects pushBack _object;
	} forEach _objects;
	
	diag_log format ["[TASK_SYSTEM] Composición creada: %1 objetos", count _spawnedObjects];
	
	_spawnedObjects
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Limpiar tarea (remover marcadores, triggers, etc)
// ═════════════════════════════════════════════════════════════════════

FN_cleanupTask = {
	params ["_taskID"];
	
	// Remover de lista global
	TASK_AllObjectives = TASK_AllObjectives - [_taskID];
	publicVariable "TASK_AllObjectives";
	
	diag_log format ["[TASK_SYSTEM] Tarea limpiada: %1", _taskID];
};

// ═════════════════════════════════════════════════════════════════════
// INICIALIZACIÓN
// ═════════════════════════════════════════════════════════════════════

if (isNil "TASK_AllObjectives") then {
	TASK_AllObjectives = [];
	publicVariable "TASK_AllObjectives";
};

if (isNil "TASK_ActiveTriggers") then {
	TASK_ActiveTriggers = [];
};

diag_log "[TASK_SYSTEM] Utilidades de tareas cargadas";

