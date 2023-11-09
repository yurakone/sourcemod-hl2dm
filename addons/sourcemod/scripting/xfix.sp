/******************************
COMPILE OPTIONS
******************************/

#pragma semicolon 1
#pragma newdecls required

/******************************
NECESSARY INCLUDES
******************************/

#include <sourcemod>
#include <clientprefs>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
//#include <basecomm>
#include <morecolors>
#include <jhl2dm>
#include <vphysics>

/******************************
PLUGIN DEFINES
******************************/

#define MAX_BUTTONS 25

/*Team Colors*/
#define PLAYERCOLOR "{thistle}"
#define TEAMCOLOR	"{tan}"
#define CHATCOLOR	"{white}"
#define REBELS		"{rebels}"
#define COMBINE		"{combine}"
#define SPEC		"{spec}"
#define UNASSIGNED	"{unassigned}"
#define ZOOM_NONE	0
#define ZOOM_XBOW	1
#define ZOOM_SUIT	2
#define ZOOM_TOGL	3
#define FIRSTPERSON 4

/*Setting static strings*/
static const char
	/*Plugin Info*/
	PL_NAME[]		 = "HL2MP - Fixes & Enhancements",
	PL_AUTHOR[]		 = "Benni, Harper, Peter Brev, sidez, V952",
	PL_DESCRIPTION[] = "Footsteps",
	PL_VERSION[]	 = "1.4.0";

/******************************
PLUGIN HANDLES
******************************/

Handle g_hTeam[MAXPLAYERS + 1],
	g_hTimeLeft,
	g_hTimer,
	gcFov;

/******************************
PLUGIN FLOATS
******************************/
float gfVolume = 1.0;

/******************************
PLUGIN BOOLEANS
******************************/
bool  gbLate,
	g_bPlayerModel[MAXPLAYERS + 1]								= { true, ... },
								g_bShowMessages[MAXPLAYERS + 1] = { true, ... },
								//g_bTchat,
								gbRoundEnd,
								gbMOTDExists,
								gbTeamplay;

/******************************
PLUGIN CONVARS
******************************/

ConVar gCvar;

enum struct _gConVar
{
	ConVar g_cplayermodelmsg;
	ConVar g_cTeamHook;
	ConVar g_cEnable;
	ConVar g_cChatEnabled;
	ConVar g_cTeamplay;
	ConVar fov_minfov;
	ConVar fov_defaultfov;
	ConVar fov_maxfov;
	ConVar sv_gravity;
	ConVar mp_falldamage;
}

_gConVar  gConVar;

/******************************
PLUGIN INTEGERS
******************************/
int		  giZoom[MAXPLAYERS + 1];

/******************************
PLUGIN STRINGMAPS
******************************/
StringMap gmKills,
	gmDeaths,
	gmTeams;

/******************************
PLUGIN STRINGS
******************************/
char g_sFootstepSnds[52][75] = {
	"player/footsteps/ladder1.wav",
	"player/footsteps/ladder2.wav",
	"player/footsteps/ladder3.wav",
	"player/footsteps/ladder4.wav",
	"player/footsteps/concrete1.wav",
	"player/footsteps/concrete2.wav",
	"player/footsteps/concrete3.wav",
	"player/footsteps/concrete4.wav",
	"player/footsteps/dirt4.wav",
	"player/footsteps/dirt2.wav",
	"player/footsteps/dirt3.wav",
	"player/footsteps/dirt4.wav",
	"player/footsteps/duct1.wav",
	"player/footsteps/duct2.wav",
	"player/footsteps/duct3.wav",
	"player/footsteps/duct4.wav",
	"player/footsteps/grass1.wav",
	"player/footsteps/grass2.wav",
	"player/footsteps/grass3.wav",
	"player/footsteps/grass4.wav",
	"player/footsteps/gravel1.wav",
	"player/footsteps/gravel2.wav",
	"player/footsteps/gravel3.wav",
	"player/footsteps/gravel4.wav",
	"player/footsteps/metalgrate1.wav",
	"player/footsteps/metalgrate2.wav",
	"player/footsteps/metalgrate3.wav",
	"player/footsteps/metalgrate4.wav",
	"player/footsteps/mud1.wav",
	"player/footsteps/mud2.wav",
	"player/footsteps/mud3.wav",
	"player/footsteps/mud4.wav",
	"player/footsteps/sand1.wav",
	"player/footsteps/sand2.wav",
	"player/footsteps/sand3.wav",
	"player/footsteps/sand4.wav",
	"player/footsteps/wood1.wav",
	"player/footsteps/wood2.wav",
	"player/footsteps/wood3.wav",
	"player/footsteps/wood4.wav",
	"physics/glass/glass_sheet_step1.wav",
	"physics/glass/glass_sheet_step2.wav",
	"physics/glass/glass_sheet_step3.wav",
	"physics/glass/glass_sheet_step4.wav",
	"physics/plaster/ceiling_tile_step1.wav",
	"physics/plaster/ceiling_tile_step2.wav",
	"physics/plaster/ceiling_tile_step3.wav",
	"physics/plaster/ceiling_tile_step4.wav",
	"physics/plaster/drywall_footstep1.wav",
	"physics/plaster/drywall_footstep2.wav",
	"physics/plaster/drywall_footstep3.wav",
	"physics/plaster/drywall_footstep4.wav"
};

char g_sWepSnds[8][75] = {
	"weapons/crossbow/bolt_load1.wav",
	"weapons/crossbow/bolt_load2.wav",
	"weapons/physcannon/physcannon_claws_close.wav",
	"weapons/physcannon/physcannon_claws_open.wav",
	"weapons/physcannon/physcannon_tooheavy.wav",
	"weapons/physcannon/physcannon_pickup.wav",
	"weapons/physcannon/physcannon_drop.wav",
	"weapons/physcannon/hold_loop.wav"
};

char ModelsHuman[45][70] = {
	"models/humans/group01/female_01.mdl",
	"models/humans/group01/female_02.mdl",
	"models/humans/group01/female_03.mdl",
	"models/humans/group01/female_04.mdl",
	"models/humans/group01/female_06.mdl",
	"models/humans/group01/female_07.mdl",
	"models/humans/group01/male_01.mdl",
	"models/humans/group01/male_02.mdl",
	"models/humans/group01/male_03.mdl",
	"models/humans/group01/male_04.mdl",
	"models/humans/group01/male_05.mdl",
	"models/humans/group01/male_06.mdl",
	"models/humans/group01/male_07.mdl",
	"models/humans/group01/male_08.mdl",
	"models/humans/group01/male_09.mdl",
	"models/humans/group02/female_01.mdl",
	"models/humans/group02/female_02.mdl",
	"models/humans/group02/female_03.mdl",
	"models/humans/group02/female_04.mdl",
	"models/humans/group02/female_06.mdl",
	"models/humans/group02/female_07.mdl",
	"models/humans/group02/male_01.mdl",
	"models/humans/group02/male_02.mdl",
	"models/humans/group02/male_03.mdl",
	"models/humans/group02/male_04.mdl",
	"models/humans/group02/male_05.mdl",
	"models/humans/group02/male_06.mdl",
	"models/humans/group02/male_07.mdl",
	"models/humans/group02/male_08.mdl",
	"models/humans/group02/male_09.mdl",
	"models/humans/group03/female_01.mdl",
	"models/humans/group03female_02.mdl",
	"models/humans/group03/female_03.mdl",
	"models/humans/group03/female_04.mdl",
	"models/humans/group03/female_06.mdl",
	"models/humans/group03/female_07.mdl",
	"models/humans/group03/male_01.mdl",
	"models/humans/group03/male_02.mdl",
	"models/humans/group03/male_03.mdl",
	"models/humans/group03/male_04.mdl",
	"models/humans/group03/male_05.mdl",
	"models/humans/group03/male_06.mdl",
	"models/humans/group03/male_07.mdl",
	"models/humans/group03/male_08.mdl",
	"models/humans/group03/male_09.mdl"
};

