/*
	═══════════════════════════════════════════════════════════════════
	FUNCIÓN: CREAR FOB (FORWARD OPERATING BASE)
	Crea una base militar completa con múltiples configuraciones
	═══════════════════════════════════════════════════════════════════
	
	Parámetros:
		_pos - Posición central del FOB [x,y,z]
		_side - Lado del FOB (east/west/resistance)
		_size - Tamaño: "SMALL", "MEDIUM", "LARGE"
		_occupied - Si está ocupado (true) o abandonado (false)
		_condition - Estado: "PRISTINE" (perfecto), "DAMAGED" (dañado), "RUINED" (ruinas)
	
	Retorna:
		[_objects, _units, _vehicles] - Arrays de objetos, unidades y vehículos
		
	Ejemplo:
		[getPos player, east, "MEDIUM", true, "PRISTINE"] remoteExec ["FN_spawnFOB", 2];
*/

if (!isServer) exitWith {};

params [
	["_pos", [0,0,0], [[]]],
	["_side", east, [sideUnknown]],
	["_size", "MEDIUM", [""]],
	["_occupied", true, [true]],
	["_condition", "PRISTINE", [""]]
];

diag_log format ["[FOB] === CREANDO FOB ==="];
diag_log format ["[FOB] Pos: %1, Side: %2, Size: %3, Occupied: %4, Condition: %5", _pos, _side, _size, _occupied, _condition];

private _allObjects = [];
private _allUnits = [];
private _allVehicles = [];
private _allGroups = [];

// ═════════════════════════════════════════════════════════════════════
// CONFIGURACIÓN POR TAMAÑO
// ═════════════════════════════════════════════════════════════════════

private _radius = 50;
private _numBunkers = 2;
private _numWatchtowers = 2;
private _numTents = 3;
private _numBarriers = 15;
private _numInfantryPatrols = 2;
private _numVehicles = 1;
private _numGarrison = 4;

switch (toUpper _size) do {
	case "SMALL": {
		_radius = 40;
		_numBunkers = 1;
		_numWatchtowers = 1;
		_numTents = 2;
		_numBarriers = 10;
		_numInfantryPatrols = 1;
		_numVehicles = 1;
		_numGarrison = 3;
	};
	case "MEDIUM": {
		_radius = 60;
		_numBunkers = 2;
		_numWatchtowers = 2;
		_numTents = 4;
		_numBarriers = 20;
		_numInfantryPatrols = 2;
		_numVehicles = 2;
		_numGarrison = 5;
	};
	case "LARGE": {
		_radius = 80;
		_numBunkers = 3;
		_numWatchtowers = 3;
		_numTents = 6;
		_numBarriers = 30;
		_numInfantryPatrols = 4;
		_numVehicles = 3;
		_numGarrison = 8;
	};
};

// ═════════════════════════════════════════════════════════════════════
// PASO 1: CREAR PERÍMETRO Y DEFENSAS
// ═════════════════════════════════════════════════════════════════════

hint parseText format [
	"<t size='1.2' color='#FFAA00'>🏗️ CONSTRUYENDO FOB %1</t><br/><br/>" +
	"<t size='0.9'>Creando perímetro defensivo...</t>",
	_size
];

// Determinar objetos según lado y tamaño
private _barrierClass = "Land_HBarrier_01_line_5_green_F"; // Barreras H verdes de Tanoa

private _watchtowerClass = switch (_side) do {
	case west: {"Land_Cargo_Patrol_V4_F"}; // Torre verde
	case east: {"Land_Cargo_Patrol_V4_F"}; // Torre verde
	case resistance: {"Land_Cargo_Tower_V4_F"}; // Torre alta verde
	default {"Land_Cargo_Patrol_V4_F"};
};

// Configurar densidad de barreras según tamaño
private _barrierSpacing = switch (toUpper _size) do {
	case "SMALL": {10}; // Más espaciado = menos protección
	case "MEDIUM": {6};
	case "LARGE": {5};  // Más denso = más protección
	default {6};
};

// CREAR PERÍMETRO CUADRADO
// Cada lado del cuadrado
private _sideLength = _radius * 2;
private _totalBarriers = 0;

