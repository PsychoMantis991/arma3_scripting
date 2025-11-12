/*
	ARCHIVO DE EJEMPLO: Configuración con RHS
	
	Este es un ejemplo de cómo quedarían las funciones
	configuradas para usar RHS (Russian Armed Forces & US Army)
	
	NO es necesario usar este archivo, es solo REFERENCIA
	
	Para usar RHS:
	1. Copia las líneas relevantes
	2. Pégalas en los archivos originales (fn_spawnInfantryGroup.sqf, etc.)
	3. Guarda y prueba
*/


// ═════════════════════════════════════════════════════════════════
// EJEMPLO 1: fn_spawnInfantryGroup.sqf con RHS
// ═════════════════════════════════════════════════════════════════

// LÍNEAS 27-33, REEMPLAZAR ESTO:
/*
private _infClasses = switch (_side) do {
	case east: {["O_Soldier_F", "O_Soldier_AR_F", "O_Soldier_GL_F", "O_medic_F", "O_Soldier_TL_F"]};
	case west: {["B_Soldier_F", "B_Soldier_AR_F", "B_Soldier_GL_F", "B_medic_F", "B_Soldier_TL_F"]};
	case resistance: {["I_Soldier_F", "I_Soldier_AR_F", "I_Soldier_GL_F", "I_medic_F", "I_Soldier_TL_F"]};
	default {["O_Soldier_F", "O_Soldier_AR_F", "O_Soldier_GL_F", "O_medic_F"]};
};
*/

// POR ESTO (RHS):
private _infClasses = switch (_side) do {
	case east: {[
		// RHS Russian VDV (Airborne)
		"rhs_vdv_rifleman",
		"rhs_vdv_arifleman",
		"rhs_vdv_rifleman_lite",
		"rhs_vdv_grenadier",
		"rhs_vdv_grenadier_rpg",
		"rhs_vdv_LAT",
		"rhs_vdv_at",
		"rhs_vdv_aa",
		"rhs_vdv_medic",
		"rhs_vdv_engineer",
		"rhs_vdv_marksman",
		"rhs_vdv_machinegunner",
		"rhs_vdv_sergeant",
		"rhs_vdv_junior_sergeant"
	]};
	case west: {[
		// RHS US Army (OCP)
		"rhsusf_army_ocp_rifleman",
		"rhsusf_army_ocp_riflemanat",
		"rhsusf_army_ocp_riflemanl",
		"rhsusf_army_ocp_autorifleman",
		"rhsusf_army_ocp_grenadier",
		"rhsusf_army_ocp_javelin",
		"rhsusf_army_ocp_aa",
		"rhsusf_army_ocp_medic",
		"rhsusf_army_ocp_engineer",
		"rhsusf_army_ocp_marksman",
		"rhsusf_army_ocp_machinegunner",
		"rhsusf_army_ocp_teamleader",
		"rhsusf_army_ocp_squadleader"
	]};
	case resistance: {[
		// RHS Insurgents
		"rhsgref_ins_rifleman",
		"rhsgref_ins_rifleman_RPG26",
		"rhsgref_ins_grenadier",
		"rhsgref_ins_medic",
		"rhsgref_ins_squadleader"
	]};
	default {[
		"rhs_vdv_rifleman",
		"rhs_vdv_arifleman",
		"rhs_vdv_grenadier",
		"rhs_vdv_medic"
	]};
};


// ═════════════════════════════════════════════════════════════════
// EJEMPLO 2: fn_spawnVehiclePatrol.sqf con RHS
// ═════════════════════════════════════════════════════════════════

// LÍNEAS 28-65, REEMPLAZAR ESTO:
/*
private _vehicleClasses = switch (_side) do {
	case east: {
		switch (_vehicleType) do {
			case "CAR": {["O_MRAP_02_hmg_F", "O_MRAP_02_gmg_F", "O_LSV_02_armed_F"]};
			case "APC": {["O_APC_Wheeled_02_rcws_F", "O_APC_Tracked_02_cannon_F"]};
			case "TANK": {["O_MBT_02_cannon_F", "O_MBT_04_cannon_F"]};
			default {["O_MRAP_02_hmg_F"]};
		};
	};
	// ... más código
};
*/