char g_sDisconnectReason[64];

/******************************
PLUGIN INFO
******************************/
public Plugin myinfo =
{
	name		= PL_NAME,
	author		= PL_AUTHOR,
	description = PL_DESCRIPTION,
	version		= PL_VERSION
};

/******************************
LATE LOAD
******************************/
public APLRes AskPluginLoad2(Handle hPlugin, bool bLate, char[] sError, int iLen)
{
	gbLate = bLate;
	return APLRes_Success;
}

/******************************
INITIATE THE PLUGIN
******************************/
public void OnPluginStart()
{
	/*GAME CHECK*/
	EngineVersion engine = GetEngineVersion();

	if (engine != Engine_HL2DM)
	{
		SetFailState("[HL2MP] This plugin is intended for Half-Life 2: Deathmatch only.");
	}

	AddNormalSoundHook(OnSound);
	AddNormalSoundHook(OnSoundXbow);
	AddNormalSoundHook(OnSoundGravGunClose);
	AddNormalSoundHook(OnSoundGravGunOpen);
	AddNormalSoundHook(OnSoundGravGunPull);
	AddNormalSoundHook(OnSoundGravGunPickUp);
	AddNormalSoundHook(OnSoundGravGunDrop);
	AddNormalSoundHook(OnSoundGravGunHold);
	AddNormalSoundHook(OnSoundGrenadeThrow);

	/*PRECACHE SOUNDS*/
	for (int i = 1; i < sizeof(g_sWepSnds); i++)
	{
		PrecacheSound(g_sWepSnds[i]);
	}

	for (int i = 1; i < sizeof(g_sFootstepSnds); i++)
	{
		PrecacheSound(g_sFootstepSnds[i]);
	}

	/*PRECACHE MODELS*/
	for (int i; i < sizeof(ModelsHuman); i++)
	{
		PrecacheModel(ModelsHuman[i]);
	}

	if (gbLate)
	{
		ReplicateToAll("0");
	}

	gmKills	 = CreateTrie();
	gmDeaths = CreateTrie();
	gmTeams	 = CreateTrie();

	/*COOKIES*/
	gcFov	 = RegClientCookie("hl2dm_fov", "Field-of-view value", CookieAccess_Public);

	/*CONVARS*/
	CreateConVar("sm_hl2mp_fixes_version", PL_VERSION, "Version", FCVAR_DONTRECORD | FCVAR_SPONLY | FCVAR_ARCHIVE);

	gConVar.g_cplayermodelmsg = CreateConVar("sm_show_playermodel_msg_global", "1", "Shows message that player model was adjusted based on team", 0, true, 0.0, true, 1.0);
	gConVar.g_cTeamHook		  = CreateConVar("sm_playermodel_fix", "1", "Enable/Disable plugin fix", 0, true, 0.0, true, 1.0);
	gConVar.g_cEnable		  = CreateConVar("sm_connect_status_enable", "1", "Determines if the plugin is enabled", 0, true, 0.0, true, 1.0);
	gConVar.g_cChatEnabled	  = CreateConVar("sm_chat_color_enabled", "1", "Enable/Disable Plugin", 0, true, 0.0, true, 1.0);

	gConVar.fov_minfov		  = CreateConVar("fov_minfov", "70", "Minimum FOV allowed on server");
	gConVar.fov_defaultfov	  = CreateConVar("fov_defaultfov", "90", "Default FOV of players on server");
	gConVar.fov_maxfov		  = CreateConVar("fov_maxfov", "110", "Maximum FOV allowed on server");

	gConVar.g_cTeamplay		  = FindConVar("mp_teamplay");
	gConVar.mp_falldamage	  = FindConVar("mp_falldamage");
	gConVar.sv_gravity		  = FindConVar("sv_gravity");
	gCvar					  = FindConVar("sv_footsteps");

	/*HOOKING*/
	HookUserMessage(GetUserMessageId("TextMsg"), dfltmsg, true);		 // To get rid of default engine messages
	HookEvent("player_team", playerteam_callback, EventHookMode_Pre);	 // To fix death when names get changed through SM commands
	HookEvent("player_disconnect", playerdisconnect_callback, EventHookMode_Pre);
	HookEvent("player_connect_client", Event_PlayerConnect, EventHookMode_Pre);
	HookEvent("server_cvar", Event_GameMessage, EventHookMode_Pre);
	HookConVarChange(gConVar.g_cTeamHook, OnConVarChanged_pModelFix);
	HookConVarChange(gConVar.g_cTeamplay, OnConVarChanged_Teamplay);
	HookUserMessage(GetUserMessageId("VGUIMenu"), UserMsg_VGUIMenu, false);
	AddNormalSoundHook(OnNormalSound);
	gConVar.sv_gravity.AddChangeHook(OnGravityChanged);

	/*AddCommandListener(cmd_say, "say");
	AddCommandListener(cmd_tsay, "say_team");*/
	AddCommandListener(OnClientChangeFOV, "fov");
	AddCommandListener(OnClientToggleZoom, "toggle_zoom");
	AddCommandListener(HandleUse, "phys_swap");
	AddCommandListener(HandleUse, "use");

	/*PUBLIC COMMANDS*/
	RegConsoleCmd("sm_show_playermodel_msg", Command_playermdlmsg, "Display message that player model was adjusted when switching teams");
	RegConsoleCmd("sm_fov", Command_FOV, "Set your desired field-of-view value");

	for (int i; i <= MaxClients; i++)
	{
		g_bPlayerModel[i]  = false;
		g_bShowMessages[i] = false;
	}

	AutoExecConfig(true, "hl2mp_fix_config");
}

