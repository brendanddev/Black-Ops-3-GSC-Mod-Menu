#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\hud_message_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_util;
#using scripts\zm\gametypes\_globallogic_audio;

#namespace hud_message;

/*
	Name: init
	Namespace: hud_message
	Checksum: 0x597C422B
	Offset: 0x428
	Size: 0x1A1
	Parameters: 0
	Flags: None
*/
function init()
{
	game["strings"]["draw"] = &"MP_DRAW_CAPS";
	game["strings"]["round_draw"] = &"MP_ROUND_DRAW_CAPS";
	game["strings"]["round_win"] = &"MP_ROUND_WIN_CAPS";
	game["strings"]["round_loss"] = &"MP_ROUND_LOSS_CAPS";
	game["strings"]["victory"] = &"MP_VICTORY_CAPS";
	game["strings"]["defeat"] = &"MP_DEFEAT_CAPS";
	game["strings"]["game_over"] = &"MP_GAME_OVER_CAPS";
	game["strings"]["halftime"] = &"MP_HALFTIME_CAPS";
	game["strings"]["overtime"] = &"MP_OVERTIME_CAPS";
	game["strings"]["roundend"] = &"MP_ROUNDEND_CAPS";
	game["strings"]["intermission"] = &"MP_INTERMISSION_CAPS";
	game["strings"]["side_switch"] = &"MP_SWITCHING_SIDES_CAPS";
	game["strings"]["match_bonus"] = &"MP_MATCH_BONUS_IS";
}

