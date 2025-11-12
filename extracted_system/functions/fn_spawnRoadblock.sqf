/*
	═══════════════════════════════════════════════════════════════════
	FUNCIÓN: CREAR ROADBLOCK (PUESTO DE CONTROL)
	Crea un puesto de control en la carretera con barreras, torres y guardias
	═══════════════════════════════════════════════════════════════════
	
	Parámetros:
		_pos - Posición central del roadblock [x,y,z]
		_side - Lado del roadblock (east/west/resistance)
		_size - Tamaño: "SMALL", "LARGE"
	
	Retorna:
		[_objects, _units, _vehicles, _groups] - Arrays de objetos, unidades, vehículos y grupos
		
	Ejemplo:
		[getPos player, east, "LARGE"] remoteExec ["FN_spawnRoadblock", 2];
*/

if (!isServer) exitWith {};

params [
	["_pos", [0,0,0], [[]]],
	["_side", east, [sideUnknown]],
	["_size", "SMALL", [""]]
];

diag_log format ["[ROADBLOCK] === CREANDO ROADBLOCK ==="];
diag_log format ["[ROADBLOCK] Pos: %1, Side: %2, Size: %3", _pos, _side, _size];

private _allObjects = [];
private _allUnits = [];
private _allVehicles = [];
private _allGroups = [];

// ═════════════════════════════════════════════════════════════════════
// CONFIGURACIÓN POR TAMAÑO
// ═════════════════════════════════════════════════════════════════════

private _width = 30;
private _depth = 25;
private _numGuardsPerGate = 2;
private _numTowers = 2;
private _numPatrols = 1;
private _numVehicles = 0;
private _hasBunkers = false;
private _hasBarrierGates = true;
private _hasSandbags = true;
private _hasLights = true;

switch (toUpper _size) do {
	case "SMALL": {
		_width = 20;
		_depth = 20;
		_numGuardsPerGate = 2;
		_numTowers = 2;
		_numPatrols = 0;
		_numVehicles = 0;
		_hasBunkers = false;
		_hasBarrierGates = true;
		_hasSandbags = true;
		_hasLights = false;
	};
	case "LARGE": {
		_width = 30;
		_depth = 35;
		_numGuardsPerGate = 3;
		_numTowers = 2;
		_numPatrols = 2;
		_numVehicles = 1;
		_hasBunkers = true;
		_hasBarrierGates = true;
		_hasSandbags = true;
		_hasLights = true;
	};
};

// ═════════════════════════════════════════════════════════════════════
// PASO 1: BUSCAR CARRETERA MÁS CERCANA Y ORIENTAR
// ═════════════════════════════════════════════════════════════════════

hint parseText format [
	"<t size='1.2' color='#FFAA00'>🚧 CONSTRUYENDO ROADBLOCK %1</t><br/><br/>" +
	"<t size='0.9'>Analizando carretera...</t>",
	_size
];

private _nearRoads = _pos nearRoads 100;
private _roadDir = 0;

if (count _nearRoads > 0) then {
	private _road = _nearRoads select 0;
	_pos = getPosATL _road;
	
	// Calcular dirección de la carretera
	private _roadConnections = roadsConnectedTo _road;
	if (count _roadConnections > 0) then {
		private _connectedRoad = _roadConnections select 0;
		_roadDir = _road getDir _connectedRoad;
	};
	
	diag_log format ["[ROADBLOCK] Carretera encontrada, dirección: %1°", _roadDir];
} else {
	diag_log "[ROADBLOCK] No se encontró carretera cercana, usando posición manual";
};

// ═════════════════════════════════════════════════════════════════════
// PASO 2: CREAR BARRERAS H EN LOS LADOS
// ═════════════════════════════════════════════════════════════════════

sleep 0.2;

hint parseText format [
	"<t size='1.2' color='#FFAA00'>🚧 CONSTRUYENDO ROADBLOCK %1</t><br/><br/>" +
	"<t size='0.9'>Colocando barreras H...</t>",
	_size
];