/******************************
PLUGIN FUNCTIONS
******************************/
public void OnMapStart()
{
	for (int i = 1; i < sizeof(g_sWepSnds); i++)
	{
		PrecacheSound(g_sWepSnds[i]);
	}

	g_hTimeLeft	 = CreateHudSynchronizer();
	g_hTimer	 = CreateTimer(1.0, t_UpdateTimeLeft, _, TIMER_REPEAT);
	gbMOTDExists = (FileExists("cfg/motd.txt") && FileSize("cfg/motd.txt") > 2);
	gbTeamplay	 = gConVar.g_cTeamplay.BoolValue;
	gbRoundEnd	 = false;

	CreateTimer(0.1, T_CheckPlayerStates, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void OnMapEnd()
{
	delete g_hTimeLeft;
	delete g_hTimer;
	gmKills.Clear();
	gmDeaths.Clear();
}

public Action Event_RoundStart(Handle hEvent, const char[] sEvent, bool bDontBroadcast)
{
	gmTeams.Clear();
	gmKills.Clear();
	gmDeaths.Clear();

	return Plugin_Continue;
}

public void OnClientPutInServer(int iClient)
{
	SDKHook(iClient, SDKHook_WeaponSwitchPost, OnClientSwitchWeapon);

	ReplicateTo(iClient, "0");

	if (GetConVarBool(gConVar.g_cEnable))
	{
		int c_Teamplay;
		c_Teamplay = GetConVarInt(FindConVar("mp_teamplay"));
		if (c_Teamplay == 0)
		{
			PrintToChatAll("\x04%N \x01is connected.", iClient);
		}
	}

	if (!IsClientSourceTV(iClient))
	{
		SDKHook(iClient, SDKHook_WeaponCanSwitchTo, Hook_WeaponCanSwitchTo);
		SDKHook(iClient, SDKHook_OnTakeDamage, Hook_OnTakeDamage);

		if (!gbMOTDExists)
		{
			// disable showing the MOTD panel if there's nothing to show
			CreateTimer(0.5, T_BlockConnectMOTD, iClient, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

/******************************
SOUNDS
******************************/
public Action OnSound(int iClients[MAXPLAYERS], int &iNumClients, char sSample[PLATFORM_MAX_PATH], int &iEntity, int &iChannel, float &fVolume, int &iLevel, int &iPitch, int &iFlags, char sEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (iEntity < 1 || iEntity > MaxClients || !IsClientInGame(iEntity))
		return Plugin_Continue;

	if (StrContains(sSample, "npc/metropolice/gear", false) != -1 || StrContains(sSample, "npc/combine_soldier/gear", false) != -1 || StrContains(sSample, "npc/footsteps/hardboot_generic", false) != -1)
	{
		float pos[3];
		float ang[3];
		GetClientAbsOrigin(iEntity, pos);
		ang[0] = 90.0;
		ang[1] = 0.0;
		ang[2] = 0.0;
		char   surfname[128];
		Handle trace = TR_TraceRayFilterEx(pos, ang, MASK_SHOT | MASK_SHOT_HULL | MASK_WATER, RayType_Infinite, TraceEntityFilter, iEntity);
		// int	   surfflags = TR_GetSurfaceFlags(trace);
		TR_GetSurfaceName(trace, surfname, sizeof(surfname));
		// int surfprops = TR_GetSurfaceProps(trace);
		CloseHandle(trace);
		// PrintToChat(iEntity, "TRMaterial Flags %i Props %i Name %s", surfflags, surfprops, surfname);

		if (GetEntityMoveType(iEntity) == MOVETYPE_LADDER)
		{
			Format(sSample, sizeof(sSample), "player/footsteps/ladder%i.wav", GetRandomInt(1, 4));
		}

		else if (StrContains(surfname, "ceiling_tile", false) != -1)
		{
			Format(sSample, sizeof(sSample), "physics/plaster/ceiling_tile_step%i.wav", GetRandomInt(1, 4));
		}

		else if (StrContains(surfname, "tile", false) != -1)
		{
			Format(sSample, sizeof(sSample), "player/footsteps/tile%i.wav", GetRandomInt(1, 4));
		}

		else if (StrContains(surfname, "metalduct", false) != -1)
		{
			Format(sSample, sizeof(sSample), "player/footsteps/duct%i.wav", GetRandomInt(1, 4));
		}

		else if (StrContains(surfname, "metalgrate", false) != -1)
		{
			Format(sSample, sizeof(sSample), "player/footsteps/metalgrate%i.wav", GetRandomInt(1, 4));
		}

		else if (StrContains(surfname, "metal", false) != -1)
		{
			Format(sSample, sizeof(sSample), "player/footsteps/metal%i.wav", GetRandomInt(1, 4));
		}

		else if (StrContains(surfname, "mud", false) != -1)
		{
			Format(sSample, sizeof(sSample), "player/footsteps/mud%i.wav", GetRandomInt(1, 4));
		}

		else if (StrContains(surfname, "sand", false) != -1)
		{
			Format(sSample, sizeof(sSample), "player/footsteps/sand%i.wav", GetRandomInt(1, 4));
		}

		else if (StrContains(surfname, "wood", false) != -1)
		{
			Format(sSample, sizeof(sSample), "player/footsteps/wood%i.wav", GetRandomInt(1, 4));
		}

		else if (StrContains(surfname, "dirt", false) != -1)
		{
			Format(sSample, sizeof(sSample), "player/footsteps/dirt%i.wav", GetRandomInt(1, 4));
		}

		else if (StrContains(surfname, "gravel", false) != -1)
		{
			Format(sSample, sizeof(sSample), "player/footsteps/gravel%i.wav", GetRandomInt(1, 4));
		}

		else if (StrContains(surfname, "grass", false) != -1)
		{
			Format(sSample, sizeof(sSample), "player/footsteps/grass%i.wav", GetRandomInt(1, 4));
		}

		else if (StrContains(surfname, "glass", false) != -1)
		{
			Format(sSample, sizeof(sSample), "physics/glass/glass_sheet_step%i.wav", GetRandomInt(1, 4));
		}

		else if (StrContains(surfname, "plaster", false) != -1)
		{
			Format(sSample, sizeof(sSample), "physics/plaster/drywall_footstep%i.wav", GetRandomInt(1, 4));
		}

		else
		{
			Format(sSample, sizeof(sSample), "player/footsteps/concrete%i.wav", GetRandomInt(1, 4));
		}
		// Format(sSample, sizeof(sSample), "player/footsteps/concrete%i.wav", GetRandomInt(1, 4));
	}
	else if (StrContains(sSample, "npc/footsteps/hardboot_generic", false) == -1) {
		// Not a footstep sound.
		return Plugin_Continue;
	}

	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (!IsClientConnected(iClient) || !IsClientInGame(iClient))
			continue;

		EmitSoundToClient(iClient, sSample, iEntity, iChannel, iLevel, iFlags, fVolume * gfVolume, iPitch);
	}

	return Plugin_Changed;
}

public Action OnSoundXbow(int iClients[MAXPLAYERS], int &iNumClients, char sSample[PLATFORM_MAX_PATH], int &iEntity, int &iChannel, float &fVolume, int &iLevel, int &iPitch, int &iFlags, char sEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (iEntity < 1 || iEntity > MaxClients || !IsClientInGame(iEntity))
		return Plugin_Continue;

	if (StrContains(sSample, "weapons/crossbow/bolt_load", false) != -1)
	{
		Format(sSample, sizeof(sSample), "weapons/crossbow/bolt_load%i.wav", GetRandomInt(1, 2));
	}

	if (StrContains(sSample, "weapons/crossbow/bolt_load", false) == -1)
	{
		return Plugin_Continue;
	}

	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (!IsClientConnected(iClient) || !IsClientInGame(iClient))
			continue;

		EmitSoundToClient(iClient, sSample, iEntity, iChannel, iLevel, iFlags, fVolume * gfVolume, iPitch);
	}

	return Plugin_Changed;
}

public Action OnSoundGravGunClose(int iClients[MAXPLAYERS], int &iNumClients, char sSample[PLATFORM_MAX_PATH], int &iEntity, int &iChannel, float &fVolume, int &iLevel, int &iPitch, int &iFlags, char sEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (iEntity < 1 || iEntity > MaxClients || !IsClientInGame(iEntity))
		return Plugin_Continue;

	if (StrContains(sSample, "weapons/physcannon/physcannon_claws_close", false) != -1)
	{
		Format(sSample, sizeof(sSample), "weapons/physcannon/physcannon_claws_close.wav");
	}

	if (StrContains(sSample, "weapons/physcannon/physcannon_claws_close", false) == -1)
	{
		return Plugin_Continue;
	}

	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (!IsClientConnected(iClient) || !IsClientInGame(iClient))
			continue;

		EmitSoundToClient(iClient, sSample, iEntity, iChannel, iLevel, iFlags, fVolume * gfVolume, iPitch);
	}

	return Plugin_Changed;
}

public Action OnSoundGravGunOpen(int iClients[MAXPLAYERS], int &iNumClients, char sSample[PLATFORM_MAX_PATH], int &iEntity, int &iChannel, float &fVolume, int &iLevel, int &iPitch, int &iFlags, char sEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (iEntity < 1 || iEntity > MaxClients || !IsClientInGame(iEntity))
		return Plugin_Continue;

	if (StrContains(sSample, "weapons/physcannon/physcannon_claws_open", false) != -1)
	{
		Format(sSample, sizeof(sSample), "weapons/physcannon/physcannon_claws_open.wav");
	}

	if (StrContains(sSample, "weapons/physcannon/physcannon_claws_open", false) == -1)
	{
		return Plugin_Continue;
	}

	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (!IsClientConnected(iClient) || !IsClientInGame(iClient))
			continue;

		EmitSoundToClient(iClient, sSample, iEntity, iChannel, iLevel, iFlags, fVolume * gfVolume, iPitch);
	}

	return Plugin_Changed;
}

public Action OnSoundGravGunPull(int iClients[MAXPLAYERS], int &iNumClients, char sSample[PLATFORM_MAX_PATH], int &iEntity, int &iChannel, float &fVolume, int &iLevel, int &iPitch, int &iFlags, char sEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (iEntity < 1 || iEntity > MaxClients || !IsClientInGame(iEntity))
		return Plugin_Continue;

	if (StrContains(sSample, "weapons/physcannon/physcannon_tooheavy", false) != -1)
	{
		Format(sSample, sizeof(sSample), "weapons/physcannon/physcannon_tooheavy.wav");
	}

	if (StrContains(sSample, "weapons/physcannon/physcannon_tooheavy", false) == -1)
	{
		return Plugin_Continue;
	}

	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (!IsClientConnected(iClient) || !IsClientInGame(iClient))
			continue;

		EmitSoundToClient(iClient, sSample, iEntity, iChannel, iLevel, iFlags, fVolume * gfVolume, iPitch);
	}

	return Plugin_Changed;
}

public Action OnSoundGravGunPickUp(int iClients[MAXPLAYERS], int &iNumClients, char sSample[PLATFORM_MAX_PATH], int &iEntity, int &iChannel, float &fVolume, int &iLevel, int &iPitch, int &iFlags, char sEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (iEntity < 1 || iEntity > MaxClients || !IsClientInGame(iEntity))
		return Plugin_Continue;

	if (StrContains(sSample, "weapons/physcannon/physcannon_pickup", false) != -1)
	{
		Format(sSample, sizeof(sSample), "weapons/physcannon/physcannon_pickup.wav");
	}

	if (StrContains(sSample, "weapons/physcannon/physcannon_pickup", false) == -1)
	{
		return Plugin_Continue;
	}

	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (!IsClientConnected(iClient) || !IsClientInGame(iClient))
			continue;

		EmitSoundToClient(iClient, sSample, iEntity, iChannel, iLevel, iFlags, fVolume * gfVolume, iPitch);
	}

	return Plugin_Changed;
}