// Función auxiliar para crear un lado del perímetro con entrada opcional
private _createWallSide = {
	params ["_startPos", "_direction", "_length", "_spacing", ["_hasGate", false], ["_gateStart", 0], ["_gateEnd", 0]];
	
	private _barriersInSide = floor (_length / _spacing);
	
	for "_i" from 0 to (_barriersInSide - 1) do {
		// Saltar posiciones si hay entrada
		if (_hasGate && _i >= _gateStart && _i <= _gateEnd) then {
			continue;
		};
		
		private _offset = _i * _spacing;
		private _barrierPos = _startPos vectorAdd [
			_offset * cos(_direction),
			_offset * sin(_direction),
			0
		];
		
		private _barrier = createVehicle [_barrierClass, _barrierPos, [], 0, "NONE"];
		_barrier setDir (_direction - 90); // Orientar perpendicular al lado
		
		// Aplicar daño según condición
		if (_condition == "DAMAGED") then {
			_barrier setDamage [0.3 + random 0.3, false];
		};
		if (_condition == "RUINED") then {
			_barrier setDamage [0.8 + random 0.2, false];
		};
		
		_allObjects pushBack _barrier;
		_totalBarriers = _totalBarriers + 1;
	};
	
	_totalBarriers
};

// Calcular posiciones de entrada (en el lado ESTE - frente)
private _numBarriersPerSide = floor (_sideLength / _barrierSpacing);
private _gateStart = floor(_numBarriersPerSide / 2) - 1;
private _gateEnd = floor(_numBarriersPerSide / 2) + 1;

// Lado NORTE (de izquierda a derecha, hacia el ESTE)
private _northStart = _pos vectorAdd [-_radius, _radius, 0];
[_northStart, 90, _sideLength, _barrierSpacing] call _createWallSide;

// Lado ESTE (de arriba a abajo, hacia el SUR) - CON ENTRADA
private _eastStart = _pos vectorAdd [_radius, _radius, 0];
[_eastStart, 180, _sideLength, _barrierSpacing, true, _gateStart, _gateEnd] call _createWallSide;

// Lado SUR (de derecha a izquierda, hacia el OESTE)
private _southStart = _pos vectorAdd [_radius, -_radius, 0];
[_southStart, 270, _sideLength, _barrierSpacing] call _createWallSide;

// Lado OESTE (de abajo a arriba, hacia el NORTE)
private _westStart = _pos vectorAdd [-_radius, -_radius, 0];
[_westStart, 0, _sideLength, _barrierSpacing] call _createWallSide;

diag_log format ["[FOB] Perímetro cuadrado creado: %1 barreras H (Spacing: %2m)", _totalBarriers, _barrierSpacing];

// ═════════════════════════════════════════════════════════════════════
// PASO 2: TORRES DE VIGILANCIA
// ═════════════════════════════════════════════════════════════════════

sleep 0.3;

hint parseText format [
	"<t size='1.2' color='#FFAA00'>🏗️ CONSTRUYENDO FOB %1</t><br/><br/>" +
	"<t size='0.9'>Instalando torres de vigilancia...</t>",
	_size
];

private _watchtowerPositions = [];

for "_i" from 1 to _numWatchtowers do {
	private _angle = (_i / _numWatchtowers) * 360;
	private _towerPos = _pos getPos [_radius - 10, _angle];
	
	private _tower = createVehicle [_watchtowerClass, _towerPos, [], 0, "NONE"];
	_tower setDir _angle;
	
	// Aplicar daño
	if (_condition == "DAMAGED") then {
		_tower setDamage [0.2 + random 0.3, false];
	};
	if (_condition == "RUINED") then {
		_tower setDamage [0.7 + random 0.3, false];
	};
	
	_allObjects pushBack _tower;
	_watchtowerPositions pushBack _tower;
};

diag_log format ["[FOB] Torres creadas: %1", _numWatchtowers];

// ═════════════════════════════════════════════════════════════════════
// PASO 3: BUNKERS Y FORTIFICACIONES
// ═════════════════════════════════════════════════════════════════════

sleep 0.3;