/*
	Name: teamOutcomeNotify
	Namespace: hud_message
	Checksum: 0x802C7D5B
	Offset: 0x5D8
	Size: 0xE73
	Parameters: 3
	Flags: None
*/
function teamOutcomeNotify(winner, isRound, endReasonText)
{
	self endon("disconnect");
	self notify("reset_outcome");
	team = self.pers["team"];
	if(isdefined(team) && team == "spectator")
	{
		for(i = 0; i < level.players.size; i++)
		{
			if(self.currentspectatingclient == level.players[i].clientid)
			{
				team = level.players[i].pers["team"];
				break;
			}
		}
	}
	else if(!isdefined(team) || !isdefined(level.teams[team]))
	{
		team = "allies";
	}
	while(self.doingNotify)
	{
		wait(0.05);
	}
	self endon("reset_outcome");
	headerFont = "extrabig";
	font = "default";
	if(self IsSplitscreen())
	{
		titleSize = 2;
		textSize = 1.5;
		iconSize = 30;
		spacing = 10;
	}
	else
	{
		titleSize = 3;
		textSize = 2;
		iconSize = 70;
		spacing = 25;
	}
	duration = 60000;
	outcomeTitle = hud::createFontString(headerFont, titleSize);
	outcomeTitle hud::setPoint("TOP", undefined, 0, 30);
	outcomeTitle.glowAlpha = 1;
	outcomeTitle.hidewheninmenu = 0;
	outcomeTitle.archived = 0;
	outcomeText = hud::createFontString(font, 2);
	outcomeText hud::setParent(outcomeTitle);
	outcomeText hud::setPoint("TOP", "BOTTOM", 0, 0);
	outcomeText.glowAlpha = 1;
	outcomeText.hidewheninmenu = 0;
	outcomeText.archived = 0;
	if(winner == "halftime")
	{
		outcomeTitle setText(game["strings"]["halftime"]);
		outcomeTitle.color = (1, 1, 1);
		winner = "allies";
	}
	else if(winner == "intermission")
	{
		outcomeTitle setText(game["strings"]["intermission"]);
		outcomeTitle.color = (1, 1, 1);
		winner = "allies";
	}
	else if(winner == "roundend")
	{
		outcomeTitle setText(game["strings"]["roundend"]);
		outcomeTitle.color = (1, 1, 1);
		winner = "allies";
	}
	else if(winner == "overtime")
	{
		outcomeTitle setText(game["strings"]["overtime"]);
		outcomeTitle.color = (1, 1, 1);
		winner = "allies";
	}
	else if(winner == "tie")
	{
		if(isRound)
		{
			outcomeTitle setText(game["strings"]["round_draw"]);
		}
		else
		{
			outcomeTitle setText(game["strings"]["draw"]);
		}
		outcomeTitle.color = (0.29, 0.61, 0.7);
		winner = "allies";
	}
	else if(isdefined(self.pers["team"]) && winner == team)
	{
		if(isRound)
		{
			outcomeTitle setText(game["strings"]["round_win"]);
		}
		else
		{
			outcomeTitle setText(game["strings"]["victory"]);
		}
		outcomeTitle.color = (0.42, 0.68, 0.46);
	}
	else if(isRound)
	{
		outcomeTitle setText(game["strings"]["round_loss"]);
	}
	else
	{
		outcomeTitle setText(game["strings"]["defeat"]);
	}
	outcomeTitle.color = (0.73, 0.29, 0.19);
	outcomeText setText(endReasonText);
	outcomeTitle setCOD7DecodeFX(200, duration, 600);
	outcomeText setPulseFX(100, duration, 1000);
	iconSpacing = 100;
	currentX = level.teamCount - 1 * -1 * iconSpacing / 2;
	teamIcons = [];
	teamIcons[team] = hud::createIcon(game["icons"][team], iconSize, iconSize);
	teamIcons[team] hud::setParent(outcomeText);
	teamIcons[team] hud::setPoint("TOP", "BOTTOM", currentX, spacing);
	teamIcons[team].hidewheninmenu = 0;
	teamIcons[team].archived = 0;
	teamIcons[team].alpha = 0;
	teamIcons[team] fadeOverTime(0.5);
	teamIcons[team].alpha = 1;
	currentX = currentX + iconSpacing;
	foreach(enemyteam in level.teams)
	{
		if(team == enemyteam)
		{
			continue;
		}
		teamIcons[enemyteam] = hud::createIcon(game["icons"][enemyteam], iconSize, iconSize);
		teamIcons[enemyteam] hud::setParent(outcomeText);
		teamIcons[enemyteam] hud::setPoint("TOP", "BOTTOM", currentX, spacing);
		teamIcons[enemyteam].hidewheninmenu = 0;
		teamIcons[enemyteam].archived = 0;
		teamIcons[enemyteam].alpha = 0;
		teamIcons[enemyteam] fadeOverTime(0.5);
		teamIcons[enemyteam].alpha = 1;
		currentX = currentX + iconSpacing;
	}
	teamScores = [];
	teamScores[team] = hud::createFontString(font, titleSize);
	teamScores[team] hud::setParent(teamIcons[team]);
	teamScores[team] hud::setPoint("TOP", "BOTTOM", 0, spacing);
	teamScores[team].glowAlpha = 1;
	if(isRound)
	{
		teamScores[team] setValue(getTeamScore(team));
	}
	else
	{
		teamScores[team] [[level.setMatchScoreHUDElemForTeam]](team);
	}
	teamScores[team].hidewheninmenu = 0;
	teamScores[team].archived = 0;
	teamScores[team] setPulseFX(100, duration, 1000);
	foreach(enemyteam in level.teams)
	{
		if(team == enemyteam)
		{
			continue;
		}
		teamScores[enemyteam] = hud::createFontString(headerFont, titleSize);
		teamScores[enemyteam] hud::setParent(teamIcons[enemyteam]);
		teamScores[enemyteam] hud::setPoint("TOP", "BOTTOM", 0, spacing);
		teamScores[enemyteam].glowAlpha = 1;
		if(isRound)
		{
			teamScores[enemyteam] setValue(getTeamScore(enemyteam));
		}
		else
		{
			teamScores[enemyteam] [[level.setMatchScoreHUDElemForTeam]](enemyteam);
		}
		teamScores[enemyteam].hidewheninmenu = 0;
		teamScores[enemyteam].archived = 0;
		teamScores[enemyteam] setPulseFX(100, duration, 1000);
	}
	font = "objective";
	matchBonus = undefined;
	if(isdefined(self.matchBonus))
	{
		matchBonus = hud::createFontString(font, 2);
		matchBonus hud::setParent(outcomeText);
		matchBonus hud::setPoint("TOP", "BOTTOM", 0, iconSize + spacing * 3 + teamScores[team].height);
		matchBonus.glowAlpha = 1;
		matchBonus.hidewheninmenu = 0;
		matchBonus.archived = 0;
		matchBonus.label = game["strings"]["match_bonus"];
		matchBonus setValue(self.matchBonus);
	}
	self thread resetOutcomeNotify(teamIcons, teamScores, outcomeTitle, outcomeText);
}