private _barrierClass = "Land_HBarrier_01_line_5_green_F"; // Barreras H verdes de Tanoa
private _barrierBigClass = "Land_HBarrier_01_big_4_green_F"; // Barreras H grandes verdes de Tanoa

// Calcular posiciones perpendiculares a la carretera
private _leftAngle = _roadDir - 90;
private _rightAngle = _roadDir + 90;
private _halfWidth = _width / 2;

// LADO IZQUIERDO (varias barreras formando muro)
private _numBarriersPerSide = ceil(_depth / 5);
for "_i" from 0 to (_numBarriersPerSide - 1) do {
	private _offsetForward = (_i * 5) - (_depth / 2);
	private _barrierPos = _pos vectorAdd [
		(_halfWidth * cos(_leftAngle)) + (_offsetForward * cos(_roadDir)),
		(_halfWidth * sin(_leftAngle)) + (_offsetForward * sin(_roadDir)),
		0
	];
	
	private _barrier = createVehicle [_barrierClass, _barrierPos, [], 0, "NONE"];
	_barrier setDir _roadDir;
	_allObjects pushBack _barrier;
};

// LADO DERECHO (varias barreras formando muro)
for "_i" from 0 to (_numBarriersPerSide - 1) do {
	private _offsetForward = (_i * 5) - (_depth / 2);
	private _barrierPos = _pos vectorAdd [
		(_halfWidth * cos(_rightAngle)) + (_offsetForward * cos(_roadDir)),
		(_halfWidth * sin(_rightAngle)) + (_offsetForward * sin(_roadDir)),
		0
	];
	
	private _barrier = createVehicle [_barrierClass, _barrierPos, [], 0, "NONE"];
	_barrier setDir _roadDir;
	_allObjects pushBack _barrier;
};

// NO crear barreras cruzando la carretera - la carretera debe pasar libremente
// Las barreras laterales ya están creadas, formando un pasillo

diag_log format ["[ROADBLOCK] Barreras laterales creadas: %1 por lado (carretera pasa por el centro)", _numBarriersPerSide];

// ═════════════════════════════════════════════════════════════════════
// PASO 3: CREAR ENTRADAS/SALIDAS CON BARRERAS
// ═════════════════════════════════════════════════════════════════════

sleep 0.2;

hint parseText format [
	"<t size='1.2' color='#FFAA00'>🚧 CONSTRUYENDO ROADBLOCK %1</t><br/><br/>" +
	"<t size='0.9'>Instalando puertas...</t>",
	_size
];

// ENTRADA (lado frontal)
private _frontPos = _pos vectorAdd [
	(_depth / 2) * cos(_roadDir),
	(_depth / 2) * sin(_roadDir),
	0
];

if (_hasBarrierGates) then {
	// Barrera levadiza cruzando la carretera en la entrada
	private _gateEntrance = createVehicle ["Land_BarGate_F", _frontPos, [], 0, "NONE"];
	_gateEntrance setDir (_roadDir + 90); // Perpendicular a la carretera
	_allObjects pushBack _gateEntrance;
	
	diag_log "[ROADBLOCK] Barrera levadiza instalada en entrada";
};

// SALIDA (lado trasero) - igual que la entrada
private _backPos = _pos vectorAdd [
	(_depth / 2) * cos(_roadDir + 180),
	(_depth / 2) * sin(_roadDir + 180),
	0
];

if (_hasBarrierGates) then {
	// Barrera levadiza cruzando la carretera en la salida
	private _gateExit = createVehicle ["Land_BarGate_F", _backPos, [], 0, "NONE"];
	_gateExit setDir (_roadDir + 90); // Perpendicular a la carretera
	_allObjects pushBack _gateExit;
	
	diag_log "[ROADBLOCK] Barrera levadiza instalada en salida";
};

diag_log "[ROADBLOCK] Puertas instaladas";

// ═════════════════════════════════════════════════════════════════════
// PASO 4: TORRES DE VIGILANCIA
// ═════════════════════════════════════════════════════════════════════

sleep 0.2;

hint parseText format [
	"<t size='1.2' color='#FFAA00'>🚧 CONSTRUYENDO ROADBLOCK %1</t><br/><br/>" +
	"<t size='0.9'>Instalando torres...</t>",
	_size
];

