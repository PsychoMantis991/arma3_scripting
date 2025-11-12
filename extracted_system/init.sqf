/*
	Archivo: init.sqf
	Descripción: Inicialización del sistema de spawn manual extraído de DRO
	
	Uso:
		Coloca este archivo en la raíz de tu misión o llámalo desde tu init.sqf existente:
		[] execVM "extracted_system\init.sqf";
*/

// ═════════════════════════════════════════════════════════════════
// PARTE 1: CÓDIGO QUE SE EJECUTA EN SERVIDOR Y CLIENTES
// Compilar todas las funciones para que estén disponibles globalmente
// ═════════════════════════════════════════════════════════════════

diag_log "===============================================";
diag_log "[EXTRACTED_SYSTEM] Iniciando compilación de funciones...";
diag_log "===============================================";

// ===== CARGAR SELECTOR DE FACCIONES =====
diag_log "[EXTRACTED_SYSTEM] Cargando selector de facciones dinámico...";
[] execVM "extracted_system\faction_selector.sqf";

// Esperar a que el selector esté listo
waitUntil {!isNil "SPAWN_availableFactionsData"};
diag_log format ["[EXTRACTED_SYSTEM] Selector listo - %1 facciones detectadas", count SPAWN_availableFactionsData];

// ===== COMPILAR FUNCIONES DE SPAWN =====
diag_log "[EXTRACTED_SYSTEM] Compilando funciones de spawn...";

FN_spawnInfantryGroup = compileFinal preprocessFileLineNumbers "extracted_system\functions\fn_spawnInfantryGroup.sqf";
FN_spawnVehiclePatrol = compileFinal preprocessFileLineNumbers "extracted_system\functions\fn_spawnVehiclePatrol.sqf";
FN_spawnGarrison = compileFinal preprocessFileLineNumbers "extracted_system\functions\fn_spawnGarrison.sqf";
FN_spawnCamp = compileFinal preprocessFileLineNumbers "extracted_system\functions\fn_spawnCamp.sqf";
FN_spawnCivilians = compileFinal preprocessFileLineNumbers "extracted_system\functions\fn_spawnCivilians.sqf";
FN_spawnCivilianVehicle = compileFinal preprocessFileLineNumbers "extracted_system\functions\fn_spawnCivilianVehicle.sqf";
FN_spawnCompoundArea = compileFinal preprocessFileLineNumbers "extracted_system\functions\fn_spawnCompoundArea.sqf";
FN_spawnFOB = compileFinal preprocessFileLineNumbers "extracted_system\functions\fn_spawnFOB.sqf";
FN_spawnRoadblock = compileFinal preprocessFileLineNumbers "extracted_system\functions\fn_spawnRoadblock.sqf";
FN_openFactionSelector = compileFinal preprocessFileLineNumbers "extracted_system\functions\fn_openFactionSelector.sqf";

// ===== COMPILAR FUNCIONES DE TAREAS =====
diag_log "[EXTRACTED_SYSTEM] Compilando funciones de tareas...";

// Utilidades de tareas (contiene FN_createBISTask, FN_generateTaskID, etc.)
call compileFinal preprocessFileLineNumbers "extracted_system\functions\tasks\fn_taskUtilities.sqf";

// Tareas hostiles
FN_createTaskHVT = compileFinal preprocessFileLineNumbers "extracted_system\functions\tasks\fn_createTaskHVT.sqf";
FN_createTaskIntel = compileFinal preprocessFileLineNumbers "extracted_system\functions\tasks\fn_createTaskIntel.sqf";
FN_createTaskCache = compileFinal preprocessFileLineNumbers "extracted_system\functions\tasks\fn_createTaskCache.sqf";
FN_createTaskClearArea = compileFinal preprocessFileLineNumbers "extracted_system\functions\tasks\fn_createTaskClearArea.sqf";
FN_createTaskPOW = compileFinal preprocessFileLineNumbers "extracted_system\functions\tasks\fn_createTaskPOW.sqf";
FN_createTaskVehicle = compileFinal preprocessFileLineNumbers "extracted_system\functions\tasks\fn_createTaskVehicle.sqf";

// Tareas neutrales
FN_createTaskDisarmIED = compileFinal preprocessFileLineNumbers "extracted_system\functions\tasks\fn_createTaskDisarmIED.sqf";
FN_createTaskProtectCivs = compileFinal preprocessFileLineNumbers "extracted_system\functions\tasks\fn_createTaskProtectCivs.sqf";

// ===== COMPILAR FUNCIONES DE INTEL =====
diag_log "[EXTRACTED_SYSTEM] Compilando funciones de intel...";

// Utilidades básicas (usadas por las tareas)
call compileFinal preprocessFileLineNumbers "extracted_system\functions\intel\fn_intelUtilities.sqf";

// Funciones de menú manual (DESHABILITADAS - Usar Zeus/Editor)
// call compileFinal preprocessFileLineNumbers "extracted_system\functions\intel\fn_intelMenuActions.sqf";
// FN_intelDialogInput = compileFinal preprocessFileLineNumbers "extracted_system\functions\intel\fn_intelDialogInput.sqf";
// INTEL_createCustomIntel = compileFinal preprocessFileLineNumbers "extracted_system\functions\intel\fn_intelCreateCustom.sqf";

