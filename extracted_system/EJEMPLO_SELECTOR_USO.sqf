/*
═══════════════════════════════════════════════════════════════════════
   EJEMPLOS DE USO DEL SELECTOR DE FACCIONES DINÁMICO
   
   Basado en el sistema de Dynamic Recon Ops
═══════════════════════════════════════════════════════════════════════

Este archivo contiene ejemplos prácticos de cómo usar el selector de
facciones dinámico en tu misión.
*/

// ═══════════════════════════════════════════════════════════════════
// EJEMPLO 1: VER TODAS LAS FACCIONES DETECTADAS
// ═══════════════════════════════════════════════════════════════════

hint parseText format [
	"<t size='1.3' color='#00FF00'>FACCIONES DETECTADAS</t><br/><br/>" +
	"<t size='1'>Total: </t><t size='1.1' color='#FFAA00'>%1</t><br/><br/>" +
	"<t size='0.9' color='#888888'>Ver detalles en RPT log</t>",
	count SPAWN_availableFactionsData
];

// Mostrar en RPT log
{
	_x params ["_factionID", "_factionName", "_factionFlag", "_sideNum"];
	private _sideName = switch (_sideNum) do {
		case 0: {"OPFOR"};
		case 1: {"BLUFOR"};
		case 2: {"INDEP"};
		case 3: {"CIV"};
		default {"UNKNOWN"};
	};
	diag_log format ["[EJEMPLO] %1: %2 (%3)", _sideName, _factionName, _factionID];
} forEach SPAWN_availableFactionsData;

// ═══════════════════════════════════════════════════════════════════
// EJEMPLO 2: MOSTRAR MENÚ DE SELECCIÓN PARA OPFOR
// ═══════════════════════════════════════════════════════════════════

// Mostrar menú de facciones OPFOR
[east] call SPAWN_showFactionMenu;

// Después de ver el menú, seleccionar la facción número 2:
// [2] call SPAWN_selectFactionByNumber;

// ═══════════════════════════════════════════════════════════════════
// EJEMPLO 3: CAMBIAR MÚLTIPLES FACCIONES
// ═══════════════════════════════════════════════════════════════════

// 1. Seleccionar OPFOR
[east] call SPAWN_showFactionMenu;
// Ejecutar: [1] call SPAWN_selectFactionByNumber;

// 2. Seleccionar BLUFOR
[west] call SPAWN_showFactionMenu;
// Ejecutar: [3] call SPAWN_selectFactionByNumber;

// 3. Seleccionar INDEPENDENT
[resistance] call SPAWN_showFactionMenu;
// Ejecutar: [2] call SPAWN_selectFactionByNumber;

// ═══════════════════════════════════════════════════════════════════
// EJEMPLO 4: ESTABLECER FACCIÓN DIRECTAMENTE (SIN MENÚ)
// ═══════════════════════════════════════════════════════════════════

// Si conoces el ID de la facción, puedes establecerla directamente

// Establecer OPFOR como RHS Russians
SPAWN_SelectedFaction_OPFOR = "rhs_faction_msv";
publicVariable "SPAWN_SelectedFaction_OPFOR";

// Establecer BLUFOR como 3CB BAF
SPAWN_SelectedFaction_BLUFOR = "UK3CB_BAF_Faction_Army_Desert";
publicVariable "SPAWN_SelectedFaction_BLUFOR";

// Establecer INDEPENDENT como Takistan
SPAWN_SelectedFaction_INDEP = "UK3CB_TKA_I";
publicVariable "SPAWN_SelectedFaction_INDEP";

hint parseText (
	"<t size='1.3' color='#00FF00'>✓ FACCIONES ESTABLECIDAS</t><br/><br/>" +
	"<t size='1'>OPFOR: </t><t color='#FF4444'>RHS Russians</t><br/>" +
	"<t size='1'>BLUFOR: </t><t color='#4444FF'>3CB BAF</t><br/>" +
	"<t size='1'>INDEP: </t><t color='#44FF44'>Takistan</t>"
);

// ═══════════════════════════════════════════════════════════════════
// EJEMPLO 5: OBTENER Y USAR CLASES DE FACCIÓN
// ═══════════════════════════════════════════════════════════════════

// Obtener todas las clases de la facción OPFOR actual
private _opforClasses = [east] call SPAWN_getFactionClasses;

