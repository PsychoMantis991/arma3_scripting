/*
	═══════════════════════════════════════════════════════════════════
	SISTEMA DE INTEL PERSONALIZADO
	Basado en DRO pero adaptado para uso manual de Zeus
	═══════════════════════════════════════════════════════════════════
	
	Permite a Zeus añadir intel a unidades, objetos y edificios con
	mensajes personalizados que se revelan al recogerlos.
*/

// ═════════════════════════════════════════════════════════════════════
// VARIABLES GLOBALES
// ═════════════════════════════════════════════════════════════════════

if (isNil "INTEL_AllIntel") then {
	INTEL_AllIntel = [];
	publicVariable "INTEL_AllIntel";
};

if (isNil "INTEL_CollectedIntel") then {
	INTEL_CollectedIntel = [];
	publicVariable "INTEL_CollectedIntel";
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Añadir Intel a Unidad (Enemigo o Civil)
// ═════════════════════════════════════════════════════════════════════

INTEL_addToUnit = {
	params [
		"_unit",
		"_intelText",
		["_intelType", "DOCUMENT"],
		["_revealMarker", ""],
		["_revealPos", []]
	];
	
	if (isNull _unit) exitWith {
		diag_log "[INTEL] Error: Unidad nula";
		false
	};
	
	// Guardar intel en la unidad
	_unit setVariable ["hasIntel", true, true];
	_unit setVariable ["intelText", _intelText, true];
	_unit setVariable ["intelType", _intelType, true];
	_unit setVariable ["revealMarker", _revealMarker, true];
	_unit setVariable ["revealPos", _revealPos, true];
	
	// Registrar en sistema global
	private _intelID = format ["intel_%1", floor(random 100000)];
	INTEL_AllIntel pushBack [_intelID, _unit, _intelText, _intelType];
	publicVariable "INTEL_AllIntel";
	
	// Añadir event handler para cuando muera
	_unit addEventHandler ["Killed", {
		params ["_unit"];
		
		if (_unit getVariable ["hasIntel", false]) then {
			// Añadir acción de búsqueda al cadáver
			_unit addAction [
				"<t color='#4444FF'>🔍 Buscar Intel</t>",
				{
					params ["_target", "_caller"];
					
					// Animación de búsqueda
					_caller playAction "Gear";
					sleep 2;
					
					// Obtener datos del intel
					private _intelText = _target getVariable ["intelText", "Documentos encontrados"];
					private _intelType = _target getVariable ["intelType", "DOCUMENT"];
					private _revealMarker = _target getVariable ["revealMarker", ""];
					private _revealPos = _target getVariable ["revealPos", []];
					
					// Mostrar intel encontrado
					[_intelText, _intelType, _revealMarker, _revealPos] call INTEL_showIntelMessage;
					
					// Registrar como recogido
					INTEL_CollectedIntel pushBack [_target, _intelText, time];
					publicVariable "INTEL_CollectedIntel";
					
					// Remover acción
					_target removeAction (_thisArgs select 2);
					_target setVariable ["hasIntel", false, true];
					
					// Notificación global
					[
						"TaskSucceeded",
						["Intel Recuperado", _intelText]
					] remoteExec ["BIS_fnc_showNotification", 0];
				},
				[],
				10,
				true,
				true,
				"",
				"_this distance _target < 3"
			];
		};
	}];
	
	diag_log format ["[INTEL] Intel añadido a unidad: %1", _unit];
	true
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Añadir Intel a Objeto (Documentos, Laptop, etc)
// ═════════════════════════════════════════════════════════════════════

INTEL_addToObject = {
	params [
		"_object",
		"_intelText",
		["_intelType", "DOCUMENT"],
		["_revealMarker", ""],
		["_revealPos", []]
	];
	
	if (isNull _object) exitWith {
		diag_log "[INTEL] Error: Objeto nulo";
		false
	};
	
	// Guardar intel en el objeto
	_object setVariable ["hasIntel", true, true];
	_object setVariable ["intelText", _intelText, true];
	_object setVariable ["intelType", _intelType, true];
	_object setVariable ["revealMarker", _revealMarker, true];
	_object setVariable ["revealPos", _revealPos, true];
	
	// Añadir acción de recoger
	_object addAction [
		"<t color='#4444FF'>📄 Recoger Intel</t>",
		{
			params ["_target", "_caller"];
			
			// Animación
			_caller playAction "Gear";
			sleep 2;
			
			// Obtener datos
			private _intelText = _target getVariable ["intelText", "Documentos encontrados"];
			private _intelType = _target getVariable ["intelType", "DOCUMENT"];
			private _revealMarker = _target getVariable ["revealMarker", ""];
			private _revealPos = _target getVariable ["revealPos", []];
			
			// Mostrar intel
			[_intelText, _intelType, _revealMarker, _revealPos] call INTEL_showIntelMessage;
			
			// Registrar
			INTEL_CollectedIntel pushBack [_target, _intelText, time];
			publicVariable "INTEL_CollectedIntel";
			
			// Remover objeto
			deleteVehicle _target;
			
			// Notificación
			[
				"TaskSucceeded",
				["Intel Recuperado", _intelText]
			] remoteExec ["BIS_fnc_showNotification", 0];
		},
		[],
		10,
		true,
		true,
		"",
		"_this distance _target < 3"
	];
	
	diag_log format ["[INTEL] Intel añadido a objeto: %1", _object];
	true
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Mostrar Mensaje de Intel
// ═════════════════════════════════════════════════════════════════════

INTEL_showIntelMessage = {
	params ["_text", ["_type", "DOCUMENT"], ["_revealMarker", ""], ["_revealPos", []]];
	
	// Mostrar hint con el intel
	private _iconText = switch (_type) do {
		case "DOCUMENT": {"📄"};
		case "LAPTOP": {"💻"};
		case "PHONE": {"📱"};
		case "MAP": {"🗺️"};
		case "RADIO": {"📻"};
		default {"📄"};
	};
	
	hint parseText format [
		"<t size='1.5' color='#4444FF' shadow='2'>%1 INTEL RECUPERADO</t><br/><br/>" +
		"<t size='1' color='#FFFFFF'>%2</t><br/><br/>" +
		"<t size='0.8' color='#888888'>Revisa tu mapa para más información</t>",
		_iconText,
		_text
	];
	
	// Revelar marcador si existe
	if (_revealMarker != "") then {
		_revealMarker setMarkerAlpha 1;
		hint parseText format [
			"<t size='1.5' color='#4444FF'>%1 INTEL RECUPERADO</t><br/><br/>" +
			"<t size='1'>%2</t><br/><br/>" +
			"<t size='1.2' color='#00FF00'>✓ Ubicación revelada en el mapa</t>",
			_iconText,
			_text
		];
	};
	
	// Revelar posición si existe
	if (count _revealPos > 0) then {
		private _markerName = format ["intelReveal_%1", floor(random 100000)];
		private _marker = createMarker [_markerName, _revealPos];
		_marker setMarkerShape "ICON";
		_marker setMarkerType "hd_warning";
		_marker setMarkerColor "ColorRed";
		_marker setMarkerText "Intel: Ubicación revelada";
		_marker setMarkerAlpha 1;
	};
	
	// Efecto de sonido
	playSound "Click";
	
	diag_log format ["[INTEL] Intel mostrado: %1", _text];
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Crear Objeto de Intel en Posición
// ═════════════════════════════════════════════════════════════════════

INTEL_createObject = {
	params [
		"_pos",
		"_intelText",
		["_objectType", "DOCUMENT"],
		["_revealMarker", ""],
		["_revealPos", []]
	];
	
	// Clases de objetos según tipo
	private _objectClass = switch (_objectType) do {
		case "DOCUMENT": {selectRandom ["Land_File1_F", "Land_File2_F", "Land_FilePhotos_F"]};
		case "LAPTOP": {selectRandom ["Land_Laptop_unfolded_F", "Land_Laptop_device_F"]};
		case "PHONE": {"Land_MobilePhone_smart_F"};
		case "MAP": {"Land_Map_F"};
		case "TABLET": {"Land_Tablet_02_F"};
		default {"Land_File1_F"};
	};
	
	// Crear objeto
	private _object = createVehicle [_objectClass, _pos, [], 0, "CAN_COLLIDE"];
	_object setDir (random 360);
	
	// Añadir intel
	[_object, _intelText, _objectType, _revealMarker, _revealPos] call INTEL_addToObject;
	
	diag_log format ["[INTEL] Objeto de intel creado en %1", _pos];
	
	_object
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Añadir Intel a Civil (Interrogación)
// ═════════════════════════════════════════════════════════════════════

INTEL_addToCivilian = {
	params [
		"_civilian",
		"_intelText",
		["_revealMarker", ""],
		["_revealPos", []]
	];
	
	if (isNull _civilian) exitWith {false};
	
	// Marcar que tiene intel
	_civilian setVariable ["hasIntel", true, true];
	_civilian setVariable ["intelText", _intelText, true];
	_civilian setVariable ["revealMarker", _revealMarker, true];
	_civilian setVariable ["revealPos", _revealPos, true];
	_civilian setVariable ["interrogated", false, true];
	
	// Acción de interrogar (solo si está vivo y cerca)
	_civilian addAction [
		"<t color='#FFAA00'>💬 Interrogar Civil</t>",
		{
			params ["_target", "_caller"];
			
			// Animación
			_caller playAction "Medic";
			_target playAction "ActsPercMstpSsurWnonDnon_DancingDuoStefan";
			
			hint "Interrogando...";
			sleep 5;
			
			// Obtener intel
			private _intelText = _target getVariable ["intelText", "El civil no sabe nada útil"];
			private _revealMarker = _target getVariable ["revealMarker", ""];
			private _revealPos = _target getVariable ["revealPos", []];
			
			// Mostrar información
			[_intelText, "INTERROGATION", _revealMarker, _revealPos] call INTEL_showIntelMessage;
			
			// Marcar como interrogado
			_target setVariable ["interrogated", true, true];
			
			// Registrar
			INTEL_CollectedIntel pushBack [_target, _intelText, time];
			publicVariable "INTEL_CollectedIntel";
			
			// Remover acción
			_target removeAction (_thisArgs select 2);
		},
		[],
		10,
		true,
		true,
		"",
		"_this distance _target < 5 && alive _target"
	];
	
	diag_log format ["[INTEL] Intel añadido a civil: %1", _civilian];
	true
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Añadir Intel Múltiple a Grupo
// ═════════════════════════════════════════════════════════════════════

INTEL_addToGroup = {
	params [
		"_group",
		"_intelText",
		["_intelType", "DOCUMENT"],
		["_revealMarker", ""],
		["_revealPos", []]
	];
	
	private _unitsWithIntel = 0;
	
	{
		if (alive _x) then {
			[_x, _intelText, _intelType, _revealMarker, _revealPos] call INTEL_addToUnit;
			_unitsWithIntel = _unitsWithIntel + 1;
		};
	} forEach units _group;
	
	diag_log format ["[INTEL] Intel añadido a %1 unidades del grupo", _unitsWithIntel];
	
	_unitsWithIntel
};

// ═════════════════════════════════════════════════════════════════════
// INICIALIZACIÓN
// ═════════════════════════════════════════════════════════════════════

diag_log "[INTEL] Sistema de intel personalizado cargado";

