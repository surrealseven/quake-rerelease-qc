.string srl_deathMsg;
.entity srl_deathEnt;
.entity srl_viewent;
.float srl_suppressMsgTime;


void() SRL_Initialize =
{
    local float gameMode = rint(cvar("temp1"));

    if (gameMode == 1)
    {
        srl_gameMode = SRL_GAMEMODE_GUNGAME;
        SRL_InitializeGunGame();
    }

    if (gameMode == 2)
    {
        srl_gameMode = SRL_GAMEMODE_SOULCOLLECTOR;
        SRL_InitializeSoulCollector();
    }    

    precache_model("progs/quaddama.mdl");
	precache_sound("items/damage.wav");
	precache_sound("items/damage2.wav");
	precache_sound("items/damage3.wav");
};

float (entity a, entity b) SRL_IsSameTeam =
{
    return (a == b) || ((a.team != TEAM_NONE) && (a.team == b.team));
}

void () SRL_PrintViewEntity =
{
    if (!SRL_ENABLE_DRAWPLAYERNAMES)
        return;

    if (self.srl_suppressMsgTime > time)
        return;

    local vector v1 = self.origin + self.view_ofs;
    local vector v2 = v1 + v_forward * 2048;
    traceline(v1, v2, FALSE, self);

    if (trace_ent.classname == "player")
    {
        self.srl_viewent = trace_ent;        
        centerprint(self, trace_ent.netname);
    }

    if (self.srl_viewent)
    {
        if (self.srl_viewent.deadflag >= DEAD_DEAD)
        {
            self.srl_viewent = world;
            centerprint(self, "");            
        }
    }
}

void (entity target, string message, entity attacker) SRL_SetDeathMessage
{
    target.srl_deathMsg = message;
    target.srl_deathEnt = attacker;
}

void () SRL_PrintDeathMessage =
{
    if (!SRL_ENABLE_DEATHMESSAGES)
        return;

    if (self.srl_deathEnt)
    {
        if (self.srl_suppressMsgTime <= time)
        {
            if (self.srl_deathMsg)
                centerprint(self, "{0}{1}", self.srl_deathMsg, self.srl_deathEnt.netname);
            else
                centerprint(self, "Killed by {0}", self.srl_deathEnt.netname);
        }

        self.srl_deathMsg = string_null;
        self.srl_deathEnt = world;
    }
}

void (float untilTime) SRL_SuppressMessages
{
    self.srl_suppressMsgTime = untilTime;
}

void () SRL_PrintWelcomeMessage =
{
    if (!SRL_ENABLE_WELCOMEMESSAGE)
        return;

    if (srl_welcomeMessage)
    {
        SRL_SuppressMessages(time + 5);
        centerprint(self, srl_welcomeMessage);
        srl_welcomeMessage = string_null;
    }
}

void () SRL_PutClientInServer =
{
}

void () SRL_PlayerPreThink =
{
}

void () SRL_PlayerPostThink =
{
    SRL_PrintWelcomeMessage();
    SRL_PrintDeathMessage();
    SRL_PrintViewEntity();

    if (srl_gameMode == SRL_GAMEMODE_GUNGAME)
        SRL_GunGamePlayerPostThink();        
}

void () SRL_ImpulseCommands =
{
    if (srl_gameMode == SRL_GAMEMODE_GUNGAME)
        SRL_GunGameImpulseCommands();
}

void () SRL_PlayerDead = 
{
}

void () SRL_StartItem =
{
    if (srl_gameMode == SRL_GAMEMODE_GUNGAME)
    {
        if (self.weapon)
            remove(self);
    }
}

void (entity target, entity attacker) SRL_Killed = 
{
    SRL_DropUnusedQuad();

    if (target != attacker)
    {
        target.srl_deathEnt = attacker;
        if (attacker.classname == "teledeath")
            target.srl_deathEnt = attacker.owner;    
    }

    if (srl_gameMode == SRL_GAMEMODE_GUNGAME)
        SRL_GunGameKilled(target, attacker);
    else if (srl_gameMode == SRL_GAMEMODE_SOULCOLLECTOR)
        SRL_SoulCollectorKilled(target, attacker);
}

float () SRL_ShouldDropBackpack = 
{
    if (srl_gameMode == SRL_GAMEMODE_GUNGAME)
        return FALSE;

    return TRUE;
}

float () SRL_CheckRules =
{
    if (srl_gameMode == SRL_GAMEMODE_GUNGAME)
    {
        SRL_CheckGunGameRules();
        return FALSE;
    }    

    return TRUE;
}

float (entity targ, entity inflictor, entity attacker, float damage) SRL_GetDamageMultiplier =
{
    if (srl_gameMode == SRL_GAMEMODE_GUNGAME)
        return SRL_GunGameGetDamageMultiplier(targ, inflictor, attacker, damage);

    return 1;
}
