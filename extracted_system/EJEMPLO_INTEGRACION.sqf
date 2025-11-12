/*
	Archivo: EJEMPLO_INTEGRACION.sqf
	Descripción: Ejemplos de cómo integrar el sistema en tu misión
*/

// ========================================
// EJEMPLO 1: Inicialización básica
// ========================================
// Simplemente añade esto a tu init.sqf:
[] execVM "extracted_system\init.sqf";


// ========================================
// EJEMPLO 2: Crear una base enemiga al inicio
// ========================================
// Coloca esto en tu init.sqf o initServer.sqf

if (isServer) then {
	// Esperar a que el sistema esté listo
	waitUntil {!isNil "FN_spawnInfantryGroup"};
	
	// Posición de la base (puedes usar getMarkerPos)
	private _basePos = [5000, 5000, 0]; // Ajusta según tu mapa
	
	// Campamento grande
	[_basePos, east, "LARGE"] call FN_spawnCamp;
	
	// 3 patrullas alrededor
	for "_i" from 1 to 3 do {
		private _patrolPos = [_basePos, 150, random 360] call BIS_fnc_relPos;
		[_patrolPos, east, [4,6], true, 300] call FN_spawnInfantryGroup;
	};
	
	// 2 vehículos
	[_basePos, east, "CAR", true, 1000] call FN_spawnVehiclePatrol;
	[[_basePos select 0, (_basePos select 1) + 50, 0], east, "APC", true, 1200] call FN_spawnVehiclePatrol;
	
	hint "Base enemiga generada";
};


// ========================================
// EJEMPLO 3: Spawn basado en trigger
// ========================================
// Coloca esto en la condición "On Activation" de un trigger:

// En el trigger, en "On Activation":
/*
private _triggerPos = getPos thisTrigger;
[_triggerPos, east, [6,8], true, 400] call FN_spawnInfantryGroup;
hint "¡Refuerzos enemigos detectados!";
*/


// ========================================
// EJEMPLO 4: Spawn progresivo (oleadas)
// ========================================
// Script para generar oleadas de enemigos

if (isServer) then {
	waitUntil {!isNil "FN_spawnInfantryGroup"};
	
	private _spawnMarker = "enemySpawn"; // Crea un marcador llamado "enemySpawn"
	private _numWaves = 5;
	private _timeBetweenWaves = 300; // 5 minutos
	
	for "_i" from 1 to _numWaves do {
		private _spawnPos = getMarkerPos _spawnMarker;
		
		// Generar escuadra
		[_spawnPos, east, [4,6], true, 500] call FN_spawnInfantryGroup;
		
		// Mensaje
		hint format ["Oleada %1 de %2 generada", _i, _numWaves];
		
		// Esperar antes de la siguiente oleada
		if (_i < _numWaves) then {
			sleep _timeBetweenWaves;
		};
	};
};


// ========================================
// EJEMPLO 5: Poblar pueblo con civiles
// ========================================

if (isServer) then {
	waitUntil {!isNil "FN_spawnCivilians"};
	
	private _towns = ["pueblo1", "pueblo2", "ciudad1"]; // Marcadores de tus pueblos
	
	{
		private _townPos = getMarkerPos _x;
		private _townSize = markerSize _x select 0; // Tamaño del marcador
		
		// Población civil proporcional al tamaño
		private _numCivs = round (_townSize / 50) max 5;
		[_townPos, _townSize, _numCivs] call FN_spawnCivilians;
		
		// Algunos vehículos civiles
		private _numVehicles = round (_numCivs / 5) max 1;
		for "_i" from 1 to _numVehicles do {
			[_townPos, true, _townSize] call FN_spawnCivilianVehicle;
		};
		
		diag_log format ["Poblado %1 con %2 civiles y %3 vehículos", _x, _numCivs, _numVehicles];
		
	} forEach _towns;
};


// ========================================
// EJEMPLO 6: Guarniciónes en edificios específicos
// ========================================

if (isServer) then {
	waitUntil {!isNil "FN_spawnGarrison"};
	
	// Opción A: Edificios cerca de un marcador
	private _centerPos = getMarkerPos "areaDefendida";
	private _buildings = nearestObjects [_centerPos, ["House"], 200];
	
	// Poner guarnición en los 5 edificios más grandes
	private _buildingsSorted = [_buildings, [], {count ([_x] call BIS_fnc_buildingPositions)}, "DESCEND"] call BIS_fnc_sortBy;
	
	{
		if (_forEachIndex < 5) then {
			[_x, east, 4] call FN_spawnGarrison;
		};
	} forEach _buildingsSorted;
	
	
	// Opción B: Edificios específicos por nombre
	// (usa objects.vr para encontrar los nombres de objetos del editor)
	private _specificBuildings = [building1, building2, building3]; // Nombres del editor
	
	{
		if (!isNil {_x}) then {
			[_x, east, 3] call FN_spawnGarrison;
		};
	} forEach _specificBuildings;
};


// ========================================
// EJEMPLO 7: Roadblocks automáticos en carreteras principales
// ========================================

