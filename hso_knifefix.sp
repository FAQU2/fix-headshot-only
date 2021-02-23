#include <sourcemod>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

bool b_HSO;

public Plugin myinfo = 
{
	name = "Headshot only knife fix",
	author = "FAQU",
	description = "Disables knife damage when headshot only mode enabled"
}

public void OnPluginStart()
{
	ConVar HSO = FindConVar("mp_damage_headshot_only");
	if (HSO)
	{
		HSO.AddChangeHook(Hook_HSO);
		if (HSO.BoolValue)
		{
			b_HSO = true;
		}
	}
}

public void Hook_HSO(ConVar convar, const char[] oldValue, const char[] newValue)
{
	int newvalue = StringToInt(newValue);
	if (newvalue > 0)
	{
		b_HSO = true;
	}
	else 
	{
		b_HSO = false;
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, Hook_TakeDamage);
}

public Action Hook_TakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype)
{
	if (b_HSO)
	{
		if (attacker < 1 || attacker > MaxClients)
		{
			return Plugin_Continue;
		}
	
		char weapon[32];
		GetClientWeapon(attacker, weapon, sizeof(weapon));
	
		if (StrContains(weapon, "knife", false) != -1)
		{
			damage = 0.0;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}