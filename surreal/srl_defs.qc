
float SRL_ENABLE_DRAWPLAYERNAMES = 1;
float SRL_ENABLE_DEATHMESSAGES = 1;
float SRL_ENABLE_WELCOMEMESSAGE = 1;
float SRL_ENABLE_DROPQUAD = 1;

float SRL_GAMEMODE_NONE = 0;
float SRL_GAMEMODE_GUNGAME = 1;
float SRL_GAMEMODE_SOULCOLLECTOR = 2;

float srl_gameMode;
string srl_welcomeMessage;

void () SRL_Initialize;
void (entity target, string message, entity attacker) SRL_SetDeathMessage;
void (float untilTime) SRL_SuppressMessages;
float (entity a, entity b) SRL_IsSameTeam;
 
void () SRL_PutClientInServer;
void () SRL_PlayerPreThink;
void () SRL_PlayerPostThink;
void () SRL_ImpulseCommands;
void () SRL_StartItem;
void (entity target, entity attacker) SRL_Killed;
float () SRL_CheckRules;
float () SRL_ShouldDropBackpack;
float (entity targ, entity inflictor, entity attacker, float damage) SRL_GetDamageMultiplier;

