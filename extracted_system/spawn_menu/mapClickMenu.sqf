/*
	Script: mapClickMenu
	Descripción: Sistema de menú contextual para colocar unidades/objetos haciendo clic en el mapa
	
	Uso:
		[] execVM "extracted_system\spawn_menu\mapClickMenu.sqf";
*/

// Variable global para controlar el estado del menú
if (isNil "SPAWN_MENU_Active") then {
	SPAWN_MENU_Active = false;
};

// Función para activar/desactivar el menú
SPAWN_toggleMenu = {
	if (SPAWN_MENU_Active) then {
		// Desactivar menú
		SPAWN_MENU_Active = false;
		findDisplay 12 displayRemoveEventHandler ["MouseButtonDown", SPAWN_MENU_MapClickHandler];
		hint "Menú de spawn DESACTIVADO";
		diag_log "[SPAWN_MENU] Menú desactivado";
	} else {
		// Activar menú
		SPAWN_MENU_Active = true;
		hint "Menú de spawn ACTIVADO\nHaz clic derecho en el mapa para abrir el menú";
		diag_log "[SPAWN_MENU] Menú activado";
		
		// Agregar handler de clic en el mapa
		waitUntil {!isNull (findDisplay 12)};
		SPAWN_MENU_MapClickHandler = (findDisplay 12) displayAddEventHandler ["MouseButtonDown", {
			params ["_displayOrControl", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
			
			// Solo procesar clic derecho (botón 1)
			if (_button == 1 && SPAWN_MENU_Active) then {
				// Obtener posición del mapa donde se hizo clic
				private _worldPos = (findDisplay 12 displayCtrl 51) ctrlMapScreenToWorld [_xPos, _yPos];
				_worldPos set [2, 0];
				
				// Guardar posición para usar en las opciones del menú
				SPAWN_MENU_ClickPos = _worldPos;
				
				// Mostrar menú contextual
				[_worldPos] call SPAWN_showContextMenu;
				
				true // Prevenir el menú por defecto del mapa
			};
		}];
	};
};

// Función para mostrar el menú contextual
SPAWN_showContextMenu = {
	params ["_pos"];
	
	// Limpiar menú anterior si existe
	if (!isNil "SPAWN_MENU_ContextMenu") then {
		{
			player removeAction _x;
		} forEach SPAWN_MENU_ContextMenu;
	};
	
	SPAWN_MENU_ContextMenu = [];
	
	// Crear marcador temporal para visualizar la posición
	if (!isNil "SPAWN_MENU_TempMarker") then {
		deleteMarker SPAWN_MENU_TempMarker;
	};
	SPAWN_MENU_TempMarker = createMarker ["spawnMenuTemp", _pos];
	SPAWN_MENU_TempMarker setMarkerShape "ICON";
	SPAWN_MENU_TempMarker setMarkerType "mil_dot";
	SPAWN_MENU_TempMarker setMarkerColor "ColorYellow";
	SPAWN_MENU_TempMarker setMarkerText "Posición de spawn";
	
	// Hint con información
	hint format [
		"MENÚ DE SPAWN\n\nPosición: %1\n\nUsa el menú de acción (tecla de acción) para seleccionar qué generar",
		mapGridPosition _pos
	];
	
	// ===== MENÚ PRINCIPAL =====
	
	// --- ZONAS COMPLETAS ---
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"<t color='#FF00FF' size='1.1'>🏭 ZONAS COMPLETAS</t>",
		{},
		nil,
		20,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ Zona Pequeña (2 patrullas, 1 vehículo, 1 guarnición)",
		{
			[SPAWN_MENU_ClickPos, east, "SMALL"] remoteExec ["FN_spawnCompoundArea", 2];
			hint "Generando zona pequeña...";
			[] call SPAWN_clearMenu;
		},
		nil,
		19,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ Zona Mediana (3 patrullas, 2 vehículos, 2 guarniciones)",
		{
			[SPAWN_MENU_ClickPos, east, "MEDIUM"] remoteExec ["FN_spawnCompoundArea", 2];
			hint "Generando zona mediana...";
			[] call SPAWN_clearMenu;
		},
		nil,
		18,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ Zona Grande (5 patrullas, 3 vehículos, 3 guarniciones)",
		{
			[SPAWN_MENU_ClickPos, east, "LARGE"] remoteExec ["FN_spawnCompoundArea", 2];
			hint "Generando zona grande...";
			[] call SPAWN_clearMenu;
		},
		nil,
		17,
		false,
		false
	]);
	
	// --- FOB (FORWARD OPERATING BASE) ---
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"<t color='#00FFFF' size='1.1'>🏰 FOB (BASE MILITAR)</t>",
		{},
		nil,
		16,
		false,
		false
	]);
	
	// FOB Enemigo Ocupado
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ 🔴 FOB Enemigo OCUPADO (Pequeño)",
		{
			[SPAWN_MENU_ClickPos, east, "SMALL", true, "PRISTINE"] remoteExec ["FN_spawnFOB", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		15.9,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ 🔴 FOB Enemigo OCUPADO (Mediano)",
		{
			[SPAWN_MENU_ClickPos, east, "MEDIUM", true, "PRISTINE"] remoteExec ["FN_spawnFOB", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		15.8,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ 🔴 FOB Enemigo OCUPADO (Grande)",
		{
			[SPAWN_MENU_ClickPos, east, "LARGE", true, "PRISTINE"] remoteExec ["FN_spawnFOB", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		15.7,
		false,
		false
	]);
	
	// FOB Enemigo Abandonado
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ ⚫ FOB Enemigo ABANDONADO (Perfecto)",
		{
			[SPAWN_MENU_ClickPos, east, "MEDIUM", false, "PRISTINE"] remoteExec ["FN_spawnFOB", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		15.6,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ ⚫ FOB Enemigo ABANDONADO (Dañado)",
		{
			[SPAWN_MENU_ClickPos, east, "MEDIUM", false, "DAMAGED"] remoteExec ["FN_spawnFOB", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		15.5,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ ⚫ FOB Enemigo ABANDONADO (Ruinas)",
		{
			[SPAWN_MENU_ClickPos, east, "MEDIUM", false, "RUINED"] remoteExec ["FN_spawnFOB", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		15.4,
		false,
		false
	]);
	
	// FOB Aliado Ocupado
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ 🔵 FOB Aliado OCUPADO (Pequeño)",
		{
			[SPAWN_MENU_ClickPos, west, "SMALL", true, "PRISTINE"] remoteExec ["FN_spawnFOB", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		15.3,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ 🔵 FOB Aliado OCUPADO (Mediano)",
		{
			[SPAWN_MENU_ClickPos, west, "MEDIUM", true, "PRISTINE"] remoteExec ["FN_spawnFOB", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		15.2,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ 🔵 FOB Aliado OCUPADO (Grande)",
		{
			[SPAWN_MENU_ClickPos, west, "LARGE", true, "PRISTINE"] remoteExec ["FN_spawnFOB", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		15.1,
		false,
		false
	]);
	
	// FOB Aliado Abandonado
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ ⚪ FOB Aliado ABANDONADO (Perfecto)",
		{
			[SPAWN_MENU_ClickPos, west, "MEDIUM", false, "PRISTINE"] remoteExec ["FN_spawnFOB", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		15.0,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ ⚪ FOB Aliado ABANDONADO (Dañado)",
		{
			[SPAWN_MENU_ClickPos, west, "MEDIUM", false, "DAMAGED"] remoteExec ["FN_spawnFOB", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		14.9,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ ⚪ FOB Aliado ABANDONADO (Ruinas)",
		{
			[SPAWN_MENU_ClickPos, west, "MEDIUM", false, "RUINED"] remoteExec ["FN_spawnFOB", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		14.8,
		false,
		false
	]);
	
	// --- INFANTERÍA ---
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"<t color='#FF4444'>INFANTERÍA</t>",
		{},
		nil,
		10,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ Escuadra pequeña (2-4 unidades)",
		{
			[SPAWN_MENU_ClickPos, east, [2,4], true, 200] remoteExec ["FN_spawnInfantryGroup", 2];
			hint "Escuadra pequeña generada";
			[] call SPAWN_clearMenu;
		},
		nil,
		9,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ Escuadra mediana (4-6 unidades)",
		{
			[SPAWN_MENU_ClickPos, east, [4,6], true, 300] remoteExec ["FN_spawnInfantryGroup", 2];
			hint "Escuadra mediana generada";
			[] call SPAWN_clearMenu;
		},
		nil,
		9,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ Escuadra grande (6-8 unidades)",
		{
			[SPAWN_MENU_ClickPos, east, [6,8], true, 400] remoteExec ["FN_spawnInfantryGroup", 2];
			hint "Escuadra grande generada";
			[] call SPAWN_clearMenu;
		},
		nil,
		9,
		false,
		false
	]);
	
	// --- VEHÍCULOS ---
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"<t color='#44FF44'>VEHÍCULOS</t>",
		{},
		nil,
		8,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ Vehículo ligero (MRAP)",
		{
			[SPAWN_MENU_ClickPos, east, "CAR", true, 800] remoteExec ["FN_spawnVehiclePatrol", 2];
			hint "Vehículo ligero generado";
			[] call SPAWN_clearMenu;
		},
		nil,
		7,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ Transporte blindado (APC)",
		{
			[SPAWN_MENU_ClickPos, east, "APC", true, 1000] remoteExec ["FN_spawnVehiclePatrol", 2];
			hint "APC generado";
			[] call SPAWN_clearMenu;
		},
		nil,
		7,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ Tanque",
		{
			[SPAWN_MENU_ClickPos, east, "TANK", true, 1200] remoteExec ["FN_spawnVehiclePatrol", 2];
			hint "Tanque generado";
			[] call SPAWN_clearMenu;
		},
		nil,
		7,
		false,
		false
	]);
	
	// --- ESTRUCTURAS ---
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"<t color='#FFAA00'>ESTRUCTURAS</t>",
		{},
		nil,
		6,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ Roadblock Pequeño (barreras simples, 1 torre)",
		{
			[SPAWN_MENU_ClickPos, east, "SMALL"] remoteExec ["FN_spawnRoadblock", 2];
			hint "Roadblock pequeño generado";
			[] call SPAWN_clearMenu;
		},
		nil,
		5,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ Roadblock Grande (barreras levadizas, 2 torres, bunkers)",
		{
			[SPAWN_MENU_ClickPos, east, "LARGE"] remoteExec ["FN_spawnRoadblock", 2];
			hint "Roadblock grande generado";
			[] call SPAWN_clearMenu;
		},
		nil,
		5,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ Campamento pequeño",
		{
			[SPAWN_MENU_ClickPos, east, "SMALL"] remoteExec ["FN_spawnCamp", 2];
			hint "Campamento pequeño generado";
			[] call SPAWN_clearMenu;
		},
		nil,
		5,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ Campamento mediano",
		{
			[SPAWN_MENU_ClickPos, east, "MEDIUM"] remoteExec ["FN_spawnCamp", 2];
			hint "Campamento mediano generado";
			[] call SPAWN_clearMenu;
		},
		nil,
		5,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ Campamento grande",
		{
			[SPAWN_MENU_ClickPos, east, "LARGE"] remoteExec ["FN_spawnCamp", 2];
			hint "Campamento grande generado";
			[] call SPAWN_clearMenu;
		},
		nil,
		5,
		false,
		false
	]);
	
	// --- CIVILES ---
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"<t color='#4444FF'>CIVILES</t>",
		{},
		nil,
		4,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ Población civil (5 civiles, área 200m)",
		{
			[SPAWN_MENU_ClickPos, 200, 5] remoteExec ["FN_spawnCivilians", 2];
			hint "Población civil generada";
			[] call SPAWN_clearMenu;
		},
		nil,
		3,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ Población civil (10 civiles, área 400m)",
		{
			[SPAWN_MENU_ClickPos, 400, 10] remoteExec ["FN_spawnCivilians", 2];
			hint "Población civil grande generada";
			[] call SPAWN_clearMenu;
		},
		nil,
		3,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ Vehículo civil",
		{
			[SPAWN_MENU_ClickPos, true, 600] remoteExec ["FN_spawnCivilianVehicle", 2];
			hint "Vehículo civil generado";
			[] call SPAWN_clearMenu;
		},
		nil,
		3,
		false,
		false
	]);
	
	// --- GUARNICIÓNES ---
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"<t color='#FF44FF'>GUARNICIÓN EN EDIFICIO</t>",
		{},
		nil,
		2,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ Guarnición pequeña (2-4 unidades)",
		{
			private _nearBuildings = nearestObjects [SPAWN_MENU_ClickPos, ["House"], 50];
			if (count _nearBuildings > 0) then {
				[_nearBuildings select 0, east, 4] remoteExec ["FN_spawnGarrison", 2];
				hint "Guarnición pequeña generada";
			} else {
				hint "No hay edificios cerca (radio 50m)";
			};
			[] call SPAWN_clearMenu;
		},
		nil,
		1.2,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ Guarnición mediana (4-8 unidades)",
		{
			private _nearBuildings = nearestObjects [SPAWN_MENU_ClickPos, ["House"], 50];
			if (count _nearBuildings > 0) then {
				[_nearBuildings select 0, east, 8] remoteExec ["FN_spawnGarrison", 2];
				hint "Guarnición mediana generada";
			} else {
				hint "No hay edificios cerca (radio 50m)";
			};
			[] call SPAWN_clearMenu;
		},
		nil,
		1.1,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ Guarnición grande (8-12 unidades)",
		{
			private _nearBuildings = nearestObjects [SPAWN_MENU_ClickPos, ["House"], 50];
			if (count _nearBuildings > 0) then {
				[_nearBuildings select 0, east, 12] remoteExec ["FN_spawnGarrison", 2];
				hint "Guarnición grande generada";
			} else {
				hint "No hay edificios cerca (radio 50m)";
			};
			[] call SPAWN_clearMenu;
		},
		nil,
		1,
		false,
		false
	]);
	
	// ═════════════════════════════════════════════════════════════
	// SECCIÓN: CREAR TAREAS
	// ═════════════════════════════════════════════════════════════
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"<t color='#FFAA00'>═══ 📋 CREAR TAREAS ═══</t>",
		{},
		nil,
		10,
		false,
		false
	]);
	
	// ─────────────────────────────────────────────────────────────
	// TAREAS HOSTILES
	// ─────────────────────────────────────────────────────────────
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"<t color='#FF4444'>⚔ HOSTILES:</t>",
		{},
		nil,
		9,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ 🎯 HVT - Eliminar Objetivo",
		{
			[SPAWN_MENU_ClickPos, east, "INSIDE"] remoteExec ["FN_createTaskHVT", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		8.9,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ 📄 Intel - Recuperar Documentos",
		{
			[SPAWN_MENU_ClickPos, east] remoteExec ["FN_createTaskIntel", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		8.8,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ 💣 Cache - Destruir Armas",
		{
			[SPAWN_MENU_ClickPos, east] remoteExec ["FN_createTaskCache", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		8.7,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ 🎯 Limpiar Área",
		{
			[SPAWN_MENU_ClickPos, east] remoteExec ["FN_createTaskClearArea", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		8.6,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ 👤 POW - Rescatar Prisionero",
		{
			[SPAWN_MENU_ClickPos, east] remoteExec ["FN_createTaskPOW", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		8.5,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ 🚗 Destruir Vehículo (APC)",
		{
			[SPAWN_MENU_ClickPos, east, "APC"] remoteExec ["FN_createTaskVehicle", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		8.4,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ 🚙 Destruir Vehículo (CAR)",
		{
			[SPAWN_MENU_ClickPos, east, "CAR"] remoteExec ["FN_createTaskVehicle", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		8.3,
		false,
		false
	]);
	
	// ─────────────────────────────────────────────────────────────
	// TAREAS NEUTRALES
	// ─────────────────────────────────────────────────────────────
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"<t color='#FFAA00'>⚠ NEUTRALES:</t>",
		{},
		nil,
		7,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ ✂️ Desarmar IEDs",
		{
			[SPAWN_MENU_ClickPos, east] remoteExec ["FN_createTaskDisarmIED", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		6.9,
		false,
		false
	]);
	
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"  └ 👥 Proteger Civiles",
		{
			[SPAWN_MENU_ClickPos, east] remoteExec ["FN_createTaskProtectCivs", 2];
			[] call SPAWN_clearMenu;
		},
		nil,
		6.8,
		false,
		false
	]);
	
	// ===== INTEL ===== (ELIMINADO - Usar Zeus/Editor en su lugar)
	
	// --- CANCELAR ---
	SPAWN_MENU_ContextMenu pushBack (player addAction [
		"<t color='#888888'>--- CANCELAR ---</t>",
		{
			hint "Spawn cancelado";
			[] call SPAWN_clearMenu;
		},
		nil,
		0,
		false,
		false
	]);
	
	diag_log format ["[SPAWN_MENU] Menú contextual mostrado en %1", _pos];
};

// Función para limpiar el menú
SPAWN_clearMenu = {
	// Remover acciones
	if (!isNil "SPAWN_MENU_ContextMenu") then {
		{
			player removeAction _x;
		} forEach SPAWN_MENU_ContextMenu;
		SPAWN_MENU_ContextMenu = nil;
	};
	
	// Eliminar marcador temporal
	if (!isNil "SPAWN_MENU_TempMarker") then {
		deleteMarker SPAWN_MENU_TempMarker;
		SPAWN_MENU_TempMarker = nil;
	};
	
	diag_log "[SPAWN_MENU] Menú limpiado";
};

// Mensaje inicial
hint "Sistema de spawn inicializado\nPresiona 0-0-1 para activar/desactivar el menú";
diag_log "[SPAWN_MENU] Sistema inicializado";

// Agregar acción para toggle del menú
player addAction [
	"<t color='#FFFF00'>Toggle Menú de Spawn</t>",
	{
		[] call SPAWN_toggleMenu;
	},
	nil,
	100,
	false,
	false
];

