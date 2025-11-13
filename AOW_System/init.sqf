// ============================================
// ALL OUT WARFARE - INIT
// ============================================

// Funciones
call compile preprocessFile "AOW_System\functions.sqf";

// SHK pos (necesario para misiones y zonas)
call compile preprocessfile "AOW_System\SHK_pos\shk_pos_init.sqf";

// EOS (necesario para zonas de enemigos)
[] execVM "AOW_System\eos\OpenMe.sqf";

// Variables
AOW_Checkbox = false;
AOW_allRandomNames = [];

// ASORVS (Garaje Virtual)
[] execVM "AOW_System\ASORVS\config.sqf";

// Bon Recruit (Reclutamiento)
[] execVM "AOW_System\bon_recruit_units\init.sqf";