private _watchtowerClass = "Land_Cargo_Patrol_V4_F"; // Torre verde de Tanoa
private _towerPositions = [];

if (_numTowers == 1) then {
	// 1 torre al lado de la carretera
	private _towerPos = _pos vectorAdd [
		(_halfWidth + 5) * cos(_leftAngle),
		(_halfWidth + 5) * sin(_leftAngle),
		0
	];
	
	private _tower = createVehicle [_watchtowerClass, _towerPos, [], 0, "NONE"];
	_tower setDir (_roadDir + 90);
	_allObjects pushBack _tower;
	_towerPositions pushBack _tower;
} else {
	// 2 torres, una a cada lado
	private _towerPos1 = _pos vectorAdd [
		(_halfWidth + 5) * cos(_leftAngle),
		(_halfWidth + 5) * sin(_leftAngle),
		0
	];
	
	private _tower1 = createVehicle [_watchtowerClass, _towerPos1, [], 0, "NONE"];
	_tower1 setDir (_roadDir + 90);
	_allObjects pushBack _tower1;
	_towerPositions pushBack _tower1;
	
	private _towerPos2 = _pos vectorAdd [
		(_halfWidth + 5) * cos(_rightAngle),
		(_halfWidth + 5) * sin(_rightAngle),
		0
	];
	
	private _tower2 = createVehicle [_watchtowerClass, _towerPos2, [], 0, "NONE"];
	_tower2 setDir (_roadDir - 90);
	_allObjects pushBack _tower2;
	_towerPositions pushBack _tower2;
};

diag_log format ["[ROADBLOCK] Torres creadas: %1", _numTowers];

// ═════════════════════════════════════════════════════════════════════
// PASO 5: BUNKERS (SOLO SI ES GRANDE)
// ═════════════════════════════════════════════════════════════════════

private _bunkerPositions = [];

if (_hasBunkers) then {
	sleep 0.2;
	
	hint parseText format [
		"<t size='1.2' color='#FFAA00'>🚧 CONSTRUYENDO ROADBLOCK %1</t><br/><br/>" +
		"<t size='0.9'>Construyendo bunkers...</t>",
		_size
	];
	
	// Nidos de ametralladora según facción (incluyen soldado y torreta)
	private _mgNestClass = switch (_side) do {
		case west: {"B_HMG_01_high_F"}; // HMG BLUFOR
		case east: {"O_HMG_01_high_F"}; // HMG OPFOR
		case resistance: {"I_HMG_01_high_F"}; // HMG Independent
		default {"O_HMG_01_high_F"};
	};
	
	// Nido MG en entrada (lado izquierdo)
	private _bunker1Pos = _frontPos vectorAdd [
		8 * cos(_leftAngle),
		8 * sin(_leftAngle),
		0
	];
	
	private _bunker1 = createVehicle [_mgNestClass, _bunker1Pos, [], 0, "NONE"];
	_bunker1 setDir _roadDir; // Apuntando hacia la carretera
	_allObjects pushBack _bunker1;
	_allVehicles pushBack _bunker1;
	_bunkerPositions pushBack _bunker1;
	
	// Añadir artillero a las unidades
	if (!isNull (gunner _bunker1)) then {
		private _gunnerGroup = group (gunner _bunker1);
		_allGroups pushBack _gunnerGroup;
		_allUnits pushBack (gunner _bunker1);
	};
	
	// Nido MG en salida (lado derecho)
	private _bunker2Pos = _backPos vectorAdd [
		8 * cos(_rightAngle),
		8 * sin(_rightAngle),
		0
	];
	
	private _bunker2 = createVehicle [_mgNestClass, _bunker2Pos, [], 0, "NONE"];
	_bunker2 setDir (_roadDir + 180); // Apuntando hacia la otra dirección
	_allObjects pushBack _bunker2;
	_allVehicles pushBack _bunker2;
	_bunkerPositions pushBack _bunker2;
	
	// Añadir artillero a las unidades
	if (!isNull (gunner _bunker2)) then {
		private _gunnerGroup = group (gunner _bunker2);
		_allGroups pushBack _gunnerGroup;
		_allUnits pushBack (gunner _bunker2);
	};
	
		diag_log "[ROADBLOCK] Bunkers creados: 2";
};