public Action OnSoundGravGunDrop(int iClients[MAXPLAYERS], int &iNumClients, char sSample[PLATFORM_MAX_PATH], int &iEntity, int &iChannel, float &fVolume, int &iLevel, int &iPitch, int &iFlags, char sEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (iEntity < 1 || iEntity > MaxClients || !IsClientInGame(iEntity))
		return Plugin_Continue;

	if (StrContains(sSample, "weapons/physcannon/physcannon_drop", false) != -1)
	{
		Format(sSample, sizeof(sSample), "weapons/physcannon/physcannon_drop.wav");
	}

	if (StrContains(sSample, "weapons/physcannon/physcannon_drop", false) == -1)
	{
		return Plugin_Continue;
	}

	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (!IsClientConnected(iClient) || !IsClientInGame(iClient))
			continue;

		EmitSoundToClient(iClient, sSample, iEntity, iChannel, iLevel, iFlags, fVolume * gfVolume, iPitch);
	}

	return Plugin_Changed;
}

public Action OnSoundGravGunHold(int iClients[MAXPLAYERS], int &iNumClients, char sSample[PLATFORM_MAX_PATH], int &iEntity, int &iChannel, float &fVolume, int &iLevel, int &iPitch, int &iFlags, char sEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (iEntity < 1 || iEntity > MaxClients || !IsClientInGame(iEntity))
		return Plugin_Continue;

	if (StrContains(sSample, "weapons/physcannon/hold_loop", false) != -1)
	{
		Format(sSample, sizeof(sSample), "weapons/physcannon/hold_loop.wav");
	}

	if (StrContains(sSample, "weapons/physcannon/hold_loop", false) == -1)
	{
		return Plugin_Continue;
	}

	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (!IsClientConnected(iClient) || !IsClientInGame(iClient))
			continue;

		EmitSoundToClient(iClient, sSample, iEntity, iChannel, iLevel, iFlags, fVolume * gfVolume, iPitch);
	}

	return Plugin_Changed;
}

public Action OnSoundGrenadeThrow(int iClients[MAXPLAYERS], int &iNumClients, char sSample[PLATFORM_MAX_PATH], int &iEntity, int &iChannel, float &fVolume, int &iLevel, int &iPitch, int &iFlags, char sEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (iEntity < 1 || iEntity > MaxClients || !IsClientInGame(iEntity))
		return Plugin_Continue;

	if (StrContains(sSample, "weapons/slam/throw", false) != -1)
	{
		Format(sSample, sizeof(sSample), "weapons/slam/throw.wav");
	}

	if (StrContains(sSample, "weapons/slam/throw.wav", false) == -1)
	{
		return Plugin_Continue;
	}

	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (!IsClientConnected(iClient) || !IsClientInGame(iClient))
			continue;

		EmitSoundToClient(iClient, sSample, iEntity, iChannel, iLevel, iFlags, fVolume * gfVolume, iPitch);
	}

	return Plugin_Changed;
}

void ReplicateTo(int iClient, const char[] sValue)
{
	if (IsClientInGame(iClient) && !IsFakeClient(iClient))
	{
		gCvar.ReplicateToClient(iClient, sValue);
	}
}

void ReplicateToAll(const char[] sValue)
{
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		ReplicateTo(iClient, sValue);
	}
}

bool TraceEntityFilter(int entity, int contentsMask, any data)
{
	if (entity == data)
	{
		return true;
	}
	if (entity > 0 && entity <= MaxClients)
	{
		return false;
	}
	return false;
}

/******************************
PLAYER MODEL FIX
******************************/
public Action playerteam_callback(Event event, const char[] name, bool dontBroadcast)	  // HL2DM: Fixes death when name gets changed through a command
{
	if (GetConVarBool(gConVar.g_cTeamHook))
	{
		SetEventBroadcast(event, true);
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		int team   = GetEventInt(event, "team");

		if (!client || IsFakeClient(client) || !IsClientInGame(client))
			return Plugin_Handled;
		DataPack pack;
		g_hTeam[client] = CreateDataTimer(0.1, changeteamtimer, pack);	  // Using a timer because team == 0 causes team change message to show on client disconnect
		pack.WriteCell(client);
		pack.WriteCell(team);
		return Plugin_Handled;
	}
	else return Plugin_Continue;
}

