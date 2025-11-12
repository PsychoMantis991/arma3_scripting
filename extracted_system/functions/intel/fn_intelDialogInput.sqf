/*
	═══════════════════════════════════════════════════════════════════
	FUNCIÓN: DIÁLOGO INTERACTIVO DE INTEL
	Permite configurar intel personalizada con inputs del usuario
	═══════════════════════════════════════════════════════════════════
*/

params [
	["_pos", [0,0,0], [[]]]
];

// Variable global para almacenar la configuración
INTEL_DIALOG_Config = nil;
INTEL_DIALOG_Active = true;

// ═════════════════════════════════════════════════════════════════════
// PASO 1: SELECCIONAR TIPO DE OBJETO DE INTEL
// ═════════════════════════════════════════════════════════════════════

private _intelTypes = [
	["Land_File1_F", "📄 Documento"],
	["Land_Laptop_unfolded_F", "💻 Laptop"],
	["Land_MobilePhone_smart_F", "📱 Teléfono"],
	["Land_Map_F", "🗺️ Mapa"],
	["Land_Tablet_02_F", "📲 Tablet"],
	["Land_File2_F", "📋 Carpeta"],
	["Land_Photos_V1_F", "📸 Fotografías"]
];

private _typeText = "<t size='1.5' color='#00FF00'>CONFIGURAR INTEL PERSONALIZADA</t><br/><br/>" +
	"<t size='1.2' color='#FFAA00'>PASO 1: Selecciona tipo de objeto</t><br/><br/>";

{
	_x params ["_class", "_name"];
	_typeText = _typeText + format ["<t size='1'>%1. %2</t><br/>", _forEachIndex + 1, _name];
} forEach _intelTypes;

_typeText = _typeText + "<br/><t size='0.9' color='#888888'>Escribe el número en el chat de lado</t>";

hint parseText _typeText;

// Esperar selección
INTEL_DIALOG_Step = 1;
INTEL_DIALOG_TypeSelected = nil;