// Ver qué unidades hay disponibles
hint parseText format [
	"<t size='1.3' color='#FF4444'>CLASES OPFOR</t><br/><br/>" +
	"<t size='1'>Infantería: </t><t color='#FFAA00'>%1</t><br/>" +
	"<t size='1'>Vehículos: </t><t color='#FFAA00'>%2</t><br/>" +
	"<t size='1'>APCs: </t><t color='#FFAA00'>%3</t><br/>" +
	"<t size='1'>Tanques: </t><t color='#FFAA00'>%4</t>",
	count (_opforClasses get "infantry"),
	count (_opforClasses get "cars"),
	count (_opforClasses get "apcs"),
	count (_opforClasses get "tanks")
];

// Listar todas las unidades de infantería en RPT log
{
	diag_log format ["[EJEMPLO] Infantería OPFOR: %1", _x];
} forEach (_opforClasses get "infantry");

// ═══════════════════════════════════════════════════════════════════
// EJEMPLO 6: SPAWN USANDO FACCIONES DINÁMICAS
// ═══════════════════════════════════════════════════════════════════

// Las funciones de spawn YA usan automáticamente el sistema dinámico
// Solo necesitas llamarlas normalmente

// Spawn de grupo de infantería (usará la facción OPFOR seleccionada)
[getPos player, east, [4,6], true, 200] remoteExec ["FN_spawnInfantryGroup", 2];

// Spawn de vehículo (usará la facción OPFOR seleccionada)
[getPos player, east, "CAR", true, 800] remoteExec ["FN_spawnVehiclePatrol", 2];

// ═══════════════════════════════════════════════════════════════════
// EJEMPLO 7: SPAWN MANUAL CON CLASES ESPECÍFICAS
// ═══════════════════════════════════════════════════════════════════

// Si quieres control total, puedes obtener las clases y crear unidades manualmente

private _classes = [east] call SPAWN_getFactionClasses;
private _infClasses = _classes get "infantryWeighted";
private _infWeights = _classes get "infantryWeights";

// Crear un grupo personalizado
private _group = createGroup east;
private _pos = getPos player;

// Spawn 5 unidades usando el sistema de pesos
for "_i" from 1 to 5 do {
	private _unitClass = [_infClasses, _infWeights] call BIS_fnc_selectRandomWeighted;
	private _unit = _group createUnit [_unitClass, _pos, [], 5, "FORM"];
};

hint format ["Grupo creado con %1 unidades", count units _group];

// ═══════════════════════════════════════════════════════════════════
// EJEMPLO 8: VERIFICAR QUÉ FACCIÓN ESTÁ ACTIVA
// ═══════════════════════════════════════════════════════════════════

// Ver qué facciones están seleccionadas actualmente
hint parseText format [
	"<t size='1.3' color='#00FF00'>FACCIONES ACTIVAS</t><br/><br/>" +
	"<t size='1' color='#FF4444'>OPFOR:</t> <t color='#FFFFFF'>%1</t><br/>" +
	"<t size='1' color='#4444FF'>BLUFOR:</t> <t color='#FFFFFF'>%2</t><br/>" +
	"<t size='1' color='#44FF44'>INDEP:</t> <t color='#FFFFFF'>%3</t>",
	SPAWN_SelectedFaction_OPFOR,
	SPAWN_SelectedFaction_BLUFOR,
	SPAWN_SelectedFaction_INDEP
];

// Obtener nombres legibles
private _opforName = "";
private _bluforName = "";
private _indepName = "";

{
	_x params ["_factionID", "_factionName", "_factionFlag", "_sideNum"];
	
	if (_factionID == SPAWN_SelectedFaction_OPFOR) then {
		_opforName = _factionName;
	};
	if (_factionID == SPAWN_SelectedFaction_BLUFOR) then {
		_bluforName = _factionName;
	};
	if (_factionID == SPAWN_SelectedFaction_INDEP) then {
		_indepName = _factionName;
	};
} forEach SPAWN_availableFactionsData;

hint parseText format [
	"<t size='1.3' color='#00FF00'>FACCIONES ACTIVAS</t><br/><br/>" +
	"<t size='1' color='#FF4444'>OPFOR:</t> <t color='#FFAA00'>%1</t><br/>" +
	"<t size='1' color='#4444FF'>BLUFOR:</t> <t color='#FFAA00'>%2</t><br/>" +
	"<t size='1' color='#44FF44'>INDEP:</t> <t color='#FFAA00'>%3</t>",
	_opforName,
	_bluforName,
	_indepName
];

