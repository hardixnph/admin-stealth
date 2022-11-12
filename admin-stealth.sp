#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <autoexecconfig>
#include <stealth>

public Plugin myinfo =
{
	name        = "[Basic] Admin Stealth",
	author      = "Hardix",
	description = "Admins are vanished when in spectators team.",
	version     = "1.0"
};

ConVar gH_Cvar_Stealth,
	gH_Cvar_Stealth_Flag;

bool gShadow_Admin_HideMe[MAXPLAYERS + 1],
	gShadow_ChangedTeam[MAXPLAYERS + 1];

int g_iDroppedEntity[MAXPLAYERS + 1][12];
int g_iPlayerManager,
	g_iConnectedOffset,
	g_iAliveOffset,
	g_iTeamOffset,
	g_iPingOffset,
	g_iScoreOffset,
	g_iDeathsOffset,
	g_iHealthOffset;

public void OnPluginStart()
{
	LoadTranslations("admin-stealth.phrases");
	ExtraCMD_OnPluginStart();
}

public void ExtraCMD_OnPluginStart()
{
	AutoExecConfig_SetFile("Admin-Stealth");
	AutoExecConfig_SetCreateFile(true);

	gH_Cvar_Stealth      = AutoExecConfig_CreateConVar("admin_stealth", "1", "Enable/Disable Admin Stealth function", 0, true, 0.0, true, 1.0);
	gH_Cvar_Stealth_Flag = AutoExecConfig_CreateConVar("admin_stealth_flag", "b", "Flag to use sm_stealth", 0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	char stealth_flag[8];

	gH_Cvar_Stealth_Flag.GetString(stealth_flag, sizeof(stealth_flag));
	int st_flag = Flag_StringToInt(stealth_flag);

	RegAdminCmd("sm_stealth", CommandStealthMode, st_flag, "Spec stealth");

	g_iConnectedOffset = FindSendPropInfo("CCSPlayerResource", "m_bConnected");
	g_iAliveOffset		 = FindSendPropInfo("CCSPlayerResource", "m_bAlive");
	g_iTeamOffset		 = FindSendPropInfo("CCSPlayerResource", "m_iTeam");
	g_iPingOffset		 = FindSendPropInfo("CCSPlayerResource", "m_iPing");
	g_iScoreOffset		 = FindSendPropInfo("CCSPlayerResource", "m_iScore");
	g_iDeathsOffset	 = FindSendPropInfo("CCSPlayerResource", "m_iDeaths");
	g_iHealthOffset	 = FindSendPropInfo("CCSPlayerResource", "m_iHealth");
}

public void OnMapStart()
{
	ExtraCMD_OnMapStart();
}

public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	ExtraCMD_Event_RoundStart(event, name, dontBroadcast);
}

public void OnClientDisconnect(int client)
{
	gShadow_Admin_HideMe[client] = false;

	for (int idx = 0; idx < 10; idx++)
	{
		if ((idx > 10) || !IsValidClient(idx)) break;

		if (g_iDroppedEntity[client][idx] != 0)
			g_iDroppedEntity[client][idx] = 0;
	}
}

public Action CommandStealthMode(int client, int args)
{
	if (gH_Cvar_Stealth.BoolValue)
	{
		if (IsValidClient(client))
		{
			if (!gShadow_Admin_HideMe[client])
			{
				for (int idx = 1; idx <= MaxClients; idx++)
				{
					if (IsValidClient(idx))
					{
						PrintToChat(idx, "%t", "Stealth Disconnect", client);
					}
				}

				gShadow_Admin_HideMe[client] = true;
				gShadow_ChangedTeam[client]  = true;

				if (GetClientTeam(client) != CS_TEAM_SPECTATOR)
					ChangeClientTeam(client, CS_TEAM_SPECTATOR);
			}
			else
			{
				for (int idx = 1; idx <= MaxClients; idx++)
				{
					if (IsValidClient(idx))
					{
						PrintToChat(idx, "%t", "Stealth Connect", client);
					}
				}

				gShadow_Admin_HideMe[client] = false;
			}
		}
	}
	return Plugin_Continue;
}

public void ExtraCMD_Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (IsValidClient(client) && gH_Cvar_Stealth.BoolValue)
	{
		for (int idx = 0; idx < 10; idx++)
		{
			if ((idx > 10) || !IsValidClient(client)) break;

			if (g_iDroppedEntity[client][idx] != 0)
				g_iDroppedEntity[client][idx] = 0;
		}
	}
}

public void ExtraCMD_OnMapStart()
{
	g_iPlayerManager = FindEntityByClassname(-1, "cs_player_manager");
	if (g_iPlayerManager != -1)
		SDKHook(g_iPlayerManager, SDKHook_ThinkPost, Hook_PMThink);

	for (int client = 1; client <= MaxClients; client++)
	{
		for (int idx = 0; idx < 10; idx++)
		{
			if ((idx > 10) || !IsValidClient(idx)) break;

			if (g_iDroppedEntity[client][idx] == 0)
				g_iDroppedEntity[client][idx] = 0;
		}
	}
}

public void Hook_PMThink(int entity)
{
	if (gH_Cvar_Stealth.BoolValue)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && gShadow_Admin_HideMe[i])
			{
				SetEntData(g_iPlayerManager, g_iAliveOffset + (i * 4), false, 4, true);
				SetEntData(g_iPlayerManager, g_iConnectedOffset + (i * 4), false, 4, true);
				SetEntData(g_iPlayerManager, g_iTeamOffset + (i * 4), 0, 4, true);
				SetEntData(g_iPlayerManager, g_iPingOffset + (i * 4), 0, 4, true);
				SetEntData(g_iPlayerManager, g_iScoreOffset + (i * 4), 0, 4, true);
				SetEntData(g_iPlayerManager, g_iDeathsOffset + (i * 4), 0, 4, true);
				SetEntData(g_iPlayerManager, g_iHealthOffset + (i * 4), 0, 4, true);
			}
		}
	}
}

public void OnGameFrame()
{
	if (gH_Cvar_Stealth.BoolValue)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && gShadow_Admin_HideMe[i])
			{
				SetEntData(g_iPlayerManager, g_iAliveOffset + (i * 4), false, 4, true);
				SetEntData(g_iPlayerManager, g_iConnectedOffset + (i * 4), false, 4, true);
				SetEntData(g_iPlayerManager, g_iTeamOffset + (i * 4), 0, 4, true);
				SetEntData(g_iPlayerManager, g_iPingOffset + (i * 4), 0, 4, true);
				SetEntData(g_iPlayerManager, g_iScoreOffset + (i * 4), 0, 4, true);
				SetEntData(g_iPlayerManager, g_iDeathsOffset + (i * 4), 0, 4, true);
				SetEntData(g_iPlayerManager, g_iHealthOffset + (i * 4), 0, 4, true);
			}
		}
	}
}
