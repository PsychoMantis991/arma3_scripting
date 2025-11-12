/*
	Función: fn_spawnGarrison
	Descripción: Genera una guarnición de unidades en un edificio
	Adaptada de: dro_spawnEnemyGarrison
	
	Parámetros:
		_building - Edificio donde colocar la guarnición (OBJECT)
		_side - Lado de las unidades (SIDE) - default: east
		_maxUnits - Máximo de unidades a colocar (NUMBER) - default: 3
	
	Retorna:
		_group - Grupo creado (GROUP)
		
	Ejemplo:
		[nearestBuilding player, east, 4] call FN_spawnGarrison;
*/

params [
	["_building", objNull, [objNull]],
	["_side", east, [sideUnknown]],
	["_maxUnits", 3, [0]]
];

if (isNull _building) exitWith {
	diag_log "[FN_spawnGarrison] ERROR: Edificio inválido";
	grpNull
};

// Obtener clases de infantería de la facción configurada
private _factionClasses = [_side] call SPAWN_getFactionClasses;
private _infClasses = _factionClasses get "infantry";

// Fallback a vanilla si no hay clases disponibles
if (count _infClasses == 0) then {
	_infClasses = switch (_side) do {
		case east: {["O_Soldier_F", "O_Soldier_AR_F", "O_Soldier_GL_F", "O_medic_F"]};
		case west: {["B_Soldier_F", "B_Soldier_AR_F", "B_Soldier_GL_F", "B_medic_F"]};
		case resistance: {["I_Soldier_F", "I_Soldier_AR_F", "I_Soldier_GL_F", "I_medic_F"]};
		default {["O_Soldier_F", "O_Soldier_AR_F"]};
	};
	diag_log format ["[FN_spawnGarrison] ADVERTENCIA: Usando clases vanilla como fallback para %1", _side];
};

// Obtener posiciones del edificio
private _buildingPositions = [_building] call BIS_fnc_buildingPositions;

if (count _buildingPositions == 0) exitWith {
	diag_log format ["[FN_spawnGarrison] ERROR: El edificio %1 no tiene posiciones válidas", typeOf _building];
	grpNull
};

// Calcular número de unidades (mínimo 2, máximo el menor entre posiciones disponibles y maxUnits)
private _availablePositions = count _buildingPositions;
private _totalGarrison = ((_availablePositions min _maxUnits) max 2);

// Si hay muy pocas posiciones, usar al menos 2
if (_totalGarrison < 2) then {
	_totalGarrison = 2 min _availablePositions;
};

if (_totalGarrison < 1) exitWith {
	diag_log format ["[FN_spawnGarrison] No se generarán unidades en %1 (sin posiciones)", getPos _building];
	grpNull
};

// Crear grupo
private _group = createGroup _side;
private _leader = objNull;
private _unitsCreated = 0;

// Barajar posiciones para distribución aleatoria
_buildingPositions = _buildingPositions call BIS_fnc_arrayShuffle;

// Colocar unidades en posiciones del edificio
for "_i" from 0 to (_totalGarrison - 1) do {
	if (_i < count _buildingPositions) then {
		private _unitClass = selectRandom _infClasses;
		private _pos = _buildingPositions select _i;
		
		// Crear unidad
		private _unit = _group createUnit [_unitClass, _pos, [], 0, "CAN_COLLIDE"];
		
		// Esperar a que la unidad se cree
		waitUntil {!isNull _unit};
		
		// Posicionar correctamente
		_unit setPosATL _pos;
		_unit setDir (random 360);
		_unit setUnitPos "UP"; // De pie
		_unit disableAI "MOVE"; // No moverse de la posición
		
		// Configurar como defensivo
		_group setBehaviour "SAFE";
		_group setCombatMode "YELLOW"; // Solo atacan si son atacados
		
		_unitsCreated = _unitsCreated + 1;
		
		if (_i == 0) then {
			_leader = _unit;
		};
		
		sleep 0.05; // Pequeña pausa para evitar problemas de spawn
	};
};

diag_log format ["[FN_spawnGarrison] Guarnición de %1/%2 unidades creada en edificio %3 (posiciones disponibles: %4)", _unitsCreated, _totalGarrison, typeOf _building, _availablePositions];

// Habilitar simulación dinámica
_group enableDynamicSimulation true;

// Retornar grupo
_group

