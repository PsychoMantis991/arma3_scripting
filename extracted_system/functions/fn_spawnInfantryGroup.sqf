/*
	Función: fn_spawnInfantryGroup
	Descripción: Genera un grupo de infantería en una posición específica
	
	Parámetros:
		_pos - Posición donde generar [x,y,z] (ARRAY)
		_side - Lado del grupo (SIDE) - default: east
		_numUnits - Número de unidades [min, max] (ARRAY) - default: [4,6]
		_patrol - Si debe patrullar el área (BOOL) - default: true
		_patrolRadius - Radio de patrulla en metros (NUMBER) - default: 200
	
	Retorna:
		_group - Grupo creado (GROUP)
		
	Ejemplo:
		[getPos player, east, [4,6], true, 300] call FN_spawnInfantryGroup;
*/

params [
	["_pos", [0,0,0], [[]]],
	["_side", east, [sideUnknown]],
	["_numUnits", [4,6], [[]]],
	["_patrol", true, [false]],
	["_patrolRadius", 200, [0]]
];

// ═════════════════════════════════════════════════════════════════
// SISTEMA DINÁMICO DE FACCIONES (Estilo DRO)
// ═════════════════════════════════════════════════════════════════

// Obtener clases de la facción seleccionada
private _factionClasses = [_side] call SPAWN_getFactionClasses;
private _infClasses = _factionClasses get "infantryWeighted";
private _infWeights = _factionClasses get "infantryWeights";

// Si no hay clases con pesos, usar clases normales
if (count _infClasses == 0) then {
	_infClasses = _factionClasses get "infantry";
	_infWeights = [];
};

// Fallback a vanilla si la facción no tiene unidades
if (count _infClasses == 0) then {
	diag_log format ["[FN_spawnInfantryGroup] ADVERTENCIA: No hay unidades para %1, usando vanilla", _side];
	_infClasses = switch (_side) do {
		case east: {["O_Soldier_F", "O_Soldier_AR_F", "O_Soldier_GL_F", "O_medic_F"]};
		case west: {["B_Soldier_F", "B_Soldier_AR_F", "B_Soldier_GL_F", "B_medic_F"]};
		case resistance: {["I_Soldier_F", "I_Soldier_AR_F", "I_Soldier_GL_F", "I_medic_F"]};
		default {["O_Soldier_F"]};
	};
	_infWeights = [];
};

// Crear grupo
private _group = createGroup _side;
private _numToSpawn = [(_numUnits select 0), (_numUnits select 1)] call BIS_fnc_randomInt;

// Generar unidades usando sistema de pesos (como DRO)
for "_i" from 1 to _numToSpawn do {
	private _unitClass = "";
	
	// Usar pesos si están disponibles
	if (count _infWeights > 0) then {
		_unitClass = [_infClasses, _infWeights] call BIS_fnc_selectRandomWeighted;
	} else {
		_unitClass = selectRandom _infClasses;
	};
	
	private _unit = _group createUnit [_unitClass, _pos, [], 5, "FORM"];
};

diag_log format ["[FN_spawnInfantryGroup] Generado grupo %1 con %2 unidades en %3", _group, count units _group, _pos];

// Configurar patrulla
if (_patrol) then {
	[_group, _pos, _patrolRadius] call BIS_fnc_taskPatrol;
	diag_log format ["[FN_spawnInfantryGroup] Grupo %1 configurado para patrullar con radio %2m", _group, _patrolRadius];
};

// Habilitar simulación dinámica para mejor rendimiento
_group enableDynamicSimulation true;

// Retornar grupo
_group

