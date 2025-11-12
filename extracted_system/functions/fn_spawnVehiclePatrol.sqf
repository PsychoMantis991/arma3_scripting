/*
	Función: fn_spawnVehiclePatrol
	Descripción: Genera un vehículo con tripulación en una posición
	
	Parámetros:
		_pos - Posición donde generar [x,y,z] (ARRAY)
		_side - Lado del vehículo (SIDE) - default: east
		_vehicleType - Tipo de vehículo: "CAR", "APC", "TANK" (STRING) - default: "CAR"
		_patrol - Si debe patrullar el área (BOOL) - default: true
		_patrolRadius - Radio de patrulla en metros (NUMBER) - default: 800
	
	Retorna:
		[_vehicle, _group] - Vehículo y grupo de tripulación (ARRAY)
		
	Ejemplo:
		[getPos player, east, "CAR", true, 1000] call FN_spawnVehiclePatrol;
*/

params [
	["_pos", [0,0,0], [[]]],
	["_side", east, [sideUnknown]],
	["_vehicleType", "CAR", [""]],
	["_patrol", true, [true]],
	["_patrolRadius", 800, [0]]
];

// ═════════════════════════════════════════════════════════════════
// SISTEMA DINÁMICO DE FACCIONES (Estilo DRO)
// ═════════════════════════════════════════════════════════════════

// Obtener clases de la facción seleccionada
private _factionClasses = [_side] call SPAWN_getFactionClasses;

// Seleccionar tipo de vehículo según parámetro
private _vehicleClasses = switch (_vehicleType) do {
	case "CAR": {_factionClasses get "cars"};
	case "APC": {_factionClasses get "apcs"};
	case "TANK": {_factionClasses get "tanks"};
	default {_factionClasses get "cars"};
};

// Fallback a vanilla si la facción no tiene vehículos de este tipo
if (count _vehicleClasses == 0) then {
	diag_log format ["[FN_spawnVehiclePatrol] ADVERTENCIA: No hay vehículos tipo %1 para %2, usando vanilla", _vehicleType, _side];
	_vehicleClasses = switch (_side) do {
		case east: {
			switch (_vehicleType) do {
				case "CAR": {["O_MRAP_02_hmg_F", "O_MRAP_02_gmg_F"]};
				case "APC": {["O_APC_Wheeled_02_rcws_v2_F", "O_APC_Tracked_02_cannon_F"]};
				case "TANK": {["O_MBT_02_cannon_F", "O_MBT_04_cannon_F"]};
				default {["O_MRAP_02_hmg_F"]};
			};
		};
		case west: {
			switch (_vehicleType) do {
				case "CAR": {["B_MRAP_01_hmg_F", "B_MRAP_01_gmg_F"]};
				case "APC": {["B_APC_Wheeled_01_cannon_F", "B_APC_Tracked_01_rcws_F"]};
				case "TANK": {["B_MBT_01_cannon_F", "B_MBT_01_TUSK_F"]};
				default {["B_MRAP_01_hmg_F"]};
			};
		};
		case resistance: {
			switch (_vehicleType) do {
				case "CAR": {["I_MRAP_03_hmg_F", "I_MRAP_03_gmg_F"]};
				case "APC": {["I_APC_Wheeled_03_cannon_F", "I_APC_tracked_03_cannon_F"]};
				case "TANK": {["I_MBT_03_cannon_F"]};
				default {["I_MRAP_03_hmg_F"]};
			};
		};
		default {["O_MRAP_02_hmg_F"]};
	};
};

// Crear vehículo
private _vehClass = selectRandom _vehicleClasses;
private _vehicle = createVehicle [_vehClass, _pos, [], 0, "NONE"];

// Crear tripulación
createVehicleCrew _vehicle;
waitUntil {!isNull (driver _vehicle)};

private _group = group (driver _vehicle);

diag_log format ["[FN_spawnVehiclePatrol] Generado vehículo %1 con tripulación %2 en %3", _vehicle, _group, _pos];

// Configurar patrulla
if (_patrol) then {
	[_group, _pos, _patrolRadius] call BIS_fnc_taskPatrol;
	diag_log format ["[FN_spawnVehiclePatrol] Vehículo %1 configurado para patrullar con radio %2m", _vehicle, _patrolRadius];
};

// Habilitar simulación dinámica
_group enableDynamicSimulation true;

// Retornar vehículo y grupo
[_vehicle, _group]