/*
	Name: teamOutcomeNotifyZombie
	Namespace: hud_message
	Checksum: 0x14D3008F
	Offset: 0x1458
	Size: 0x29B
	Parameters: 3
	Flags: None
*/
function teamOutcomeNotifyZombie(winner, isRound, endReasonText)
{
	self endon("disconnect");
	self notify("reset_outcome");
	team = self.pers["team"];
	if(isdefined(team) && team == "spectator")
	{
		for(i = 0; i < level.players.size; i++)
		{
			if(self.currentspectatingclient == level.players[i].clientid)
			{
				team = level.players[i].pers["team"];
				break;
			}
		}
	}
	else if(!isdefined(team) || !isdefined(level.teams[team]))
	{
		team = "allies";
	}
	while(self.doingNotify)
	{
		wait(0.05);
	}
	self endon("reset_outcome");
	if(self IsSplitscreen())
	{
		titleSize = 2;
		spacing = 10;
		font = "default";
	}
	else
	{
		titleSize = 3;
		spacing = 50;
		font = "objective";
	}
	outcomeTitle = hud::createFontString(font, titleSize);
	outcomeTitle hud::setPoint("TOP", undefined, 0, spacing);
	outcomeTitle.glowAlpha = 1;
	outcomeTitle.hidewheninmenu = 0;
	outcomeTitle.archived = 0;
	outcomeTitle setText(endReasonText);
	outcomeTitle setPulseFX(100, 60000, 1000);
	self thread resetOutcomeNotify(undefined, undefined, outcomeTitle);
}

