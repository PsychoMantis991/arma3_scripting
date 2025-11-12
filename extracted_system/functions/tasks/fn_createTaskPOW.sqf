/*TAREA: RESCATAR PRISIONERO - Basado en DRO pow.sqf*/
params [["_pos", [0,0,0], [[]]], ["_side", east]];
private _taskID = [] call FN_generateTaskID;
private _markerName = format ["powMarker%1", floor(random 10000)];
// Crear prisionero
private _powGroup = createGroup west;
private _pow = _powGroup createUnit ["B_Soldier_F", _pos, [], 5, "NONE"];
_pow setCaptive true;
_pow setUnitPos "DOWN";
_pow disableAI "MOVE";
_pow setName (selectRandom ["Miller", "Johnson", "Smith", "Davis", "Wilson"]);
removeAllWeapons _pow;
// Guardias
private _guards = [_pos, _side, [4, 6], true, 80] call FN_createObjectiveGuards;
// Marcador
[_pos, _markerName, "hd_unknown", "ColorRed", "", 1] call FN_createTaskMarker;
// Tarea principal
private _taskTitle = format ["Rescatar Prisionero: %1", name _pow];
private _taskDesc = format ["Uno de nuestros soldados está siendo retenido. Rescátalo y asegura su extracción."];
[_taskID, _taskTitle, _taskDesc, _pos, "meet", "", 2] call FN_createBISTask;
// Sub-tarea: extraer
private _extractID = format ["extract%1", floor(random 10000)];
// Trigger de rescate
private _trigger1 = createTrigger ["EmptyDetector", _pos, true];
_trigger1 setTriggerArea [30, 30, 0, false];
_trigger1 setTriggerActivation ["WEST", "PRESENT", false];
_trigger1 setTriggerStatements [
	"thisTrigger getVariable 'pow' in thisList && alive (thisTrigger getVariable 'pow')",
	format [
		"(thisTrigger getVariable 'pow') setCaptive false; (thisTrigger getVariable 'pow') enableAI 'MOVE'; (thisTrigger getVariable 'pow') setUnitPos 'AUTO'; hint parseText '<t size=''1.5'' color=''#00FF00''>✓ PRISIONERO RESCATADO</t><br/>Llévalo a zona segura'; ['%1', 'SUCCEEDED', true] call BIS_fnc_taskSetState;",
		_taskID
	],
	""
];
_trigger1 setVariable ["pow", _pow, true];
hint parseText format ["<t size='1.5' color='#4444FF'>👤 NUEVA TAREA: RESCATAR POW</t><br/><br/>Nombre: <t color='#FFAA00'>%1</t>", name _pow];
[_taskID, _pow]