// POR ESTO (RHS):
private _vehicleClasses = switch (_side) do {
	case east: {
		switch (_vehicleType) do {
			case "CAR": {[
				// RHS Russian Light Vehicles
				"rhs_tigr_sts_msv",           // Tigr con KORD
				"rhs_tigr_m_msv",             // Tigr con PKM
				"rhs_uaz_open_MSV_01",        // UAZ abierto
				"rhs_uaz_MSV_01",             // UAZ cerrado
				"rhs_gaz66_msv",              // GAZ-66 truck
				"rhs_gaz66_flat_msv"          // GAZ-66 flatbed
			]};
			case "APC": {[
				// RHS Russian APCs
				"rhs_btr60_msv",              // BTR-60
				"rhs_btr70_msv",              // BTR-70
				"rhs_btr80_msv",              // BTR-80
				"rhs_btr80a_msv",             // BTR-80A
				"rhs_bmp1_msv",               // BMP-1
				"rhs_bmp2_msv",               // BMP-2
				"rhs_bmp3_msv",               // BMP-3
				"rhs_bmd1",                   // BMD-1
				"rhs_bmd2"                    // BMD-2
			]};
			case "TANK": {[
				// RHS Russian Tanks
				"rhs_t72ba_tv",               // T-72B
				"rhs_t72bd_tv",               // T-72B3
				"rhs_t80",                    // T-80
				"rhs_t80b",                   // T-80B
				"rhs_t80bv",                  // T-80BV
				"rhs_t80u",                   // T-80U
				"rhs_t90a_tv",                // T-90A
				"rhs_t90_tv"                  // T-90
			]};
			default {["rhs_tigr_sts_msv"]};
		};
	};
	case west: {
		switch (_vehicleType) do {
			case "CAR": {[
				// RHS US Light Vehicles
				"rhsusf_m1025_w_m2",          // HMMWV M2
				"rhsusf_m1025_w",             // HMMWV Unarmed
				"rhsusf_m998_w_2dr",          // HMMWV 2-door
				"rhsusf_m1043_w_m2",          // HMMWV M1043 M2
				"rhsusf_m1045_w",             // HMMWV M1045
				"rhsusf_M1078A1P2_wd_fmtv_usarmy"  // FMTV Truck
			]};
			case "APC": {[
				// RHS US APCs & IFVs
				"rhsusf_m113_usarmy",         // M113
				"rhsusf_m113d_usarmy",        // M113 Diesel
				"RHS_M2A3",                   // Bradley M2A3
				"RHS_M2A3_BUSKIII",           // Bradley BUSK III
				"rhsusf_m1117_w",             // ASV
				"rhsusf_stryker_m1126_m2_wd"  // Stryker M2
			]};
			case "TANK": {[
				// RHS US Tanks
				"rhsusf_m1a1aim_tuski_wd",    // M1A1 AIM
				"rhsusf_m1a1fep_wd",          // M1A1 FEP
				"rhsusf_m1a2sep1tuskiwd_usarmy", // M1A2 SEP TUSK
				"rhsusf_m1a2sep1wd_usarmy"    // M1A2 SEP
			]};
			default {["rhsusf_m1025_w_m2"]};
		};
	};
	case resistance: {
		switch (_vehicleType) do {
			case "CAR": {[
				// RHS Insurgent Vehicles
				"rhsgref_ins_uaz",
				"rhsgref_ins_uaz_dshkm",
				"rhsgref_ins_ural",
				"rhsgref_ins_ural_open"
			]};
			case "APC": {[
				"rhsgref_BRDM2",
				"rhsgref_BTR60"
			]};
			case "TANK": {[
				"rhsgref_ins_t72ba"
			]};
			default {["rhsgref_ins_uaz_dshkm"]};
		};
	};
	default {["rhs_tigr_sts_msv"]};
};