/*
	Name: outcomeNotify
	Namespace: hud_message
	Checksum: 0xA1D32CCE
	Offset: 0x1700
	Size: 0x99B
	Parameters: 3
	Flags: None
*/
function outcomeNotify(winner, isRoundEnd, endReasonText)
{
	self endon("disconnect");
	self notify("reset_outcome");
	while(self.doingNotify)
	{
		wait(0.05);
	}
	self endon("reset_outcome");
	headerFont = "extrabig";
	font = "default";
	if(self IsSplitscreen())
	{
		titleSize = 2;
		winnerSize = 1.5;
		otherSize = 1.5;
		iconSize = 30;
		spacing = 10;
	}
	else
	{
		titleSize = 3;
		winnerSize = 2;
		otherSize = 1.5;
		iconSize = 30;
		spacing = 20;
	}
	duration = 60000;
	players = level.placement["all"];
	outcomeTitle = hud::createFontString(headerFont, titleSize);
	outcomeTitle hud::setPoint("TOP", undefined, 0, spacing);
	if(!util::isOneRound() && !isRoundEnd)
	{
		outcomeTitle setText(game["strings"]["game_over"]);
	}
	else if(isdefined(players[1]) && players[0].score == players[1].score && players[0].deaths == players[1].deaths && (self == players[0] || self == players[1]))
	{
		outcomeTitle setText(game["strings"]["tie"]);
	}
	else if(isdefined(players[2]) && players[0].score == players[2].score && players[0].deaths == players[2].deaths && self == players[2])
	{
		outcomeTitle setText(game["strings"]["tie"]);
	}
	else if(isdefined(players[0]) && self == players[0])
	{
		outcomeTitle setText(game["strings"]["victory"]);
		outcomeTitle.color = (0.42, 0.68, 0.46);
	}
	else
	{
		outcomeTitle setText(game["strings"]["defeat"]);
		outcomeTitle.color = (0.73, 0.29, 0.19);
	}
	outcomeTitle.glowAlpha = 1;
	outcomeTitle.hidewheninmenu = 0;
	outcomeTitle.archived = 0;
	outcomeTitle setCOD7DecodeFX(200, duration, 600);
	outcomeText = hud::createFontString(font, 2);
	outcomeText hud::setParent(outcomeTitle);
	outcomeText hud::setPoint("TOP", "BOTTOM", 0, 0);
	outcomeText.glowAlpha = 1;
	outcomeText.hidewheninmenu = 0;
	outcomeText.archived = 0;
	outcomeText setText(endReasonText);
	firstTitle = hud::createFontString(font, winnerSize);
	firstTitle hud::setParent(outcomeText);
	firstTitle hud::setPoint("TOP", "BOTTOM", 0, spacing);
	firstTitle.glowAlpha = 1;
	firstTitle.hidewheninmenu = 0;
	firstTitle.archived = 0;
	if(isdefined(players[0]))
	{
		firstTitle.label = &"MP_FIRSTPLACE_NAME";
		firstTitle setPlayerNameString(players[0]);
		firstTitle setCOD7DecodeFX(175, duration, 600);
	}
	secondTitle = hud::createFontString(font, otherSize);
	secondTitle hud::setParent(firstTitle);
	secondTitle hud::setPoint("TOP", "BOTTOM", 0, spacing);
	secondTitle.glowAlpha = 1;
	secondTitle.hidewheninmenu = 0;
	secondTitle.archived = 0;
	if(isdefined(players[1]))
	{
		secondTitle.label = &"MP_SECONDPLACE_NAME";
		secondTitle setPlayerNameString(players[1]);
		secondTitle setCOD7DecodeFX(175, duration, 600);
	}
	thirdTitle = hud::createFontString(font, otherSize);
	thirdTitle hud::setParent(secondTitle);
	thirdTitle hud::setPoint("TOP", "BOTTOM", 0, spacing);
	thirdTitle hud::setParent(secondTitle);
	thirdTitle.glowAlpha = 1;
	thirdTitle.hidewheninmenu = 0;
	thirdTitle.archived = 0;
	if(isdefined(players[2]))
	{
		thirdTitle.label = &"MP_THIRDPLACE_NAME";
		thirdTitle setPlayerNameString(players[2]);
		thirdTitle setCOD7DecodeFX(175, duration, 600);
	}
	matchBonus = hud::createFontString(font, 2);
	matchBonus hud::setParent(thirdTitle);
	matchBonus hud::setPoint("TOP", "BOTTOM", 0, spacing);
	matchBonus.glowAlpha = 1;
	matchBonus.hidewheninmenu = 0;
	matchBonus.archived = 0;
	if(isdefined(self.matchBonus))
	{
		matchBonus.label = game["strings"]["match_bonus"];
		matchBonus setValue(self.matchBonus);
	}
	self thread updateOutcome(firstTitle, secondTitle, thirdTitle);
	self thread resetOutcomeNotify(undefined, undefined, outcomeTitle, outcomeText, firstTitle, secondTitle, thirdTitle, matchBonus);
}

