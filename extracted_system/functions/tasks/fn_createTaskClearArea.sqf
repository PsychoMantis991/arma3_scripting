/*TAREA: LIMPIAR ÁREA - Basado en DRO clearArea.sqf*/
params [["_pos", [0,0,0], [[]]], ["_side", east]];
private _taskID = [] call FN_generateTaskID;
private _markerName = format ["clearMarker%1", floor(random 10000)];
private _marker = createMarker [_markerName, _pos];
_marker setMarkerShape "ELLIPSE";
_marker setMarkerSize [150, 150];
_marker setMarkerBrush "Border";
_marker setMarkerColor "ColorRed";
// Enemigos en área
for "_i" from 1 to 3 do {
	[_pos, _side, [3, 5], true, 140] call FN_createObjectiveGuards;
};
// Tarea
private _taskTitle = "Limpiar Área";
private _taskDesc = format ["Elimina todas las fuerzas enemigas del área marcada."];
[_taskID, _taskTitle, _taskDesc, _pos, "attack", "", 1] call FN_createBISTask;
// Trigger
private _trigger = createTrigger ["EmptyDetector", _pos, true];
_trigger setTriggerArea [150, 150, 0, false, 20];
_trigger setTriggerActivation ["ANY", "PRESENT", false];
_trigger setTriggerStatements [
	format ["({side _x == %1 && alive _x} count thisList) == 0", str _side],
	format ["['%1', true, true] call FN_completeTask; deleteMarker '%2'; hint parseText '<t size=''1.5'' color=''#00FF00''>✓ ÁREA LIMPIA</t>';", _taskID, _markerName],
	""
];
_trigger setTriggerTimeout [5, 8, 10, true];
hint parseText "<t size='1.5' color='#FF4444'>🎯 NUEVA TAREA: LIMPIAR ÁREA</t>";
[_taskID, _marker]