diag_log "[EXTRACTED_SYSTEM] ✓ Funciones compiladas correctamente en servidor/clientes";

// ═════════════════════════════════════════════════════════════════
// PARTE 2: CÓDIGO SOLO PARA CLIENTES (INTERFAZ)
// ═════════════════════════════════════════════════════════════════

if (!hasInterface) exitWith {
	diag_log "[EXTRACTED_SYSTEM] Servidor inicializado - funciones disponibles";
};

// Esperar a que el jugador esté listo
waitUntil {!isNull player};

// ===== VERIFICAR SI ES ZEUS =====
sleep 3;  // Dar tiempo suficiente para que se asigne el curator y termine la intro

private _curatorLogic = getAssignedCuratorLogic player;

if (isNull _curatorLogic) exitWith {
	// Jugador normal - NO mostrar ningún mensaje
	diag_log "[EXTRACTED_SYSTEM] Cliente normal - Sistema de spawn no disponible";
};

// ═════════════════════════════════════════════════════════════════
// SOLO ZEUS A PARTIR DE AQUÍ
// ═════════════════════════════════════════════════════════════════
diag_log "===============================================";
diag_log format ["[EXTRACTED_SYSTEM] Iniciando interfaz para Zeus: %1", name player];
diag_log format ["[EXTRACTED_SYSTEM] Curator asignado: %1", _curatorLogic];
diag_log "===============================================";

// ===== INICIAR MENÚ DE SPAWN =====
diag_log "[EXTRACTED_SYSTEM] Iniciando menú de spawn...";
[] execVM "extracted_system\spawn_menu\mapClickMenu.sqf";

// ===== MENSAJE DE BIENVENIDA PARA ZEUS =====
sleep 2;
hint composeText [
	parseText "<t color='#FFAA00' size='1.5'>SISTEMA DE SPAWN PARA ZEUS</t>", lineBreak,
	"================================", lineBreak, lineBreak,
	parseText "<t color='#00FF00'>✓ Sistema inicializado correctamente</t>", lineBreak,
	parseText format ["<t color='#AAAAFF'>Zeus activo: %1</t>", name player], lineBreak, lineBreak,
	parseText "<t color='#FFFF00'>USO:</t>", lineBreak,
	"1. Usa la acción 'Toggle Menú de Spawn'", lineBreak,
	"2. Abre el mapa (M)", lineBreak,
	"3. Haz clic derecho donde quieras generar", lineBreak,
	"4. Selecciona qué generar del menú", lineBreak, lineBreak,
	parseText "<t color='#00AAFF'>Funciones disponibles:</t>", lineBreak,
	"- Infantería (escuadras)", lineBreak,
	"- Vehículos (MRAP, APC, Tanques)", lineBreak,
	"- Estructuras (Roadblocks, Campamentos)", lineBreak,
	"- Civiles (población, vehículos)", lineBreak,
	"- Guarniciones en edificios", lineBreak,
	"- Tareas personalizadas (8 tipos)", lineBreak,
	"- Sistema de Intel manual", lineBreak, lineBreak,
	parseText "<t color='#FF8800'>NOTA: Los spawns se sincronizan automáticamente</t>"
];

diag_log "[EXTRACTED_SYSTEM] Sistema completamente inicializado";
diag_log "===============================================";

// ===== FUNCIONES HELPER ADICIONALES (opcionales) =====

// Función para limpiar todas las unidades generadas
SPAWN_cleanupAll = {
	hint "Limpiando todas las unidades generadas...";
	
	private _count = 0;
	{
		if (!isPlayer _x) then {
			deleteVehicle _x;
			_count = _count + 1;
		};
	} forEach allUnits;
	
	{
		deleteVehicle _x;
		_count = _count + 1;
	} forEach vehicles;
	
	hint format ["Limpieza completada: %1 objetos eliminados", _count];
	diag_log format ["[SPAWN_cleanupAll] Eliminados %1 objetos", _count];
};

// Agregar acción de limpieza
player addAction [
	"<t color='#FF0000'>LIMPIAR TODO</t>",
	{
		[] call SPAWN_cleanupAll;
	},
	nil,
	-1,
	false,
	false
];

// Agregar acciones de selector de facciones
player addAction [
	"<t color='#FF4444'>🎖️ Cambiar Facción OPFOR (Enemigos)</t>",
	{
		[east] call FN_openFactionSelector;
	},
	nil,
	98,
	false,
	false
];

player addAction [
	"<t color='#4444FF'>🎖️ Cambiar Facción BLUFOR (Aliados)</t>",
	{
		[west] call FN_openFactionSelector;
	},
	nil,
	97,
	false,
	false
];

player addAction [
	"<t color='#44FF44'>🎖️ Cambiar Facción INDEPENDENT</t>",
	{
		[resistance] call FN_openFactionSelector;
	},
	nil,
	96,
	false,
	false
];

player addAction [
	"<t color='#FFFFFF'>🎖️ Cambiar Facción CIVILIAN (Civiles)</t>",
	{
		[civilian] call FN_openFactionSelector;
	},
	nil,
	95,
	false,
	false
];

diag_log "[EXTRACTED_SYSTEM] Funciones helper agregadas";