// ═════════════════════════════════════════════════════════════════════
// PASO 5.5: SACOS DE ARENA Y POSICIONES DEFENSIVAS
// ═════════════════════════════════════════════════════════════════════

if (_hasSandbags) then {
	sleep 0.2;
	
	hint parseText format [
		"<t size='1.2' color='#FFAA00'>🚧 CONSTRUYENDO ROADBLOCK %1</t><br/><br/>" +
		"<t size='0.9'>Fortificando posiciones...</t>",
		_size
	];
	
	// Posiciones de sacos de arena en la entrada (a ambos lados del paso)
	private _sandbagClass = "Land_BagFence_Long_F";
	
	// Lado izquierdo de la entrada
	for "_i" from 0 to 2 do {
		private _sandbagPos = _frontPos vectorAdd [
			(6 + (_i * 2)) * cos(_leftAngle),
			(6 + (_i * 2)) * sin(_leftAngle),
			0
		];
		private _sandbag = createVehicle [_sandbagClass, _sandbagPos, [], 0, "NONE"];
		_sandbag setDir _roadDir;
		_allObjects pushBack _sandbag;
	};
	
	// Lado derecho de la entrada
	for "_i" from 0 to 2 do {
		private _sandbagPos = _frontPos vectorAdd [
			(6 + (_i * 2)) * cos(_rightAngle),
			(6 + (_i * 2)) * sin(_rightAngle),
			0
		];
		private _sandbag = createVehicle [_sandbagClass, _sandbagPos, [], 0, "NONE"];
		_sandbag setDir _roadDir;
		_allObjects pushBack _sandbag;
	};
	
	// Posiciones en la salida
	for "_i" from 0 to 2 do {
		private _sandbagPos = _backPos vectorAdd [
			(6 + (_i * 2)) * cos(_leftAngle),
			(6 + (_i * 2)) * sin(_leftAngle),
			0
		];
		private _sandbag = createVehicle [_sandbagClass, _sandbagPos, [], 0, "NONE"];
		_sandbag setDir (_roadDir + 180);
		_allObjects pushBack _sandbag;
	};
	
	for "_i" from 0 to 2 do {
		private _sandbagPos = _backPos vectorAdd [
			(6 + (_i * 2)) * cos(_rightAngle),
			(6 + (_i * 2)) * sin(_rightAngle),
			0
		];
		private _sandbag = createVehicle [_sandbagClass, _sandbagPos, [], 0, "NONE"];
		_sandbag setDir (_roadDir + 180);
		_allObjects pushBack _sandbag;
	};
	
	// Esquinas con sacos tipo bunker pequeño
	private _cornerClass = "Land_BagFence_Corner_F";
	
	// Esquinas entrada
	private _corner1 = createVehicle [_cornerClass, _frontPos vectorAdd [
		12 * cos(_leftAngle),
		12 * sin(_leftAngle),
		0
	], [], 0, "NONE"];
	_corner1 setDir (_roadDir + 45);
	_allObjects pushBack _corner1;
	
	private _corner2 = createVehicle [_cornerClass, _frontPos vectorAdd [
		12 * cos(_rightAngle),
		12 * sin(_rightAngle),
		0
	], [], 0, "NONE"];
	_corner2 setDir (_roadDir - 45);
	_allObjects pushBack _corner2;
	
	diag_log "[ROADBLOCK] Posiciones defensivas con sacos creadas";
};

// ═════════════════════════════════════════════════════════════════════
// PASO 6: PROPS Y DETALLES
// ═════════════════════════════════════════════════════════════════════

sleep 0.2;

hint parseText format [
	"<t size='1.2' color='#FFAA00'>🚧 CONSTRUYENDO ROADBLOCK %1</t><br/><br/>" +
	"<t size='0.9'>Añadiendo detalles...</t>",
	_size
];

