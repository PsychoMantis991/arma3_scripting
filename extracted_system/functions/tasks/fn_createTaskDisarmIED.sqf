/*
	═══════════════════════════════════════════════════════════════════
	TAREA: DESARMAR IEDs
	Basado en DRO disarmIED.sqf
	═══════════════════════════════════════════════════════════════════
*/

params [
	["_pos", [0,0,0], [[]]],
	["_side", east]
];

private _taskID = [] call FN_generateTaskID;
private _markerName = format ["iedMarker%1", floor(random 10000)];

// Buscar carreteras cercanas
private _roads = _pos nearRoads 200;

if (count _roads == 0) exitWith {
	hint "No hay carreteras cercanas para colocar IEDs";
	diag_log "[TASK_IED] Error: No hay carreteras cercanas";
	[_taskID, []]
};

// Crear IEDs en carreteras
private _ieds = [];
private _numIEDs = [3, 5] call BIS_fnc_randomInt;

for "_i" from 1 to _numIEDs do {
	private _road = selectRandom _roads;
	private _roadPos = getPos _road;
	
	// Crear objeto IED visible usando varios tipos
	private _iedTypes = [
		"IEDUrbanSmall_Remote_Mag",
		"IEDLandSmall_Remote_Mag",
		"IEDUrbanBig_Remote_Mag",
		"Land_Sack_F",
		"Land_CanisterFuel_F"
	];
	private _iedClass = selectRandom _iedTypes;
	
	private _iedObject = createVehicle [_iedClass, _roadPos, [], 0, "CAN_COLLIDE"];
	_iedObject setPos [_roadPos select 0, _roadPos select 1, 0];
	_iedObject setDir (random 360);
	_iedObject enableSimulation true;
	_iedObject allowDamage false; // Evitar que sea destruido accidentalmente
	
	// Crear marcador local para cada IED
	private _iedMarker = createMarker [format ["ied_%1_%2", _taskID, _i], _roadPos];
	_iedMarker setMarkerShape "ICON";
	_iedMarker setMarkerType "hd_warning";
	_iedMarker setMarkerColor "ColorOrange";
	_iedMarker setMarkerAlpha 0.5;
	_iedMarker setMarkerText format ["IED #%1", _i];
	
	// Añadir acción para desarmar con ACE Defusal Kit
	_iedObject addAction [
		"<t color='#FFAA00'>✂️ Desarmar IED (Requiere Kit ACE)</t>",
		{
			params ["_target", "_caller", "_actionId"];
			
			// Verificar si tiene kit de desactivación
			private _hasDefusalKit = false;
			private _aceLoaded = isClass (configFile >> "CfgPatches" >> "ace_explosives");
			
			// Verificar si ACE está cargado
			if (_aceLoaded) then {
				// ACE está cargado - verificar kit específico de ACE
				private _aceKitName = "ACE_DefusalKit";
				_hasDefusalKit = _aceKitName in (items _caller);
				
				if (!_hasDefusalKit) exitWith {
					hint parseText "<t size='1.2' color='#FF4444'>✗ NECESITAS ACE DEFUSAL KIT</t><br/><br/><t size='0.9'>No tienes el equipo necesario para desarmar IEDs</t>";
					playSound "addItemFailed";
				};
			} else {
				// ACE no está cargado - verificar herramientas vanilla
				private _vanillaTools = [
					"ToolKit",
					"MineDetector"
				];
				
				// También permitir ACE kit si se añadió manualmente
				_vanillaTools pushBack "ACE_DefusalKit";
				
				{
					if (_x in (items _caller)) exitWith {
						_hasDefusalKit = true;
					};
				} forEach _vanillaTools;
				
				if (!_hasDefusalKit) exitWith {
					hint parseText "<t size='1.2' color='#FF4444'>✗ NECESITAS HERRAMIENTAS</t><br/><br/><t size='0.9'>Necesitas: Toolkit, Detector de Minas o ACE Defusal Kit</t>";
					playSound "addItemFailed";
				};
			};
			
			// Usar spawn para permitir sleep
			[_target, _caller, _actionId] spawn {
				params ["_target", "_caller", "_actionId"];
				
				// Animación
				_caller playAction "MedicOther";
				
				// Mostrar progreso
				hint "Desarmando IED...";
				sleep 8; // Tiempo más largo para mayor realismo
				
				// Posibilidad de fallo (10% de probabilidad)
				if (random 100 < 10) exitWith {
					hint parseText "<t size='1.2' color='#FF4444'>✗ ERROR AL DESARMAR</t><br/><br/><t size='0.9'>El IED sigue activo. Inténtalo de nuevo.</t>";
					playSound "addItemFailed";
				};
				
				// Eliminar marcador del IED
				private _iedMarkers = allMapMarkers select {_x find "ied_" == 0};
				{
					private _markerPos = getMarkerPos _x;
					if (_markerPos distance _target < 5) then {
						deleteMarker _x;
					};
				} forEach _iedMarkers;
				
				// Eliminar IED
				deleteVehicle _target;
				
				// Confirmar
				hint parseText "<t size='1.2' color='#00FF00'>✓ IED DESARMADO</t><br/><br/><t size='0.9'>El explosivo ha sido neutralizado con éxito</t>";
				playSound "addItemOK";
				
				diag_log "[TASK_IED] IED desarmado con éxito";
			};
		},
		[],
		10,
		true,
		true,
		"",
		"_this distance _target < 5"
	];
	
	// Marcar IED como parte de la tarea
	_iedObject setVariable ["taskID", _taskID, true];
	_iedObject setVariable ["isIED", true, true];
	_iedObject setVariable ["iedMarker", _iedMarker, true];
	
	_ieds pushBack _iedObject;
	
	diag_log format ["[TASK_IED] IED creado en %1 (clase: %2)", _roadPos, _iedClass];
	
	sleep 0.1; // Pequeña pausa entre creaciones
};

