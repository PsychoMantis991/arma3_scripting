/*
	═══════════════════════════════════════════════════════════════════
	MENÚ INTERACTIVO DE SELECCIÓN DE FACCIONES
	Permite a Zeus cambiar facciones fácilmente desde el juego
	═══════════════════════════════════════════════════════════════════
*/

params [["_forSide", east]];

// Obtener facciones disponibles para este lado
private _sideNum = switch (_forSide) do {
	case east: {0};
	case west: {1};
	case resistance: {2};
	case civilian: {3};
	default {0};
};

private _sideName = switch (_forSide) do {
	case east: {"OPFOR (Enemigos)"};
	case west: {"BLUFOR (Aliados)"};
	case resistance: {"INDEPENDENT (Independientes)"};
	case civilian: {"CIVILIAN (Civiles)"};
	default {"UNKNOWN"};
};

// Filtrar facciones por lado
private _availableForSide = [];
{
	_x params ["_factionID", "_factionName", "_factionFlag", "_thisSideNum"];
	
	if (_thisSideNum == _sideNum) then {
		private _color = switch (_thisSideNum) do {
			case 0: {"#FF4444"};
			case 1: {"#4444FF"};
			case 2: {"#44FF44"};
			case 3: {"#FFFFFF"};
			default {"#FFFFFF"};
		};
		
		_availableForSide pushBack [_factionID, _factionName, _factionFlag, _color];
	};
} forEach SPAWN_availableFactionsData;

if (count _availableForSide == 0) exitWith {
	hint parseText format [
		"<t color='#FF4444' size='1.5'>✗ NO HAY FACCIONES</t><br/><br/>" +
		"<t size='1'>No hay facciones disponibles para %1</t>",
		_sideName
	];
};

// Limpiar menú anterior
if (!isNil "FACTION_SELECTOR_Menu") then {
	{
		player removeAction _x;
	} forEach FACTION_SELECTOR_Menu;
};

FACTION_SELECTOR_Menu = [];

// Mensaje informativo
hint parseText format [
	"<t size='1.5' color='#FFAA00'>🎖️ SELECCIONAR FACCIÓN</t><br/><br/>" +
	"<t size='1.1' color='#00FF00'>%1</t><br/><br/>" +
	"<t size='0.9' color='#CCCCCC'>Total de facciones: %2</t><br/><br/>" +
	"<t size='0.8' color='#888888'>Usa el menú de acción para seleccionar...</t>",
	_sideName,
	count _availableForSide
];

// Crear acciones para cada facción
{
	_x params ["_factionID", "_factionName", "_factionFlag", "_color"];
	
	FACTION_SELECTOR_Menu pushBack (player addAction [
		format ["<t color='%2'>%1. %3</t>", _forEachIndex + 1, _color, _factionName],
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
			_arguments params ["_factionID", "_factionName", "_forSide", "_color"];
			
			// Guardar selección
			switch (_forSide) do {
				case east: {
					SPAWN_SelectedFaction_OPFOR = _factionID;
					publicVariable "SPAWN_SelectedFaction_OPFOR";
				};
				case west: {
					SPAWN_SelectedFaction_BLUFOR = _factionID;
					publicVariable "SPAWN_SelectedFaction_BLUFOR";
				};
				case resistance: {
					SPAWN_SelectedFaction_INDEP = _factionID;
					publicVariable "SPAWN_SelectedFaction_INDEP";
				};
				case civilian: {
					SPAWN_SelectedFaction_CIVILIAN = _factionID;
					publicVariable "SPAWN_SelectedFaction_CIVILIAN";
				};
			};
			
			// Limpiar caché para forzar recarga
			SPAWN_FactionClassesCache deleteAt _factionID;
			
			// Notificación
			hint parseText format [
				"<t size='1.5' color='#00FF00'>✓ FACCIÓN SELECCIONADA</t><br/><br/>" +
				"<t size='1.2' color='%3'>%1</t><br/>" +
				"<t size='0.9' color='#888888'>ID: %2</t><br/><br/>" +
				"<t size='0.8' color='#FFFF00'>Los nuevos spawns usarán esta facción</t>",
				_factionName,
				_factionID,
				_color
			];
			
			diag_log format ["[FACTION_SELECTOR] Facción seleccionada: %1 (%2) para %3", _factionName, _factionID, _forSide];
			
			// Limpiar menú
			[] call FACTION_SELECTOR_clearMenu;
		},
		[_factionID, _factionName, _forSide, _color],
		10 - _forEachIndex,
		false,
		false
	]);
} forEach _availableForSide;

// Acción de cancelar
FACTION_SELECTOR_Menu pushBack (player addAction [
	"<t color='#888888'>--- CANCELAR ---</t>",
	{
		hint "Selección cancelada";
		[] call FACTION_SELECTOR_clearMenu;
	},
	[],
	-1,
	false,
	false
]);

// Guardar contexto
FACTION_SELECTOR_CurrentMenu = [_forSide, _availableForSide];

diag_log format ["[FACTION_SELECTOR] Menú mostrado para %1 con %2 facciones", _sideName, count _availableForSide];

// Función para limpiar el menú
FACTION_SELECTOR_clearMenu = {
	if (!isNil "FACTION_SELECTOR_Menu") then {
		{
			player removeAction _x;
		} forEach FACTION_SELECTOR_Menu;
		FACTION_SELECTOR_Menu = nil;
	};
	
	FACTION_SELECTOR_CurrentMenu = nil;
};