/*
	Name: wagerOutcomeNotify
	Namespace: hud_message
	Checksum: 0xF9458B9F
	Offset: 0x20A8
	Size: 0xA0B
	Parameters: 2
	Flags: None
*/
function wagerOutcomeNotify(winner, endReasonText)
{
	self endon("disconnect");
	self notify("reset_outcome");
	while(self.doingNotify)
	{
		wait(0.05);
	}
	self endon("reset_outcome");
	headerFont = "extrabig";
	font = "objective";
	if(self IsSplitscreen())
	{
		titleSize = 2;
		winnerSize = 1.5;
		otherSize = 1.5;
		iconSize = 30;
		spacing = 2;
	}
	else
	{
		titleSize = 3;
		winnerSize = 2;
		otherSize = 1.5;
		iconSize = 30;
		spacing = 20;
	}
	halftime = 0;
	if(isdefined(level.sidebet) && level.sidebet)
	{
		halftime = 1;
	}
	duration = 60000;
	players = level.placement["all"];
	outcomeTitle = hud::createFontString(headerFont, titleSize);
	outcomeTitle hud::setPoint("TOP", undefined, 0, spacing);
	if(halftime)
	{
		outcomeTitle setText(game["strings"]["intermission"]);
		outcomeTitle.color = (1, 1, 0);
		outcomeTitle.glowColor = (1, 0, 0);
	}
	else if(isdefined(level.dontCalcWagerWinnings) && level.dontCalcWagerWinnings == 1)
	{
		outcomeTitle setText(game["strings"]["wager_topwinners"]);
		outcomeTitle.color = (0.42, 0.68, 0.46);
	}
	else if(isdefined(self.wagerWinnings) && self.wagerWinnings > 0)
	{
		outcomeTitle setText(game["strings"]["wager_inthemoney"]);
		outcomeTitle.color = (0.42, 0.68, 0.46);
	}
	else
	{
		outcomeTitle setText(game["strings"]["wager_loss"]);
		outcomeTitle.color = (0.73, 0.29, 0.19);
	}
	outcomeTitle.glowAlpha = 1;
	outcomeTitle.hidewheninmenu = 0;
	outcomeTitle.archived = 0;
	outcomeTitle setCOD7DecodeFX(200, duration, 600);
	outcomeText = hud::createFontString(font, 2);
	outcomeText hud::setParent(outcomeTitle);
	outcomeText hud::setPoint("TOP", "BOTTOM", 0, 0);
	outcomeText.glowAlpha = 1;
	outcomeText.hidewheninmenu = 0;
	outcomeText.archived = 0;
	outcomeText setText(endReasonText);
	playerNameHudElems = [];
	playerCPHudElems = [];
	numPlayers = players.size;
	for(i = 0; i < numPlayers; i++)
	{
		if(!halftime && isdefined(players[i]))
		{
			secondTitle = hud::createFontString(font, otherSize);
			if(playerNameHudElems.size == 0)
			{
				secondTitle hud::setParent(outcomeText);
				secondTitle hud::setPoint("TOP_LEFT", "BOTTOM", -175, spacing * 3);
			}
			else
			{
				secondTitle hud::setParent(playerNameHudElems[playerNameHudElems.size - 1]);
				secondTitle hud::setPoint("TOP_LEFT", "BOTTOM_LEFT", 0, spacing);
			}
			secondTitle.glowAlpha = 1;
			secondTitle.hidewheninmenu = 0;
			secondTitle.archived = 0;
			secondTitle.label = &"MP_WAGER_PLACE_NAME";
			secondTitle.playerNum = i;
			secondTitle setPlayerNameString(players[i]);
			playerNameHudElems[playerNameHudElems.size] = secondTitle;
			secondCP = hud::createFontString(font, otherSize);
			secondCP hud::setParent(secondTitle);
			secondCP hud::setPoint("TOP_RIGHT", "TOP_LEFT", 350, 0);
			secondCP.glowAlpha = 1;
			secondCP.hidewheninmenu = 0;
			secondCP.archived = 0;
			secondCP.label = &"MENU_POINTS";
			secondCP.currentValue = 0;
			if(isdefined(players[i].wagerWinnings))
			{
				secondCP.targetValue = players[i].wagerWinnings;
			}
			else
			{
				secondCP.targetValue = 0;
			}
			if(secondCP.targetValue > 0)
			{
				secondCP.color = (0.42, 0.68, 0.46);
			}
			secondCP setValue(0);
			playerCPHudElems[playerCPHudElems.size] = secondCP;
		}
	}
	self thread updateWagerOutcome(playerNameHudElems, playerCPHudElems);
	self thread resetWagerOutcomeNotify(playerNameHudElems, playerCPHudElems, outcomeTitle, outcomeText);
	if(halftime)
	{
		return;
	}
	stillUpdating = 1;
	countUpDuration = 2;
	CPIncrement = 9999;
	if(isdefined(playerCPHudElems[0]))
	{
		CPIncrement = Int(playerCPHudElems[0].targetValue / countUpDuration / 0.05);
		if(CPIncrement < 1)
		{
			CPIncrement = 1;
		}
	}
	while(stillUpdating)
	{
		stillUpdating = 0;
		for(i = 0; i < playerCPHudElems.size; i++)
		{
			if(isdefined(playerCPHudElems[i]) && playerCPHudElems[i].currentValue < playerCPHudElems[i].targetValue)
			{
				playerCPHudElems[i].currentValue = playerCPHudElems[i].currentValue + CPIncrement;
				if(playerCPHudElems[i].currentValue > playerCPHudElems[i].targetValue)
				{
					playerCPHudElems[i].currentValue = playerCPHudElems[i].targetValue;
				}
				playerCPHudElems[i] setValue(playerCPHudElems[i].currentValue);
				stillUpdating = 1;
			}
		}
		wait(0.05);
	}
}

