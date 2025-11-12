/*
	═══════════════════════════════════════════════════════════════════
	EJEMPLOS PRÁCTICOS - SISTEMA DE INTEL
	Copiar y pegar en la consola debug de Zeus
	═══════════════════════════════════════════════════════════════════
*/

// ═════════════════════════════════════════════════════════════════════
// EJEMPLO 1: Intel Básico en Unidad Enemiga
// ═════════════════════════════════════════════════════════════════════

// Apunta a un enemigo y ejecuta:
[
	cursorObject, 
	"Documentos con órdenes de atacar la base FOB Alpha"
] remoteExec ["INTEL_addToUnit", 2];

// El enemigo ahora tiene intel. Al morir, los jugadores pueden registrarlo.


// ═════════════════════════════════════════════════════════════════════
// EJEMPLO 2: Civil con Información
// ═════════════════════════════════════════════════════════════════════

// Apunta a un civil y ejecuta:
[
	cursorObject, 
	"Vi camiones militares dirigiéndose hacia el norte hace una hora"
] remoteExec ["INTEL_addToCivilian", 2];

// Los jugadores podrán interrogarlo mientras esté vivo.


// ═════════════════════════════════════════════════════════════════════
// EJEMPLO 3: Laptop con Comunicaciones
// ═════════════════════════════════════════════════════════════════════

_pos = getPos player;
[
	_pos, 
	"Correos electrónicos del comando enemigo sobre refuerzos en camino", 
	"LAPTOP"
] remoteExec ["INTEL_createObject", 2];


// ═════════════════════════════════════════════════════════════════════
// EJEMPLO 4: Mapa Táctico con Revelación de Marcador
// ═════════════════════════════════════════════════════════════════════

// PASO 1: Crear marcador OCULTO en ubicación secreta
_markerName = "baseSecreta1";
_posicionSecreta = [12000, 15000, 0]; // Cambia por coordenadas reales

_marker = createMarker [_markerName, _posicionSecreta];
_marker setMarkerShape "ICON";
_marker setMarkerType "hd_objective";
_marker setMarkerColor "ColorRed";
_marker setMarkerText "Base Enemiga Principal";
_marker setMarkerAlpha 0; // OCULTO - se revelará al recoger el intel

// PASO 2: Crear mapa que revela el marcador
_posIntel = getPos player;
[
	_posIntel, 
	"Mapa táctico con la ubicación de la base enemiga principal", 
	"MAP",
	_markerName,
	_posicionSecreta
] remoteExec ["INTEL_createObject", 2];


// ═════════════════════════════════════════════════════════════════════
// EJEMPLO 5: Intel en Todo un Grupo
// ═════════════════════════════════════════════════════════════════════

// Apunta a cualquier miembro del grupo y ejecuta:
_grupo = group cursorObject;
[
	_grupo, 
	"Órdenes de operación del pelotón - Objetivo: Capturar aeródromo",
	"DOCUMENT"
] remoteExec ["INTEL_addToGroup", 2];

// Todas las unidades del grupo tendrán el mismo intel.


// ═════════════════════════════════════════════════════════════════════
// EJEMPLO 6: Teléfono con Mensajes SMS
// ═════════════════════════════════════════════════════════════════════

_pos = getPos player;
[
	_pos, 
	"Mensaje SMS: 'El convoy saldrá a las 1500h. Ruta alternativa por el valle.'", 
	"PHONE"
] remoteExec ["INTEL_createObject", 2];


// ═════════════════════════════════════════════════════════════════════
// EJEMPLO 7: Documentos Clasificados
// ═════════════════════════════════════════════════════════════════════

_pos = getPos player;
[
	_pos, 
	"CLASIFICADO: Lista de agentes infiltrados en la zona AO-12", 
	"DOCUMENT"
] remoteExec ["INTEL_createObject", 2];


// ═════════════════════════════════════════════════════════════════════
// EJEMPLO 8: Intel con Posición Revelada (sin marcador previo)
// ═════════════════════════════════════════════════════════════════════

_posIntel = getPos player;
_posicionEnemiga = [11500, 14200, 0]; // Ubicación a revelar

[
	_posIntel, 
	"Coordenadas de un puesto de observación enemigo", 
	"TABLET",
	"", // No hay marcador previo
	_posicionEnemiga // Se creará marcador automáticamente
] remoteExec ["INTEL_createObject", 2];


// ═════════════════════════════════════════════════════════════════════
// EJEMPLO 9: Añadir Intel a Todos los Enemigos Cercanos
// ═════════════════════════════════════════════════════════════════════

_pos = getPos player;
_radio = 150; // metros

// Buscar todos los enemigos en radio
_enemigos = _pos nearEntities [["CAManBase"], _radio];
_enemigos = _enemigos select {alive _x && side _x == east && !isPlayer _x};

// Añadir intel a todos
{
	[
		_x, 
		"Fragmento del plan de ataque enemigo", 
		"DOCUMENT"
	] remoteExec ["INTEL_addToUnit", 2];
} forEach _enemigos;

hint format ["Intel añadido a %1 enemigos", count _enemigos];


// ═════════════════════════════════════════════════════════════════════
// EJEMPLO 10: Intel en Edificio Específico
// ═════════════════════════════════════════════════════════════════════

// Buscar edificio más cercano al jugador
_edificio = nearestBuilding player;
_posiciones = [_edificio] call BIS_fnc_buildingPositions;

