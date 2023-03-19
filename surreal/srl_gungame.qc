
float srl_gunGameWeaponLevels = 7;
float srl_gunGameFragsPerLevel;
float srl_gunGameReverseOrder;

void () SRL_InitializeGunGame =
{
    srl_welcomeMessage = "Welcome to SURREAL GUN GAME!\n\nAxe kills and telefrags will set you back.";

    srl_gunGameFragsPerLevel = rint(cvar("temp2"));
    if (srl_gunGameFragsPerLevel < 0)
    {
        srl_gunGameFragsPerLevel = -srl_gunGameFragsPerLevel;
        srl_gunGameReverseOrder = TRUE;
    }
    if (srl_gunGameFragsPerLevel == 0)
        srl_gunGameFragsPerLevel = 3;

    precache_sound ("doors/basetry.wav");
}

void () SRL_CheckGunGameProgression =
{
    if (self.frags < 0)
        self.frags = 0;

    local float weaponLevel = floor(self.frags / srl_gunGameFragsPerLevel);
    local float progression = srl_gunGameFragsPerLevel - (self.frags - weaponLevel * srl_gunGameFragsPerLevel);

    if (progression < 1)
        progression = 1;

    self.currentammo = progression;

    self.ammo_cells = 100;
    self.ammo_nails = 100;
    self.ammo_rockets = 100;
    self.ammo_shells = 100;                
    
    local float weaponMask = (IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_NAILGUN | IT_SUPER_NAILGUN | IT_GRENADE_LAUNCHER | IT_ROCKET_LAUNCHER | IT_LIGHTNING);
    local string weaponModel = string_null;

    self.items -= self.items & weaponMask;
    if (srl_gunGameReverseOrder)
        weaponLevel = srl_gunGameWeaponLevels - 1 - weaponLevel;
    if (weaponLevel < 1)
    {            
        self.items |= IT_SHOTGUN;
        weaponModel = "progs/v_shot.mdl";
    }
    else if (weaponLevel < 2)
    {
        self.items |= IT_SUPER_SHOTGUN;
        weaponModel = "progs/v_shot2.mdl";
    }
    else if (weaponLevel < 3)
    {
        self.items |= IT_NAILGUN;
        weaponModel = "progs/v_nail.mdl";
    }
    else if (weaponLevel < 4)
    {
        self.items |= IT_SUPER_NAILGUN;
        weaponModel = "progs/v_nail2.mdl";
    }
    else if (weaponLevel < 5)
    {
        self.items |= IT_GRENADE_LAUNCHER;
        weaponModel = "progs/v_rock.mdl";
    }
    else if (weaponLevel < 6)
    {
        self.items |= IT_ROCKET_LAUNCHER;
        weaponModel = "progs/v_rock2.mdl";
    }
    else if (weaponLevel < 7)
    {
        self.items |= IT_LIGHTNING;
        weaponModel = "progs/v_light.mdl";
    }

    if (self.weapon != IT_AXE)
    {
        if (self.weapon != (self.items & weaponMask))
        {
            self.weapon = self.items & weaponMask;
            self.weaponmodel = weaponModel;
            player_run();
        }
    }    
}

void () SRL_GunGamePlayerPostThink =
{
    SRL_CheckGunGameProgression();
}

void () SRL_GunGameImpulseCommands = 
{
    if (self.impulse == 1)
    {
        CycleWeaponCommand();
        self.impulse = 0;
    }
}

void () SRL_CheckGunGameRules =
{
    local float timelimit = cvar("timelimit") * 60;
    if (timelimit && (time >= timelimit))
    {
        NextLevel ();
        return;
    }

    if (self.frags >= srl_gunGameWeaponLevels * srl_gunGameFragsPerLevel)
    {
        NextLevel();
        return;
    }
}


void (entity targ, entity attacker, float numLevels) SRL_GunGameDemote = 
{
    targ.frags = targ.frags - srl_gunGameFragsPerLevel * numLevels;
    if (targ.frags < 0)
        targ.frags = 0;

    SRL_SetDeathMessage(targ, "Demoted by ", attacker);
    localsound(targ, "doors/basetry.wav");

    bprint(targ.netname);
    bprint(" was demoted by ");
    bprint(attacker.netname);
}

void (entity targ, entity attacker) SRL_GunGameKilled =
{
    if (targ.classname != "player")
        return;
	
    if (attacker.classname == "teledeath")
    {
        SRL_GunGameDemote(targ, attacker.owner, 2);
        return;
    }
    
    if (attacker.classname == "player")
    {
        if (targ != attacker)
        {
            if (attacker.weapon == IT_AXE)
            {
                // died by axe
                SRL_GunGameDemote(targ, attacker, 1);
                return;
            }
        }            
    }
}

float (entity targ, entity inflictor, entity attacker, float damage) SRL_GunGameGetDamageMultiplier =
{
    if (attacker.weapon == IT_AXE)
        return 4;

    return 1;
}