public Action changeteamtimer(Handle timer, DataPack pack)
{
	int client;
	int team;

	pack.Reset();
	client = pack.ReadCell();
	team   = pack.ReadCell();

	if (team == 3)
	{
		if (!IsClientInGame(client))
			return Plugin_Stop;

		ClientCommand(client, "cl_playermodel models/humans/group03/female_04.mdl");
		SetEntityRenderColor(client, 255, 255, 255, 255);
		if (GetConVarBool(gConVar.g_cplayermodelmsg))
		{
			if (g_bPlayerModel[client])
			{
				PrintToChat(client, "Adjusting your cl_playermodel setting to match your team.");
			}
		}
		CPrintToChatAll("%s%N \x01has joined team: %sRebels", REBELS, client, REBELS);

		LogAction(client, -1, "%N has changed teams (Rebels). Client's cl_playermodel parameter adjusted to reflect new team.", client);

		return Plugin_Stop;
	}

	if (team == 2)
	{
		if (!IsClientInGame(client))
			return Plugin_Stop;

		ClientCommand(client, "cl_playermodel models/police.mdl");
		SetEntityRenderColor(client, 255, 255, 255, 255);
		if (GetConVarBool(gConVar.g_cplayermodelmsg))
		{
			if (g_bPlayerModel[client])
			{
				PrintToChat(client, "Adjusting your cl_playermodel setting to match your team.");
			}
		}
		CPrintToChatAll("%s%N \x01has joined team: %sCombine", COMBINE, client, COMBINE);

		LogAction(client, -1, "%N has changed teams (Combine). Client's cl_playermodel parameter adjusted to reflect new team.", client);

		return Plugin_Stop;
	}

	if (team == 1)
	{
		if (!IsClientInGame(client))
			return Plugin_Stop;

		CPrintToChatAll("%s%N \x01has joined team: %sSpectators", SPEC, client, SPEC);

		LogAction(client, -1, "%N has changed teams (Spectators). Client's cl_playermodel parameter adjusted to reflect new team.", client);

		return Plugin_Stop;
	}

	if (team == 0)
	{
		if (!IsClientInGame(client))
			return Plugin_Stop;

		CPrintToChatAll("%s%N \x01has joined team: %sPlayers", UNASSIGNED, client, UNASSIGNED);

		LogAction(client, -1, "%N has changed teams (Players). Client's cl_playermodel parameter adjusted to reflect new team.", client);

		return Plugin_Stop;
	}
	return Plugin_Stop;
}

public Action Command_playermdlmsg(int client, int args)
{
	if (!client || IsFakeClient(client))
		return Plugin_Handled;

	if (GetConVarBool(gConVar.g_cTeamHook))
	{
		if (GetConVarBool(gConVar.g_cplayermodelmsg))
		{
			if (!args || args > 1)
			{
				PrintToChat(client, "Usage: \x04sm_show_playermodel_msg <0|1>");
				return Plugin_Handled;
			}

			char arg[5];

			GetCmdArgString(arg, sizeof(arg));

			if (StrEqual(arg, "1"))
			{
				if (g_bPlayerModel[client])
				{
					PrintToChat(client, "Messages are already showing.");
					return Plugin_Handled;
				}
				PrintToChat(client, "Player model adjusted messages showing.");
				g_bPlayerModel[client]	= true;
				g_bShowMessages[client] = true;
				return Plugin_Handled;
			}

			else if (StrEqual(arg, "0"))
			{
				if (!g_bPlayerModel[client])
				{
					PrintToChat(client, "Messages are already suppressed.");
					return Plugin_Handled;
				}
				PrintToChat(client, "Player model adjusted messages suppressed.");
				g_bPlayerModel[client]	= false;
				g_bShowMessages[client] = false;
				return Plugin_Handled;
			}

			else
			{
				PrintToChat(client, "Value must be \x040 \x01or \x041\x01.");
				return Plugin_Handled;
			}
		}

		else
		{
			PrintToChat(client, "This server has disabled the displaying of adjusted player model messages.");
			return Plugin_Handled;
		}
	}

	else
	{
		PrintToChat(client, "This plugin is currently disabled.");
		return Plugin_Handled;
	}
}

public Action dfltmsg(UserMsg msg, Handle hMsg, const int[] iPlayers, int iNumPlayers, bool bReliable, bool bInit)
{
	char sMessage[70];

	BfReadString(hMsg, sMessage, sizeof(sMessage), true);
	if (StrContains(sMessage, "more seconds before trying to switch") != -1 || StrContains(sMessage, "Your player model is") != -1 || StrContains(sMessage, "You are on team") != -1)
	{
		return Plugin_Handled;	  // Get rid of those crap messages
	}

	return Plugin_Continue;
}

public void OnConVarChanged_pModelFix(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (strcmp(newValue, "1") == 0)
	{
		PrintToServer("[HL2MP] Player will know that their player model is being updated on team change.");
		LogMessage("Players know player model is being updated on team change.");
	}
	else if (strcmp(newValue, "0") == 0)
	{
		PrintToServer("[HL2MP] Player will no longer know that their player model is being updated on team change.");
		LogMessage("Players no longer know that their player model is being updated on team change.");
	}
}

public void OnConVarChanged_Teamplay(ConVar convar, const char[] oldValue, const char[] newValue)
{
	for (int i; i <= MaxClients; i++)
	{
		if (i == 0)
		{
			int c_Teamplay;
			c_Teamplay = GetConVarInt(FindConVar("mp_teamplay"));
			if (c_Teamplay == 1)
			{
				PrintToServer("Teamplay has been enabled. Reloading map...");
				PrintToChatAll("Teamplay is now enabled.");
			}

			else if (c_Teamplay == 0)
			{
				PrintToServer("Teamplay has been disabled. Reloading map...");
				PrintToChatAll("Teamplay is now disabled.");
			}
		}
	}
	CreateTimer(0.1, TeamplayChanged_Timer);
	return;
}

public Action TeamplayChanged_Timer(Handle Timer, any data)
{
	char sMap[64];
	GetCurrentMap(sMap, sizeof(sMap));
	ForceChangeLevel(sMap, "mp_teamplay changed");
	return Plugin_Stop;
}

/******************************
CONNECT STATUS
******************************/
public Action Event_PlayerConnect(Event event, const char[] name, bool dontBroadcast)
{
	event.BroadcastDisabled = true;
	return Plugin_Continue;
}

public Action playerdisconnect_callback(Event event, const char[] name, bool dontBroadcast)
{
	if (GetConVarBool(gConVar.g_cEnable))
	{
		SetEventBroadcast(event, true);
		GetEventString(event, "reason", g_sDisconnectReason, sizeof(g_sDisconnectReason));
		return Plugin_Handled;
	}
	else return Plugin_Continue;
}

public Action playerconnect_callback(Event event, const char[] name, bool dontBroadcast)
{
	if (GetConVarBool(gConVar.g_cEnable))
	{
		SetEventBroadcast(event, true);
		return Plugin_Handled;
	}
	else return Plugin_Continue;
}

public bool OnClientConnect(int client)
{
	if (GetConVarBool(gConVar.g_cEnable))
	{
		PrintToChatAll("\x04%N \x01is connecting...", client);
	}
	return true;
}

