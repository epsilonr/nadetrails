#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>

#pragma semicolon 1

public Plugin myinfo =
{
	name = "NadeTrails Color Menu for VIPs",
	author = "Nokta",
	description = "",
	version = "1.0",
	url = "https://github.com/epsilonr"
};

Handle g_hClientCookie = INVALID_HANDLE;

int g_Renk[MAXPLAYERS + 1] = 1;

int g_iBeamSprite;

ConVar g_TailTime, g_TailFadeTime, g_TailWidth, g_DefaultAlpha;

public void OnPluginStart()
{
	g_hClientCookie = RegClientCookie("Nadetrails", "Nadetrails", CookieAccess_Private);
	
	g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	
	RegConsoleCmd("sm_nade", Command_Menu);
	RegConsoleCmd("sm_nademenu", Command_Menu);
	RegConsoleCmd("sm_nadetails", Command_Menu);
	RegConsoleCmd("sm_nadetrails", Command_Menu);
	
	g_TailTime 		= CreateConVar("sm_tails_tailtime", "5.0", "Time the tail stays visible.", _, true, 0.0, true, 25.0);
	g_TailFadeTime 	= CreateConVar("sm_tails_tailfadetime", "1", "Time for tail to fade over.");
	g_TailWidth 	= CreateConVar("sm_tails_tailwidth", "1.0", "Width of the tail.");
	g_DefaultAlpha	= CreateConVar("sm_tails_defaultalpha", "255", "Default alpha for trails (0 is invisible, 255 is solid).", _, true, 0.0, true, 255.0);
}

public void OnClientCookiesCached(int client)
{
	char sValue[8];
	GetClientCookie(client, g_hClientCookie, sValue, sizeof(sValue));
	
	g_Renk[client] = StringToInt(sValue);
}

public void OnMapStart()
{
	g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
}

public Action Command_Menu(int client, int args)
{
	if(!IsValidPlayer(client))
		return Plugin_Handled;
		
	if(!IsPlayeraaaaVIP(client))
	{
		PrintToChat(client, " \x04[Tracers]\x01 You must be \x07VIP\x01 to use this command.");
		return Plugin_Handled;
	}
		
	AnaMenu(client);
	return Plugin_Handled;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrEqual(classname, "hegrenade_projectile")) SDKHook(entity, SDKHook_SpawnPost, SpawnPost);
}

public void SpawnPost(int weapon)
{
	if(!IsValidEdict(weapon))
		return;
	
	int client = GetEntPropEnt(weapon, Prop_Data, "m_hOwnerEntity");
	
	if(IsValidPlayer(client) && IsPlayeraaaaVIP(client) && g_Renk[client] != -1)
	{
		int g_FRenk[4];
		g_FRenk[3] = g_DefaultAlpha.IntValue;
		
		if(g_Renk[client] == 1)
		{
			g_FRenk[0] = 255;
			g_FRenk[1] = 0;
			g_FRenk[2] = 0;
		}
		
		if(g_Renk[client] == 2)
		{
			g_FRenk[0] = 255;
			g_FRenk[1] = 20;
			g_FRenk[2] = 147;
		}
		
		if(g_Renk[client] == 3)
		{
			g_FRenk[0] = 128;
			g_FRenk[1] = 0;
			g_FRenk[2] = 128;
		}
		
		if(g_Renk[client] == 4)
		{
			g_FRenk[0] = 255;
			g_FRenk[1] = 255;
			g_FRenk[2] = 255;
		}
		
		if(g_Renk[client] == 5)
		{
			g_FRenk[0] = 105;
			g_FRenk[1] = 105;
			g_FRenk[2] = 105;
		}
		
		if(g_Renk[client] == 6)
		{
			g_FRenk[0] = 255;
			g_FRenk[1] = 165;
			g_FRenk[2] = 0;
		}
		
		if(g_Renk[client] == 7)
		{
			g_FRenk[0] = 0;
			g_FRenk[1] = 0;
			g_FRenk[2] = 255;
		}

		if(g_Renk[client] == 8)
		{
			g_FRenk[0] = 0;
			g_FRenk[1] = 255;
			g_FRenk[2] = 0;
		}
		
		if(g_Renk[client] == 9)
		{
			float i = GetGameTime();
			float Frequency = 2.5;
			g_FRenk[0] = RoundFloat(Sine(Frequency * i + 0.0) * 127.0 + 128.0);
			g_FRenk[1] = RoundFloat(Sine(Frequency * i + 2.0943951) * 127.0 + 128.0);
			g_FRenk[2] = RoundFloat(Sine(Frequency * i + 4.1887902) * 127.0 + 128.0);
		}
		
		TE_SetupBeamFollow(weapon, g_iBeamSprite, 0, g_TailTime.FloatValue, g_TailWidth.FloatValue, g_TailWidth.FloatValue, g_TailFadeTime.IntValue, g_FRenk);
		TE_SendToAll();
	}
		
	
}

