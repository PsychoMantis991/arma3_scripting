/*
	Función: fn_spawnCivilianVehicle
	Descripción: Genera un vehículo civil con conductor
	
	Parámetros:
		_pos - Posición donde generar [x,y,z] (ARRAY)
		_patrol - Si debe patrullar el área (BOOL) - default: true
		_patrolRadius - Radio de patrulla en metros (NUMBER) - default: 400
	
	Retorna:
		[_vehicle, _group] - Vehículo y grupo (ARRAY)
		
	Ejemplo:
		[getPos player, true, 600] call FN_spawnCivilianVehicle;
*/

params [
	["_pos", [0,0,0], [[]]],
	["_patrol", true, [true]],
	["_patrolRadius", 400, [0]]
];

// Clases de vehículos civiles comunes
private _civCarClasses = [
	"C_Hatchback_01_F",
	"C_Hatchback_01_sport_F",
	"C_Offroad_02_unarmed_F",
	"C_SUV_01_F",
	"C_Van_01_transport_F",
	"C_Van_02_transport_F",
	"C_Truck_02_transport_F"
];

// Seleccionar clase aleatoria
private _class = selectRandom _civCarClasses;

// Buscar posición vacía cerca
private _spawnPos = _pos findEmptyPosition [0, 50, _class];
if (count _spawnPos == 0) then {
	_spawnPos = _pos;
};

// Crear vehículo
private _vehicle = createVehicle [_class, _spawnPos, [], 0, "NONE"];

// Orientar vehículo hacia carretera si hay una cerca
private _roadList = _spawnPos nearRoads 20;
if (count _roadList > 0) then {
	private _road = _roadList select 0;
	private _roadConnections = roadsConnectedTo _road;
	if (count _roadConnections > 0) then {
		private _direction = [_road, _roadConnections select 0] call BIS_fnc_DirTo;
		_vehicle setDir _direction;
	};
};

// Crear tripulación civil
createVehicleCrew _vehicle;
waitUntil {!isNull (driver _vehicle)};

private _group = group (driver _vehicle);

diag_log format ["[FN_spawnCivilianVehicle] Vehículo civil %1 creado en %2", _class, _spawnPos];

// Configurar patrulla si está habilitado
if (_patrol) then {
	[_group, _spawnPos, _patrolRadius] call BIS_fnc_taskPatrol;
	diag_log format ["[FN_spawnCivilianVehicle] Vehículo configurado para patrullar con radio %1m", _patrolRadius];
};

// Habilitar simulación dinámica
_group enableDynamicSimulation true;

// Retornar vehículo y grupo
[_vehicle, _group]

