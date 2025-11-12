/*
	════════════════════════════════════════════════════════════════
	SISTEMA DE SELECCIÓN DE FACCIONES DINÁMICO
	Basado en Dynamic Recon Ops
	════════════════════════════════════════════════════════════════
	
	Este sistema replica exactamente el funcionamiento de DRO:
	1. Escanea automáticamente todos los mods cargados
	2. Detecta todas las facciones disponibles
	3. Extrae clases de unidades y vehículos por tipo
	4. Permite selección dinámica de facciones
	
	Basado en:
	- DRO start.sqf (líneas 119-214): Detección de facciones
	- DRO defineFactionClasses.sqf: Extracción de clases
	- DRO populateStartupMenu.sqf: Menú de selección
*/

// ═════════════════════════════════════════════════════════════════
// PASO 1: DETECCIÓN AUTOMÁTICA DE FACCIONES
// (Basado en DRO start.sqf líneas 119-214)
// ═════════════════════════════════════════════════════════════════

diag_log "======================================";
diag_log "[FACTION_SELECTOR] Iniciando escaneo de facciones...";
diag_log "======================================";

// Arrays para almacenar facciones disponibles
SPAWN_availableFactionsData = [];
SPAWN_factionsWithUnits = [];

// Paso 1: Recorrer todos los vehículos en CfgVehicles y contar unidades por facción
{
	if (isNumber (configFile >> "CfgVehicles" >> (configName _x) >> "scope")) then {
		if (((configFile >> "CfgVehicles" >> (configName _x) >> "scope") call BIS_fnc_GetCfgData) == 2) then {
			_factionClass = ((configFile >> "CfgVehicles" >> (configName _x) >> "faction") call BIS_fnc_GetCfgData);
			
			// Solo contar infantería
			if ((configName _x) isKindOf "Man") then {
				_index = ([SPAWN_factionsWithUnits, _factionClass] call BIS_fnc_findInPairs);
				if (_index == -1) then {
					SPAWN_factionsWithUnits pushBack [_factionClass, 1];
				} else {
					SPAWN_factionsWithUnits set [_index, [((SPAWN_factionsWithUnits select _index) select 0), ((SPAWN_factionsWithUnits select _index) select 1) + 1]];
				}; 
			};		
		};
	};
} forEach ("(configName _x) isKindOf 'AllVehicles'" configClasses (configFile / "CfgVehicles"));

diag_log format ["[FACTION_SELECTOR] Facciones encontradas: %1", count SPAWN_factionsWithUnits];

// Paso 2: Filtrar facciones y extraer información
{
	_thisFaction = (_x select 0);
	_unitCount = (_x select 1);
	_thisSideNum = ((configFile >> "CfgFactionClasses" >> _thisFaction >> "side") call BIS_fnc_GetCfgData);
	
	if (!isNil "_thisSideNum") then {
		// Convertir side de texto a número si es necesario (como DRO)
		if (typeName _thisSideNum == "TEXT") then {
			if ((["west", _thisSideNum, false] call BIS_fnc_inString)) then {
				_thisSideNum = 1;
			};
			if ((["east", _thisSideNum, false] call BIS_fnc_inString)) then {
				_thisSideNum = 0;
			};
			if ((["guer", _thisSideNum, false] call BIS_fnc_inString) || (["ind", _thisSideNum, false] call BIS_fnc_inString)) then {
				_thisSideNum = 2;
			};
		};	
		
		// Solo incluir facciones con side válido y más de 1 unidad
		if (typeName _thisSideNum == "SCALAR") then {
			if (_thisSideNum <= 3 && _thisSideNum > -1 && _unitCount > 1) then {
				
				_thisFactionName = ((configFile >> "CfgFactionClasses" >> _thisFaction >> "displayName") call BIS_fnc_GetCfgData);			
				_thisFactionFlag = ((configfile >> "CfgFactionClasses" >> _thisFaction >> "flag") call BIS_fnc_GetCfgData);
				
				// Formato: [ID_Faccion, Nombre, Bandera, NumeroLado]
				// Este es el mismo formato que usa DRO
				if (!isNil "_thisFactionFlag") then {
					SPAWN_availableFactionsData pushBack [_thisFaction, _thisFactionName, _thisFactionFlag, _thisSideNum];
				} else {
					SPAWN_availableFactionsData pushBack [_thisFaction, _thisFactionName, "", _thisSideNum];
				};
				
				diag_log format ["[FACTION_SELECTOR] ✓ %1 (%2) | Lado: %3 | Unidades: %4", _thisFactionName, _thisFaction, _thisSideNum, _unitCount];
			};	
		};
	};
} forEach SPAWN_factionsWithUnits;