// ═════════════════════════════════════════════════════════════════
// EJEMPLO 3: fn_spawnGarrison.sqf con RHS (opcional)
// ═════════════════════════════════════════════════════════════════

// LÍNEAS 27-31, REEMPLAZAR:
/*
private _infClasses = switch (_side) do {
	case east: {["O_Soldier_F", "O_Soldier_AR_F", "O_Soldier_GL_F", "O_medic_F"]};
	case west: {["B_Soldier_F", "B_Soldier_AR_F", "B_Soldier_GL_F", "B_medic_F"]};
	case resistance: {["I_Soldier_F", "I_Soldier_AR_F", "I_Soldier_GL_F", "I_medic_F"]};
	default {["O_Soldier_F", "O_Soldier_AR_F"]};
};
*/

// POR ESTO:
private _infClasses = switch (_side) do {
	case east: {[
		"rhs_vdv_rifleman",
		"rhs_vdv_grenadier",
		"rhs_vdv_machinegunner",
		"rhs_vdv_medic"
	]};
	case west: {[
		"rhsusf_army_ocp_rifleman",
		"rhsusf_army_ocp_grenadier",
		"rhsusf_army_ocp_machinegunner",
		"rhsusf_army_ocp_medic"
	]};
	case resistance: {[
		"rhsgref_ins_rifleman",
		"rhsgref_ins_grenadier"
	]};
	default {[
		"rhs_vdv_rifleman",
		"rhs_vdv_grenadier"
	]};
};


// ═════════════════════════════════════════════════════════════════
// EJEMPLO 4: Uso directo con RHS desde Zeus
// ═════════════════════════════════════════════════════════════════

// Estos comandos funcionarán si ya cambiaste las clases:

// Generar escuadra rusa
[getPos player, east, [6,8], true, 400] remoteExec ["FN_spawnInfantryGroup", 2];

// Generar BTR-80
[getPos player, east, "APC", true, 1000] remoteExec ["FN_spawnVehiclePatrol", 2];

// Generar T-90
[getPos player, east, "TANK", true, 1200] remoteExec ["FN_spawnVehiclePatrol", 2];


// ═════════════════════════════════════════════════════════════════
// NOTAS IMPORTANTES SOBRE RHS
// ═════════════════════════════════════════════════════════════════

/*
	FACCIONES RHS DISPONIBLES:
	
	RHS AFRF (Armed Forces of Russian Federation):
	─────────────────────────────────────────────
	- MSV (Motor Rifle Troops) - rhs_*_msv
	- VDV (Airborne) - rhs_vdv_*
	- VMF (Naval Infantry) - rhs_vmf_*
	- VV (Internal Troops) - rhs_vv_*
	
	RHS USAF (United States Armed Forces):
	──────────────────────────────────────
	- US Army (OCP) - rhsusf_army_ocp_*
	- US Army (UCP) - rhsusf_army_ucp_*
	- USMC (MARPAT Desert) - rhsusf_usmc_marpat_d_*
	- USMC (MARPAT Woodland) - rhsusf_usmc_marpat_wd_*
	
	RHS GREF (Global Mobilization):
	────────────────────────────────
	- Insurgents - rhsgref_ins_*
	- Chernarus Defense Forces - rhsgref_cdf_*
	- National Party of Chernarus - rhsgref_nat_*
	
	VARIANTES DE CAMUFLAJE:
	───────────────────────
	- _msv = Flora
	- _vdv = Flora (VDV)
	- _vmf = KLMK
	- _emr = EMR Digital
	- _emr_des = EMR Desert
*/


// ═════════════════════════════════════════════════════════════════
// VERIFICACIÓN RÁPIDA
// ═════════════════════════════════════════════════════════════════

/*
	Para verificar que RHS está cargado correctamente:
	
	1. Ejecuta en consola debug:
	
	   isClass (configFile >> "CfgPatches" >> "rhsusf_main")
	   
	   Debe devolver: true
	
	2. O verifica una clase específica:
	
	   isClass (configFile >> "CfgVehicles" >> "rhs_vdv_rifleman")
	   
	   Debe devolver: true
*/