public void OnClientDisconnect(int client)
{
	if (GetConVarBool(gConVar.g_cEnable))
	{
		if (!IsClientInGame(client))
		{
			PrintToChatAll("%s%N \x01has disconnected [\x04%s\x01]", UNASSIGNED, client, g_sDisconnectReason);
			return;
		}

		int team;
		team = GetClientTeam(client);

		if (!GetClientTeam(client))
		{
			PrintToChatAll("\x04%N \x01has disconnected - [\x04%s\x01]", client, g_sDisconnectReason);
			return;
		}

		if (team == 3)
		{
			PrintToChatAll("%s%N \x01has disconnected - [\x04%s\x01]", REBELS, client, g_sDisconnectReason);
			return;
		}

		else if (team == 2)
		{
			PrintToChatAll("%s%N \x01has disconnected - [\x04%s\x01]", COMBINE, client, g_sDisconnectReason);
			return;
		}

		else if (team == 1)
		{
			PrintToChatAll("%s%N \x01has disconnected [\x04%s\x01]", SPEC, client, g_sDisconnectReason);
			return;
		}

		else if (team == 0)
		{
			PrintToChatAll("%s%N \x01has disconnected [\x04%s\x01]", UNASSIGNED, client, g_sDisconnectReason);
			return;
		}
	}
}

/******************************
CHAT ENHANCEMENT
******************************/
/*public Action cmd_say(int client, const char[] cmd, int argc)
{
	if (GetConVarInt(gConVar.g_cChatEnabled) == 0) return Plugin_Continue;

	bool gag = BaseComm_IsClientGagged(client);

	if (gag) return Plugin_Handled;

	if (g_bTchat) return Plugin_Handled;

	char s_Text[127]; 
	int	 iteam;

	iteam = GetClientTeam(client);
	GetCmdArgString(s_Text, sizeof(s_Text)); 
	StripQuotes(s_Text);					

	if (s_Text[0] == '/') return Plugin_Handled; 

	if (iteam == 1)
	{
		CPrintToChatAll("%s[SPEC] %s%N: %s%s", SPEC, PLAYERCOLOR, client, CHATCOLOR, s_Text); 
		return Plugin_Handled;
	}

	if (iteam == 2)
	{
		CPrintToChatAll("%s%N: %s%s", COMBINE, client, CHATCOLOR, s_Text); 
		return Plugin_Handled;
	}

	if (iteam == 3)
	{
		CPrintToChatAll("%s%N: %s%s", REBELS, client, CHATCOLOR, s_Text); 
		return Plugin_Handled;
	}

	CPrintToChatAll("%s%N: %s%s", REBELS, client, CHATCOLOR, s_Text); 

	return Plugin_Handled; 
}

public Action cmd_tsay(int client, const char[] cmd, int argc)
{
	if (GetConVarInt(gConVar.g_cChatEnabled) == 0) return Plugin_Continue; 

	bool gag = BaseComm_IsClientGagged(client);

	if (gag) return Plugin_Handled;

	if (GetConVarInt(gConVar.g_cTeamplay) <= 0)
	{
		g_bTchat = true;
		PrintToChat(client, "[SM] Team play must be enabled to use team chat.");
		CreateTimer(0.1, t_reset, _, TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Handled;
	}

	char s_Text[127];
	int	 iteam;

	iteam = GetClientTeam(client);
	GetCmdArgString(s_Text, sizeof(s_Text));
	StripQuotes(s_Text);					

	if (s_Text[0] == '/') return Plugin_Handled; 

	if (iteam == 1)
	{
		CPrintToChatAll("%s[Spectators] %s%N: %s%s", SPEC, PLAYERCOLOR, client, CHATCOLOR, s_Text); 
		return Plugin_Handled;
	}

	if (iteam == 2)
	{
		CPrintToChatAll("%s[Combine] %s%N: %s%s", TEAMCOLOR, COMBINE, client, CHATCOLOR, s_Text); 
		return Plugin_Handled;
	}

	if (iteam == 3)
	{
		CPrintToChatAll("%s[Rebels] %s%N: %s%s", TEAMCOLOR, REBELS, client, CHATCOLOR, s_Text);
		return Plugin_Handled;
	}

	return Plugin_Handled;
}

public Action t_reset(Handle timer, any data)
{
	g_bTchat = false;
	return Plugin_Stop;
}*/

/******************************
TIMELEFT ON HUD
******************************/
public Action t_UpdateTimeLeft(Handle timer, any data)
{
	static int	time;
	static char timeleft[32];

	GetMapTimeLeft(time);

	if (time > -1)
	{
		if (time > 3600)
		{
			FormatEx(timeleft, sizeof(timeleft), "%ih %02im", time / 3600, (time / 60) % 60);
		}
		else if (time < 60)
		{
			FormatEx(timeleft, sizeof(timeleft), "%02i", time);
		}
		else FormatEx(timeleft, sizeof(timeleft), "%i:%02i", time / 60, time % 60);
	}

	SetHudTextParams(-1.0, 0.01, 1.10, 255, 220, 0, 255, 0, 0.0, 0.0, 0.0);

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			ShowSyncHudText(i, g_hTimeLeft, timeleft);
		}
	}
	return Plugin_Continue;
}

/******************************
FOV
******************************/
public Action Command_FOV(int iClient, int iArgs)
{
	RequestFOV(iClient, GetCmdArgInt(1));

	return Plugin_Handled;
}

public Action OnClientChangeFOV(int iClient, const char[] sCommand, int iArgs)
{
	RequestFOV(iClient, GetCmdArgInt(1));

	return Plugin_Handled;
}

void RequestFOV(int iClient, int iFov)
{
	if (iFov < GetConVarInt(gConVar.fov_minfov) || iFov > GetConVarInt(gConVar.fov_maxfov))
	{
		CPrintToChat(iClient, "%sYour FOV can only be between %s%d %sand %s%d.", CHATCOLOR, SPEC, GetConVarInt(gConVar.fov_minfov), CHATCOLOR, SPEC, GetConVarInt(gConVar.fov_maxfov));
	}
	else
	{
		SetClientCookieInt(iClient, gcFov, iFov);
		CPrintToChat(iClient, "%sFOV set: %s%d", CHATCOLOR, SPEC, iFov);
	}
}

