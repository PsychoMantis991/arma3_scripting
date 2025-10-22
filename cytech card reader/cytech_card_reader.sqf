/*
	Script de Lector de Tarjetas para Arma 3 - Mod Cytech
	Autor: Script de acceso con tarjetas jerárquicas
	Versión: 1.0
	
	Descripción:
	Sistema de control de acceso mediante tarjetas con niveles jerárquicos
	Niveles: A (más bajo) -> B -> C -> D -> E (más alto)
	Una tarjeta de nivel superior puede acceder a todas las puertas de niveles inferiores
	
	Uso:
	1. Coloca este script en la carpeta de tu misión
	2. Llama a la función de inicialización desde el init.sqf o desde el objeto lector
	3. Configura las puertas y lectores según necesites
*/

// ===============================================
// CONFIGURACIÓN GLOBAL DE NIVELES DE ACCESO
// ===============================================

// Define los niveles de acceso en orden jerárquico (de menor a mayor)
CYTECH_AccessLevels = ["A", "B", "C", "D", "E"];

// Define los nombres de clase de las tarjetas (ajusta según el mod Cytech)
CYTECH_CardClasses = [
	"cytech_item_idcard_a",  // Tarjeta A
	"cytech_item_idcard_b",  // Tarjeta B
	"cytech_item_idcard_c",  // Tarjeta C
	"cytech_item_idcard_d",  // Tarjeta D
	"cytech_item_idcard_e"   // Tarjeta E
];

// ===============================================
// FUNCIÓN: Obtener nivel de acceso de un jugador
// ===============================================
CYTECH_fnc_getPlayerAccessLevel = {
	params ["_player"];
	
	private _highestLevel = -1;
	private _highestLevelName = "";
	
	// Recorre todos los niveles de tarjetas
	{
		private _cardClass = _x;
		private _levelIndex = _forEachIndex;
		
		// Verifica si el jugador tiene esta tarjeta
		if (_cardClass in (items _player + magazines _player)) then {
			if (_levelIndex > _highestLevel) then {
				_highestLevel = _levelIndex;
				_highestLevelName = CYTECH_AccessLevels select _levelIndex;
			};
		};
	} forEach CYTECH_CardClasses;
	
	// Retorna el nivel más alto encontrado (índice y nombre)
	[_highestLevel, _highestLevelName]
};

// ===============================================
// FUNCIÓN: Verificar si un jugador tiene acceso
// ===============================================
CYTECH_fnc_checkAccess = {
	params ["_player", "_requiredLevel"];
	
	// Obtiene el nivel de acceso del jugador
	private _playerAccessData = [_player] call CYTECH_fnc_getPlayerAccessLevel;
	private _playerLevel = _playerAccessData select 0;
	
	// Verifica si el nivel del jugador es igual o superior al requerido
	private _requiredIndex = CYTECH_AccessLevels find _requiredLevel;
	
	if (_requiredIndex == -1) exitWith {
		systemChat format ["ERROR: Nivel requerido '%1' no válido", _requiredLevel];
		false
	};
	
	// El jugador tiene acceso si su nivel es >= al requerido
	(_playerLevel >= _requiredIndex)
};

