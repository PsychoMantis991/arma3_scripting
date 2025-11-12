/*
	Función: fn_spawnCompoundArea
	Descripción: Genera una zona completa con múltiples elementos enemigos
	
	Parámetros:
		_pos - Posición central de la zona [x,y,z] (ARRAY)
		_side - Lado de las unidades (SIDE) - default: east
		_size - Tamaño de la zona: "SMALL", "MEDIUM", "LARGE" (STRING)
	
	Retorna:
		_allUnits - Array con todos los grupos/unidades generados (ARRAY)
		
	Ejemplo:
		[getPos player, east, "MEDIUM"] call FN_spawnCompoundArea;
*/

params [
	["_pos", [0,0,0], [[]]],
	["_side", east, [sideUnknown]],
	["_size", "MEDIUM", [""]]
];

diag_log format ["[FN_spawnCompoundArea] Generando zona %1 en %2", _size, _pos];

// Configuración según tamaño
private _config = switch (toUpper _size) do {
	case "SMALL": {
		[
			[2, 4],      // Patrullas de infantería [min, max]
			2,           // Número de patrullas
			1,           // Vehículos estáticos
			2,           // Guarniciones (igual que patrullas)
			50,          // Radio base
			false        // Sin campamento
		]
	};
	case "MEDIUM": {
		[
			[4, 6],      // Patrullas de infantería
			3,           // Número de patrullas
			2,           // Vehículos estáticos
			3,           // Guarniciones (igual que patrullas)
			100,         // Radio base
			true         // Con campamento pequeño
		]
	};
	case "LARGE": {
		[
			[6, 8],      // Patrullas de infantería
			4,           // Número de patrullas
			3,           // Vehículos estáticos
			4,           // Guarniciones (igual que patrullas)
			150,         // Radio base
			true         // Con campamento mediano
		]
	};
	default {
		[
			[4, 6],
			3,
			2,
			3,
			100,
			true
		]
	};
};

_config params ["_infSize", "_numPatrols", "_numVehicles", "_numGarrisons", "_baseRadius", "_withCamp"];

private _allGroups = [];
private _allVehicles = [];

// ═════════════════════════════════════════════════════════════════
// 1. PATRULLAS DE INFANTERÍA
// ═════════════════════════════════════════════════════════════════

hint parseText format [
	"<t size='1.2' color='#FFAA00'>🏗️ GENERANDO ZONA %1</t><br/><br/>" +
	"<t size='0.9'>Creando patrullas de infantería...</t>",
	_size
];

for "_i" from 1 to _numPatrols do {
	// Posición aleatoria alrededor del centro
	private _patrolPos = _pos getPos [random _baseRadius, random 360];
	
	// Crear patrulla
	private _group = [_patrolPos, _side, _infSize, true, _baseRadius] call FN_spawnInfantryGroup;
	
	if (!isNull _group) then {
		_allGroups pushBack _group;
	};
	
	sleep 0.1; // Pequeña pausa para evitar lag
};

diag_log format ["[FN_spawnCompoundArea] %1 patrullas de infantería creadas", _numPatrols];

// ═════════════════════════════════════════════════════════════════
// 2. VEHÍCULOS PATRULLANDO
// ═════════════════════════════════════════════════════════════════

hint parseText format [
	"<t size='1.2' color='#FFAA00'>🏗️ GENERANDO ZONA %1</t><br/><br/>" +
	"<t size='0.9'>Creando vehículos...</t>",
	_size
];

for "_i" from 1 to _numVehicles do {
	// Buscar una posición segura en carretera
	private _vehPos = _pos;
	private _roads = _pos nearRoads (_baseRadius * 0.8);
	
	if (count _roads > 0) then {
		// Usar carretera cercana
		_vehPos = getPos (selectRandom _roads);
	} else {
		// Si no hay carretera, buscar terreno plano
		private _attempts = 0;
		while {_attempts < 10} do {
			private _testPos = _pos getPos [random (_baseRadius * 0.7), random 360];
			if (!surfaceIsWater _testPos && {(getTerrainHeightASL _testPos) isEqualTo (getTerrainHeightASL _testPos)}) then {
				_vehPos = _testPos;
				_attempts = 100;
			};
			_attempts = _attempts + 1;
		};
	};
	
	// Alternar entre CAR y APC
	private _vehType = if (_i mod 2 == 0) then {"CAR"} else {"APC"};
	
	// Crear vehículo ESTÁTICO (patrol = false)
	private _result = [_vehPos, _side, _vehType, false, 0] call FN_spawnVehiclePatrol;
	
	if (count _result > 0) then {
		_result params ["_vehicle", "_group"];
		
		if (!isNull _vehicle) then {
			// Configurar vehículo como estático defensivo
			_vehicle setDir (random 360);
			_vehicle engineOn false;
			_vehicle setFuel 0.3; // Poco combustible para limitar movimiento
			
			// Configurar tripulación en modo defensivo
			_group setBehaviour "SAFE";
			_group setCombatMode "YELLOW"; // Solo atacan si son atacados
			{
				_x disableAI "MOVE"; // No moverse del vehículo
				_x disableAI "AUTOCOMBAT"; // No atacar automáticamente
			} forEach (units _group);
			
			_allVehicles pushBack _vehicle;
			_allGroups pushBack _group;
			
			diag_log format ["[FN_spawnCompoundArea] Vehículo estático creado: %1", typeOf _vehicle];
		};
	};
	
	sleep 0.1;
};

