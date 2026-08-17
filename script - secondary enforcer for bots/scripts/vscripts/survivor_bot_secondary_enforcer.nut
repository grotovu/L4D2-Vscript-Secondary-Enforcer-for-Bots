printl("--- INITIALIZING BOT-ONLY SECONDARY WEAPON ENFORCER ---");

// Default Settings (Will be overwritten by config file)
::WE_Settings <- {
    model_nick = "pistol"
    model_rochelle = "electric_guitar"
    model_coach = "tonfa"
    model_ellis = "baseball_bat"
    
    model_bill = "pistol" 
    model_zoey = "baseball_bat"
    model_francis = "tonfa"
    model_louis = "electric_guitar"
    
    interval = 3.0
};

::WE_ConfigPath <- "secondary_weapon_enforcer/settings_bots.txt";
::WE_Blacklist <- {};

// CONFIG
::WE_SaveConfig <- function()
{
    local content = "// Survivor Bot Secondary Weapon Configuration\n";
    content += "// Format: key weapon_name\n";
    content += "// Set to 'pistol' to allow bots to keep default guns.\n\n";
    
    foreach (key, value in ::WE_Settings)
    {
        content += key + " " + value + "\n";
    }
    
    StringToFile(::WE_ConfigPath, content);
    printl("ENFORCER: Config saved to ems/" + ::WE_ConfigPath);
}

::WE_LoadConfig <- function()
{
    local fileData = FileToString(::WE_ConfigPath);
    if (!fileData)
    {
        ::WE_SaveConfig(); // Create it if it doesn't exist
        return;
    }

    local lines = split(fileData, "\n\r");
    foreach (line in lines)
    {
        line = strip(line);
        if (line == "" || line.slice(0, 2) == "//") continue;

        local pair = split(line, " ");
        if (pair.len() >= 2)
        {
            local key = strip(pair[0]);
            local val = strip(pair[1]);

            if (key in ::WE_Settings)
            {
                if (key == "interval") ::WE_Settings[key] = val.tofloat();
                else ::WE_Settings[key] = val;
            }
        }
    }
    printl("ENFORCER: Configuration loaded successfully.");
}

// CORE LOGIC
::WE_Enforce <- function()
{
    local p = null;
    while (p = Entities.FindByClassname(p, "player"))
    {
        if (!p || !p.IsValid()) continue;
        if (IsPlayerABot(p) == false) continue; // Humans keep freedom
        if (p.IsDead()) continue;

        // SKIP Incap/Ledge
        if (NetProps.GetPropInt(p, "m_isIncapacitated") != 0 || 
            NetProps.GetPropInt(p, "m_isHangingFromLedge") != 0)
            continue;

        local mdl = p.GetModelName().tolower();
        local targetWeapon = "";

        // Model ID Mapping
        if (mdl.find("producer") != null)      targetWeapon = ::WE_Settings.model_rochelle;
        else if (mdl.find("gambler") != null)  targetWeapon = ::WE_Settings.model_nick;
        else if (mdl.find("coach") != null)    targetWeapon = ::WE_Settings.model_coach;
        else if (mdl.find("mechanic") != null) targetWeapon = ::WE_Settings.model_ellis;
        else if (mdl.find("namvet") != null)   targetWeapon = ::WE_Settings.model_bill;
        else if (mdl.find("teenangst") != null) targetWeapon = ::WE_Settings.model_zoey;
        else if (mdl.find("biker") != null)    targetWeapon = ::WE_Settings.model_francis;
        else if (mdl.find("manager") != null)  targetWeapon = ::WE_Settings.model_louis;

        // BYPASS: If target is pistols OR weapon is blacklisted for this map
        if (targetWeapon == "" || targetWeapon == "weapon_pistol" || targetWeapon == "pistol") continue;
        if (targetWeapon in ::WE_Blacklist) continue;

        // FIND PISTOLS
        local pistolEnt = null;
        for (local i = 0; i < 16; i++)
        {
            local w = NetProps.GetPropEntityArray(p, "m_hMyWeapons", i);
            if (w && w.IsValid() && w.GetClassname() == "weapon_pistol")
            {
                pistolEnt = w;
                break;
            }
        }

        // SWAP ATTEMPT (Only if bot is holding pistols)
        if (pistolEnt)
        {
            p.GiveItem(targetWeapon);

            // VERIFICATION (Learning Fallback)
            local success = false;
            for (local i = 0; i < 16; i++)
            {
                local nw = NetProps.GetPropEntityArray(p, "m_hMyWeapons", i);
                if (nw && nw.IsValid())
                {
                    local nClass = nw.GetClassname();
                    if ((targetWeapon == "pistol_magnum" && nClass == "weapon_pistol_magnum") || 
                        (targetWeapon != "pistol_magnum" && nClass == "weapon_melee"))
                    {
                        success = true;
                        break;
                    }
                }
            }

            if (success)
            {
                pistolEnt.Kill(); // Only remove pistols if the new weapon arrived
            }
            else
            {
                // Weapon is not available on this map. Blacklist it.
                printl("ENFORCER: " + targetWeapon + " not found on this map. Bot " + mdl + " will keep pistols.");
                ::WE_Blacklist[targetWeapon] <- true;
            }
        }
    }
}

// RECURSIVE LOOP
::WE_Loop <- function()
{
    ::WE_Enforce();
    EntFire("worldspawn", "RunScriptCode", "::WE_Loop()", ::WE_Settings.interval);
}

// INITIALIZATION
::WE_LoadConfig();
::WE_Blacklist <- {};
EntFire("worldspawn", "RunScriptCode", "::WE_Loop()", 2.0);

printl("--- BOT SECONDARY WEAPON ENFORCER (CONFIG & FALLBACKS) LOADED ---");