if (isServer) then {
	waitUntil {!isNil "FN_spawnRoadblock"};
	
	// Obtener todas las carreteras principales cerca de un área
	private _centerPos = getMarkerPos "zonaCombate";
	private _mainRoads = _centerPos nearRoads 2000;
	
	// Filtrar solo carreteras principales (opcional)
	private _numRoadblocks = 3;
	
	for "_i" from 1 to _numRoadblocks do {
		if (count _mainRoads > 0) then {
			private _roadIndex = floor (random (count _mainRoads));
			private _selectedRoad = _mainRoads select _roadIndex;
			_mainRoads deleteAt _roadIndex;
			
			[getPos _selectedRoad, east, 50] call FN_spawnRoadblock;
		};
	};
	
	hint format ["%1 roadblocks generados", _numRoadblocks];
};


// ========================================
// EJEMPLO 8: Sistema de refuerzos dinámico
// ========================================

if (isServer) then {
	waitUntil {!isNil "FN_spawnInfantryGroup"};
	
	// Detectar cuando quedan pocos enemigos y enviar refuerzos
	[] spawn {
		private _reinforcementMarker = "refuerzos";
		private _minEnemies = 10;
		
		while {true} do {
			sleep 60; // Revisar cada minuto
			
			// Contar enemigos vivos
			private _enemyCount = {alive _x && side _x == east && !isPlayer _x} count allUnits;
			
			if (_enemyCount < _minEnemies) then {
				// Enviar refuerzos
				private _reinforcementPos = getMarkerPos _reinforcementMarker;
				
				[_reinforcementPos, east, [6,8], true, 600] call FN_spawnInfantryGroup;
				[_reinforcementPos, east, "CAR", true, 1000] call FN_spawnVehiclePatrol;
				
				hint "¡Refuerzos enemigos desplegados!";
				diag_log format ["Refuerzos enviados. Enemigos antes: %1", _enemyCount];
			};
		};
	};
};


// ========================================
// EJEMPLO 9: Combo - Pueblo con enemigos y civiles
// ========================================

if (isServer) then {
	waitUntil {!isNil "FN_spawnInfantryGroup" && !isNil "FN_spawnCivilians"};
	
	private _townPos = getMarkerPos "puebloOcupado";
	
	// Población civil
	[_townPos, 300, 12] call FN_spawnCivilians;
	
	// Vehículos civiles
	for "_i" from 1 to 3 do {
		[_townPos, true, 400] call FN_spawnCivilianVehicle;
	};
	
	// Ocupación enemiga
	// Patrullas
	for "_i" from 1 to 2 do {
		private _patrolPos = [_townPos, 100, random 360] call BIS_fnc_relPos;
		[_patrolPos, east, [3,4], true, 250] call FN_spawnInfantryGroup;
	};
	
	// Vehículo de patrulla
	[_townPos, east, "CAR", true, 600] call FN_spawnVehiclePatrol;
	
	// Guarniciones en edificios clave
	private _buildings = nearestObjects [_townPos, ["House"], 200];
	{
		if (_forEachIndex < 4) then {
			[_x, east, 2] call FN_spawnGarrison;
		};
	} forEach _buildings;
	
	// Roadblock en entrada del pueblo
	[_townPos, east, 150] call FN_spawnRoadblock;
	
	hint "Pueblo ocupado generado";
};


// ========================================
// EJEMPLO 10: Limpiar área específica
// ========================================

// Función para limpiar solo unidades en un área específica
SPAWN_cleanupArea = {
	params ["_centerPos", "_radius"];
	
	private _count = 0;
	
	{
		if (_x distance _centerPos <= _radius && !isPlayer _x) then {
			deleteVehicle _x;
			_count = _count + 1;
		};
	} forEach allUnits;
	
	{
		if (_x distance _centerPos <= _radius) then {
			deleteVehicle _x;
			_count = _count + 1;
		};
	} forEach vehicles;
	
	hint format ["Limpiados %1 objetos en radio de %2m", _count, _radius];
};

// Uso:
// [getPos player, 500] call SPAWN_cleanupArea;


// ========================================
// EJEMPLO 11: Guardar y cargar spawns
// ========================================

// Guardar información de spawns para replicarlos
SPAWN_saveSpawnData = {
	params ["_varName"];
	
	private _allEnemies = [];
	{
		if (side _x == east && !isPlayer _x) then {
			_allEnemies pushBack [getPos _x, typeOf _x];
		};
	} forEach allUnits;
	
	missionNamespace setVariable [_varName, _allEnemies];
	hint format ["Guardados %1 spawns en variable %2", count _allEnemies, _varName];
};

// Cargar spawns guardados
SPAWN_loadSpawnData = {
	params ["_varName"];
	
	private _spawnData = missionNamespace getVariable [_varName, []];
	
	{
		private _pos = _x select 0;
		private _type = _x select 1;
		
		private _group = createGroup east;
		_group createUnit [_type, _pos, [], 0, "NONE"];
		
	} forEach _spawnData;
	
	hint format ["Cargados %1 spawns desde variable %2", count _spawnData, _varName];
};

// Uso:
// ["miSetup"] call SPAWN_saveSpawnData;
// ["miSetup"] call SPAWN_loadSpawnData;