void AnaMenu(int client)
{
	Menu menu = new Menu(Handler_Main);
	menu.SetTitle("[Nade Trails]\n ");
	menu.AddItem("kapat", "Reset Settings\n ");
	menu.AddItem("kir", "Red");
	menu.AddItem("yes", "Green");
	menu.AddItem("pem", "Pink");
	menu.AddItem("mor", "Purple");
	menu.AddItem("tur", "Orange");
	menu.AddItem("mav", "Blue");
	menu.AddItem("bey", "White");
	menu.AddItem("gri", "Grey");
	menu.AddItem("gok", "Rainbow\n ");
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_Main(Menu menu, MenuAction action, int client, int itemNum)
{
	switch (action)
	{	

		case MenuAction_Display:
		{
			char buffer[255];
			Format(buffer, sizeof(buffer), "[Nade Trails]\n ", client);
			
			Panel panel = view_as<Panel>(itemNum);
			panel.SetTitle(buffer);
		}

		case MenuAction_Select:
		{
			char sCookieValue[8];
			char item[32];
			menu.GetItem(itemNum, item, sizeof(item));
			
			if (StrEqual(item, "kir"))
			{
				g_Renk[client] = 1;
				IntToString(g_Renk[client], sCookieValue, sizeof(sCookieValue));
				SetClientCookie(client, g_hClientCookie, sCookieValue);
			}
			if (StrEqual(item, "pem"))
			{
				g_Renk[client] = 2;
				IntToString(g_Renk[client], sCookieValue, sizeof(sCookieValue));
				SetClientCookie(client, g_hClientCookie, sCookieValue);
			}
			if (StrEqual(item, "mor"))
			{
				g_Renk[client] = 3;
				IntToString(g_Renk[client], sCookieValue, sizeof(sCookieValue));
				SetClientCookie(client, g_hClientCookie, sCookieValue);
			}
			if (StrEqual(item, "bey"))
			{
				g_Renk[client] = 4;
				IntToString(g_Renk[client], sCookieValue, sizeof(sCookieValue));
				SetClientCookie(client, g_hClientCookie, sCookieValue);
			}
			if (StrEqual(item, "gri"))
			{
				g_Renk[client] = 5;
				IntToString(g_Renk[client], sCookieValue, sizeof(sCookieValue));
				SetClientCookie(client, g_hClientCookie, sCookieValue);
			}
			if (StrEqual(item, "tur"))
			{
				g_Renk[client] = 6;
				IntToString(g_Renk[client], sCookieValue, sizeof(sCookieValue));
				SetClientCookie(client, g_hClientCookie, sCookieValue);
			}
			if (StrEqual(item, "mav"))
			{
				g_Renk[client] = 7;
				IntToString(g_Renk[client], sCookieValue, sizeof(sCookieValue));
				SetClientCookie(client, g_hClientCookie, sCookieValue);
			}
			if (StrEqual(item, "yes"))
			{
				g_Renk[client] = 8;
				IntToString(g_Renk[client], sCookieValue, sizeof(sCookieValue));
				SetClientCookie(client, g_hClientCookie, sCookieValue);
			}
			if (StrEqual(item, "gok"))
			{
				g_Renk[client] = 9;
				IntToString(g_Renk[client], sCookieValue, sizeof(sCookieValue));
				SetClientCookie(client, g_hClientCookie, sCookieValue);
			}
			
			if (StrEqual(item, "kapat"))
			{
				g_Renk[client] = -1;
				IntToString(g_Renk[client], sCookieValue, sizeof(sCookieValue));
				SetClientCookie(client, g_hClientCookie, sCookieValue);
			}
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

stock bool IsPlayeraaaaVIP(int client)
{
	if(GetUserFlagBits(client) & ADMFLAG_RESERVATION) return true;
	if(CheckCommandAccess(client, "sm_slay", true)) return true;
	return false;
}