diag_log format ["[FACTION_SELECTOR] Total de facciones válidas: %1", count SPAWN_availableFactionsData];
publicVariable "SPAWN_availableFactionsData";

// ═════════════════════════════════════════════════════════════════
// PASO 2: EXTRACCIÓN DE CLASES DE UNIDADES Y VEHÍCULOS
// (Basado en DRO defineFactionClasses.sqf)
// ═════════════════════════════════════════════════════════════════

SPAWN_extractFactionClasses = {
	params ["_factionID"];
	
	diag_log format ["[FACTION_SELECTOR] Extrayendo clases para: %1", _factionID];
	
	private _infClasses = [];
	private _infClassesWeighted = [];
	private _infWeights = [];
	private _carClasses = [];
	private _carTurretClasses = [];
	private _apcClasses = [];
	private _tankClasses = [];
	
	private _cfgVeh = configFile >> "CfgVehicles";
	
	// Recorrer todos los vehículos (como DRO)
	{
		_cfgName = (configName _x);
		_cfgVehName = _cfgVeh >> _cfgName;
		_thisFac = ((_cfgVeh >> _cfgName >> "faction") call BIS_fnc_GetCfgData);
		
		// Verificar si pertenece a esta facción
		if ((toUpper _thisFac) == (toUpper _factionID)) then {
			
			// ─────────────────────────────────────────────────────
			// INFANTERÍA
			// ─────────────────────────────────────────────────────
			if (_cfgName isKindOf 'Man') then {
				// Excluir tipos no deseados (como DRO)
				if (
					!((["driver", _cfgName, false] call BIS_fnc_inString) ||
					(["diver", _cfgName, false] call BIS_fnc_inString) ||
					(["pilot", _cfgName, false] call BIS_fnc_inString) ||
					(["crew", _cfgName, false] call BIS_fnc_inString) ||
					(["survivor", _cfgName, false] call BIS_fnc_inString) ||
					(["unarmed", _cfgName, false] call BIS_fnc_inString) ||
					(["protagonist", _cfgName, false] call BIS_fnc_inString) ||
					(["_vr_", _cfgName, false] call BIS_fnc_inString) ||
					(["officer", _cfgName, false] call BIS_fnc_inString) ||
					(["commander", _cfgName, false] call BIS_fnc_inString))
				) then {
					// Solo unidades armadas
					if ((count ((_cfgVehName >> "weapons") call BIS_fnc_GetCfgData) > 2)) then {
						_infClasses pushBackUnique _cfgName;
						
						// Sistema de pesos como DRO (líneas 154-207)
						_thisWeight = 0.5; // peso por defecto
						
						// Verificar rol
						_thisRole = ((_cfgVehName >> "role") call BIS_fnc_GetCfgData);
						switch (_thisRole) do {
							case "Crewman": {_thisWeight = 0};
							case "Assistant": {_thisWeight = 0.15};
							case "CombatLifeSaver": {_thisWeight = 0.25};
							case "Grenadier": {_thisWeight = 0.25};
							case "MachineGunner": {_thisWeight = 0.25};
							case "Marksman": {_thisWeight = 0.1};
							case "MissileSpecialist": {_thisWeight = 0.15};
							case "Rifleman": {_thisWeight = 1};
							case "Sapper": {_thisWeight = 0.15};
							case "SpecialOperative": {_thisWeight = 0.15};
							default {_thisWeight = 0.5};
						};
						
						// Sobrescribir peso según nombre (como DRO)
						_thisDisplayName = ((_cfgVehName >> "displayName") call BIS_fnc_GetCfgData);
						{
							if (([(_x select 0), _thisDisplayName, false] call BIS_fnc_inString)) exitWith {
								_thisWeight = (_x select 1);
							};
						} forEach [
							["medic", 0.25], ["grenadier", 0.25], ["machine", 0.25],
							["auto", 0.25], ["sniper", 0.1], ["marksman", 0.1],
							["spotter", 0.1], ["sharp", 0.1], ["asst.", 0.15],
							["missile", 0.15], ["AT", 0.15], ["AA", 0.15],
							["special", 0.15], ["leader", 0.15], ["gunner", 0.15],
							["ammo", 0.15], ["uav", 0.1], ["engineer", 0.1]
						];
						
						_infClassesWeighted pushBack _cfgName;
						_infWeights pushBack _thisWeight;
					};
				};
			}
			
			// ─────────────────────────────────────────────────────
			// VEHÍCULOS TERRESTRES
			// ─────────────────────────────────────────────────────
			else {
				if (_cfgName isKindOf 'LandVehicle') then {
					_edSubcat = ((_cfgVehName >> "editorSubcategory") call BIS_fnc_GetCfgData);
					
					// COCHES (como DRO líneas 213-246)
					if (_cfgName isKindOf 'Car') then {
						if (!isNil "_edSubcat") then {
							if (_edSubcat == "EdSubcat_APCs") then {
								_apcClasses pushBackUnique _cfgName;
							} else {
								_carClasses pushBackUnique _cfgName;
								// Detectar si tiene torreta
								if (count ([_cfgName, false] call BIS_fnc_allTurrets) > 0) then {
									_carTurretClasses pushBackUnique _cfgName;
								};
							};
						} else {
							_carClasses pushBackUnique _cfgName;
							if (count ([_cfgName, false] call BIS_fnc_allTurrets) > 0) then {
								_carTurretClasses pushBackUnique _cfgName;
							};
						};
					} else {
						// TANQUES Y APCS (como DRO líneas 288-303)
						if (_cfgName isKindOf 'Tank') then {
							if (!isNil "_edSubcat") then {
								// Excluir artillería y AA
								if (
									!(["artillery", _edSubcat, false] call BIS_fnc_inString) &&
									!(["aa", _edSubcat, false] call BIS_fnc_inString) &&
									!(["drone", _edSubcat, false] call BIS_fnc_inString)
								) then {
									if (_edSubcat == "EdSubcat_APCs") then {
										_apcClasses pushBackUnique _cfgName;
									} else {
										_tankClasses pushBackUnique _cfgName;
									};
								};
							} else {
								_tankClasses pushBackUnique _cfgName;
							};
						};
					};
				};
			};
		};
	} forEach ("(getNumber (_x >> 'scope') == 2)" configClasses (configFile / "CfgVehicles"));
	
	diag_log format ["[FACTION_SELECTOR]   → Infantería: %1 clases", count _infClasses];
	diag_log format ["[FACTION_SELECTOR]   → Vehículos: %1 clases", count _carClasses];
	diag_log format ["[FACTION_SELECTOR]   → APCs: %1 clases", count _apcClasses];
	diag_log format ["[FACTION_SELECTOR]   → Tanques: %1 clases", count _tankClasses];
	
	// Retornar hashmap con las clases (compatible con sistema actual)
	createHashMapFromArray [
		["infantry", _infClasses],
		["infantryWeighted", _infClassesWeighted],
		["infantryWeights", _infWeights],
		["cars", _carClasses],
		["carsTurret", _carTurretClasses],
		["apcs", _apcClasses],
		["tanks", _tankClasses]
	]
};