/*
	Name: teamWagerOutcomeNotify
	Namespace: hud_message
	Checksum: 0x48C57BC3
	Offset: 0x2AC0
	Size: 0xD6B
	Parameters: 3
	Flags: None
*/
function teamWagerOutcomeNotify(winner, isRoundEnd, endReasonText)
{
	self endon("disconnect");
	self notify("reset_outcome");
	team = self.pers["team"];
	if(!isdefined(team) || !isdefined(level.teams[team]))
	{
		team = "allies";
	}
	wait(0.05);
	while(self.doingNotify)
	{
		wait(0.05);
	}
	self endon("reset_outcome");
	headerFont = "extrabig";
	font = "objective";
	if(self IsSplitscreen())
	{
		titleSize = 2;
		textSize = 1.5;
		iconSize = 30;
		spacing = 10;
	}
	else
	{
		titleSize = 3;
		textSize = 2;
		iconSize = 70;
		spacing = 15;
	}
	halftime = 0;
	if(isdefined(level.sidebet) && level.sidebet)
	{
		halftime = 1;
	}
	duration = 60000;
	outcomeTitle = hud::createFontString(headerFont, titleSize);
	outcomeTitle hud::setPoint("TOP", undefined, 0, spacing);
	outcomeTitle.glowAlpha = 1;
	outcomeTitle.hidewheninmenu = 0;
	outcomeTitle.archived = 0;
	outcomeText = hud::createFontString(font, 2);
	outcomeText hud::setParent(outcomeTitle);
	outcomeText hud::setPoint("TOP", "BOTTOM", 0, 0);
	outcomeText.glowAlpha = 1;
	outcomeText.hidewheninmenu = 0;
	outcomeText.archived = 0;
	if(winner == "tie")
	{
		if(isRoundEnd)
		{
			outcomeTitle setText(game["strings"]["round_draw"]);
		}
		else
		{
			outcomeTitle setText(game["strings"]["draw"]);
		}
		outcomeTitle.color = (1, 1, 1);
		winner = "allies";
	}
	else if(winner == "overtime")
	{
		outcomeTitle setText(game["strings"]["overtime"]);
		outcomeTitle.color = (1, 1, 1);
	}
	else if(isdefined(self.pers["team"]) && winner == team)
	{
		if(isRoundEnd)
		{
			outcomeTitle setText(game["strings"]["round_win"]);
		}
		else
		{
			outcomeTitle setText(game["strings"]["victory"]);
		}
		outcomeTitle.color = (0.42, 0.68, 0.46);
	}
	else if(isRoundEnd)
	{
		outcomeTitle setText(game["strings"]["round_loss"]);
	}
	else
	{
		outcomeTitle setText(game["strings"]["defeat"]);
	}
	outcomeTitle.color = (0.73, 0.29, 0.19);
	if(!isdefined(level.dontShowEndReason) || !level.dontShowEndReason)
	{
		outcomeText setText(endReasonText);
	}
	outcomeTitle setPulseFX(100, duration, 1000);
	outcomeText setPulseFX(100, duration, 1000);
	teamIcons = [];
	teamIcons[team] = hud::createIcon(game["icons"][team], iconSize, iconSize);
	teamIcons[team] hud::setParent(outcomeText);
	teamIcons[team] hud::setPoint("TOP", "BOTTOM", -60, spacing);
	teamIcons[team].hidewheninmenu = 0;
	teamIcons[team].archived = 0;
	teamIcons[team].alpha = 0;
	teamIcons[team] fadeOverTime(0.5);
	teamIcons[team].alpha = 1;
	foreach(enemyteam in level.teams)
	{
		if(team == enemyteam)
		{
			continue;
		}
		teamIcons[enemyteam] = hud::createIcon(game["icons"][enemyteam], iconSize, iconSize);
		teamIcons[enemyteam] hud::setParent(outcomeText);
		teamIcons[enemyteam] hud::setPoint("TOP", "BOTTOM", 60, spacing);
		teamIcons[enemyteam].hidewheninmenu = 0;
		teamIcons[enemyteam].archived = 0;
		teamIcons[enemyteam].alpha = 0;
		teamIcons[enemyteam] fadeOverTime(0.5);
		teamIcons[enemyteam].alpha = 1;
	}
	teamScores = [];
	teamScores[team] = hud::createFontString(font, titleSize);
	teamScores[team] hud::setParent(teamIcons[team]);
	teamScores[team] hud::setPoint("TOP", "BOTTOM", 0, spacing);
	teamScores[team].glowAlpha = 1;
	teamScores[team] setValue(getTeamScore(team));
	teamScores[team].hidewheninmenu = 0;
	teamScores[team].archived = 0;
	teamScores[team] setPulseFX(100, duration, 1000);
	foreach(enemyteam in level.teams)
	{
		if(team == enemyteam)
		{
			continue;
		}
		teamScores[enemyteam] = hud::createFontString(font, titleSize);
		teamScores[enemyteam] hud::setParent(teamIcons[enemyteam]);
		teamScores[enemyteam] hud::setPoint("TOP", "BOTTOM", 0, spacing);
		teamScores[enemyteam].glowAlpha = 1;
		teamScores[enemyteam] setValue(getTeamScore(enemyteam));
		teamScores[enemyteam].hidewheninmenu = 0;
		teamScores[enemyteam].archived = 0;
		teamScores[enemyteam] setPulseFX(100, duration, 1000);
	}
	matchBonus = undefined;
	sidebetWinnings = undefined;
	if(!isRoundEnd && !halftime && isdefined(self.wagerWinnings))
	{
		matchBonus = hud::createFontString(font, 2);
		matchBonus hud::setParent(outcomeText);
		matchBonus hud::setPoint("TOP", "BOTTOM", 0, iconSize + spacing * 3 + teamScores[team].height);
		matchBonus.glowAlpha = 1;
		matchBonus.hidewheninmenu = 0;
		matchBonus.archived = 0;
		matchBonus.label = game["strings"]["wager_winnings"];
		matchBonus setValue(self.wagerWinnings);
		if(isdefined(game["side_bets"]) && game["side_bets"])
		{
			sidebetWinnings = hud::createFontString(font, 2);
			sidebetWinnings hud::setParent(matchBonus);
			sidebetWinnings hud::setPoint("TOP", "BOTTOM", 0, spacing);
			sidebetWinnings.glowAlpha = 1;
			sidebetWinnings.hidewheninmenu = 0;
			sidebetWinnings.archived = 0;
			sidebetWinnings.label = game["strings"]["wager_sidebet_winnings"];
			sidebetWinnings setValue(self.pers["wager_sideBetWinnings"]);
		}
	}
	self thread resetOutcomeNotify(teamIcons, teamScores, outcomeTitle, outcomeText, matchBonus, sidebetWinnings);
}