// Señales de tráfico y conos
private _roadCone = createVehicle ["RoadCone_F", _frontPos vectorAdd [2, 0, 0], [], 0, "NONE"];
_allObjects pushBack _roadCone;

private _roadCone2 = createVehicle ["RoadCone_F", _frontPos vectorAdd [-2, 0, 0], [], 0, "NONE"];
_allObjects pushBack _roadCone2;

private _roadCone3 = createVehicle ["RoadCone_F", _backPos vectorAdd [2, 0, 0], [], 0, "NONE"];
_allObjects pushBack _roadCone3;

private _roadCone4 = createVehicle ["RoadCone_F", _backPos vectorAdd [-2, 0, 0], [], 0, "NONE"];
_allObjects pushBack _roadCone4;

// Luces portátiles
private _light1 = createVehicle ["Land_PortableLight_single_F", _pos vectorAdd [
	(_halfWidth - 3) * cos(_leftAngle),
	(_halfWidth - 3) * sin(_leftAngle),
	0
], [], 0, "NONE"];
_allObjects pushBack _light1;

private _light2 = createVehicle ["Land_PortableLight_single_F", _pos vectorAdd [
	(_halfWidth - 3) * cos(_rightAngle),
	(_halfWidth - 3) * sin(_rightAngle),
	0
], [], 0, "NONE"];
_allObjects pushBack _light2;

// Mesa y sillas para punto de control
private _table = createVehicle ["Land_CampingTable_F", _pos vectorAdd [-2, 0, 0], [], 0, "NONE"];
_table setDir _roadDir;
_allObjects pushBack _table;

private _chair = createVehicle ["Land_CampingChair_V2_F", _pos vectorAdd [-2.5, 0, 0], [], 0, "NONE"];
_chair setDir (_roadDir + 180);
_allObjects pushBack _chair;

diag_log "[ROADBLOCK] Props añadidos";

// ═════════════════════════════════════════════════════════════════════
// PASO 7: UNIDADES
// ═════════════════════════════════════════════════════════════════════

sleep 0.2;

hint parseText format [
	"<t size='1.2' color='#FFAA00'>🚧 CONSTRUYENDO ROADBLOCK %1</t><br/><br/>" +
	"<t size='0.9'>Desplegando guardias...</t>",
	_size
];

// Guardias en la entrada (frente)
private _frontGuardGroup = createGroup _side;
_allGroups pushBack _frontGuardGroup;

for "_i" from 1 to _numGuardsPerGate do {
	private _guardPos = _frontPos vectorAdd [
		((_i - 1) * 4 - 2) * cos(_leftAngle),
		((_i - 1) * 4 - 2) * sin(_leftAngle),
		0
	];
	
	private _factionClasses = [_side] call SPAWN_getFactionClasses;
	private _infantryClasses = _factionClasses get "infantry";
	
	if (count _infantryClasses > 0) then {
		private _unitClass = selectRandom _infantryClasses;
		private _unit = _frontGuardGroup createUnit [_unitClass, _guardPos, [], 0, "NONE"];
		_unit setDir _roadDir;
		_unit setUnitPos "MIDDLE"; // Agachado
		_allUnits pushBack _unit;
	};
};

// Guardias en la salida (atrás)
private _backGuardGroup = createGroup _side;
_allGroups pushBack _backGuardGroup;

for "_i" from 1 to _numGuardsPerGate do {
	private _guardPos = _backPos vectorAdd [
		((_i - 1) * 4 - 2) * cos(_leftAngle),
		((_i - 1) * 4 - 2) * sin(_leftAngle),
		0
	];
	
	private _factionClasses = [_side] call SPAWN_getFactionClasses;
	private _infantryClasses = _factionClasses get "infantry";
	
	if (count _infantryClasses > 0) then {
		private _unitClass = selectRandom _infantryClasses;
		private _unit = _backGuardGroup createUnit [_unitClass, _guardPos, [], 0, "NONE"];
		_unit setDir (_roadDir + 180);
		_unit setUnitPos "MIDDLE";
		_allUnits pushBack _unit;
	};
};