// ═════════════════════════════════════════════════════════════════
// PASO 3: VARIABLES GLOBALES DE SELECCIÓN
// ═════════════════════════════════════════════════════════════════

// Facciones seleccionadas actualmente (por defecto: vanilla)
if (isNil "SPAWN_SelectedFaction_OPFOR") then {
	SPAWN_SelectedFaction_OPFOR = "OPF_F"; // CSAT
};
if (isNil "SPAWN_SelectedFaction_BLUFOR") then {
	SPAWN_SelectedFaction_BLUFOR = "BLU_F"; // NATO
};
if (isNil "SPAWN_SelectedFaction_INDEP") then {
	SPAWN_SelectedFaction_INDEP = "IND_F"; // AAF
};
if (isNil "SPAWN_SelectedFaction_CIVILIAN") then {
	SPAWN_SelectedFaction_CIVILIAN = "CIV_F"; // Civilians
};

// Cache para clases extraídas (evita procesar múltiples veces)
SPAWN_FactionClassesCache = createHashMapFromArray [];

// ═════════════════════════════════════════════════════════════════
// PASO 4: MENÚ DE SELECCIÓN DE FACCIÓN
// (Basado en DRO populateStartupMenu.sqf líneas 126-254)
// ═════════════════════════════════════════════════════════════════