// Listener temporal para chat
INTEL_DIALOG_ChatHandler = addMissionEventHandler ["HandleChatMessage", {
	params ["_channel", "_owner", "_from", "_text"];
	
	// Solo procesar si el diálogo está activo y es chat de lado
	if (!INTEL_DIALOG_Active || _channel != 5) exitWith {false};
	
	private _num = parseNumber _text;
	
	// PASO 1: Selección de tipo
	if (INTEL_DIALOG_Step == 1) exitWith {
		if (_num < 1 || _num > 7) exitWith {
			hint "Número inválido. Usa 1-7";
			false
		};
		
		private _types = [
			["Land_File1_F", "📄 Documento"],
			["Land_Laptop_unfolded_F", "💻 Laptop"],
			["Land_MobilePhone_smart_F", "📱 Teléfono"],
			["Land_Map_F", "🗺️ Mapa"],
			["Land_Tablet_02_F", "📲 Tablet"],
			["Land_File2_F", "📋 Carpeta"],
			["Land_Photos_V1_F", "📸 Fotografías"]
		];
		
		private _selected = _types select (_num - 1);
		INTEL_DIALOG_TypeSelected = _selected select 0;
		INTEL_DIALOG_Step = 2;
		
		hint parseText format [
			"<t size='1.5' color='#00FF00'>✓ TIPO SELECCIONADO</t><br/><br/>" +
			"<t size='1.2'>%1</t><br/><br/>" +
			"<t size='1.2' color='#FFAA00'>PASO 2: Escribe el mensaje de intel</t><br/><br/>" +
			"<t size='0.9' color='#888888'>Escribe en el chat de lado el texto que quieres mostrar<br/>" +
			"Ejemplo: 'Los enemigos planean atacar al amanecer'</t>",
			_selected select 1
		];
		
		true
	};
	
	// PASO 2: Mensaje de intel
	if (INTEL_DIALOG_Step == 2) exitWith {
		INTEL_DIALOG_Message = _text;
		INTEL_DIALOG_Step = 3;
		
		hint parseText format [
			"<t size='1.5' color='#00FF00'>✓ MENSAJE CONFIGURADO</t><br/><br/>" +
			"<t size='1'>Mensaje:</t> <t color='#FFAA00'>%1</t><br/><br/>" +
			"<t size='1.2' color='#FFAA00'>PASO 3: ¿Crear marcador oculto?</t><br/><br/>" +
			"<t size='1'>1. Sí - Crear marcador oculto</t><br/>" +
			"<t size='1'>2. No - Solo mensaje</t><br/><br/>" +
			"<t size='0.9' color='#888888'>Escribe 1 o 2</t>",
			_text
		];
		
		true
	};
	
	// PASO 3: ¿Crear marcador?
	if (INTEL_DIALOG_Step == 3) exitWith {
		if (_num != 1 && _num != 2) exitWith {
			hint "Opción inválida. Usa 1 o 2";
			false
		};
		
		INTEL_DIALOG_CreateMarker = (_num == 1);
		
		if (INTEL_DIALOG_CreateMarker) then {
			INTEL_DIALOG_Step = 4;
			
			hint parseText (
				"<t size='1.5' color='#00FF00'>✓ MARCADOR ACTIVADO</t><br/><br/>" +
				"<t size='1.2' color='#FFAA00'>PASO 4: Posición del marcador</t><br/><br/>" +
				"<t size='1'>Escribe las coordenadas del marcador</t><br/>" +
				"<t size='0.9' color='#888888'>Formato: X,Y<br/>" +
				"Ejemplo: 15234,18567<br/><br/>" +
				"Puedes hacer Ctrl+Clic en el mapa para obtener las coordenadas</t>"
			);
		} else {
			// Finalizar sin marcador
			INTEL_DIALOG_Step = 99;
			[] spawn {
				sleep 0.5;
				[] call INTEL_DIALOG_finalize;
			};
			
			hint parseText (
				"<t size='1.5' color='#00FF00'>✓ CONFIGURACIÓN COMPLETA</t><br/><br/>" +
				"<t size='1'>Creando intel...</t>"
			);
		};
		
		true
	};
	
	// PASO 4: Posición del marcador
	if (INTEL_DIALOG_Step == 4) exitWith {
		// Parsear coordenadas X,Y
		private _coords = _text splitString ",";
		
		if (count _coords != 2) exitWith {
			hint parseText (
				"<t color='#FF4444'>Formato inválido</t><br/><br/>" +
				"<t size='0.9'>Usa: X,Y<br/>Ejemplo: 15234,18567</t>"
			);
			false
		};
		
		private _x = parseNumber (_coords select 0);
		private _y = parseNumber (_coords select 1);
		
		if (_x == 0 || _y == 0) exitWith {
			hint "Coordenadas inválidas";
			false
		};
		
		INTEL_DIALOG_MarkerPos = [_x, _y, 0];
		INTEL_DIALOG_Step = 5;
		
		hint parseText format [
			"<t size='1.5' color='#00FF00'>✓ POSICIÓN CONFIGURADA</t><br/><br/>" +
			"<t size='1'>Coordenadas:</t> <t color='#FFAA00'>%1</t><br/><br/>" +
			"<t size='1.2' color='#FFAA00'>PASO 5: Tipo de marcador</t><br/><br/>" +
			"<t size='1'>1. 📍 Ubicación enemiga</t><br/>" +
			"<t size='1'>2. 💣 Cache de armas</t><br/>" +
			"<t size='1'>3. 🎯 Objetivo importante</t><br/>" +
			"<t size='1'>4. 🏠 Edificio de interés</t><br/>" +
			"<t size='1'>5. ⚠️ Zona peligrosa</t><br/><br/>" +
			"<t size='0.9' color='#888888'>Escribe el número (1-5)</t>",
			mapGridPosition [_x, _y, 0]
		];
		
		true
	};
	
	// PASO 5: Tipo de marcador
	if (INTEL_DIALOG_Step == 5) exitWith {
		if (_num < 1 || _num > 5) exitWith {
			hint "Número inválido. Usa 1-5";
			false
		};
		
		private _markerTypes = [
			["mil_objective", "ColorRed", "Ubicación enemiga"],
			["hd_destroy", "ColorOrange", "Cache de armas"],
			["hd_objective", "ColorYellow", "Objetivo importante"],
			["loc_bunker", "ColorBlue", "Edificio de interés"],
			["hd_warning", "ColorRed", "Zona peligrosa"]
		];
		
		private _markerConfig = _markerTypes select (_num - 1);
		INTEL_DIALOG_MarkerType = _markerConfig select 0;
		INTEL_DIALOG_MarkerColor = _markerConfig select 1;
		INTEL_DIALOG_Step = 6;
		
		hint parseText format [
			"<t size='1.5' color='#00FF00'>✓ TIPO DE MARCADOR</t><br/><br/>" +
			"<t size='1.2'>%1</t><br/><br/>" +
			"<t size='1.2' color='#FFAA00'>PASO 6: Texto del marcador</t><br/><br/>" +
			"<t size='0.9' color='#888888'>Escribe el texto que aparecerá en el marcador<br/>" +
			"Ejemplo: 'Posible campamento enemigo'</t>",
			_markerConfig select 2
		];
		
		true
	};
	
	// PASO 6: Texto del marcador
	if (INTEL_DIALOG_Step == 6) exitWith {
		INTEL_DIALOG_MarkerText = _text;
		INTEL_DIALOG_Step = 99;
		
		// Finalizar
		[] spawn {
			sleep 0.5;
			[] call INTEL_DIALOG_finalize;
		};
		
		hint parseText format [
			"<t size='1.5' color='#00FF00'>✓ CONFIGURACIÓN COMPLETA</t><br/><br/>" +
			"<t size='1'>Marcador:</t> <t color='#FFAA00'>%1</t><br/><br/>" +
			"<t size='1'>Creando intel...</t>",
			_text
		];
		
		true
	};
	
	false
}];