diag_log format ["[FN_spawnCompoundArea] %1 vehículos creados", _numVehicles];

// ═════════════════════════════════════════════════════════════════
// 3. GUARNICIONES EN EDIFICIOS
// ═════════════════════════════════════════════════════════════════

hint parseText format [
	"<t size='1.2' color='#FFAA00'>🏗️ GENERANDO ZONA %1</t><br/><br/>" +
	"<t size='0.9'>Guarneciendo edificios...</t>",
	_size
];

// Buscar edificios en el área
private _buildings = nearestObjects [_pos, ["House"], _baseRadius];
_buildings = _buildings select {count ([_x] call BIS_fnc_buildingPositions) > 0};

private _garrisonsCreated = 0;

for "_i" from 1 to (_numGarrisons min (count _buildings)) do {
	if (_i <= count _buildings) then {
		private _building = _buildings select (_i - 1);
		
		// Tamaño de guarnición según tamaño de zona
		private _garrisonSize = switch (toUpper _size) do {
			case "SMALL": {4};
			case "MEDIUM": {6};
			case "LARGE": {8};
			default {4};
		};
		
		private _group = [_building, _side, _garrisonSize] call FN_spawnGarrison;
		
		if (!isNull _group) then {
			_allGroups pushBack _group;
			_garrisonsCreated = _garrisonsCreated + 1;
		};
		
		sleep 0.1;
	};
};

diag_log format ["[FN_spawnCompoundArea] %1 guarniciones creadas", _garrisonsCreated];

// ═════════════════════════════════════════════════════════════════
// 4. CAMPAMENTO (OPCIONAL)
// ═════════════════════════════════════════════════════════════════

if (_withCamp) then {
	hint parseText format [
		"<t size='1.2' color='#FFAA00'>🏗️ GENERANDO ZONA %1</t><br/><br/>" +
		"<t size='0.9'>Construyendo campamento...</t>",
		_size
	];
	
	private _campPos = _pos getPos [random 30, random 360];
	private _campSize = if (_size == "LARGE") then {"MEDIUM"} else {"SMALL"};
	
	[_campPos, _side, _campSize] call FN_spawnCamp;
	
	sleep 0.1;
};

// ═════════════════════════════════════════════════════════════════
// 5. ELEMENTOS ADICIONALES
// ═════════════════════════════════════════════════════════════════

// Roadblock en carretera cercana (solo MEDIUM y LARGE)
// Roadblock automático desactivado - usar menú de mapa para crear roadblocks manualmente
/*
if (_size == "MEDIUM" || _size == "LARGE") then {
	hint parseText format [
		"<t size='1.2' color='#FFAA00'>🏗️ GENERANDO ZONA %1</t><br/><br/>" +
		"<t size='0.9'>Colocando roadblock...</t>",
		_size
	];
	
	private _roads = _pos nearRoads (_baseRadius * 1.5);
	if (count _roads > 0) then {
		private _roadPos = getPos (selectRandom _roads);
		[_roadPos, _side] call FN_spawnRoadblock;
	};
};
*/

// ═════════════════════════════════════════════════════════════════
// RESUMEN FINAL
// ═════════════════════════════════════════════════════════════════

private _totalInfantry = 0;
{
	_totalInfantry = _totalInfantry + (count units _x);
} forEach _allGroups;

hint parseText format [
	"<t size='1.5' color='#00FF00'>✓ ZONA %1 COMPLETADA</t><br/><br/>" +
	"<t size='1' color='#FFFF00'>RESUMEN:</t><br/>" +
	"<t size='0.9'>• Infantería: %2 unidades (%3 grupos)</t><br/>" +
	"<t size='0.9'>• Vehículos: %4</t><br/>" +
	"<t size='0.9'>• Guarniciones: %5</t><br/>" +
	"<t size='0.9'>• Campamento: %6</t><br/>" +
	"<t size='0.9'>• Radio: %7m</t>",
	_size,
	_totalInfantry,
	count _allGroups,
	count _allVehicles,
	_garrisonsCreated,
	if (_withCamp) then {"Sí"} else {"No"},
	_baseRadius
];

diag_log format [
	"[FN_spawnCompoundArea] Zona %1 completada - Infantería: %2 | Vehículos: %3 | Guarniciones: %4",
	_size,
	_totalInfantry,
	count _allVehicles,
	_garrisonsCreated
];

// Retornar todos los elementos
[_allGroups, _allVehicles]