SPAWN_showFactionMenu = {
	params [["_forSide", east]];
	
	// Convertir side a número (como DRO)
	private _sideNum = switch (_forSide) do {
		case east: {0};
		case west: {1};
		case resistance: {2};
		case civilian: {3};
		default {0};
	};
	
	// Filtrar facciones por lado
	private _availableForSide = [];
	{
		_x params ["_factionID", "_factionName", "_factionFlag", "_thisSideNum"];
		
		if (_thisSideNum == _sideNum) then {
			// Determinar color según lado (como DRO líneas 212-225)
			private _color = switch (_thisSideNum) do {
				case 0: {"#FF4444"}; // Rojo para OPFOR
				case 1: {"#4444FF"}; // Azul para BLUFOR
				case 2: {"#44FF44"}; // Verde para INDEP
				case 3: {"#FFFFFF"}; // Blanco para CIV
				default {"#FFFFFF"};
			};
			
			_availableForSide pushBack [_factionID, _factionName, _factionFlag, _color];
		};
	} forEach SPAWN_availableFactionsData;
	
	if (count _availableForSide == 0) exitWith {
		hint parseText format ["<t color='#FF4444' size='1.2'>✗ NO HAY FACCIONES DISPONIBLES</t><br/><br/>Lado: %1", _forSide];
	};
	
	// Crear hint con lista de facciones (estilo DRO)
	private _sideName = switch (_forSide) do {
		case east: {"OPFOR"};
		case west: {"BLUFOR"};
		case resistance: {"INDEPENDENT"};
		case civilian: {"CIVILIAN"};
		default {"UNKNOWN"};
	};
	
	private _menuText = format [
		"<t size='1.5' color='#00FF00' shadow='2'>═══════════════════</t><br/>" +
		"<t size='1.4' color='#FFAA00' shadow='2'>SELECCIONAR FACCIÓN</t><br/>" +
		"<t size='1.5' color='#00FF00' shadow='2'>═══════════════════</t><br/><br/>" +
		"<t size='1' color='#CCCCCC'>Lado: </t><t size='1.1' color='#FFFF00'>%1</t><br/><br/>",
		_sideName
	];
	
	// Listar facciones
	{
		_x params ["_factionID", "_factionName", "_factionFlag", "_color"];
		_menuText = _menuText + format [
			"<t size='1' color='%3'>%1</t>. <t size='1.1' color='%3'>%2</t><br/>",
			_forEachIndex + 1,
			_factionName,
			_color
		];
	} forEach _availableForSide;
	
	_menuText = _menuText + "<br/><t size='0.9' color='#888888'>Usa el chat del lado para seleccionar (1-" + str(count _availableForSide) + ")</t>";
	
	hint parseText _menuText;
	
	// Guardar contexto actual
	SPAWN_CurrentFactionMenu = [_forSide, _availableForSide];
	
	diag_log format ["[FACTION_SELECTOR] Menú mostrado para %1 con %2 facciones", _forSide, count _availableForSide];
};

// ═════════════════════════════════════════════════════════════════
// FUNCIÓN: Seleccionar Facción por Número
// ═════════════════════════════════════════════════════════════════

SPAWN_selectFactionByNumber = {
	params ["_number"];
	
	if (isNil "SPAWN_CurrentFactionMenu") exitWith {
		hint parseText "<t color='#FF4444'>No hay menú de facción activo</t><br/><br/>Usa primero: [east/west/resistance] call SPAWN_showFactionMenu";
	};
	
	SPAWN_CurrentFactionMenu params ["_forSide", "_availableForSide"];
	
	private _index = _number - 1;
	
	if (_index < 0 || _index >= count _availableForSide) exitWith {
		hint parseText format [
			"<t color='#FF4444' size='1.2'>✗ NÚMERO INVÁLIDO</t><br/><br/>" +
			"<t size='1'>Número: </t><t color='#FFAA00' size='1.1'>%1</t><br/>" +
			"<t size='1'>Rango válido: </t><t color='#00FF00' size='1.1'>1-%2</t>",
			_number,
			count _availableForSide
		];
	};
	
	private _selected = _availableForSide select _index;
	_selected params ["_factionID", "_factionName", "_factionFlag", "_color"];
	
	// Guardar selección (como DRO okAO.sqf líneas 10-34)
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
	
	hint parseText format [
		"<t size='1.5' color='#00FF00' shadow='2'>✓ FACCIÓN SELECCIONADA</t><br/><br/>" +
		"<t size='1.2' color='%3'>%1</t><br/>" +
		"<t size='0.9' color='#888888'>ID: %2</t>",
		_factionName,
		_factionID,
		_color
	];
	
	SPAWN_CurrentFactionMenu = nil;
	
	diag_log format ["[FACTION_SELECTOR] Facción seleccionada: %1 (%2) para %3", _factionName, _factionID, _forSide];
};

