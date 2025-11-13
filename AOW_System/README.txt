╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║                      ALL OUT WARFARE - SISTEMA MODULAR                        ║
║                          Versión Limpia y Simplificada                        ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝


📋 ¿QUÉ INCLUYE ESTE SISTEMA?
═══════════════════════════════════════════════════════════════════════════════

✅ Crear Zonas de Enemigos (6 presets de dificultad)
✅ Crear 8 Tipos de Misiones Dinámicas
✅ Sistema MHQ (Mobile Headquarters)
✅ Teleport a MHQ
✅ ACE Arsenal (con fallback a BI Arsenal)
✅ Compatible con ASORVS (Garaje Virtual)
✅ Compatible con Bon Recruit (Reclutamiento)


📁 ESTRUCTURA DEL SISTEMA
═══════════════════════════════════════════════════════════════════════════════

AOW_System/
├── functions.sqf           ← Funciones esenciales
├── init.sqf                ← Inicialización
├── initServer.sqf          ← Servidor
├── description.ext         ← Configuración GUIs
├── README.txt              ← Este archivo
├── PLANTILLAS.txt          ← Código para copiar/pegar
│
├── AOW_MHQ/                ← Sistema MHQ
│   ├── CreateMHQ.sqf
│   ├── DialogMHQ.sqf
│   ├── MarkerMHQ.sqf
│   └── TPmhq.sqf
│
├── Tasks/                  ← Creación de misiones
│   ├── Tasks1.sqf
│   ├── DialogTasks.sqf
│   ├── Tasks2.sqf
│   └── MakeMission.sqf
│
├── Zones/                  ← Creación de zonas
│   ├── Zone1.sqf
│   ├── DialogZone.sqf
│   ├── Zone2.sqf
│   └── DeleteZone.sqf
│
├── AOW_GUI/                ← Interfaces gráficas
├── eos/                    ← Sistema de enemigos
├── SHK_pos/                ← Sistema de posiciones
├── ASORVS/                 ← Garaje Virtual (incluido)
└── bon_recruit_units/      ← Reclutamiento (incluido)


🚀 INSTALACIÓN EN 5 PASOS
═══════════════════════════════════════════════════════════════════════════════

PASO 1: COPIAR CARPETA
───────────────────────────────────────────────────────────────────────────────
Copia toda la carpeta AOW_System/ a tu misión


PASO 2: EDITAR init.sqf
───────────────────────────────────────────────────────────────────────────────
Añade al INICIO de tu init.sqf (o créalo si no existe):

    execVM "AOW_System\init.sqf";


PASO 3: EDITAR initServer.sqf
───────────────────────────────────────────────────────────────────────────────
Añade al INICIO de tu initServer.sqf (o créalo si no existe):

    execVM "AOW_System\initServer.sqf";


PASO 4: EDITAR description.ext
───────────────────────────────────────────────────────────────────────────────
Añade al FINAL de tu description.ext:

    #include "AOW_System\AOW_GUI\Defines.hpp"
    #include "AOW_System\AOW_GUI\AowMenu.hpp"
    #include "AOW_System\AOW_GUI\CreateTasks.hpp"
    #include "AOW_System\AOW_GUI\CreateZone.hpp"
    #include "AOW_System\ASORVS\menu.hpp"
    #include "AOW_System\bon_recruit_units\dialog\common.hpp"
    #include "AOW_System\bon_recruit_units\dialog\recruitment.hpp"


PASO 5: AÑADIR ACCIONES A OBJETOS
───────────────────────────────────────────────────────────────────────────────
En el editor, añade acciones a tus objetos (ver PLANTILLAS.txt)

Ejemplo rápido - Laptop de comando:

    this addAction ["🌍 Create Zone", {[] execVM "AOW_System\Zones\Zone1.sqf";}, [], 6, false, true, "", ""];
    this addAction ["🎯 Create Mission", {[] execVM "AOW_System\Tasks\Tasks1.sqf";}, [], 5.9, false, true, "", ""];
    this addAction ["🏗️ Deploy MHQ", {[] execVM "AOW_System\AOW_MHQ\DialogMHQ.sqf";}, [], 5.8, false, true, "", ""];


