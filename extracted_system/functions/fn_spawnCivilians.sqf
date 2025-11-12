/*
	Función: fn_spawnCivilians
	Descripción: Genera civiles en un área directamente (sin módulos)
	Adaptada de: generateCivilians.sqf de DRO
	
	Parámetros:
		_pos - Posición central del área [x,y,z] (ARRAY)
		_areaSize - Tamaño del área en metros (NUMBER) - default: 200
		_numCivs - Número de civiles a generar (NUMBER) - default: 5
	
	Retorna:
		_civs - Array de civiles creados (ARRAY)
		
	Ejemplo:
		[getPos player, 300, 10] call FN_spawnCivilians;
*/

params [
	["_pos", [0,0,0], [[]]],
	["_areaSize", 200, [0]],
	["_numCivs", 5, [0]]
];

// Array para almacenar civiles creados
private _civilians = [];

// Obtener clases de civiles de la facción seleccionada
private _factionClasses = [civilian] call SPAWN_getFactionClasses;
private _civClasses = _factionClasses get "infantry";

// Fallback a vanilla si no hay clases disponibles
if (count _civClasses == 0) then {
	diag_log "[fn_spawnCivilians] No se encontraron civiles en facción seleccionada, usando vanilla";
	_civClasses = [
		"C_man_1",
		"C_man_1_1_F",
		"C_man_1_2_F",
		"C_man_1_3_F",
		"C_man_polo_1_F",
		"C_man_polo_2_F",
		"C_man_polo_3_F",
		"C_man_polo_4_F",
		"C_man_polo_5_F",
		"C_man_polo_6_F",
		"C_man_p_fugitive_F",
		"C_man_p_beggar_F",
		"C_man_p_shorts_1_F",
		"C_man_shorts_1_F",
		"C_man_shorts_2_F",
		"C_man_shorts_3_F",
		"C_man_shorts_4_F",
		"C_Man_casual_1_F",
		"C_Man_casual_2_F",
		"C_Man_casual_3_F",
		"C_Man_casual_4_F",
		"C_Man_casual_5_F",
		"C_Man_casual_6_F"
	];
};

// Crear civiles en posiciones aleatorias
for "_i" from 1 to _numCivs do {
	// Encontrar posición aleatoria en el área
	private _spawnPos = _pos getPos [random _areaSize, random 360];
	_spawnPos = [_spawnPos select 0, _spawnPos select 1, 0];
	
	// Buscar posición segura cerca
	private _safePos = _spawnPos findEmptyPosition [0, 50, "C_man_1"];
	
	if (count _safePos > 0) then {
		_spawnPos = _safePos;
	};
	
	// Crear grupo civil
	private _civGroup = createGroup civilian;
	
	// Crear civil
	private _civClass = selectRandom _civClasses;
	private _civ = _civGroup createUnit [_civClass, _spawnPos, [], 0, "FORM"];
	
	// Configurar comportamiento
	_civ setBehaviour "SAFE";
	_civ setSpeedMode "LIMITED";
	_civ allowFleeing 1;
	
	// Hacer que camine aleatoriamente
	if (random 100 > 30) then {
		// 70% probabilidad de caminar
		private _wp1 = _civGroup addWaypoint [_spawnPos getPos [50 + random 100, random 360], 0];
		_wp1 setWaypointType "MOVE";
		_wp1 setWaypointSpeed "LIMITED";
		_wp1 setWaypointBehaviour "SAFE";
		
		private _wp2 = _civGroup addWaypoint [_spawnPos getPos [50 + random 100, random 360], 0];
		_wp2 setWaypointType "MOVE";
		_wp2 setWaypointSpeed "LIMITED";
		
		private _wp3 = _civGroup addWaypoint [_spawnPos, 0];
		_wp3 setWaypointType "CYCLE";
	} else {
		// 30% probabilidad de quedarse quieto
		doStop _civ;
		_civ disableAI "PATH";
	};
	
	// Añadir a array
	_civilians pushBack _civ;
	
	// Log
	diag_log format ["[FN_spawnCivilians] Civil creado: %1 en %2", _civClass, _spawnPos];
};

// Mensaje de confirmación
hint parseText format [
	"<t size='1.2' color='#4444FF'>👥 CIVILES GENERADOS</t><br/><br/>" +
	"<t size='1'>Total: %1 civiles</t><br/>" +
	"<t size='0.9'>Área: %2m</t>",
	count _civilians,
	_areaSize
];

diag_log format ["[FN_spawnCivilians] %1 civiles creados en área de %2m centrada en %3", count _civilians, _areaSize, _pos];

// Retornar array de civiles
_civilians