// ═══════════════════════════════════════════════════════════════════
// EJEMPLO 9: CREAR ACCIONES PERSONALIZADAS PARA CAMBIAR FACCIONES
// ═══════════════════════════════════════════════════════════════════

// Agregar acción al jugador para abrir menú de facciones OPFOR
player addAction [
	"<t color='#FF4444'>🔧 Cambiar Facción OPFOR</t>",
	{
		[east] call SPAWN_showFactionMenu;
	},
	nil,
	10,
	false,
	true
];

// Agregar acción para BLUFOR
player addAction [
	"<t color='#4444FF'>🔧 Cambiar Facción BLUFOR</t>",
	{
		[west] call SPAWN_showFactionMenu;
	},
	nil,
	9,
	false,
	true
];

// Agregar acción para INDEPENDENT
player addAction [
	"<t color='#44FF44'>🔧 Cambiar Facción INDEPENDENT</t>",
	{
		[resistance] call SPAWN_showFactionMenu;
	},
	nil,
	8,
	false,
	true
];

// ═══════════════════════════════════════════════════════════════════
// EJEMPLO 10: GUARDAR/CARGAR FACCIONES EN PERFIL
// ═══════════════════════════════════════════════════════════════════

// GUARDAR facciones seleccionadas en el perfil del jugador
profileNamespace setVariable ["MiMision_OPFOR_Faction", SPAWN_SelectedFaction_OPFOR];
profileNamespace setVariable ["MiMision_BLUFOR_Faction", SPAWN_SelectedFaction_BLUFOR];
profileNamespace setVariable ["MiMision_INDEP_Faction", SPAWN_SelectedFaction_INDEP];
saveProfileNamespace;

hint "Facciones guardadas en perfil";

// CARGAR facciones guardadas al inicio de la misión (poner en init.sqf)
if (!isNil {profileNamespace getVariable "MiMision_OPFOR_Faction"}) then {
	SPAWN_SelectedFaction_OPFOR = profileNamespace getVariable "MiMision_OPFOR_Faction";
	publicVariable "SPAWN_SelectedFaction_OPFOR";
};

if (!isNil {profileNamespace getVariable "MiMision_BLUFOR_Faction"}) then {
	SPAWN_SelectedFaction_BLUFOR = profileNamespace getVariable "MiMision_BLUFOR_Faction";
	publicVariable "SPAWN_SelectedFaction_BLUFOR";
};

if (!isNil {profileNamespace getVariable "MiMision_INDEP_Faction"}) then {
	SPAWN_SelectedFaction_INDEP = profileNamespace getVariable "MiMision_INDEP_Faction";
	publicVariable "SPAWN_SelectedFaction_INDEP";
};

// ═══════════════════════════════════════════════════════════════════
// EJEMPLO 11: SISTEMA DE RADIO HINT PARA CAMBIAR FACCIONES
// ═══════════════════════════════════════════════════════════════════

// Función personalizada para mostrar menú con radio hint
CUSTOM_showFactionRadioMenu = {
	params ["_side"];
	
	private _sideNum = switch (_side) do {
		case east: {0};
		case west: {1};
		case resistance: {2};
		default {0};
	};
	
	private _availableFactions = [];
	{
		_x params ["_factionID", "_factionName", "_factionFlag", "_thisSideNum"];
		if (_thisSideNum == _sideNum) then {
			_availableFactions pushBack [_factionID, _factionName];
		};
	} forEach SPAWN_availableFactionsData;
	
	// Usar systemChat en lugar de hint
	systemChat "═══ FACCIONES DISPONIBLES ═══";
	{
		_x params ["_factionID", "_factionName"];
		systemChat format ["%1. %2", _forEachIndex + 1, _factionName];
	} forEach _availableFactions;
	systemChat "═══════════════════════════════";
	
	SPAWN_CurrentFactionMenu = [_side, _availableFactions];
};

// Uso
[east] call CUSTOM_showFactionRadioMenu;

// ═══════════════════════════════════════════════════════════════════
// FIN DE EJEMPLOS
// ═══════════════════════════════════════════════════════════════════