// ═════════════════════════════════════════════════════════════════════
// FUNCIÓN: FINALIZAR Y CREAR INTEL
// ═════════════════════════════════════════════════════════════════════

INTEL_DIALOG_finalize = {
	// Eliminar event handler
	removeMissionEventHandler ["HandleChatMessage", INTEL_DIALOG_ChatHandler];
	INTEL_DIALOG_Active = false;
	
	// Obtener configuración
	private _objectClass = INTEL_DIALOG_TypeSelected;
	private _message = INTEL_DIALOG_Message;
	private _createMarker = INTEL_DIALOG_CreateMarker;
	private _markerPos = if (!isNil "INTEL_DIALOG_MarkerPos") then {INTEL_DIALOG_MarkerPos} else {[0,0,0]};
	private _markerType = if (!isNil "INTEL_DIALOG_MarkerType") then {INTEL_DIALOG_MarkerType} else {"mil_objective"};
	private _markerColor = if (!isNil "INTEL_DIALOG_MarkerColor") then {INTEL_DIALOG_MarkerColor} else {"ColorRed"};
	private _markerText = if (!isNil "INTEL_DIALOG_MarkerText") then {INTEL_DIALOG_MarkerText} else {"Intel"};
	private _pos = INTEL_DIALOG_Position;
	
	// Crear intel en el servidor
	[
		_pos,
		_objectClass,
		_message,
		_createMarker,
		_markerPos,
		_markerType,
		_markerColor,
		_markerText
	] remoteExec ["INTEL_createCustomIntel", 2];
	
	// Limpiar variables
	INTEL_DIALOG_TypeSelected = nil;
	INTEL_DIALOG_Message = nil;
	INTEL_DIALOG_CreateMarker = nil;
	INTEL_DIALOG_MarkerPos = nil;
	INTEL_DIALOG_MarkerType = nil;
	INTEL_DIALOG_MarkerColor = nil;
	INTEL_DIALOG_MarkerText = nil;
	INTEL_DIALOG_Position = nil;
	INTEL_DIALOG_Step = nil;
	INTEL_DIALOG_ChatHandler = nil;
	
	diag_log "[INTEL_DIALOG] Diálogo completado y intel creada";
};

// Guardar posición para usar después
INTEL_DIALOG_Position = _pos;

diag_log "[INTEL_DIALOG] Diálogo de intel iniciado";