public Action OnPlayerRunCmd(int iClient, int &iButtons, int &iImpulse, float fVel[3], float fAngles[3], int &iWeapon)
{
	if (!IsClientConnected(iClient) || !IsClientInGame(iClient) || IsFakeClient(iClient))
	{
		return Plugin_Continue;
	}

	if (IsClientObserver(iClient))
	{
		int iMode	 = GetEntProp(iClient, Prop_Send, "m_iObserverMode"),
			iTarget	 = GetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget");
		Handle hMenu = StartMessageOne("VGUIMenu", iClient);

		// disable broken spectator menu >
		if (hMenu != INVALID_HANDLE)
		{
			BfWriteString(hMenu, "specmenu");
			BfWriteByte(hMenu, 0);
			EndMessage();
		}

		// force free-look where appropriate - this removes the extra (pointless) third person spec mode >
		if (iMode == SPECMODE_ENEMYVIEW || iTarget <= 0 || !IsClientInGame(iTarget))
		{
			SetEntProp(iClient, Prop_Data, "m_iObserverMode", SPECMODE_FREELOOK);
		}

		// fix bug where spectator can't move while free-looking >
		if (iMode == SPECMODE_FREELOOK)
		{
			SetEntityMoveType(iClient, MOVETYPE_NOCLIP);
		}

		// block spectator sprinting >
		iButtons &= ~IN_SPEED;

		// also fixes 1hp bug >
		return Plugin_Changed;
	}

	if (!IsPlayerAlive(iClient))
	{
		// no use when dead >
		iButtons &= ~IN_USE;
		return Plugin_Changed;
	}

	// shotgun altfire lagcomp fix by V952 >
	int	 iActiveWeapon = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
	char sWeapon[32];

	if (IsValidEdict(iActiveWeapon))
	{
		GetEdictClassname(iActiveWeapon, sWeapon, sizeof(sWeapon));

		if (StrEqual(sWeapon, "weapon_shotgun") && (iButtons & IN_ATTACK2) == IN_ATTACK2)
		{
			iButtons |= IN_ATTACK;
			return Plugin_Changed;
		}
	}

	// Block crouch standing-view exploit >
	/*if ((iButtons & IN_DUCK) && GetEntProp(iClient, Prop_Send, "m_bDucked", 1) && GetEntProp(iClient, Prop_Send, "m_bDucking", 1))
	{
		iButtons ^= IN_DUCK;
		return Plugin_Changed;
	}*/

	if (AreClientCookiesCached(iClient))
	{
		static int iLastButtons[MAXPLAYERS + 1];

		int		   iFov = GetClientCookieInt(iClient, gcFov);

		if (iFov < GetConVarInt(gConVar.fov_minfov) || iFov > GetConVarInt(gConVar.fov_maxfov))
		{
			// fov is out of bounds, reset
			iFov = GetConVarInt(gConVar.fov_defaultfov);
		}

		if (!IsClientObserver(iClient) && IsPlayerAlive(iClient))
		{
			char sCurrentWeapon[32];

			GetClientWeapon(iClient, sCurrentWeapon, sizeof(sCurrentWeapon));

			if (giZoom[iClient] == ZOOM_XBOW || giZoom[iClient] == ZOOM_TOGL)
			{
				// block suit zoom while xbow/toggle-zoomed
				iButtons &= ~IN_ZOOM;
			}

			if (giZoom[iClient] == ZOOM_TOGL)
			{
				if (StrEqual(sCurrentWeapon, "weapon_crossbow"))
				{
					// block xbow zoom while toggle zoomed
					iButtons &= ~IN_ATTACK2;
				}

				SetEntProp(iClient, Prop_Send, "m_iDefaultFOV", 90);
				return Plugin_Continue;
			}

			if (iButtons & IN_ZOOM)
			{
				if (!(iLastButtons[iClient] & IN_ZOOM) && !giZoom[iClient])
				{
					// suit zooming
					giZoom[iClient] = ZOOM_SUIT;
				}
			}
			else if (giZoom[iClient] == ZOOM_SUIT) {
				// no longer suit zooming
				giZoom[iClient] = ZOOM_NONE;
			}

			if ((StrEqual(sCurrentWeapon, "weapon_crossbow") && (iButtons & IN_ATTACK2) && !(iLastButtons[iClient] & IN_ATTACK2)) || (!StrEqual(sCurrentWeapon, "weapon_crossbow") && giZoom[iClient] == ZOOM_XBOW))
			{
				// xbow zoom cycle
				giZoom[iClient] = (giZoom[iClient] == ZOOM_XBOW ? ZOOM_NONE : ZOOM_XBOW);
			}
		}
		else {
			giZoom[iClient] = ZOOM_NONE;
		}

		// set values
		if (giZoom[iClient] || (IsClientObserver(iClient) && GetEntProp(iClient, Prop_Send, "m_iObserverMode") == FIRSTPERSON))
		{
			SetEntProp(iClient, Prop_Send, "m_iDefaultFOV", 90);
		}
		else if (giZoom[iClient] == ZOOM_NONE) {
			SetEntProp(iClient, Prop_Send, "m_iFOV", iFov);
			SetEntProp(iClient, Prop_Send, "m_iDefaultFOV", iFov);
		}

		iLastButtons[iClient] = iButtons;
	}

	return Plugin_Continue;
}

public Action OnClientToggleZoom(int iClient, const char[] sCommand, int iArgs)
{
	if (giZoom[iClient] != ZOOM_NONE)
	{
		if (giZoom[iClient] == ZOOM_TOGL || giZoom[iClient] == ZOOM_SUIT)
		{
			giZoom[iClient] = ZOOM_NONE;
		}
	}
	else {
		giZoom[iClient] = ZOOM_TOGL;
	}

	return Plugin_Continue;
}

public Action OnClientSwitchWeapon(int iClient, int iWeapon)
{
	if (giZoom[iClient] == ZOOM_TOGL)
	{
		giZoom[iClient] = ZOOM_NONE;
	}

	return Plugin_Continue;
}

public void OnGravityChanged(Handle hConvar, const char[] sOldValue, const char[] sNewValue)
{
	float fGravity[3];

	fGravity[2] -= StringToFloat(sNewValue);

	// force sv_gravity change to take effect immediately (by default, props retain the previous map's gravity) >
	Phys_SetEnvironmentGravity(fGravity);
}

public Action Hook_OnTakeDamage(int iClient, int &iAttacker, int &iInflictor, float &fDamage, int &iDamageType)
{
	if (iDamageType & DMG_FALL)
	{
		// Fix mp_falldamage value not having any effect >
		fDamage = gConVar.mp_falldamage.FloatValue;
	}
	else if (iDamageType & DMG_BLAST)
	{
		// Remove explosion ringing noise for everyone
		// (typically this is removed by competitive configs, which provides a significant advantage and cannot be prevented)
		iDamageType = DMG_GENERIC;
	}
	else {
		return Plugin_Continue;
	}

	return Plugin_Changed;
}

public Action Hook_WeaponCanSwitchTo(int iClient, int iWeapon)
{
	// Hands animation fix by toizy >
	SetEntityFlags(iClient, GetEntityFlags(iClient) | FL_ONGROUND);

	return Plugin_Changed;
}

public void OnEntityCreated(int iEntity, const char[] sEntity)
{
	// env_sprite fix by sidezz >
	if (StrEqual(sEntity, "env_sprite", false) || StrEqual(sEntity, "env_spritetrail", false))
	{
		RequestFrame(GetSpriteData, EntIndexToEntRef(iEntity));
	}

	return;
}

public Action OnNormalSound(int iClients[MAXPLAYERS], int &iNumClients, char sSample[PLATFORM_MAX_PATH], int &iEntity, int &iChannel, float &fVolume, int &iLevel, int &iPitch, int &iFlags, char sEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (iEntity > 1 && iEntity <= MaxClients && IsClientInGame(iEntity))
	{
		if (StrContains(sSample, "npc/metropolice/die", false) != -1)
		{
			Format(sSample, sizeof(sSample), "npc/combine_soldier/die%i.wav", GetRandomInt(1, 3));
			return Plugin_Changed;
		}
	}

	return Plugin_Continue;
}

void GetSpriteData(int iRef)
{
	int iSprite = EntRefToEntIndex(iRef);

	if (IsValidEntity(iSprite))
	{
		int	 iNade = GetEntPropEnt(iSprite, Prop_Data, "m_hAttachedToEntity");
		char sClass[32];

		if (iNade == -1)
		{
			return;
		}

		GetEdictClassname(iNade, sClass, sizeof(sClass));

		if (StrEqual(sClass, "npc_grenade_frag", false))
		{
			for (int i = MaxClients + 1; i < 2048; i++)
			{
				char sOtherClass[32];

				if (!IsValidEntity(i))
				{
					continue;
				}

				GetEdictClassname(i, sOtherClass, sizeof(sOtherClass));

				if (StrEqual(sOtherClass, "env_spritetrail", false) || StrEqual(sOtherClass, "env_sprite", false))
				{
					if (GetEntPropEnt(i, Prop_Data, "m_hAttachedToEntity") == iNade)
					{
						int iGlow  = GetEntPropEnt(iNade, Prop_Data, "m_pMainGlow"),
							iTrail = GetEntPropEnt(iNade, Prop_Data, "m_pGlowTrail");

						if (i != iGlow && i != iTrail)
						{
							AcceptEntityInput(i, "Kill");
						}
					}
				}
			}
		}
	}
}