hint parseText format [
	"<t size='1.2' color='#FFAA00'>🏗️ CONSTRUYENDO FOB %1</t><br/><br/>" +
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

private _bunkerPositions = [];

for "_i" from 1 to _numBunkers do {
	private _angle = ((_i / _numBunkers) * 360) + 30; // Offset de torres
	private _bunkerPos = _pos getPos [_radius - 15, _angle];
	
	// Crear nido MG (incluye torreta y artillero)
	private _bunker = createVehicle [_mgNestClass, _bunkerPos, [], 0, "NONE"];
	_bunker setDir (_angle + 180); // Apuntar hacia afuera para defensa
	
	// Aplicar daño si es necesario
	if (_condition == "DAMAGED") then {
		_bunker setDamage [0.3 + random 0.2, false];
	};
	if (_condition == "RUINED") then {
		_bunker setDamage [0.8 + random 0.2, false];
	};
	
	_allObjects pushBack _bunker;
	_allVehicles pushBack _bunker; // Añadir como vehículo para tracking
	_bunkerPositions pushBack _bunker;
	
	// El artillero se crea automáticamente
	if (!isNull (gunner _bunker)) then {
		private _gunnerGroup = group (gunner _bunker);
		_allGroups pushBack _gunnerGroup;
		_allUnits pushBack (gunner _bunker);
	};
};

diag_log format ["[FOB] Bunkers creados: %1", _numBunkers];

// ═════════════════════════════════════════════════════════════════════
// PASO 4: ÁREA INTERNA - TIENDAS Y ESTRUCTURAS
// ═════════════════════════════════════════════════════════════════════

sleep 0.3;

hint parseText format [
	"<t size='1.2' color='#FFAA00'>🏗️ CONSTRUYENDO FOB %1</t><br/><br/>" +
	"<t size='0.9'>Montando área de campamento...</t>",
	_size
];

private _tentClass = "Land_MedicalTent_01_MTP_closed_F";
private _tentPositions = [];

// Distribuir tiendas en área interna
private _innerRadius = _radius * 0.4;

for "_i" from 1 to _numTents do {
	private _angle = (_i / _numTents) * 360;
	private _tentPos = _pos getPos [_innerRadius, _angle];
	
	private _tent = createVehicle [_tentClass, _tentPos, [], 0, "NONE"];
	_tent setDir (random 360);
	
	// Aplicar daño
	if (_condition == "DAMAGED") then {
		_tent setDamage [0.2 + random 0.3, false];
	};
	if (_condition == "RUINED") then {
		_tent setDamage [0.6 + random 0.4, false];
	};
	
	_allObjects pushBack _tent;
	_tentPositions pushBack _tent;
};

// Añadir estructuras adicionales
private _additionalStructures = [
	["Land_Cargo_HQ_V3_F", 0, 0, 0],
	["Land_Cargo_House_V3_F", 15, 90, 5],
	["CamoNet_BLUFOR_big_F", -15, 180, -5],
	["Land_HelipadSquare_F", 25, 270, 0]
];

{
	_x params ["_class", "_offsetX", "_offsetY", "_offsetDir"];
	private _objPos = _pos vectorAdd [_offsetX, _offsetY, 0];
	
	private _obj = createVehicle [_class, _objPos, [], 0, "NONE"];
	_obj setDir _offsetDir;
	
	// Aplicar daño
	if (_condition == "DAMAGED") then {
		_obj setDamage [0.2 + random 0.3, false];
	};
	if (_condition == "RUINED") then {
		_obj setDamage [0.7 + random 0.3, false];
	};
	
	_allObjects pushBack _obj;
} forEach _additionalStructures;

diag_log format ["[FOB] Estructuras internas creadas"];

// ═════════════════════════════════════════════════════════════════════
// PASO 5: PROPS Y DETALLES
// ═════════════════════════════════════════════════════════════════════

sleep 0.3;

hint parseText format [
	"<t size='1.2' color='#FFAA00'>🏗️ CONSTRUYENDO FOB %1</t><br/><br/>" +
	"<t size='0.9'>Añadiendo detalles...</t>",
	_size
];

// Props decorativos
private _props = [
	"Land_WoodenCrate_01_stack_x3_F",
	"Land_Pallet_F",
	"Land_CanisterFuel_F",
	"Land_PortableLight_double_F",
	"Land_CampingTable_F",
	"Land_CampingChair_V2_F"
];

for "_i" from 1 to 10 do {
	private _propClass = selectRandom _props;
	private _propPos = _pos getPos [random _innerRadius, random 360];
	
	private _prop = createVehicle [_propClass, _propPos, [], 0, "NONE"];
	_prop setDir (random 360);
	
	// Aplicar daño
	if (_condition == "DAMAGED") then {
		_prop setDamage [0.1 + random 0.3, false];
	};
	if (_condition == "RUINED") then {
		_prop setDamage [0.5 + random 0.5, false];
	};
	
	_allObjects pushBack _prop;
};

diag_log format ["[FOB] Props añadidos"];

// ═════════════════════════════════════════════════════════════════════
// PASO 6: UNIDADES (SOLO SI ESTÁ OCUPADO)
// ═════════════════════════════════════════════════════════════════════

if (_occupied) then {
	sleep 0.3;
	
	hint parseText format [
		"<t size='1.2' color='#FFAA00'>🏗️ CONSTRUYENDO FOB %1</t><br/><br/>" +
		"<t size='0.9'>Desplegando guarnición...</t>",
		_size
	];
	
	// Guarniciones en torres
	{
		private _tower = _x;
		private _group = [getPos _tower, _side, [2, 3], false] call FN_spawnInfantryGroup;
		_allGroups pushBack _group;
		_allUnits append (units _group);
	} forEach _watchtowerPositions;
	
	// Guarniciones en bunkers
	{
		private _bunker = _x;
		private _group = [getPos _bunker, _side, [2, 2], false] call FN_spawnInfantryGroup;
		_allGroups pushBack _group;
		_allUnits append (units _group);
	} forEach _bunkerPositions;
	
	// Patrullas de infantería
	for "_i" from 1 to _numInfantryPatrols do {
		private _patrolPos = _pos getPos [random (_radius * 0.5), random 360];
		private _group = [_patrolPos, _side, [4, 6], true, _radius] call FN_spawnInfantryGroup;
		_allGroups pushBack _group;
		_allUnits append (units _group);
	};
	
	// Vehículos
	for "_i" from 1 to _numVehicles do {
		private _vehPos = _pos getPos [_radius * 0.6, (_i / _numVehicles) * 360];
		private _vehType = if (_size == "LARGE") then {"APC"} else {"CAR"};
		
		// Vehículos ESTÁTICOS en FOBs (patrol = false)
		private _result = [_vehPos, _side, _vehType, false, 0] call FN_spawnVehiclePatrol;
		
		if (count _result > 0) then {
			_result params ["_vehicle", "_group"];
			
			// Configurar como estático defensivo
			_vehicle setDir (random 360);
			_vehicle engineOn false;
			_vehicle setFuel 0.3;
			
			_group setBehaviour "SAFE";
			_group setCombatMode "YELLOW";
			{
				_x disableAI "MOVE";
				_x disableAI "AUTOCOMBAT";
			} forEach (units _group);
			
			_allVehicles pushBack _vehicle;
			_allGroups pushBack _group;
			_allUnits append (units _group);
		};
	};
	
	diag_log format ["[FOB] Guarnición desplegada: %1 unidades", count _allUnits];
} else {
	diag_log "[FOB] FOB abandonado - sin unidades";
};

// ═════════════════════════════════════════════════════════════════════
// PASO 7: MARCADOR
// ═════════════════════════════════════════════════════════════════════

private _markerName = format ["fob_marker_%1", floor(random 10000)];
private _marker = createMarker [_markerName, _pos];
_marker setMarkerShape "ELLIPSE";
_marker setMarkerSize [_radius, _radius];
_marker setMarkerBrush "Border";

private _markerColor = switch (_side) do {
	case west: {"ColorBLUFOR"};
	case east: {"ColorOPFOR"};
	case resistance: {"ColorIndependent"};
	default {"ColorWhite"};
};

_marker setMarkerColor _markerColor;

private _statusText = if (_occupied) then {"OCUPADO"} else {"ABANDONADO"};
private _conditionText = switch (_condition) do {
	case "PRISTINE": {"Perfecto"};
	case "DAMAGED": {"Dañado"};
	case "RUINED": {"En Ruinas"};
	default {"Desconocido"};
};

_marker setMarkerText format ["FOB %1 - %2 - %3", _size, _statusText, _conditionText];

// ═════════════════════════════════════════════════════════════════════
// RESUMEN FINAL
// ═════════════════════════════════════════════════════════════════════

private _summary = format [
	"<t size='1.5' color='#00FF00'>✓ FOB %1 COMPLETADO</t><br/><br/>" +
	"<t size='1' color='#FFFF00'>CONFIGURACIÓN:</t><br/>" +
	"<t size='0.9'>• Tamaño: %1</t><br/>" +
	"<t size='0.9'>• Estado: %2</t><br/>" +
	"<t size='0.9'>• Condición: %3</t><br/><br/>" +
	"<t size='1' color='#FFFF00'>ELEMENTOS:</t><br/>" +
	"<t size='0.9'>• Objetos: %4</t><br/>" +
	"<t size='0.9'>• Unidades: %5</t><br/>" +
	"<t size='0.9'>• Vehículos: %6</t><br/>" +
	"<t size='0.9'>• Radio: %7m</t>",
	_size,
	_statusText,
	_conditionText,
	count _allObjects,
	count _allUnits,
	count _allVehicles,
	_radius
];

hint parseText _summary;

diag_log format ["[FOB] === FOB COMPLETADO ==="];
diag_log format ["[FOB] Objetos: %1, Unidades: %2, Vehículos: %3", count _allObjects, count _allUnits, count _allVehicles];

// Retornar
[_allObjects, _allUnits, _allVehicles, _allGroups]