if (count _posiciones > 0) then {
	// Colocar laptop en planta superior
	_posLaptop = _posiciones select ((count _posiciones) - 1);
	[
		_posLaptop, 
		"Laptop del comandante con planes operacionales", 
		"LAPTOP"
	] remoteExec ["INTEL_createObject", 2];
	
	// Colocar documentos en planta baja
	_posDoc = _posiciones select 0;
	[
		_posDoc, 
		"Informes de patrulla y registros de actividad", 
		"DOCUMENT"
	] remoteExec ["INTEL_createObject", 2];
	
	hint "Intel colocado en edificio";
} else {
	hint "El edificio no tiene posiciones válidas";
};


// ═════════════════════════════════════════════════════════════════════
// EJEMPLO 11: Cadena de Intel (3 niveles)
// ═════════════════════════════════════════════════════════════════════

// NIVEL 1: Intel inicial (en posición conocida)
_pos1 = getPos player;
_pos2 = _pos1 getPos [500, 45]; // 500m al NE
_pos3 = _pos2 getPos [800, 135]; // 800m al SE desde pos2
_posFinal = _pos3 getPos [1000, 270]; // 1000m al oeste desde pos3

// Crear marcadores ocultos
_m2 = createMarker ["intel_chain_2", _pos2];
_m2 setMarkerShape "ICON";
_m2 setMarkerType "hd_warning";
_m2 setMarkerColor "ColorYellow";
_m2 setMarkerText "Intel Nivel 2";
_m2 setMarkerAlpha 0;

_m3 = createMarker ["intel_chain_3", _pos3];
_m3 setMarkerShape "ICON";
_m3 setMarkerType "hd_warning";
_m3 setMarkerColor "ColorOrange";
_m3 setMarkerText "Intel Nivel 3";
_m3 setMarkerAlpha 0;

_mFinal = createMarker ["intel_chain_final", _posFinal];
_mFinal setMarkerShape "ICON";
_mFinal setMarkerType "hd_objective";
_mFinal setMarkerColor "ColorRed";
_mFinal setMarkerText "OBJETIVO FINAL";
_mFinal setMarkerAlpha 0;

// Intel 1 (en tu posición actual)
[
	_pos1, 
	"Mapa con ubicación de un escondite secundario", 
	"MAP",
	"intel_chain_2",
	_pos2
] remoteExec ["INTEL_createObject", 2];

// Intel 2 (en ubicación revelada por Intel 1)
[
	_pos2, 
	"Documentos que mencionan un puesto de comando", 
	"DOCUMENT",
	"intel_chain_3",
	_pos3
] remoteExec ["INTEL_createObject", 2];

// Intel 3 (en ubicación revelada por Intel 2)
[
	_pos3, 
	"Laptop con coordenadas exactas del HQ enemigo", 
	"LAPTOP",
	"intel_chain_final",
	_posFinal
] remoteExec ["INTEL_createObject", 2];

hint "Cadena de intel creada (3 niveles)";


// ═════════════════════════════════════════════════════════════════════
// EJEMPLO 12: HVT con Intel Crítico
// ═════════════════════════════════════════════════════════════════════

// Primero, crea una tarea HVT desde el menú contextual del mapa
// Luego, cuando aparezca el HVT, apunta a él y ejecuta:

[
	cursorObject, 
	"INTEL CRÍTICO: Ataque coordinado planificado para mañana al amanecer. Múltiples objetivos aliados comprometidos.",
	"DOCUMENT"
] remoteExec ["INTEL_addToUnit", 2];

// Los jugadores deben neutralizar y registrar al HVT para obtener el intel.


// ═════════════════════════════════════════════════════════════════════
// EJEMPLO 13: Múltiples Civiles con Fragmentos de Información
// ═════════════════════════════════════════════════════════════════════

// Buscar todos los civiles cercanos
_civiles = (getPos player) nearEntities [["CAManBase"], 200];
_civiles = _civiles select {alive _x && side _x == civilian};

// Información fragmentada
_fragmentos = [
	"Vi soldados cerca del viejo molino al norte",
	"Escuché disparos cerca de las colinas del este anoche",
	"Un convoy militar pasó por aquí hace dos horas",
	"Hay un campamento enemigo cerca del lago"
];

// Asignar fragmentos aleatorios
{
	if (count _fragmentos > 0) then {
		private _fragmento = selectRandom _fragmentos;
		_fragmentos = _fragmentos - [_fragmento];
		
		[_x, _fragmento] remoteExec ["INTEL_addToCivilian", 2];
	};
} forEach _civiles;

hint format ["Intel asignado a %1 civiles", count _civiles min 4];


// ═════════════════════════════════════════════════════════════════════
// EJEMPLO 14: Intel de Emergencia (Uso Rápido)
// ═════════════════════════════════════════════════════════════════════

// Para generar intel rápido en tu posición con mensaje aleatorio:
[getPos player] remoteExec ["INTEL_menuQuickIntel", 2];


// ═════════════════════════════════════════════════════════════════════
// EJEMPLO 15: Limpiar Todo el Intel Creado
// ═════════════════════════════════════════════════════════════════════

// Para debugging o reset de misión:
INTEL_AllIntel = [];
INTEL_CollectedIntel = [];
publicVariable "INTEL_AllIntel";
publicVariable "INTEL_CollectedIntel";
hint "Sistema de intel reiniciado";


// ═════════════════════════════════════════════════════════════════════
// NOTAS:
// ═════════════════════════════════════════════════════════════════════
// - Todos los comandos deben ejecutarse en la consola debug de Zeus
// - "cursorObject" se refiere al objeto/unidad que estás mirando
// - Las coordenadas [X, Y, Z] deben ajustarse según tu mapa
// - El tercer parámetro es el tipo: "DOCUMENT", "LAPTOP", "PHONE", "MAP", "TABLET"
// - remoteExec ["función", 2] ejecuta en el servidor para sincronización
// ═════════════════════════════════════════════════════════════════════