¡LISTO! Ya puedes usar el sistema.


🎯 FUNCIONALIDADES DETALLADAS
═══════════════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. CREAR ZONAS DE ENEMIGOS                                                 │
└─────────────────────────────────────────────────────────────────────────────┘

Script: AOW_System\Zones\Zone1.sqf

Cómo funciona:
1. Jugador interactúa con objeto
2. Se abre el mapa
3. Jugador hace clic donde quiere la zona
4. Se abre diálogo de configuración
5. Selecciona enemigos, dificultad, etc.
6. ¡Zona creada!

Presets de dificultad:
• Very Easy
• Easy
• Medium
• Hard
• Very Hard
• Insane

Configuración manual:
• Tamaño de zona (50m - 400m)
• Infantería (0-20 grupos)
• Vehículos ligeros (0-2)
• Blindados (0-10)
• Aéreos (0-6)
• Francotiradores (0-10)
• Helicópteros (0-6)
• Facción enemiga
• Zona invisible (opcional)


┌─────────────────────────────────────────────────────────────────────────────┐
│ 2. CREAR MISIONES                                                          │
└─────────────────────────────────────────────────────────────────────────────┘

Script: AOW_System\Tasks\Tasks1.sqf

8 Tipos de misiones:

1. SABOTAGE
   Destruir infraestructura (torres eléctricas)

2. ASSASSINATE
   Eliminar objetivo de alto valor (HVT)

3. FIND & DESTROY
   Encontrar y destruir cajas de suministros

4. DESTROY
   Destruir vehículo enemigo (tanque)

5. EXTRACTION
   Rescatar civil y llevarlo a base

6. CAPTURE
   Capturar vehículo enemigo y llevarlo a base

7. DISARM IEDS
   Desactivar múltiples IEDs en un área

8. ASSAULT FOB
   Capturar FOB enemiga


┌─────────────────────────────────────────────────────────────────────────────┐
│ 3. SISTEMA MHQ                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

Convertir vehículos en Mobile HQ:

Opción A - Desde objeto de control:
    [] execVM "AOW_System\AOW_MHQ\DialogMHQ.sqf";

Opción B - Vehículo pre-configurado:
    [this] execVM "AOW_System\AOW_MHQ\CreateMHQ.sqf";

Características del MHQ:
✓ Punto de respawn móvil
✓ ACE Arsenal integrado
✓ Teleport a base (si existe marker respawn_west)
✓ Marker en mapa
✓ Protección contra limpieza

Teleport a MHQ:
    [] execVM "AOW_System\AOW_MHQ\TPmhq.sqf";


┌─────────────────────────────────────────────────────────────────────────────┐
│ 4. ACE ARSENAL                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

Función: AOW_fnc_openArsenal

Uso en objeto:
    this addAction ["Arsenal", {[_this select 0] call AOW_fnc_openArsenal;}, [], 6, false, true, "", ""];

Características:
✓ Detecta automáticamente si tienes ACE3
✓ Usa ACE Arsenal si está disponible
✓ Fallback a BI Arsenal si no hay ACE


📝 MARKERS NECESARIOS
═══════════════════════════════════════════════════════════════════════════════

Para GARAJE VIRTUAL (ASORVS):
Crea estos markers en el mapa (F6 en editor):

    VVS1  → Spawn de coches
    VVS2  → Spawn de blindados
    VVS3  → Spawn de helicópteros
    VVS5  → Spawn de aviones
    VVS7  → Spawn de barcos

Para TELEPORT (opcional):
    respawn_west  → Tu punto de spawn/base


🔧 SISTEMAS INCLUIDOS Y HABILITADOS
═══════════════════════════════════════════════════════════════════════════════

