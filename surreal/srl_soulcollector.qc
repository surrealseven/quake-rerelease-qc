

void () SRL_InitializeSoulCollector =
{
    srl_welcomeMessage = "Welcome to SURREAL SOUL COLLECTOR!\n\nPick up runes to score frags.";

    precache_sound("weapons/lock4.wav");
    precache_sound("misc/basekey.wav");

    precache_model("progs/end1.mdl");
    precache_model("progs/end2.mdl");
    precache_model("progs/end3.mdl");
    precache_model("progs/end4.mdl");
}


void () SRL_SoulTouch = 
{
    if (other.classname != "player")
        return;

    if (other.health <= 0)
        return;

    if (SRL_IsSameTeam(self, other))
    {
        localsound(other, "misc/basekey.wav");        
    }
    else
    {        
        localsound(other, "weapons/lock4.wav");
        other.frags += self.frags;
    }

    stuffcmd(other, "bf\n");

    dprint(other.netname);
    dprint(" picked up ");
    dprint(self.owner.netname);
    dprint("'s soul\n");

    remove(self);
}

void (float fragCount, entity attacker) SRL_DropSoul = 
{
    local entity soul = spawn();
    soul.owner = self;
    soul.enemy = attacker;
    soul.origin = self.origin - '0 0 24';
    soul.frags = fragCount;
    soul.classname = "playersoul";
    soul.flags = FL_ITEM | FL_OBJECTIVE;
    soul.solid = SOLID_TRIGGER;
    soul.movetype = MOVETYPE_TOSS;
    soul.touch = SRL_SoulTouch;
    soul.nextthink = time + 120;
    soul.think = SUB_Remove;
    soul.effects = EF_BRIGHTFIELD | EF_CANDLELIGHT;        
    soul.team = self.team;

    soul.velocity_z = 300;

    local float rand = random();
    if (rand < 0.25)
        setmodel(soul, "progs/end1.mdl");
    else if (rand < 0.5)
        setmodel(soul, "progs/end2.mdl");
    else if (rand < 0.75)
        setmodel(soul, "progs/end3.mdl");
    else
        setmodel(soul, "progs/end4.mdl");
    setsize(soul, '-16 -16 -24', '16 16 32');
}

void (entity target, entity attacker) SRL_SoulCollectorKilled = 
{
    if (target.classname != "player")
        return;

    if ((attacker.classname == "player") && (target != attacker))
    {
        attacker.frags--;
        SRL_DropSoul(1, attacker);
    }
}


