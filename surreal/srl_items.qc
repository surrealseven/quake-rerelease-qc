

void () SRL_QuadTouch =
{
    if (other.classname != "player")
        return;

    if (other.health <= 0)
        return;

    other.items |= IT_QUAD;
    other.super_damage_finished = time + self.super_time;
    sound (other, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

    remove(self);
}

void () SRL_DropUnusedQuad =
{    
    if (!SRL_ENABLE_DROPQUAD)
        return;

    if (self.items & IT_QUAD)
    {
        local float timeLeft = self.super_damage_finished - time;
        if (timeLeft > 3)
        {
            local entity quad = spawn();
            quad.origin = self.origin - '0 0 24';
            quad.classname = "item_artifact_super_damage";
            quad.flags = FL_ITEM;
            quad.solid = SOLID_TRIGGER;
            quad.movetype = MOVETYPE_TOSS;
            quad.effects = EF_QUADLIGHT;
            quad.noise = "items/damage.wav";
            setmodel(quad, "progs/quaddama.mdl");
            quad.netname = "$qc_quad_damage";
            quad.items = IT_QUAD;
            setsize(quad, '-16 -16 -24', '16 16 32');
            quad.nextthink = time + 30;
            quad.think = SUB_Remove;
            quad.touch = SRL_QuadTouch;
            quad.super_time = timeLeft;
            quad.velocity = self.velocity;
            quad.velocity_z += 300;
        }
    }
}




