# 🔐 Sistema de Tarjetas de Acceso para Arma 3 - Mod Cytech

## 📋 Descripción

Sistema jerárquico de control de acceso mediante tarjetas para Arma 3 utilizando el mod Cytech. Las tarjetas tienen niveles del A al E, donde una tarjeta de nivel superior puede acceder a todas las puertas de niveles inferiores.

## 📊 Niveles de Acceso

| Nivel | Descripción | Puede acceder a |
|-------|-------------|----------------|
| **A** | Más bajo - Áreas públicas | Solo nivel A |
| **B** | Bajo - Áreas restringidas | Niveles A, B |
| **C** | Medio - Áreas confidenciales | Niveles A, B, C |
| **D** | Alto - Alta seguridad | Niveles A, B, C, D |
| **E** | Máximo - Máxima seguridad | Todos los niveles (A, B, C, D, E) |

### Ejemplos de Jerarquía:
- ✅ Tarjeta **E** puede abrir puertas A, B, C, D y E
- ✅ Tarjeta **C** puede abrir puertas A, B y C
- ❌ Tarjeta **B** NO puede abrir puertas C, D o E
- ❌ Tarjeta **A** SOLO puede abrir puertas A

## 🚀 Instalación

### Paso 1: Copiar el Script
1. Copia el archivo `cytech_card_reader.sqf` a la carpeta de tu misión
2. Por ejemplo: `MPMissions\TuMision.Altis\cytech_card_reader.sqf`

### Paso 2: Cargar el Script
En tu archivo `init.sqf`, añade al principio:

```sqf
// Cargar sistema de tarjetas Cytech
execVM "cytech_card_reader.sqf";
```

## 📖 Guía de Uso

### 1️⃣ Configurar un Lector de Tarjetas

#### En el Editor de Arma 3:

1. **Coloca un objeto para el lector** (puede ser un terminal, tablet, o cualquier objeto)
   - Dale un nombre, por ejemplo: `lector1`

2. **Coloca una puerta cerca**
   - Dale un nombre, por ejemplo: `puerta1`

3. **En el campo INIT del lector**, escribe:
```sqf
[this, puerta1, "C"] call CYTECH_fnc_setupCardReader;
```

Esto crea un lector que requiere tarjeta nivel **C** o superior (D, E).

#### Ejemplo con múltiples puertas:

```sqf
// En init.sqf o en cada lector:

// Entrada principal - cualquier tarjeta
[lector_entrada, puerta_entrada, "A"] call CYTECH_fnc_setupCardReader;

// Oficinas - personal autorizado
[lector_oficinas, puerta_oficinas, "B"] call CYTECH_fnc_setupCardReader;

// Laboratorio - científicos
[lector_lab, puerta_lab, "C"] call CYTECH_fnc_setupCardReader;

// Armería - seguridad alta
[lector_armeria, puerta_armeria, "D"] call CYTECH_fnc_setupCardReader;

// Sala de servidores - acceso máximo
[lector_servidores, puerta_servidores, "E"] call CYTECH_fnc_setupCardReader;
```

### 2️⃣ Dar Tarjetas a Jugadores

#### Método 1: En el init.sqf
```sqf
// Dar tarjeta nivel D al jugador
[player, "D"] call CYTECH_fnc_giveCard;
```

#### Método 2: Como recompensa por misión
```sqf
// Cuando el jugador completa un objetivo
if (objetivo1_completado) then {
    [player, "C"] call CYTECH_fnc_giveCard;
    hint "Has obtenido una tarjeta de acceso nivel C";
};
```

#### Método 3: Desde un objeto (por ejemplo, una caja)
```sqf
// En el campo INIT de una caja o cadáver:
this addAction [
    "Recoger Tarjeta de Acceso Nivel E",
    {
        params ["_target", "_caller"];
        [_caller, "E"] call CYTECH_fnc_giveCard;
        _target removeAction (_this select 2);
    }
];
```

### 3️⃣ Verificar Nivel de Acceso

#### Mostrar nivel de acceso del jugador:
```sqf
[player] call CYTECH_fnc_showAccessInfo;
```

#### Verificar acceso programáticamente:
```sqf
private _tieneAcceso = [player, "C"] call CYTECH_fnc_checkAccess;

if (_tieneAcceso) then {
    hint "Tienes acceso nivel C o superior";
} else {
    hint "Necesitas tarjeta nivel C o superior";
};
```