// ===============================================
// FUNCIÓN: Abrir puerta con verificación de acceso
// ===============================================
CYTECH_fnc_openDoorWithAccess = {
	params ["_door", "_requiredLevel", "_player"];
	
	// Verifica si el jugador tiene el nivel de acceso necesario
	private _hasAccess = [_player, _requiredLevel] call CYTECH_fnc_checkAccess;
	
	if (_hasAccess) then {
		// Acceso concedido
		private _playerData = [_player] call CYTECH_fnc_getPlayerAccessLevel;
		private _playerLevelName = _playerData select 1;
		
		systemChat format ["✓ ACCESO CONCEDIDO - Tarjeta nivel %1 autorizada para nivel %2", _playerLevelName, _requiredLevel];
		hint parseText format ["<t color='#00ff00' size='1.5'>ACCESO CONCEDIDO</t><br/><t size='1'>Tarjeta: Nivel %1<br/>Requerido: Nivel %2</t>", _playerLevelName, _requiredLevel];
		
		// Reproduce sonido de acceso concedido
		playSound3D ["A3\Sounds_F\sfx\beep_target.wss", _door, false, getPosASL _door, 2, 1, 15];
		
		// Abre la puerta
		_door animate ["door_1_rot", 1];
		
		// Cierra la puerta automáticamente después de 5 segundos
		[_door] spawn {
			params ["_door"];
			sleep 5;
			_door animate ["door_1_rot", 0];
		};
		
		true
	} else {
		// Acceso denegado
		private _playerData = [_player] call CYTECH_fnc_getPlayerAccessLevel;
		private _playerLevelName = _playerData select 1;
		
		if (_playerLevelName == "") then {
			systemChat "✗ ACCESO DENEGADO - No tienes ninguna tarjeta de acceso";
			hint parseText "<t color='#ff0000' size='1.5'>ACCESO DENEGADO</t><br/><t size='1'>No tienes tarjeta de acceso</t>";
		} else {
			systemChat format ["✗ ACCESO DENEGADO - Tarjeta nivel %1 insuficiente para nivel %2", _playerLevelName, _requiredLevel];
			hint parseText format ["<t color='#ff0000' size='1.5'>ACCESO DENEGADO</t><br/><t size='1'>Tu tarjeta: Nivel %1<br/>Se requiere: Nivel %2 o superior</t>", _playerLevelName, _requiredLevel];
		};
		
		// Reproduce sonido de acceso denegado (beep de error)
		playSound3D ["A3\Sounds_F\sfx\ui\Orange_NotificationDefault.wss", _door, false, getPosASL _door, 2, 0.8, 15];
		
		false
	};
};

// ===============================================
// FUNCIÓN: Añadir acción de lector de tarjetas a un objeto
// ===============================================
CYTECH_fnc_addCardReaderAction = {
	params ["_reader", "_door", "_requiredLevel"];
	
	private _actionText = format ["<t color='#00ffff'>🔒 Usar Lector de Tarjetas (Nivel %1)</t>", _requiredLevel];
	
	_reader addAction [
		_actionText,
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
			_arguments params ["_door", "_requiredLevel"];
			
			// Intenta abrir la puerta con verificación de acceso
			[_door, _requiredLevel, _caller] call CYTECH_fnc_openDoorWithAccess;
		},
		[_door, _requiredLevel],
		1.5,
		true,
		true,
		"",
		"true",
		3
	];
};

// ===============================================
// FUNCIÓN: Configurar lector con puerta automáticamente
// ===============================================
CYTECH_fnc_setupCardReader = {
	params ["_reader", "_door", "_requiredLevel"];
	
	// Valida el nivel requerido
	if !(_requiredLevel in CYTECH_AccessLevels) exitWith {
		systemChat format ["ERROR: Nivel '%1' no es válido. Usa: A, B, C, D o E", _requiredLevel];
	};
	
	// Añade la acción al lector
	[_reader, _door, _requiredLevel] call CYTECH_fnc_addCardReaderAction;
	
	// Marca el lector visualmente (opcional)
	private _marker = createVehicle ["Sign_Sphere10cm_F", getPos _reader, [], 0, "CAN_COLLIDE"];
	_marker attachTo [_reader, [0, 0, 0.5]];
	_marker setObjectTexture [0, format ["#(rgb,8,8,3)color(%1,%2,%3,1)", random 1, random 1, random 1, 1]];
	
	systemChat format ["✓ Lector de tarjetas configurado: Nivel %1 requerido", _requiredLevel];
};

