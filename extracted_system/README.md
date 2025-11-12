# 🎖️ SISTEMA DE SPAWN Y TAREAS PARA ZEUS

Sistema completo de generación manual de unidades, estructuras y tareas extraído de Dynamic Recon Ops (DRO) y adaptado para uso exclusivo de Zeus.

---

## 📋 ÍNDICE

1. [Instalación](#-instalación)
2. [Uso Rápido](#-uso-rápido)
3. [Selector de Facciones](#-selector-de-facciones)
4. [Funciones de Spawn](#-funciones-de-spawn)
5. [Sistema de Tareas](#-sistema-de-tareas)
6. [Estructuras y Fortificaciones](#-estructuras-y-fortificaciones)
7. [Sistema de Intel](#-sistema-de-intel)
8. [IEDs y Explosivos](#-ieds-y-explosivos)
9. [Comandos Rápidos](#-comandos-rápidos)
10. [Solución de Problemas](#-solución-de-problemas)

---

## 📦 INSTALACIÓN

### 1️⃣ Copiar archivos
Copia la carpeta `extracted_system` a la raíz de tu misión.

### 2️⃣ Inicializar el sistema
En tu `init.sqf` (o crear uno si no existe):

```sqf
[] execVM "extracted_system\init.sqf";
```

### 3️⃣ Asignar Zeus
1. Coloca un módulo **Zeus** en el editor (F5 → Módulos → Zeus)
2. Sincroniza el módulo Zeus con el slot del jugador que será Zeus
3. **Importante**: El sistema solo funciona si tienes un curator asignado

### 4️⃣ ¡Listo!
Cuando entres como Zeus, verás un mensaje de bienvenida y tendrás acceso al menú de spawn.

---

## 🚀 USO RÁPIDO

### Abrir el menú de spawn:
1. **Usa la acción** "Toggle Menú de Spawn" (en tu lista de acciones)
2. **Abre el mapa** (tecla `M`)
3. **Haz clic derecho** donde quieras generar algo
4. **Selecciona** lo que quieres generar del menú

### Cambiar facciones:
- Usa las acciones en tu rueda de scroll:
  - 🔴 Cambiar Facción OPFOR (Enemigos)
  - 🔵 Cambiar Facción BLUFOR (Aliados)
  - 🟢 Cambiar Facción INDEPENDENT
  - ⚪ Cambiar Facción CIVILIAN (Civiles)

---

## 🎖️ SELECTOR DE FACCIONES

### Detección automática de mods
El sistema detecta automáticamente las facciones disponibles de:
- ✅ **Vanilla Arma 3** (CSAT, NATO, AAF, FIA)
- ✅ **RHS** (USAF, AFRF, GREF, SAF)
- ✅ **CUP** (Ejércitos del mundo)
- ✅ **3CB Factions** (CSAT variants, AAF, ADA, etc.)
- ✅ **Otros mods** (automático)

### Cómo cambiar facciones:
1. Usa la acción correspondiente (ej: "🎖️ Cambiar Facción OPFOR")
2. Se abrirá un diálogo con todas las facciones detectadas
3. Selecciona la facción deseada
4. Confirma tu selección
5. **Todas las unidades futuras** usarán esta facción

### Información mostrada:
- **Nombre de la facción** (legible)
- **Lado** (OPFOR, BLUFOR, etc.)
- **Nombre de clase** (interno del juego)

---

## 🪖 FUNCIONES DE SPAWN

### 👥 INFANTERÍA

#### **Grupo de Infantería Estándar**
- **Descripción**: Escuadra de 4-8 soldados
- **Opciones**:
  - Con/sin patrulla automática
  - Radio de patrulla configurable
- **Uso**: Ideal para guarniciones, patrullas, defensas

#### **Guarnición en Edificios**
- **Descripción**: Unidades distribuidas en posiciones de edificios cercanos
- **Opciones**:
  - Cantidad de unidades (1-20)
  - Radio de búsqueda de edificios (50-500m)
- **Uso**: Defender pueblos, bases, puntos estratégicos
- **Nota**: Busca automáticamente posiciones de fuego en ventanas/terrazas

### 🚗 VEHÍCULOS

#### **Patrulla de Vehículo**
- **Descripción**: Vehículo con tripulación completa
- **Tipos disponibles**:
  - 🚙 **MRAP** (4x4 blindado ligero)
  - 🚛 **APC** (Transporte blindado de personal)
  - 🛡️ **IFV** (Vehículo de combate de infantería)
  - 🎯 **Tanque** (Carro de combate principal)
  - 🚁 **Helicóptero** (Transporte o ataque)
- **Opciones**:
  - Con/sin patrulla automática
  - Radio de patrulla configurable
- **Nota**: Tripulación completa (conductor, artillero, comandante)

### 👔 CIVILES

#### **Grupo de Civiles**
- **Descripción**: 1-5 civiles caminando
- **Comportamiento**: Se mueven aleatoriamente por la zona
- **Uso**: Poblar ciudades, crear ambiente

#### **Vehículo Civil**
- **Descripción**: Vehículo civil con conductor
- **Tipos**: Coches, furgonetas, camiones según facción
- **Comportamiento**: Conduce por carreteras cercanas

---

## 🏗️ ESTRUCTURAS Y FORTIFICACIONES

### 🏕️ CAMPAMENTOS

#### **Campamento Pequeño**
- **Contenido**:
  - 2-3 tiendas de campaña
  - Fogata
  - Cajones de suministros
  - 2-4 unidades de guardia
- **Radio**: ~15-20m
- **Uso**: Puesto avanzado, patrulla descansando

#### **Campamento Mediano**
- **Contenido**:
  - 4-6 tiendas
  - Área de mando
  - Suministros y cajas de munición
  - 4-6 unidades
  - Posibles vehículos ligeros
- **Radio**: ~25-35m
- **Uso**: Base temporal, punto de reagrupación

#### **Campamento Grande**
- **Contenido**:
  - 8-12 tiendas
  - Centro de mando
  - Armería
  - Depósito de suministros
  - 8-12 unidades
  - Vehículos (MRAP, camiones)
  - Perímetro defensivo
- **Radio**: ~40-60m
- **Uso**: Base operacional, cuartel general

### 🏰 FOBs (Forward Operating Base)

#### **Características Generales**
- **Forma**: Cuadrada con barreras H (H-barriers)
- **Defensa**: Watchtowers, bunkers, guardias
- **Interior**: Tiendas, suministros, vehículos
- **Estados**: Pristino, Dañado, Ruinado

#### **FOB Pequeño**
- **Tamaño**: ~30x30m
- **Barreras**: Espaciadas (menos densas)
- **Guarnición**: 4-6 unidades
- **Torres**: 2 watchtowers
- **Vehículos**: 1-2 ligeros
- **Uso**: Puesto de observación, checkpoint avanzado

#### **FOB Mediano**
- **Tamaño**: ~50x50m
- **Barreras**: Densidad media
- **Guarnición**: 8-12 unidades
- **Torres**: 4 watchtowers
- **Bunkers**: 1-2 bunkers
- **Vehículos**: 2-4 (MRAP, APC)
- **Uso**: Base operativa estándar

#### **FOB Grande**
- **Tamaño**: ~80x80m
- **Barreras**: Muy densas (perímetro completo)
- **Guarnición**: 12-20 unidades
- **Torres**: 6-8 watchtowers
- **Bunkers**: 3-4 bunkers
- **Vehículos**: 4-8 (incluyendo tanques)
- **Uso**: Base principal, hub logístico

#### **Opciones de Bando**
- **Enemigo** (OPFOR): Guarnición hostil completa
- **Aliado** (BLUFOR/INDEPENDENT): Base amiga
- **Vacío**: Sin unidades (para conquista/captura)

### 🚧 ROADBLOCKS

#### **Roadblock Pequeño**
- **Barreras**: 2-3 H-barriers + 1 lift barrier
- **Personal**: 2-4 guardias
- **Torres**: 1 watchtower pequeño
- **Uso**: Control de tráfico simple
- **Tamaño**: ~15-20m de ancho

#### **Roadblock Grande**
- **Barreras**: 6-8 H-barriers + 2 lift barriers (entrada/salida)
- **Personal**: 6-10 guardias (mínimo 2 por puerta)
- **Torres**: 2 watchtowers o bunkers
- **Patrullas**: 1-2 patrullas de 4 hombres
- **Extra**: Sacos de arena, alambradas, luces
- **Uso**: Checkpoint militar fortificado
- **Tamaño**: ~40-50m de ancho

#### **Colocación Automática**
- ✅ Se orienta automáticamente según la carretera
- ✅ Barreras levadizas funcionales
- ✅ Guardias en posiciones estratégicas
- ✅ Patrullas cubren flancos (roadblock grande)

### 🏘️ COMPOUND / ÁREA FORTIFICADA

#### **Descripción**
Área delimitada por vallas/muros con estructuras internas.

#### **Contenido**
- Perímetro con vallas (Hesco, alambre, muros)
- Búnkeres en esquinas
- Estructuras internas (cobertizos, almacenes)
- Guarnición distribuida
- Vehículos de patrulla

#### **Opciones**
- Tamaño del área (radio)
- Nivel de defensa (ligero, medio, pesado)
- Cantidad de guarnición

---

## 📋 SISTEMA DE TAREAS

### Tareas Hostiles (OPFOR)

#### 🎯 **HVT (High Value Target)**
- **Objetivo**: Capturar o eliminar un objetivo de alto valor
- **Generación**:
  - Oficial enemigo de alto rango
  - Escolta de 2-4 guardaespaldas
  - Posible vehículo de transporte
- **Condiciones de éxito**:
  - **Captura**: HVT inconsciente o rendido y en custodia
  - **Eliminación**: HVT muerto
- **Extras**: Intel sobre ubicación de otros objetivos

#### 📄 **Intel**
- **Objetivo**: Recuperar documentos/laptop con información
- **Generación**:
  - Laptop o documentos en edificio/campamento
  - Posibles guardias
  - Puede estar en vehículo
- **Condiciones de éxito**:
  - Jugador toma el objeto de intel
  - Aparece marcador para "Extraer Intel"
  - Completar cuando se extrae de la zona
- **Extras**: Revela posiciones enemigas en el mapa

#### 💣 **Cache de Armas**
- **Objetivo**: Destruir alijo de armas/municiones
- **Generación**:
  - 3-6 cajones de munición
  - Guardias (4-8 unidades)
  - Posible campamento asociado
- **Condiciones de éxito**:
  - Destruir todos los cajones
  - Puede hacerse con explosivos, fuego, etc.
- **Extras**: Puede revelar otras caches cercanas

#### 🏴 **Limpiar Área**
- **Objetivo**: Eliminar todas las fuerzas enemigas en un área
- **Generación**:
  - Múltiples grupos enemigos (3-5)
  - Posibles vehículos
  - Área definida (círculo de 100-300m)
- **Condiciones de éxito**:
  - Todos los enemigos en el área muertos o rendidos
  - Se verifica cada 5 segundos
- **Extras**: Suele preceder a establecer una FOB

#### 🚁 **POW (Prisionero de Guerra)**
- **Objetivo**: Rescatar prisioneros enemigos cautivos
- **Generación**:
  - 1-3 prisioneros (aliados desarmados)
  - Guardias enemigos (4-6)
  - Edificio o jaula improvisada
- **Condiciones de éxito**:
  - Liberar prisioneros (eliminar guardias)
  - Escoltar a zona segura
- **Extras**: Prisioneros dan información (intel)

#### 🚙 **Vehículo Objetivo**
- **Objetivo**: Destruir o capturar vehículo enemigo
- **Generación**:
  - Vehículo de alto valor (APC, tanque, etc.)
  - Tripulación
  - Posible escolta
- **Opciones**:
  - **Destruir**: Simplemente destruir el vehículo
  - **Robar**: Tripulación aliada debe entrar
- **Condiciones de éxito**:
  - Destruir: Vehículo destruido
  - Robar: Aliado conduce el vehículo a zona segura

### Tareas Neutrales (Civiles)

#### 💣 **Desarmar IED**
- **Objetivo**: Desactivar artefacto explosivo improvisado
- **Generación**:
  - IED colocado (mina, bomba, trampa)
  - Posibles civiles en peligro cercanos
- **Condiciones de éxito**:
  - **Con ACE**: Usar sistema de desactivación ACE
  - **Sin ACE**: Aproximarse y mantener scroll "Desarmar IED"
- **Peligro**: Puede explotar si fallas
- **Extras**: Puede revelar célula terrorista cercana

#### 👨‍👩‍👧 **Proteger Civiles**
- **Objetivo**: Defender grupo de civiles de ataque
- **Generación**:
  - 3-8 civiles en zona
  - Oleadas de atacantes enemigos
  - Tiempo límite (10-15 min)
- **Condiciones de éxito**:
  - Mantener vivos al menos el 50% de civiles
  - Repeler todos los ataques
  - Sobrevivir el tiempo límite
- **Fallo**: Si mueren demasiados civiles

### Creación de Tareas

#### Desde el Menú de Mapa:
1. Abre el mapa (M)
2. Activa el menú de spawn
3. Click derecho donde quieres la tarea
4. Selecciona "📋 TAREAS" → Tipo de tarea
5. Configura opciones en el diálogo
6. Confirma

#### Opciones Configurables:
- **Nombre de la tarea**: Título que verán los jugadores
- **Descripción**: Briefing detallado
- **Radio del objetivo**: Área de operaciones
- **Número de enemigos**: Dificultad
- **Extras**: Intel, refuerzos, etc.

#### Sistema de Estados:
- ⏳ **CREATED**: Tarea asignada
- ▶️ **ASSIGNED**: En progreso
- ✅ **SUCCEEDED**: Completada con éxito
- ❌ **FAILED**: Fallada
- ⛔ **CANCELED**: Cancelada por Zeus

---

## 🕵️ SISTEMA DE INTEL

### Intel Automático (Tareas)

Cuando se completan ciertas tareas, se genera intel automáticamente:

#### **Intel de HVT**
- Revela: Posición de otros oficiales enemigos
- Radio: 1000m
- Duración: 10 minutos

#### **Intel de Cache**
- Revela: Otras caches de armas cercanas
- Radio: 500m
- Duración: 15 minutos

#### **Intel de Documentos**
- Revela: Todas las unidades enemigas en área
- Radio: 2000m
- Duración: 20 minutos

### Intel Manual (Objetos del Editor)

#### **Opción 1: Usar Zeus**
1. Coloca un objeto de intel (laptop, documentos) desde Zeus
2. Añade una acción personalizada:
```sqf
this addAction [
    "Tomar Intel",
    {
        hint "Intel recuperado!";
        deleteVehicle (_this select 0);
        // Tu código aquí
    }
];
```

#### **Opción 2: Usar Editor 3DEN**
1. Coloca objeto (ej: `Land_Laptop_03_black_F`)
2. En Init del objeto:
```sqf
this addAction [
    "<t color='#00FF00'>📄 Recuperar Intel</t>",
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        
        // Mensaje al jugador
        ["Intel Recuperado", "Has encontrado información valiosa"] remoteExec ["BIS_fnc_showNotification", _caller];
        
        // Revelar enemigos (opcional)
        [_caller, 1000] call FN_revealIntelInArea;  // Si usas funciones del sistema
        
        // Eliminar objeto
        deleteVehicle _target;
    },
    nil,
    1.5,
    true,
    true,
    "",
    "_this distance _target < 3"
];
```

### Funciones de Intel Disponibles

#### `FN_revealIntelInArea`
Revela unidades enemigas en un área.

```sqf
// Uso:
[jugador, radio] call FN_revealIntelInArea;

// Ejemplo:
[player, 1500] call FN_revealIntelInArea;  // Revela 1.5km alrededor
```

#### `FN_addIntelMarker`
Añade marcador de intel en el mapa.

```sqf
// Uso:
[posicion, nombre, descripcion, duracion] call FN_addIntelMarker;

// Ejemplo:
[getPos player, "Campamento Enemigo", "Intel indica presencia enemiga", 600] call FN_addIntelMarker;
```

---

## 💣 IEDS Y EXPLOSIVOS

### Detección de ACE

El sistema detecta automáticamente si ACE3 está instalado y adapta su comportamiento.

### Con ACE3 Instalado

#### **IEDs Interactivos**
- Usa el sistema completo de explosivos ACE
- Requiere **Especialista EOD** para desactivar
- Sistema realista de desactivación:
  1. Aproximarse al IED
  2. Usar ACción ACE "Interactuar"
  3. Seleccionar "Desactivar explosivo"
  4. Esperar tiempo de desactivación
  5. Posibilidad de fallo (explosión)

#### **Tipos de IEDs ACE**
- `ACE_IEDUrbanSmall_Range_Ammo`
- `ACE_IEDUrbanBig_Range_Ammo`
- `ACE_IEDLandSmall_Range_Ammo`
- `ACE_IEDLandBig_Range_Ammo`

### Sin ACE3

#### **IEDs Simplificados**
- Usa minas de Arma 3 vanilla
- Desactivación mediante scroll:
  1. Aproximarse al IED (<5m)
  2. Usar acción "Desarmar IED"
  3. Mantener 5 segundos
  4. IED desactivado

#### **Tipos de IEDs Vanilla**
- `APERSBoundingMine`
- `APERSTripMine`
- `ATMine`
- `SLAMDirectionalMine`

### Colocación de IEDs

#### **Manual (Zeus)**
1. Abre Zeus
2. Coloca objeto de tipo "Mina" o "IED"
3. El sistema lo detectará automáticamente

#### **Desde el Sistema**
*(Nota: Actualmente no implementado en menú, pero puedes llamar función)*

```sqf
// Crear IED en posición
[getPos player, "URBAN", "SMALL"] call FN_createIED;

// Parámetros:
// - Posición [x,y,z]
// - Tipo: "URBAN" o "LAND"
// - Tamaño: "SMALL" o "BIG"
```

---

## ⌨️ COMANDOS RÁPIDOS

### Acciones del Jugador Zeus

#### **Menú Principal**
- 📍 **Toggle Menú de Spawn**: Activa/desactiva el menú en el mapa

#### **Cambio de Facciones**
- 🔴 **Cambiar Facción OPFOR**: Selecciona enemigos
- 🔵 **Cambiar Facción BLUFOR**: Selecciona aliados
- 🟢 **Cambiar Facción INDEPENDENT**: Selecciona independientes
- ⚪ **Cambiar Facción CIVILIAN**: Selecciona civiles

#### **Limpieza**
- 🗑️ **LIMPIAR TODO**: Elimina todas las unidades generadas (¡CUIDADO!)

### Comandos de Consola Debug

Abre la consola (Ctrl + D en Zeus) y ejecuta:

#### **Listar Facciones Detectadas**
```sqf
{
    systemChat format ["Facción: %1 (%2)", _x select 0, _x select 2];
} forEach SPAWN_availableFactionsData;
```

#### **Ver Facción Actual**
```sqf
hint format [
    "OPFOR: %1\nBLUFOR: %2\nINDEP: %3\nCIV: %4",
    SPAWN_selectedFaction_EAST,
    SPAWN_selectedFaction_WEST,
    SPAWN_selectedFaction_RESISTANCE,
    SPAWN_selectedFaction_CIVILIAN
];
```

#### **Spawn Rápido de Escuadra**
```sqf
[getPos player, east, true, 200] call FN_spawnInfantryGroup;
```

#### **Spawn Rápido de Vehículo**
```sqf
[getPos player, east, "MRAP", true, 500] call FN_spawnVehiclePatrol;
```

#### **Crear Tarea Manual**
```sqf
[
    getPos player,       // Posición
    east,                // Lado enemigo
    "Destruir Cache",    // Título
    "Elimina el alijo de armas", // Descripción
    200                  // Radio
] call FN_createTaskCache;
```

---

## ⚙️ CONFIGURACIÓN AVANZADA

### Variables Globales

#### **Facciones Seleccionadas**
```sqf
SPAWN_selectedFaction_EAST       // OPFOR (default: OPF_F)
SPAWN_selectedFaction_WEST       // BLUFOR (default: BLU_F)
SPAWN_selectedFaction_RESISTANCE // INDEPENDENT (default: IND_F)
SPAWN_selectedFaction_CIVILIAN   // CIVILIAN (default: CIV_F)
```

#### **Datos de Facciones**
```sqf
SPAWN_availableFactionsData  // Array con todas las facciones detectadas
// Formato: [["Nombre Legible", side, "classname"], ...]
```

### Modificar Comportamiento

#### **Cambiar Facción por Defecto**
En `faction_selector.sqf`, líneas 180-190:

```sqf
// Cambiar OPFOR por defecto a RHS Russians
SPAWN_selectedFaction_EAST = "rhs_faction_msv";

// Cambiar BLUFOR por defecto a RHS USAF
SPAWN_selectedFaction_WEST = "rhs_faction_usaf";
```

#### **Ajustar Tamaño de Grupos**
En `fn_spawnInfantryGroup.sqf`, línea ~50:

```sqf
// Cambiar de 4-8 unidades a 6-12
private _groupSize = 6 + floor(random 7);  // Era: 4 + floor(random 5)
```

#### **Modificar Radio de Patrulla**
En `fn_spawnInfantryGroup.sqf`, línea ~80:

```sqf
// Cambiar radio máximo de patrulla
private _patrolRadius = 50 + _radius;  // Añade 50m al radio especificado
```

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### ❌ "El menú de spawn no aparece"

**Causa**: No estás asignado como Zeus

**Solución**:
1. En el editor, coloca un módulo Zeus (F5 → Modules → Zeus → Game Master)
2. Sincroniza el módulo con tu slot de jugador (arrastrar línea)
3. Guarda y reinicia la misión

---

### ❌ "No veo mi mod de facciones"

**Causa**: El mod no está cargado o usa nombres de clase no estándar

**Solución**:
1. Verifica que el mod esté en `modlist` y cargado
2. Abre la consola debug y ejecuta:
```sqf
{
    if (getText (_x >> "displayName") != "") then {
        systemChat format ["Facción: %1", configName _x];
    };
} forEach ("true" configClasses (configFile >> "CfgFactionClasses"));
```
3. Si no aparece, el mod puede usar un sistema personalizado no compatible

---

### ❌ "Las unidades no patrullan"

**Causa**: El waypoint no se creó correctamente

**Solución**:
1. Asegúrate de haber marcado "Con patrulla" al crear el grupo
2. Aumenta el radio de patrulla (mínimo 100m recomendado)
3. Verifica que haya espacio suficiente alrededor para patrullar

---

### ❌ "La tarea no se completa"

**Causa**: Condiciones de victoria no cumplidas

**Solución**:

**Para HVT (Captura)**:
- El HVT debe estar **inconsciente** (no muerto)
- Un jugador debe estar cerca (<10m)
- Espera 5-10 segundos para verificación

**Para Cache**:
- **Todos** los cajones deben estar destruidos
- Usa explosivos o dispara hasta destruir
- Verifica el log: `diag_log` mostrará progreso

**Para Limpiar Área**:
- Busca enemigos escondidos en edificios
- Revisa vehículos abandonados con tripulación
- Expande el área de búsqueda

---

### ❌ "Los IEDs no se pueden desarmar"

**Causa**: ACE no instalado o no detectado

**Solución con ACE**:
1. Necesitas un **Especialista EOD** (Explosive Ordnance Disposal)
2. Aproximarse al IED
3. ACE Interact (Windows por defecto)
4. Seleccionar "Defuse Explosive"

**Solución sin ACE**:
1. Aproximarse (<5m)
2. Usar acción de scroll wheel "Desarmar IED"
3. Mantener posición 5 segundos
4. ¡No mover o se reinicia!

---

### ❌ "Error: Variable no definida"

**Causa**: Sistema no inicializado correctamente

**Solución**:
1. Verifica que `init.sqf` llama al sistema:
```sqf
[] execVM "extracted_system\init.sqf";
```
2. Espera 5-10 segundos después de entrar a la misión
3. Revisa el RPT log para errores específicos:
   - `C:\Users\<TuUsuario>\AppData\Local\Arma 3\Arma3_x64_xxx.rpt`

---

### ❌ "El roadblock está girado incorrectamente"

**Causa**: No hay carretera cerca o carretera mal detectada

**Solución**:
1. Coloca el roadblock **directamente sobre una carretera**
2. Si no funciona, colócalo manualmente:
   - Usa Zeus para rotar las barreras
   - Recoloca guardias en posiciones correctas

---

### ❌ "Las unidades desaparecen"

**Causa**: Dynamic Simulation o limpieza automática

**Solución**:
1. El sistema ya usa `enableDynamicSimulation`
2. Si siguen desapareciendo, desactiva limpieza automática:
   - En configuración de misión (Eden Editor)
   - Busca "Garbage Collection"
   - Desactiva o aumenta el tiempo

---

### ❌ "Error de params: Tipo Bool, esperado número"

**Causa**: Bug conocido corregido en versión reciente

**Solución**:
1. Actualiza `fn_spawnInfantryGroup.sqf`
2. En línea 23, cambia:
```sqf
// INCORRECTO:
["_patrol", true, [true]]

// CORRECTO:
["_patrol", true, [false]]
```

---

### ❌ "Zeus sigue viendo la intro de la misión"

**Causa**: CuratorLogic no asignado lo suficientemente rápido

**Solución**:
En tu `init.sqf` de la misión, aumenta el sleep:
```sqf
waitUntil {!isNull player};
sleep 2;  // Aumentar a 3 o 5 si es necesario
private _isZeus = !isNull (getAssignedCuratorLogic player);
```

---

## 📞 SOPORTE Y CONTACTO

### Archivos del Sistema
- `init.sqf` - Inicialización principal
- `faction_selector.sqf` - Detección de facciones
- `functions/` - Todas las funciones de spawn y tareas
- `spawn_menu/` - Sistema de menú contextual del mapa

### Logs Útiles
Todos los logs del sistema empiezan con `[EXTRACTED_SYSTEM]` en el archivo RPT.

Ubicación del RPT:
```
C:\Users\<TuUsuario>\AppData\Local\Arma 3\Arma3_x64_<fecha>.rpt
```

### Debugging
Para activar más logs, añade al inicio de `init.sqf`:
```sqf
SPAWN_DEBUG_MODE = true;
```

---

## 🎖️ CRÉDITOS

- **Sistema original**: Dynamic Recon Ops (DRO)
- **Adaptación Zeus**: Sistema extraído y modificado para uso manual
- **Compatibilidad**: RHS, CUP, 3CB Factions, ACE3
- **Versión**: 2.0
- **Última actualización**: Octubre 2025

---

## 📄 LICENCIA

Este sistema es una adaptación de Dynamic Recon Ops para uso exclusivo de Zeus.
Libre uso para misiones privadas y comunitarias.
No redistribuir sin permiso.

---

**¡Disfruta creando misiones épicas con Zeus! 🎖️**