## 🎮 Escenario de Ejemplo Completo

### Misión: Infiltración en Base Militar

```sqf
// En init.sqf

// Cargar sistema
execVM "cytech_card_reader.sqf";

// Configurar puertas
[lector1, puerta_entrada, "A"] call CYTECH_fnc_setupCardReader;
[lector2, puerta_barracas, "B"] call CYTECH_fnc_setupCardReader;
[lector3, puerta_comando, "D"] call CYTECH_fnc_setupCardReader;
[lector4, puerta_bunker, "E"] call CYTECH_fnc_setupCardReader;

// Dar tarjeta inicial al jugador (nivel bajo)
[player, "A"] call CYTECH_fnc_giveCard;

// Crear trigger para obtener tarjeta B al eliminar guardia
guardia1 addEventHandler ["Killed", {
    params ["_unit", "_killer"];
    [_killer, "B"] call CYTECH_fnc_giveCard;
    hint "Has obtenido la tarjeta del guardia (Nivel B)";
}];

// Tarjeta D en una caja fuerte
caja_fuerte addAction [
    "Tomar Tarjeta de Comandante",
    {
        [player, "D"] call CYTECH_fnc_giveCard;
    }
];
```

## ⚙️ Personalización Avanzada

### Cambiar Nombres de las Clases de Tarjetas

Si el mod Cytech usa nombres diferentes, edita esta línea en el script:

```sqf
CYTECH_CardClasses = [
    "cytech_item_idcard_a",  // Cambia estos nombres
    "cytech_item_idcard_b",
    "cytech_item_idcard_c",
    "cytech_item_idcard_d",
    "cytech_item_idcard_e"
];
```

### Cambiar Tiempo de Cierre Automático de Puertas

En la función `CYTECH_fnc_openDoorWithAccess`, busca:

```sqf
sleep 5;  // Cambia el 5 por los segundos que quieras
```

### Cambiar Animación de Puerta

Si tus puertas usan una animación diferente, cambia:

```sqf
_door animate ["door_1_rot", 1];  // Cambia "door_1_rot" por el nombre de tu animación
```

## 🔧 Solución de Problemas

### ❌ La puerta no se abre
- Verifica que el nombre de la animación sea correcto
- Revisa los nombres del lector y la puerta
- Asegúrate de que el script se cargó correctamente

### ❌ No aparece la acción en el lector
- Verifica que estés lo suficientemente cerca (3 metros)
- Comprueba que la función `setupCardReader` se haya llamado correctamente

### ❌ El jugador no tiene tarjeta aunque se le dio
- Verifica que los nombres de clase de las tarjetas coincidan con los del mod Cytech
- Revisa que el inventario del jugador no esté lleno

## 📝 Funciones Disponibles

| Función | Descripción | Parámetros |
|---------|-------------|------------|
| `CYTECH_fnc_setupCardReader` | Configura un lector con una puerta | `[lector, puerta, nivel]` |
| `CYTECH_fnc_giveCard` | Da una tarjeta a un jugador | `[jugador, nivel]` |
| `CYTECH_fnc_checkAccess` | Verifica si tiene acceso | `[jugador, nivel]` |
| `CYTECH_fnc_showAccessInfo` | Muestra nivel actual | `[jugador]` |
| `CYTECH_fnc_openDoorWithAccess` | Abre puerta si tiene acceso | `[puerta, nivel, jugador]` |

## 💡 Ideas de Uso

1. **Sistema de Seguridad Progresivo**: El jugador comienza con tarjeta A y debe encontrar tarjetas superiores
2. **Roles Multiplayer**: Diferentes jugadores con diferentes niveles de acceso
3. **Modo Supervivencia**: Las tarjetas son recursos valiosos
4. **Infiltración**: Robar tarjetas de enemigos para acceder a áreas restringidas
5. **Torre de Oficinas**: Cada piso requiere un nivel de acceso superior

## 🎯 Compatibilidad

- ✅ Arma 3
- ✅ Mod Cytech (ajustar nombres de clase si es necesario)
- ✅ Singleplayer
- ✅ Multiplayer (compatible)
- ✅ Dedicado Server (compatible)

## 📧 Notas Finales

Este script es totalmente personalizable. Siéntete libre de modificarlo según las necesidades de tu misión. La lógica jerárquica de las tarjetas hace que sea fácil crear sistemas de seguridad realistas y desafiantes.

¡Buena suerte con tu misión! 🎖️