// ===============================================
// FUNCIÓN: Dar tarjeta a un jugador
// ===============================================
CYTECH_fnc_giveCard = {
	params ["_player", "_level"];
	
	private _levelIndex = CYTECH_AccessLevels find _level;
	
	if (_levelIndex == -1) exitWith {
		systemChat format ["ERROR: Nivel '%1' no válido", _level];
	};
	
	private _cardClass = CYTECH_CardClasses select _levelIndex;
	_player addItem _cardClass;
	
	systemChat format ["✓ Tarjeta de nivel %1 entregada", _level];
	hint parseText format ["<t color='#00ff00' size='1.5'>TARJETA RECIBIDA</t><br/><t size='1'>Nivel de acceso: %1</t>", _level];
};

// ===============================================
// FUNCIÓN: Mostrar información de nivel de acceso
// ===============================================
CYTECH_fnc_showAccessInfo = {
	params ["_player"];
	
	private _accessData = [_player] call CYTECH_fnc_getPlayerAccessLevel;
	private _levelIndex = _accessData select 0;
	private _levelName = _accessData select 1;
	
	if (_levelIndex == -1) then {
		hint parseText "<t color='#ff0000' size='1.5'>SIN ACCESO</t><br/><t size='1'>No tienes ninguna tarjeta de acceso</t>";
	} else {
		private _accessibleLevels = "";
		for "_i" from 0 to _levelIndex do {
			_accessibleLevels = _accessibleLevels + (CYTECH_AccessLevels select _i) + " ";
		};
		
		hint parseText format [
			"<t color='#00ff00' size='1.5'>NIVEL DE ACCESO: %1</t><br/><t size='1'>Puedes acceder a niveles: %2</t>",
			_levelName,
			_accessibleLevels
		];
	};
};

// ===============================================
// EJEMPLOS DE USO
// ===============================================

/*
	EJEMPLO 1: Configurar un lector en el editor de Arma 3
	
	1. Coloca un objeto que hará de "lector" (por ejemplo, un terminal o tablet)
	   Dale el nombre: lector1
	   
	2. Coloca una puerta cerca
	   Dale el nombre: puerta1
	   
	3. En el campo init del lector, escribe:
	   [this, puerta1, "C"] call CYTECH_fnc_setupCardReader;
	   
	   Esto creará un lector que requiere tarjeta nivel C (o superior: D, E)
*/

/*
	EJEMPLO 2: Dar una tarjeta a un jugador desde el init.sqf
	
	[player, "D"] call CYTECH_fnc_giveCard;
	
	Esto le dará al jugador una tarjeta nivel D
*/

/*
	EJEMPLO 3: Verificar acceso manualmente
	
	private _tieneAcceso = [player, "B"] call CYTECH_fnc_checkAccess;
	if (_tieneAcceso) then {
		hint "Tienes acceso nivel B o superior";
	};
*/

/*
	EJEMPLO 4: Mostrar nivel de acceso del jugador
	
	[player] call CYTECH_fnc_showAccessInfo;
*/

/*
	EJEMPLO 5: Configurar múltiples lectores con diferentes niveles
	
	En el init.sqf:
	
	[lector1, puerta1, "A"] call CYTECH_fnc_setupCardReader;  // Área pública
	[lector2, puerta2, "B"] call CYTECH_fnc_setupCardReader;  // Área restringida
	[lector3, puerta3, "C"] call CYTECH_fnc_setupCardReader;  // Área confidencial
	[lector4, puerta4, "D"] call CYTECH_fnc_setupCardReader;  // Área alta seguridad
	[lector5, puerta5, "E"] call CYTECH_fnc_setupCardReader;  // Área máxima seguridad
*/

// ===============================================
// INICIALIZACIÓN AUTOMÁTICA
// ===============================================

// Si ejecutas este archivo directamente, muestra un mensaje de bienvenida
if (!isNil "player") then {
	systemChat "✓ Sistema de tarjetas Cytech cargado correctamente";
	systemChat "Niveles de acceso: A (bajo) → E (alto)";
	systemChat "Las tarjetas superiores pueden acceder a puertas de nivel inferior";
};

// ===============================================
// FIN DEL SCRIPT
// ===============================================