public Action T_CheckPlayerStates(Handle hTimer)
{
	static bool bWasAlive[MAXPLAYERS + 1] = { false };
	static int	iWasTeam[MAXPLAYERS + 1]  = { -1 };

	int			iTeamScore[4];

	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (!IsClientInGame(iClient))
		{
			iWasTeam[iClient]  = -1;
			bWasAlive[iClient] = false;
			continue;
		}

		if (IsClientSourceTV(iClient))
		{
			continue;
		}

		int	 iTeam	= GetClientTeam(iClient);
		bool bAlive = IsPlayerAlive(iClient);

		if (iWasTeam[iClient] == -1)
		{
			int iKills,
				iDeaths;

			gmKills.GetValue(AuthId(iClient), iKills);
			gmDeaths.GetValue(AuthId(iClient), iDeaths);

			Client_SetScore(iClient, iKills);
			Client_SetDeaths(iClient, iDeaths);
		}
		else if (iTeam != iWasTeam[iClient]) {
			OnPlayerPostTeamChange(iClient, iTeam, bWasAlive[iClient], bAlive);
		}

		iWasTeam[iClient]  = iTeam;
		bWasAlive[iClient] = bAlive;
		iTeamScore[iTeam] += Client_GetScore(iClient);

		if (!gbRoundEnd)
		{
			SavePlayerState(iClient);
		}
	}

	// team scores should reflect current team members
	for (int i = 1; i < 4; i++)
	{
		Team_SetScore(i, iTeamScore[i]);
	}

	return Plugin_Continue;
}

void SavePlayerStates()
{
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (IsClientInGame(iClient) && !IsClientSourceTV(iClient))
		{
			SavePlayerState(iClient);
		}
	}
}

void SavePlayerState(int iClient)
{
	int	 iTeam;
	char sId[32];

	GetClientAuthId(iClient, AuthId_Engine, sId, sizeof(sId));
	iTeam = (gbTeamplay					 ? GetClientTeam(iClient)
			 : IsClientObserver(iClient) ? TEAM_SPECTATORS
										 : TEAM_REBELS);

	gmKills.SetValue(sId, Client_GetScore(iClient));
	gmDeaths.SetValue(sId, Client_GetDeaths(iClient));
	gmTeams.SetValue(sId, iTeam);
}

void OnPlayerPostTeamChange(int iClient, int iTeam, bool bWasAlive, bool bIsAlive)
{
	if (!bIsAlive)
	{
		if (iTeam == TEAM_SPECTATORS)
		{
			if (gbTeamplay)
			{
				if (!bWasAlive)
				{
					// player was dead and joined spec, the game will record a kill, fix:
					Client_SetScore(iClient, Client_GetScore(iClient) - 1);
				}
				else {
					// player was alive and joined spec, the game will record a death, fix:
					Client_SetDeaths(iClient, Client_GetDeaths(iClient) - 1);
				}
			}
		}
		else if (bWasAlive) {
			// player was alive and changed team, the game will record a suicide, fix:
			Client_SetScore(iClient, Client_GetScore(iClient) + 1);
			Client_SetDeaths(iClient, Client_GetDeaths(iClient) - 1);
		}
	}
}

public Action T_BlockConnectMOTD(Handle hTimer, int iClient)
{
	if (IsClientConnected(iClient) && IsClientInGame(iClient) && !IsFakeClient(iClient))
	{
		Handle hMsg = StartMessageOne("VGUIMenu", iClient);

		if (hMsg != INVALID_HANDLE)
		{
			BfWriteString(hMsg, "info");
			BfWriteByte(hMsg, 0);
			EndMessage();
		}
	}

	return Plugin_Handled;
}

public Action UserMsg_VGUIMenu(UserMsg msg, Handle hMsg, const int[] iPlayers, int iNumPlayers, bool bReliable, bool bInit)
{
	char sMsg[10];

	BfReadString(hMsg, sMsg, sizeof(sMsg));
	if (StrEqual(sMsg, "scores"))
	{
		gbRoundEnd = true;
		RequestFrame(SavePlayerStates);
	}

	return Plugin_Continue;
}

public Action Event_GameMessage(Event hEvent, const char[] sEvent, bool bDontBroadcast)
{
	// block Server cvar spam
	hEvent.BroadcastDisabled = true;

	return Plugin_Changed;
}

public Action HandleUse(int client, const char[] cmd, int argc)
{
	char WeaponName[32];
	GetClientWeapon(client, WeaponName, sizeof(WeaponName));

	if (StrEqual(WeaponName, "weapon_physcannon"))
	{
		if (GetEntityOpen(HasClientWeapon(client, "weapon_physcannon")) && GetEffectState(HasClientWeapon(client, "weapon_physcannon")) == 3)
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

/******************************
PLUGIN STOCKS
******************************/
// Does cookie have value
stock bool ClientCookieHasValue(int iClient, Handle hCookie)
{
	char sCookie[2];
	GetClientCookie(iClient, hCookie, sCookie, sizeof(sCookie));

	if (sCookie[0] == '\0')
	{
		return false;
	}

	return true;
}

// Get cookie boolean value
stock bool GetClientCookieBool(Handle hCookie, int iClient, bool bUnset = true)
{
	if (!IsClientConnected(iClient) || !IsClientInGame(iClient) || IsFakeClient(iClient))
	{
		return false;
	}

	if (!AreClientCookiesCached(iClient) && !bUnset)
	{
		return false;
	}

	return (GetClientCookieInt(iClient, hCookie) >= 1);
}

// Get cookie int value
/*stock int GetClientCookieInt(int iClient, Handle hCookie)
{
	char sCookie[8];
	GetClientCookie(iClient, hCookie, sCookie, sizeof(sCookie));

	return StringToInt(sCookie);
}*/

// Set cookie int value
stock void SetClientCookieInt(int iClient, Handle hCookie, int iValue)
{
	char sValue[8];
	IntToString(iValue, sValue, sizeof(sValue));

	SetClientCookie(iClient, hCookie, sValue);
}

stock int GetEffectState(int Ent) { return GetEntProp(Ent, Prop_Send, "m_EffectState"); }

stock bool GetEntityOpen(int Ent) { return GetEntProp(Ent, Prop_Send, "m_bOpen", 1) ? true : false; }

stock int  HasClientWeapon(int Client, const char[] WeaponName)
{
	// Initialize:
	int Offset	= FindSendPropInfo("CHL2MP_Player", "m_hMyWeapons");

	int MaxGuns = 256;

	// Loop:
	for (int X = 0; X < MaxGuns; X = (X + 4))
	{
		// Initialize:
		int WeaponId = GetEntDataEnt2(Client, Offset + X);

		// Valid:
		if (WeaponId > 0)
		{
			char ClassName[32];
			GetEdictClassname(WeaponId, ClassName, sizeof(ClassName));
			if (StrEqual(ClassName, WeaponName))
			{
				return WeaponId;
			}
		}
	}
	return -1;
}
