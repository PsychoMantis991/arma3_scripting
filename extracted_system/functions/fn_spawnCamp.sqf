/*
	Función: fn_spawnCamp
	Descripción: Genera un pequeño campamento militar
	Adaptada de: generateCampsite.sqf
	
	Parámetros:
		_pos - Posición central [x,y,z] (ARRAY)
		_side - Lado del campamento (SIDE) - default: east
		_size - Tamaño: "SMALL", "MEDIUM", "LARGE" (STRING) - default: "SMALL"
	
	Retorna:
		[_objects, _group] - Objetos colocados y grupo de defensa (ARRAY)
		
	Ejemplo:
		[getPos player, east, "MEDIUM"] call FN_spawnCamp;
*/

params [
	["_pos", [0,0,0], [[]]],
	["_side", east, [sideUnknown]],
	["_size", "SMALL", [""]]
];

// Calcular número de objetos según tamaño
private _numTents = switch (_size) do {
	case "SMALL": {2};
	case "MEDIUM": {4};
	case "LARGE": {6};
	default {2};
};

private _numDefenders = switch (_size) do {
	case "SMALL": {[2, 3]};
	case "MEDIUM": {[4, 6]};
	case "LARGE": {[6, 8]};
	default {[2, 3]};
};

// Clases de objetos para el campamento
private _tentClasses = [
	"Land_TentDome_F",
	"CamoNet_BLUFOR_open_F",
	"Land_Camping_Light_F"
];

private _objects = [];

// Generar tiendas en patrón circular
for "_i" from 0 to (_numTents - 1) do {
	private _angle = (360 / _numTents) * _i;
	private _tentPos = [_pos, 8, _angle] call BIS_fnc_relPos;
	private _tent = createVehicle [selectRandom _tentClasses, _tentPos, [], 0, "CAN_COLLIDE"];
	_tent setDir (_angle + 180);
	_objects pushBack _tent;
};

// Hoguera central
private _fireplace = createVehicle ["Campfire_burning_F", _pos, [], 0, "CAN_COLLIDE"];
_objects pushBack _fireplace;

// Objetos adicionales
if (_size == "MEDIUM" || _size == "LARGE") then {
	// Caja de suministros
	private _boxPos = [_pos, 10, 45] call BIS_fnc_relPos;
	private _box = createVehicle ["Box_NATO_Ammo_F", _boxPos, [], 0, "CAN_COLLIDE"];
	_objects pushBack _box;
	
	// Mesa
	private _tablePos = [_pos, 6, 180] call BIS_fnc_relPos;
	private _table = createVehicle ["Land_CampingTable_F", _tablePos, [], 0, "CAN_COLLIDE"];
	_objects pushBack _table;
};

// Vehículo para campamentos grandes
if (_size == "LARGE") then {
	private _vehPos = [_pos, 15, 90] call BIS_fnc_relPos;
	private _result = [_vehPos, _side, "CAR", false] call FN_spawnVehiclePatrol;
	private _vehicle = _result select 0;
	_objects pushBack _vehicle;
};

// Generar grupo de defensa
private _group = [_pos, _side, _numDefenders, false] call FN_spawnInfantryGroup;

// Configurar grupo para defender el campamento
[_group, _pos] call BIS_fnc_taskDefend;

diag_log format ["[FN_spawnCamp] Campamento %1 creado en %2 con %3 objetos y %4 defensores", _size, _pos, count _objects, count units _group];

// Retornar objetos y grupo
[_objects, _group]

