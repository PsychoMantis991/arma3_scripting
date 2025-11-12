/*TAREA: DESTRUIR VEHÍCULO - Basado en DRO vehicle.sqf*/
params [["_pos", [0,0,0], [[]]], ["_side", east], ["_type", "APC"]];
private _taskID = [] call FN_generateTaskID;
private _markerName = format ["vehMarker%1", floor(random 10000)];
// Crear vehículo
private _factionClasses = [_side] call SPAWN_getFactionClasses;
private _vehClasses = switch (_type) do {
	case "CAR": {_factionClasses get "cars"};
	case "APC": {_factionClasses get "apcs"};
	case "TANK": {_factionClasses get "tanks"};
	default {_factionClasses get "cars"};
};
if (count _vehClasses == 0) then {_vehClasses = ["O_MRAP_02_hmg_F"]};
private _vehClass = selectRandom _vehClasses;
private _vehicle = createVehicle [_vehClass, _pos, [], 0, "NONE"];
createVehicleCrew _vehicle;
private _crew = crew _vehicle;
// Patrulla
[group (driver _vehicle), _pos, 400] call BIS_fnc_taskPatrol;
// Marcador
[_pos, _markerName, "hd_destroy", "ColorRed", "", 1] call FN_createTaskMarker;
// Tarea
private _taskTitle = "Destruir Vehículo";
private _taskDesc = format ["Destruye el %1 enemigo en la región.", getText (configFile >> "CfgVehicles" >> _vehClass >> "displayName")];
[_taskID, _taskTitle, _taskDesc, _pos, "destroy", "", 1] call FN_createBISTask;
// Trigger
private _trigger = createTrigger ["EmptyDetector", _pos, true];
_trigger setTriggerArea [0, 0, 0, false];
_trigger setTriggerActivation ["ANY", "PRESENT", false];
_trigger setTriggerStatements [
	"!alive (thisTrigger getVariable 'veh')",
	format ["['%1', true, true] call FN_completeTask; deleteMarker '%2'; hint parseText '<t size=''1.5'' color=''#00FF00''>✓ VEHÍCULO DESTRUIDO</t>';", _taskID, _markerName],
	""
];
_trigger setVariable ["veh", _vehicle, true];
hint parseText format ["<t size='1.5' color='#FF4444'>🚗 NUEVA TAREA: DESTRUIR VEHÍCULO</t><br/><br/>Tipo: %1", _type];
[_taskID, _vehicle]