GARAJE VIRTUAL (ASORVS):
✓ Ya incluido y habilitado en AOW_System\ASORVS\
✓ Para usarlo:
  1. Crea markers VVS1, VVS2, VVS3, etc. en el mapa (donde quieres que aparezcan)
  2. Añade acciones a objetos (ver PLANTILLAS.txt)

RECLUTAMIENTO (Bon Recruit):
✓ Ya incluido y habilitado en AOW_System\bon_recruit_units\
✓ Para usarlo:
  1. Añade acciones a objetos (ver PLANTILLAS.txt)

ZEUS:
Compatible con Zeus. Las unidades spawneadas se pueden añadir automáticamente.

AI CACHING:
Compatible con ZBE Cache para mejor rendimiento.


⚙️ CONFIGURACIÓN AVANZADA
═══════════════════════════════════════════════════════════════════════════════

CAMBIAR FACCIONES ENEMIGAS:
Edita: AOW_System\eos\UnitPools.sqf

LIMITAR A ZEUS/ADMIN:
En Tasks1.sqf o Zone1.sqf, reemplaza:
    _GameMasters = allUnits;
Por:
    _GameMasters = [zeus1, zeus2];

AÑADIR NUEVOS TIPOS DE MISIONES:
Edita: AOW_System\Tasks\MakeMission.sqf


🐛 SOLUCIÓN DE PROBLEMAS
═══════════════════════════════════════════════════════════════════════════════

Problema: "No se crean zonas de enemigos"
Solución: Verifica que EOS está inicializado (eos\OpenMe.sqf)
          Revisa eos\UnitPools.sqf

Problema: "No aparecen diálogos"
Solución: Verifica que incluiste los GUIs en description.ext

Problema: "Error AOW_fnc_getFreeNames"
Solución: Verifica que functions.sqf se carga en init.sqf

Problema: "ACE Arsenal no funciona"
Solución: La función detecta automáticamente ACE. Si no tienes ACE,
          usará BI Arsenal automáticamente.

Problema: "Garaje virtual no funciona"
Solución: Verifica que tienes ASORVS instalado y los markers VVS creados


📊 REQUISITOS
═══════════════════════════════════════════════════════════════════════════════

OBLIGATORIOS:
✓ Arma 3 (actualizado)
✓ EOS (incluido)
✓ SHK_pos (incluido)

OPCIONALES:
✓ ACE3 (para ACE Arsenal)
✓ ASORVS (para garaje virtual)
✓ Bon Recruit Units (para reclutamiento)
✓ ZBE Cache (para rendimiento)


💡 TIPS Y TRUCOS
═══════════════════════════════════════════════════════════════════════════════

1. Usa presets de dificultad para crear zonas rápidamente
2. Combina múltiples acciones en un mismo objeto
3. Crea markers VVS donde quieras spawns de vehículos
4. El MHQ puede ser cualquier vehículo
5. Puedes tener múltiples MHQs activos
6. Las zonas se guardan automáticamente
7. Usa Alt+Click para eliminar zonas


📋 CHECKLIST DE INSTALACIÓN
═══════════════════════════════════════════════════════════════════════════════

□ Carpeta AOW_System/ copiada a la misión
□ init.sqf editado (execVM "AOW_System\init.sqf")
□ initServer.sqf editado (execVM "AOW_System\initServer.sqf")
□ description.ext editado (includes de GUIs)
□ Acciones añadidas a objetos en el editor
□ Markers creados (VVS1, VVS2, etc.) si usas ASORVS
□ Probado en editor
□ Probado en servidor


🎉 ¡LISTO PARA USAR!
═══════════════════════════════════════════════════════════════════════════════

Tienes un sistema completo de misiones dinámicas listo para usar.

Ver PLANTILLAS.txt para ejemplos de código.


═══════════════════════════════════════════════════════════════════════════════
                        Creado por: Psycho Mantis
                        Versión: 1.0 Modular
                        Fecha: Noviembre 2025
═══════════════════════════════════════════════════════════════════════════════

