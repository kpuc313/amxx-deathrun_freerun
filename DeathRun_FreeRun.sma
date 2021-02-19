/*****************************************************************
*                            MADE BY
*
*   K   K   RRRRR    U     U     CCCCC    3333333      1   3333333
*   K  K    R    R   U     U    C     C         3     11         3
*   K K     R    R   U     U    C               3    1 1         3
*   KK      RRRRR    U     U    C           33333   1  1     33333
*   K K     R        U     U    C               3      1         3
*   K  K    R        U     U    C     C         3      1         3
*   K   K   R         UUUUU U    CCCCC    3333333      1   3333333
*
******************************************************************
*                       AMX MOD X Script                         *
*     You can modify the code, but DO NOT modify the author!     *
******************************************************************
*
* Description:
* ============
* This plugin is specially made for Deathrun Mod. When you are terrorist you can
* enable free mode when you say /free, so you can't enable traps and they can't
* pick guns (Only knives are allowed to be used!).
*
******************************************************************
*
* Thanks to:
* ==========
* <VeCo> and papyrus_kn - for helping me with the code.
*
*****************************************************************/

#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <fun>

new g_MsgSync
new bool:usedfree
new bool:block

public plugin_init() {
	register_plugin("DeathRun FreeRun", "1.0", "kpuc313")

	register_clcmd("say","cmdSay")
	register_clcmd("say_team","cmdSay")
	
	register_event("TextMsg","RoundRestart","a","2=#Game_will_restart_in")
	register_event("TextMsg","RoundRestart","a","2=#Game_Commencing")
	register_logevent("RoundStart",2,"1=Round_Start")
	
	register_forward(FM_PlayerPreThink, "fw_PreThink")
	RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "armoury_entity", "fw_TouchWeapon")
	
	g_MsgSync = CreateHudSyncObj()
}

public cmdSay(id) {
	new said[192]
	read_args(said,192)
	if((contain(said, "free") != -1 ) || (contain(said, "/free") != -1 ))
		cmdFree(id)
	return PLUGIN_CONTINUE
}

public block_command(id) if(is_user_connected(id)) block = true

public RoundStart() {
	for(new id=1;id<32;id++) {
		remove_task(id)
		set_task(30.0,"block_command",id)
		usedfree = false
		block = false
	}
}

public RoundRestart() {
	for(new id=1;id<32;id++) {
		remove_task(id)
		set_task(30.0,"block_command",id)
		usedfree = false
		block = false
	}
}

public fw_TouchWeapon(weapon, id) {
	if(!is_user_connected(id)) return HAM_IGNORED
	if(usedfree) {
		return HAM_SUPERCEDE
	}
	return HAM_IGNORED
}

public fw_PreThink(id) {		
	new button = pev(id, pev_button) 
	if(usedfree && get_user_team(id) == 1 && button & IN_USE) {
		client_print(id, print_center, "You can't use buttons because you enabled FreeRun Mode!")
		return HAM_SUPERCEDE
	}
	return HAM_IGNORED
}

public cmdFree(id) {
	if(block) {
		return PLUGIN_HANDLED;
	} else {
		if(is_user_alive(id) && get_user_team(id) == 1) {
			if(!usedfree) {
				new name[32], players[32], num
				get_user_name(id, name, charsmax(name))
				get_players(players,num,"h")
			
				set_hudmessage(255, 0, 0, -1.0, 0.20, 1, 6.0, 6.0, 0.1, 0.2, -1)
				ShowSyncHudMsg(0, g_MsgSync, "%s just enable FreeRun Mode. Go Go Go!!!", name)
				client_cmd(0, "spk ^"vox/run fast^"")
		
				for(new i=0;i<num;i++)
				{
					strip_user_weapons(players[i])
					give_item(players[i], "weapon_knife")
				}
				usedfree = true
			}
		}
	}
	return PLUGIN_CONTINUE
}