// ═════════════════════════════════════════════════════════════════
// FUNCIÓN: Obtener Clases de Facción Seleccionada
// ═════════════════════════════════════════════════════════════════

SPAWN_getFactionClasses = {
	params ["_side"];
	
	// Obtener facción seleccionada para este lado
	private _factionID = switch (_side) do {
		case east: {SPAWN_SelectedFaction_OPFOR};
		case west: {SPAWN_SelectedFaction_BLUFOR};
		case resistance: {SPAWN_SelectedFaction_INDEP};
		case civilian: {SPAWN_SelectedFaction_CIVILIAN};
		default {""};
	};
	
	if (_factionID == "") exitWith {
		diag_log format ["[FACTION_SELECTOR] ERROR: No hay facción seleccionada para %1", _side];
		createHashMapFromArray [
			["infantry", []],
			["infantryWeighted", []],
			["infantryWeights", []],
			["cars", []],
			["carsTurret", []],
			["apcs", []],
			["tanks", []]
		]
	};
	
	// Verificar caché
	private _cached = SPAWN_FactionClassesCache get _factionID;
	if (!isNil "_cached") exitWith {
		diag_log format ["[FACTION_SELECTOR] Usando caché para facción: %1", _factionID];
		_cached
	};
	
	// Extraer clases
	private _classes = [_factionID] call SPAWN_extractFactionClasses;
	
	// Guardar en caché
	SPAWN_FactionClassesCache set [_factionID, _classes];
	
	_classes
};

// ═════════════════════════════════════════════════════════════════
// INICIALIZACIÓN COMPLETA
// ═════════════════════════════════════════════════════════════════

diag_log "======================================";
diag_log "[FACTION_SELECTOR] Sistema inicializado correctamente";
diag_log format ["[FACTION_SELECTOR] OPFOR por defecto: %1", SPAWN_SelectedFaction_OPFOR];
diag_log format ["[FACTION_SELECTOR] BLUFOR por defecto: %1", SPAWN_SelectedFaction_BLUFOR];
diag_log format ["[FACTION_SELECTOR] INDEP por defecto: %1", SPAWN_SelectedFaction_INDEP];
diag_log format ["[FACTION_SELECTOR] CIVILIAN por defecto: %1", SPAWN_SelectedFaction_CIVILIAN];
diag_log "======================================";

// Mostrar mensaje de bienvenida
if (hasInterface) then {
	hint parseText (
		"<t size='1.5' color='#00FF00' shadow='2'>✓ SISTEMA DE FACCIONES CARGADO</t><br/><br/>" +
		"<t size='1' color='#CCCCCC'>Facciones detectadas: </t><t size='1.1' color='#FFAA00'>" + str(count SPAWN_availableFactionsData) + "</t><br/><br/>" +
		"<t size='0.9' color='#888888'>Para cambiar facción usa:<br/>" +
		"[east/west/resistance] call SPAWN_showFactionMenu</t>"
	);
};

/*
═════════════════════════════════════════════════════════════════
GUÍA DE USO RÁPIDO
═════════════════════════════════════════════════════════════════

1. MOSTRAR MENÚ DE SELECCIÓN:
   [east] call SPAWN_showFactionMenu;
   [west] call SPAWN_showFactionMenu;
   [resistance] call SPAWN_showFactionMenu;
   [civilian] call SPAWN_showFactionMenu;

2. SELECCIONAR FACCIÓN (después de ver el menú):
   [1] call SPAWN_selectFactionByNumber;  // Primera facción
   [2] call SPAWN_selectFactionByNumber;  // Segunda facción
   etc.

3. OBTENER CLASES DE LA FACCIÓN ACTUAL:
   private _classes = [east] call SPAWN_getFactionClasses;
   _classes get "infantry"  // Array de clases de infantería
   _classes get "cars"      // Array de vehículos ligeros
   _classes get "apcs"      // Array de APCs
   _classes get "tanks"     // Array de tanques

═════════════════════════════════════════════════════════════════
*/