// Guardias en torres
{
	private _tower = _x;
	private _towerGroup = [getPos _tower, _side, [2, 2], false] call FN_spawnInfantryGroup;
	_allGroups pushBack _towerGroup;
	_allUnits append (units _towerGroup);
} forEach _towerPositions;

// Guardias en bunkers
{
	private _bunker = _x;
	private _bunkerGroup = [getPos _bunker, _side, [2, 2], false] call FN_spawnInfantryGroup;
	_allGroups pushBack _bunkerGroup;
	_allUnits append (units _bunkerGroup);
} forEach _bunkerPositions;

// Patrullas (solo en roadblock grande)
if (_numPatrols > 0) then {
	for "_i" from 1 to _numPatrols do {
		private _patrolPos = _pos vectorAdd [random 10 - 5, random 10 - 5, 0];
		private _patrolGroup = [_patrolPos, _side, [3, 4], true, _width] call FN_spawnInfantryGroup;
		_allGroups pushBack _patrolGroup;
		_allUnits append (units _patrolGroup);
	};
};

// Vehículos (solo en roadblock grande)
if (_numVehicles > 0) then {
	for "_i" from 1 to _numVehicles do {
		private _vehPos = _pos vectorAdd [
			(_halfWidth - 8) * cos(_leftAngle),
			(_halfWidth - 8) * sin(_leftAngle),
			0
		];
		
		private _result = [_vehPos, _side, "CAR", false] call FN_spawnVehiclePatrol;
		
		if (count _result > 0) then {
			_result params ["_vehicle", "_group"];
			_vehicle setDir (_roadDir + 90);
			_allVehicles pushBack _vehicle;
			_allGroups pushBack _group;
			_allUnits append (units _group);
		};
	};
};

diag_log format ["[ROADBLOCK] Guardias desplegados: %1 unidades", count _allUnits];

// ═════════════════════════════════════════════════════════════════════
// PASO 8: MARCADOR
// ═════════════════════════════════════════════════════════════════════

private _markerName = format ["roadblock_marker_%1", floor(random 10000)];
private _marker = createMarker [_markerName, _pos];
_marker setMarkerShape "ICON";
_marker setMarkerType "mil_warning";

private _markerColor = switch (_side) do {
	case west: {"ColorBLUFOR"};
	case east: {"ColorOPFOR"};
	case resistance: {"ColorIndependent"};
	default {"ColorWhite"};
};

_marker setMarkerColor _markerColor;
_marker setMarkerText format ["Roadblock %1", _size];

// ═════════════════════════════════════════════════════════════════════
// RESUMEN FINAL
// ═════════════════════════════════════════════════════════════════════

private _summary = format [
	"<t size='1.5' color='#00FF00'>✓ ROADBLOCK %1 COMPLETADO</t><br/><br/>" +
	"<t size='1' color='#FFFF00'>CONFIGURACIÓN:</t><br/>" +
	"<t size='0.9'>• Tamaño: %1</t><br/>" +
	"<t size='0.9'>• Torres: %2</t><br/>" +
	"<t size='0.9'>• Bunkers: %3</t><br/><br/>" +
	"<t size='1' color='#FFFF00'>ELEMENTOS:</t><br/>" +
	"<t size='0.9'>• Objetos: %4</t><br/>" +
	"<t size='0.9'>• Guardias: %5</t><br/>" +
	"<t size='0.9'>• Vehículos: %6</t><br/>" +
	"<t size='0.9'>• Ancho: %7m x %8m</t>",
	_size,
	_numTowers,
	if (_hasBunkers) then {2} else {0},
	count _allObjects,
	count _allUnits,
	count _allVehicles,
	_width,
	_depth
];

hint parseText _summary;

diag_log format ["[ROADBLOCK] === ROADBLOCK COMPLETADO ==="];
diag_log format ["[ROADBLOCK] Objetos: %1, Unidades: %2, Vehículos: %3", count _allObjects, count _allUnits, count _allVehicles];

// Retornar
[_allObjects, _allUnits, _allVehicles, _allGroups]
