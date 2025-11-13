// ============================================
// ALL OUT WARFARE - FUNCIONES ESENCIALES
// ============================================

// Generar nombres únicos para markers
AOW_fnc_getFreeNames = {
    _allNames = missionNamespace getVariable ["AOW_allRandomNames", []];
    _newName = format ["AOW_RANDOM_NAME_%1", count _allNames];
    _allNames pushBack _newName;
    missionNamespace setVariable ["AOW_allRandomNames", _allNames];
    publicVariable "AOW_allRandomNames";
    _newName
};

// ACE Arsenal con fallback a BI Arsenal
AOW_fnc_openArsenal = {
    _object = _this select 0;
    if (isClass (configFile >> "CfgPatches" >> "ace_arsenal")) then {
        [_object, player] call ace_arsenal_fnc_openBox;
    } else {
        ["Open", true] spawn BIS_fnc_arsenal;
    };
};