/*
	Name: resetOutcomeNotify
	Namespace: hud_message
	Checksum: 0x6304B2C9
	Offset: 0x3838
	Size: 0x241
	Parameters: 10
	Flags: None
*/
function resetOutcomeNotify(hudElemList1, hudElemList2, hudElem3, hudElem4, hudElem5, hudElem6, hudElem7, hudElem8, hudElem9, hudElem10)
{
	self endon("disconnect");
	self waittill("reset_outcome");
	destroyHudElem(hudElem3);
	destroyHudElem(hudElem4);
	destroyHudElem(hudElem5);
	destroyHudElem(hudElem6);
	destroyHudElem(hudElem7);
	destroyHudElem(hudElem8);
	destroyHudElem(hudElem9);
	destroyHudElem(hudElem10);
	if(isdefined(hudElemList1))
	{
		foreach(elem in hudElemList1)
		{
			destroyHudElem(elem);
		}
	}
	else if(isdefined(hudElemList2))
	{
		foreach(elem in hudElemList2)
		{
			destroyHudElem(elem);
		}
	}
}

/*
	Name: resetWagerOutcomeNotify
	Namespace: hud_message
	Checksum: 0xB7D5C738
	Offset: 0x3A88
	Size: 0x12B
	Parameters: 4
	Flags: None
*/
function resetWagerOutcomeNotify(playerNameHudElems, playerCPHudElems, outcomeTitle, outcomeText)
{
	self endon("disconnect");
	self waittill("reset_outcome");
	for(i = playerNameHudElems.size - 1; i >= 0; i--)
	{
		if(isdefined(playerNameHudElems[i]))
		{
			playerNameHudElems[i] destroy();
		}
	}
	for(i = playerCPHudElems.size - 1; i >= 0; i--)
	{
		if(isdefined(playerCPHudElems[i]))
		{
			playerCPHudElems[i] destroy();
		}
	}
	if(isdefined(outcomeText))
	{
		outcomeText destroy();
	}
	if(isdefined(outcomeTitle))
	{
		outcomeTitle destroy();
	}
}