// Crear marcador
[_pos, _markerName, "hd_warning", "ColorOrange", "Zona de IEDs", 1] call FN_createTaskMarker;

// Crear tarea
private _taskTitle = "Desarmar IEDs";

// Detectar si ACE está cargado
private _hasACE = isClass (configFile >> "CfgPatches" >> "ace_explosives");
private _toolRequired = if (_hasACE) then {"ACE Defusal Kit"} else {"Toolkit, Detector de Minas o ACE Defusal Kit"};

private _taskDesc = format [
	"Se han detectado %1 IEDs en las carreteras cercanas. Localízalos y desármalos con cuidado para asegurar la ruta.<br/><br/>" +
	"<t color='#FFAA00'>EQUIPO REQUERIDO:</t> %2",
	count _ieds,
	_toolRequired
];

[_taskID, _taskTitle, _taskDesc, _pos, "mine", "", 1] call FN_createBISTask;

// Crear trigger para detectar completado
private _trigger = createTrigger ["EmptyDetector", _pos, true];
_trigger setTriggerArea [0, 0, 0, false];
_trigger setTriggerActivation ["ANY", "PRESENT", true];

_trigger setTriggerStatements [
	"{!isNull _x} count (thisTrigger getVariable 'ieds') == 0", 
	format [
		"['%1', true, true] call FN_completeTask; deleteMarker '%2'; hint parseText '<t size=''1.5'' color=''#00FF00''>✓ TODOS LOS IEDs DESARMADOS</t>';",
		_taskID,
		_markerName
	], 
	""
];

_trigger setVariable ["ieds", _ieds, true];

// Mensaje de confirmación
private _hasACEConfirm = isClass (configFile >> "CfgPatches" >> "ace_explosives");
hint parseText format [
	"<t size='1.5' color='#FFAA00'>⚠️ NUEVA TAREA: DESARMAR IEDs</t><br/><br/>" +
	"<t size='1'>Total de IEDs: %1</t><br/>" +
	"<t size='0.9' color='#FF8800'>¡Ten cuidado! Busca en las carreteras</t><br/><br/>" +
	"<t size='0.9' color='#FFFF00'>Equipo necesario: %2</t>",
	count _ieds,
	if (_hasACEConfirm) then {"ACE Defusal Kit"} else {"Toolkit/Detector"}
];

diag_log format ["[TASK_IED] Tarea creada: %1 IEDs en área de %2", count _ieds, _pos];

// Retornar
[_taskID, _ieds]
