#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#undef REQUIRE_PLUGIN
#include <myjailbreak>
#define REQUIRE_PLUGIN

#include <multicolors>
#include <cstrike>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Anti - AFK",
	author = "good_live",
	description = "Moves all player to spectator that are afk for more than one minute.",
	version = "1.0",
	url = "painlessgaming.eu"
};

ConVar g_cTimeCheck;
float g_fPlayerSpawnPositon[MAXPLAYERS + 1][3];
bool g_bMyJB = false;

public void OnPluginStart()
{
	g_bMyJB = LibraryExists("myjailbreak");
	g_cTimeCheck = CreateConVar("anti_afk_time", "60", "The time in secounds after that all afk players get moved to spec");
	
	HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("player_spawn", OnPlayerSpawn);
}

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast) 
{ 
	CreateTimer(g_cTimeCheck.FloatValue, Timer_CheckAfk);
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid", -1));
	
	//Save player position
	GetClientAbsOrigin(client, g_fPlayerSpawnPositon[client]);
}

public Action Timer_CheckAfk(Handle timer)
{
	if(g_bMyJB && MyJailbreak_IsEventDayRunning())
		return Plugin_Continue;
	float clientPosition[3];
	for (int i = 1; i <= MaxClients; i++)
	{
		if(!IsPlayerAlive(i))
			continue;
		
		GetClientAbsOrigin(i, clientPosition);
		
		if(clientPosition[0] == g_fPlayerSpawnPositon[i][0] && clientPosition[1] == g_fPlayerSpawnPositon[i][1] && clientPosition[2] == g_fPlayerSpawnPositon[i][2])
		{
			CPrintToChatAll("[{green}PLG-JAIL{default}]{purple}%N{default} wurde zu den Zuschauer gemoved, weil er AFK war", i);
			ChangeClientTeam(i, CS_TEAM_SPECTATOR);
		}
	}
	return Plugin_Continue;
}
 
public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "myjailbreak"))
	{
		g_bMyJB = false;
	}
}
 
public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "myjailbreak"))
	{
		g_bMyJB = true;
	}
}
