/*
	═══════════════════════════════════════════════════════════════════
	MENÚ DE INTEL PARA ZEUS
	Acciones para añadir intel desde el menú contextual del mapa
	═══════════════════════════════════════════════════════════════════
*/

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Menú para Añadir Intel a Unidad Cercana
// ═════════════════════════════════════════════════════════════════════

INTEL_menuAddToNearUnit = {
	params ["_pos"];
	
	// Buscar unidades cercanas (50m)
	private _nearUnits = _pos nearEntities [["CAManBase"], 50];
	_nearUnits = _nearUnits select {alive _x && !isPlayer _x};
	
	if (count _nearUnits == 0) exitWith {
		hint "No hay unidades IA cercanas (radio 50m)";
	};
	
	// Encontrar la más cercana
	private _nearestUnit = _nearUnits select 0;
	private _unitType = if (side _nearestUnit == civilian) then {"CIVIL"} else {"ENEMIGO"};
	
	// Abrir input para el texto del intel
	private _dialog = createDialog "RscDisplayDebriefing";
	
	// Por simplicidad, usamos un hint con instrucciones
	hint parseText format [
		"<t size='1.2' color='#4444FF'>📋 AÑADIR INTEL</t><br/><br/>" +
		"<t size='1'>Unidad más cercana: %1 (%2)</t><br/><br/>" +
		"<t size='0.9' color='#FFFF00'>Para añadir intel, ejecuta en consola debug:</t><br/><br/>" +
		"<t font='EtelkaMonospacePro' size='0.8' color='#00FF00'>[_unit, ""Tu mensaje""] remoteExec [""INTEL_addToUnit"", 2];</t><br/><br/>" +
		"<t size='0.8'>Guarda la unidad con: _unit = cursorObject;</t>",
		typeOf _nearestUnit,
		_unitType
	];
	
	// Copiar comando al portapapeles
	copyToClipboard format ['[cursorObject, "Información encontrada"] remoteExec ["INTEL_addToUnit", 2];'];
	
	diag_log format ["[INTEL] Preparado para añadir intel a: %1", _nearestUnit];
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Crear Objeto de Intel en Posición
// ═════════════════════════════════════════════════════════════════════

INTEL_menuCreateObject = {
	params ["_pos", ["_objectType", "DOCUMENT"]];
	
	// Texto de ejemplo según tipo
	private _exampleText = switch (_objectType) do {
		case "DOCUMENT": {"Documentos encontrados con información de una posición enemiga"};
		case "LAPTOP": {"Ordenador portátil con datos de comunicaciones enemigas"};
		case "PHONE": {"Teléfono móvil con mensajes sobre un ataque planificado"};
		case "MAP": {"Mapa con marcas que indican rutas de patrulla"};
		case "TABLET": {"Tablet con órdenes militares y coordenadas"};
		default {"Información recuperada"};
	};
	
	// Crear objeto con intel de ejemplo
	private _object = [_pos, _exampleText, _objectType] remoteExec ["INTEL_createObject", 2];
	
	hint parseText format [
		"<t size='1.2' color='#4444FF'>✓ Intel Creado</t><br/><br/>" +
		"<t size='1'>Tipo: %1</t><br/>" +
		"<t size='0.9'>Los jugadores podrán recogerlo</t><br/><br/>" +
		"<t size='0.8' color='#FFFF00'>Personaliza el mensaje con:</t><br/>" +
		"<t font='EtelkaMonospacePro' size='0.7' color='#00FF00'>[_obj, ""Tu texto"", ""%1""] remoteExec [""INTEL_addToObject"", 2];</t>",
		_objectType
	];
	
	diag_log format ["[INTEL] Objeto de intel creado: %1 en %2", _objectType, _pos];
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Menú Rápido de Intel Predefinido
// ═════════════════════════════════════════════════════════════════════

INTEL_menuQuickIntel = {
	params ["_pos"];
	
	// Intel rápidos predefinidos
	private _quickIntels = [
		["Posición enemiga al norte", "DOCUMENT"],
		["Refuerzos en camino desde el sur", "RADIO"],
		["Reunión a las 1800h en el punto de encuentro", "PHONE"],
		["Ruta de patrulla marcada en el mapa", "MAP"],
		["Órdenes de atacar la base aliada", "LAPTOP"]
	];
	
	// Seleccionar uno aleatorio
	private _selected = selectRandom _quickIntels;
	private _text = _selected select 0;
	private _type = _selected select 1;
	
	// Crear objeto
	[_pos, _text, _type] remoteExec ["INTEL_createObject", 2];
	
	hint parseText format [
		"<t size='1.2' color='#4444FF'>✓ Intel Rápido Creado</t><br/><br/>" +
		"<t size='1'>%1</t>",
		_text
	];
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Añadir Intel con Revelación de Marcador
// ═════════════════════════════════════════════════════════════════════

INTEL_menuCreateWithMarker = {
	params ["_pos"];
	
	// Crear marcador oculto en posición aleatoria cercana
	private _revealPos = _pos getPos [500 + random 1000, random 360];
	private _markerName = format ["intelHidden_%1", floor(random 100000)];
	
	private _marker = createMarker [_markerName, _revealPos];
	_marker setMarkerShape "ICON";
	_marker setMarkerType "hd_objective";
	_marker setMarkerColor "ColorRed";
	_marker setMarkerText "Ubicación enemiga";
	_marker setMarkerAlpha 0; // Oculto inicialmente
	
	// Crear objeto con intel que revela el marcador
	private _intelText = format [
		"Hemos descubierto una posición enemiga a %1m al %2",
		floor (_pos distance _revealPos),
		[_pos, _revealPos] call BIS_fnc_dirTo
	];
	
	[_pos, _intelText, "MAP", _markerName, _revealPos] remoteExec ["INTEL_createObject", 2];
	
	hint parseText format [
		"<t size='1.2' color='#4444FF'>✓ Intel con Marcador Creado</t><br/><br/>" +
		"<t size='1'>Al recogerlo, revelará un marcador oculto</t>"
	];
	
	diag_log format ["[INTEL] Intel con marcador creado: %1 revela %2", _pos, _markerName];
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Añadir Intel a Todos los Enemigos Cercanos
// ═════════════════════════════════════════════════════════════════════

INTEL_menuAddToNearEnemies = {
	params ["_pos", ["_radius", 100]];
	
	// Buscar enemigos cercanos
	private _enemies = _pos nearEntities [["CAManBase"], _radius];
	_enemies = _enemies select {alive _x && side _x == east && !isPlayer _x};
	
	if (count _enemies == 0) exitWith {
		hint format ["No hay enemigos en radio %1m", _radius];
	};
	
	// Texto de intel
	private _intelText = format [
		"Documentos con información táctica enemiga (encontrados en %1 unidades)",
		count _enemies
	];
	
	// Añadir a todos
	{
		[_x, _intelText, "DOCUMENT"] remoteExec ["INTEL_addToUnit", 2];
	} forEach _enemies;
	
	hint parseText format [
		"<t size='1.2' color='#00FF00'>✓ Intel Añadido</t><br/><br/>" +
		"<t size='1'>%1 enemigos ahora tienen intel</t>",
		count _enemies
	];
	
	diag_log format ["[INTEL] Intel añadido a %1 enemigos", count _enemies];
};

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: Crear Set Completo de Intel (Edificio con Intel)
// ═════════════════════════════════════════════════════════════════════

INTEL_menuCreateBuildingIntel = {
	params ["_pos"];
	
	// Buscar edificio más cercano
	private _nearBuildings = nearestObjects [_pos, ["House"], 50];
	_nearBuildings = _nearBuildings select {
		count ([_x] call BIS_fnc_buildingPositions) > 0
	};
	
	if (count _nearBuildings == 0) exitWith {
		hint "No hay edificios cercanos con posiciones válidas";
	};
	
	private _building = _nearBuildings select 0;
	private _buildingPos = [_building] call BIS_fnc_buildingPositions;
	
	if (count _buildingPos == 0) exitWith {
		hint "El edificio no tiene posiciones válidas";
	};
	
	// Crear varios objetos de intel dentro
	private _numIntel = 1 + floor(random 3);
	private _objectsCreated = [];
	
	for "_i" from 0 to (_numIntel - 1) do {
		private _intelPos = selectRandom _buildingPos;
		private _intelType = selectRandom ["DOCUMENT", "LAPTOP", "PHONE", "MAP"];
		private _intelTexts = [
			"Informes de patrulla con horarios detallados",
			"Lista de objetivos aliados prioritarios",
			"Comunicaciones interceptadas del comando enemigo",
			"Mapas con posiciones de defensa",
			"Órdenes de reconocimiento del área"
		];
		
		private _obj = [_intelPos, selectRandom _intelTexts, _intelType] remoteExec ["INTEL_createObject", 2];
		_objectsCreated pushBack _obj;
	};
	
	hint parseText format [
		"<t size='1.2' color='#4444FF'>✓ Edificio con Intel</t><br/><br/>" +
		"<t size='1'>%1 objetos de intel colocados</t><br/>" +
		"<t size='0.9'>Los jugadores deberán registrar el edificio</t>",
		_numIntel
	];
	
	diag_log format ["[INTEL] Edificio con intel creado: %1 objetos", _numIntel];
};

// ═════════════════════════════════════════════════════════════════════
// INICIALIZACIÓN
// ═════════════════════════════════════════════════════════════════════

diag_log "[INTEL] Menú de acciones de intel cargado";

