#if defined _stealth_included
 #endinput
#endif
#define _stealth_included

/**
* Checks if the specified client index is valid or not.
*
* @param client				An entity index
* @param bAllowBots			Set Bots to be accepted or not. Default: False
* @param bAllowDead			Set Dead Players to be accepted or not. Default: True
* @param Team				Set the team the player must be in
* @return					Returns true if the specified entity index is a player connected, false otherwise.
*/
stock bool IsValidClient(int client, bool bAllowBots = false, bool bAllowDead = true, int team = -1)
{
    if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || (!bAllowBots && IsFakeClient(client)) || IsClientSourceTV(client) || IsClientReplay(client) || (!bAllowDead && !IsPlayerAlive(client)) || (team != -1 && GetClientTeam(client) != team))
    {
        return false;
    }
    return true;
}

/**
* Convert flag from char to int
*
* @param buffer				Buffer to read the flag letter from
* @return					Returns the int value of the flag given as a letter. (-1 if the flag is incorrect)
*/
stock int Flag_StringToInt(char[] buffer)
{
	int length = strlen(buffer);
	if ((StrContains("abcdefghijklmnopqrstz", buffer) != -1) && (length == 1))
	{
		FlagStringToInt_Change(buffer, "a", ADMFLAG_RESERVATION);
		FlagStringToInt_Change(buffer, "b", ADMFLAG_GENERIC);
		FlagStringToInt_Change(buffer, "c", ADMFLAG_KICK);
		FlagStringToInt_Change(buffer, "d", ADMFLAG_BAN);
		FlagStringToInt_Change(buffer, "e", ADMFLAG_UNBAN);
		FlagStringToInt_Change(buffer, "f", ADMFLAG_SLAY);
		FlagStringToInt_Change(buffer, "g", ADMFLAG_CHANGEMAP);
		FlagStringToInt_Change(buffer, "h", ADMFLAG_CONVARS);
		FlagStringToInt_Change(buffer, "i", ADMFLAG_CONFIG);
		FlagStringToInt_Change(buffer, "j", ADMFLAG_CHAT);
		FlagStringToInt_Change(buffer, "k", ADMFLAG_VOTE);
		FlagStringToInt_Change(buffer, "l", ADMFLAG_PASSWORD);
		FlagStringToInt_Change(buffer, "m", ADMFLAG_RCON);
		FlagStringToInt_Change(buffer, "n", ADMFLAG_CHEATS);
		FlagStringToInt_Change(buffer, "z", ADMFLAG_ROOT);
		FlagStringToInt_Change(buffer, "o", ADMFLAG_CUSTOM1);
		FlagStringToInt_Change(buffer, "p", ADMFLAG_CUSTOM2);
		FlagStringToInt_Change(buffer, "q", ADMFLAG_CUSTOM3);
		FlagStringToInt_Change(buffer, "r", ADMFLAG_CUSTOM4);
		FlagStringToInt_Change(buffer, "s", ADMFLAG_CUSTOM5);
		FlagStringToInt_Change(buffer, "t", ADMFLAG_CUSTOM6);
		
		return StringToInt(buffer);
	}
	else
		return -1;
}

stock void FlagStringToInt_Change(char[] StrToReplace, char[] flag, int ReplaceWith)
{
	char NewFlagValue[10];
	IntToString(ReplaceWith, NewFlagValue, sizeof(NewFlagValue));
	ReplaceString(StrToReplace, 10, flag, NewFlagValue, false);
}