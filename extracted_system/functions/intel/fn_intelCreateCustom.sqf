/*
	═══════════════════════════════════════════════════════════════════
	FUNCIÓN: CREAR INTEL PERSONALIZADA (SERVIDOR)
	Crea un objeto de intel con configuración personalizada
	═══════════════════════════════════════════════════════════════════
*/

if (!isServer) exitWith {};

params [
	["_pos", [0,0,0], [[]]],
	["_objectClass", "Land_File1_F", [""]],
	["_message", "Intel recuperada", [""]],
	["_createMarker", false, [false]],
	["_markerPos", [0,0,0], [[]]],
	["_markerType", "mil_objective", [""]],
	["_markerColor", "ColorRed", [""]],
	["_markerText", "Intel", [""]]
];

diag_log format ["[INTEL_CREATE] Creando intel personalizada en %1", _pos];
diag_log format ["[INTEL_CREATE] Objeto: %1, Mensaje: %2", _objectClass, _message];
diag_log format ["[INTEL_CREATE] Marcador: %1, Pos: %2", _createMarker, _markerPos];

// Crear objeto de intel
private _intelObject = createVehicle [_objectClass, _pos, [], 0, "NONE"];
_intelObject setPos _pos;
_intelObject enableSimulation false;

// Configurar acción de recoger intel
_intelObject addAction [
	"<t color='#00FF00'>📄 Recoger Intel</t>",
	{
		params ["_target", "_caller", "_actionId", "_arguments"];
		_arguments params ["_message", "_createMarker", "_markerPos", "_markerType", "_markerColor", "_markerText"];
		
		// Mostrar mensaje
		hint parseText format [
			"<t size='1.5' color='#00FF00'>📄 INTEL RECUPERADA</t><br/><br/>" +
			"<t size='1' color='#FFFFFF'>%1</t>",
			_message
		];
		
		// Crear marcador si está configurado
		if (_createMarker && {_markerPos select 0 != 0 && _markerPos select 1 != 0}) then {
			private _markerName = format ["intel_marker_%1", floor(random 10000)];
			private _marker = createMarker [_markerName, _markerPos];
			_marker setMarkerType _markerType;
			_marker setMarkerColor _markerColor;
			_marker setMarkerText _markerText;
			_marker setMarkerAlpha 0;
			
			// Revelar marcador progresivamente
			[_marker] spawn {
				params ["_marker"];
				
				for "_i" from 0 to 10 do {
					_marker setMarkerAlpha (_i / 10);
					sleep 0.1;
				};
				
				hint parseText format [
					"<t size='1.2' color='#FFAA00'>🗺️ NUEVO MARCADOR REVELADO</t><br/><br/>" +
					"<t size='1'>%1</t><br/><br/>" +
					"<t size='0.9' color='#888888'>Revisa tu mapa</t>",
					markerText _marker
				];
			};
			
			diag_log format ["[INTEL_CREATE] Marcador revelado: %1 en %2", _markerText, _markerPos];
		};
		
		// Eliminar objeto de intel
		deleteVehicle _target;
		
		diag_log "[INTEL_CREATE] Intel recogida por jugador";
	},
	[_message, _createMarker, _markerPos, _markerType, _markerColor, _markerText],
	10,
	true,
	true,
	"",
	"_this distance _target < 3"
];

// Confirmación
[
	format [
		"<t size='1.5' color='#00FF00'>✓ INTEL CREADA</t><br/><br/>" +
		"<t size='1'>Ubicación:</t> <t color='#FFAA00'>%1</t><br/>" +
		"<t size='1'>Tipo:</t> <t color='#FFAA00'>%2</t><br/>" +
		"<t size='1'>Marcador:</t> <t color='#FFAA00'>%3</t>",
		mapGridPosition _pos,
		_objectClass,
		if (_createMarker) then {"Sí"} else {"No"}
	]
] remoteExec ["hint", 0];

diag_log format ["[INTEL_CREATE] Intel personalizada creada exitosamente en %1", _pos];

// Retornar objeto
_intelObject