/*
	Name: updateOutcome
	Namespace: hud_message
	Checksum: 0xFCA790C3
	Offset: 0x3BC0
	Size: 0x16F
	Parameters: 3
	Flags: None
*/
function updateOutcome(firstTitle, secondTitle, thirdTitle)
{
	self endon("disconnect");
	self endon("reset_outcome");
	while(1)
	{
		self waittill("update_outcome");
		players = level.placement["all"];
		if(isdefined(firstTitle) && isdefined(players[0]))
		{
			firstTitle setPlayerNameString(players[0]);
		}
		else if(isdefined(firstTitle))
		{
			firstTitle.alpha = 0;
		}
		if(isdefined(secondTitle) && isdefined(players[1]))
		{
			secondTitle setPlayerNameString(players[1]);
		}
		else if(isdefined(secondTitle))
		{
			secondTitle.alpha = 0;
		}
		if(isdefined(thirdTitle) && isdefined(players[2]))
		{
			thirdTitle setPlayerNameString(players[2]);
		}
		else if(isdefined(thirdTitle))
		{
			thirdTitle.alpha = 0;
		}
	}
}

/*
	Name: updateWagerOutcome
	Namespace: hud_message
	Checksum: 0xE596F585
	Offset: 0x3D38
	Size: 0x145
	Parameters: 2
	Flags: None
*/
function updateWagerOutcome(playerNameHudElems, playerCPHudElems)
{
	self endon("disconnect");
	self endon("reset_outcome");
	while(1)
	{
		self waittill("update_outcome");
		players = level.placement["all"];
		for(i = 0; i < playerNameHudElems.size; i++)
		{
			if(isdefined(playerNameHudElems[i]) && isdefined(players[playerNameHudElems[i].playerNum]))
			{
				playerNameHudElems[i] setPlayerNameString(players[playerNameHudElems[i].playerNum]);
				continue;
			}
			if(isdefined(playerNameHudElems[i]))
			{
				playerNameHudElems[i].alpha = 0;
			}
			if(isdefined(playerCPHudElems[i]))
			{
				playerCPHudElems[i].alpha = 0;
			}
		}
	}
}

