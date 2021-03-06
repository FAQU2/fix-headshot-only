#include <sourcemod>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

bool b_HSO;

public Plugin myinfo = 
{
	name = "HS-Only damage fix",
	author = "FAQU",
	description = "Disables knife damage when headshot-only mode is enabled",
	version = "1.0"
}

public void OnPluginStart()
{
	ConVar HSO = FindConVar("mp_damage_headshot_only");
	if (!HSO)
	{
		SetFailState("Could not find required cvar 'mp_damage_headshot_only'");
	}
	
	HSO.AddChangeHook(Hook_HSO);
	b_HSO = HSO.BoolValue;
	
	for (int i = 1; i <= MaxClients; i++) // useful if plugin gets reloaded
	{
		if (IsClientInGame(i))
		{
			SDKHook(i, SDKHook_OnTakeDamage, Hook_TakeDamage);
		}
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, Hook_TakeDamage);
}

public void Hook_HSO(ConVar convar, const char[] oldValue, const char[] newValue)
{
	int newvalue = StringToInt(newValue);
	b_HSO = newvalue > 0;
}

public Action Hook_TakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3])
{
	if (b_HSO)
	{
		if (IsWeaponKnife(weapon))
		{
			damage = 0.0;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

bool IsWeaponKnife(int weapon)
{
	char netclass[256];
	GetEntityNetClass(weapon, netclass, sizeof(netclass));
	return strncmp(netclass, "CKnife", 6, true) == 0;
}
