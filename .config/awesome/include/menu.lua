-- {{{ Menu
-- Create a laucher widget and a main menu
--{ "",	""},
cmenu = {}

cmenu.awesome = {
	{ "Manpage", 				terminal .. " -x man awesome" 				},
	{ "Edit config",			terminal .. " -x vim " .. awesome.conffile 		},
	{ "Restart", 				awesome.restart 					},
	{ "Quit", 				awesome.quit 						}
}
cmenu.std = {
	{ "FireFox", 				"firefox"						},
	{ "ThunderBird",			"thunderbird"						},
	{ "Transmission",			"transmission-gtk"					},
	{ "Skype", 				"skype"							}
}
cmenu.tools = {
	{ "VirtualBox",				"virtualbox"						},
	{ "WireShark", 				"wireshark"						},
	{ "Wammu",				"wammu"							},
	{ "Screen keyboard",			"onboard"						},
 	{ "Terminal", 				terminal 						}
}
cmenu.media = {
	{ "Ncmpcpp", 				terminal .. " -x ncmpcpp"				},
}
cmenu.office = {
	{ "LibreOffice",			"libreoffice" 						},
	{ "Dia",				"dia"							},
	{ "MatLab", 				"matlab"						},
	{ "Gummi",				"gummi"							},
	{ "KiCAD",				"kicad"							},
}

cmenu.system = {
	{ "AlsaMixer",				terminal .. " -x alsamixer" 				},
}

local retMenu = {
 		{ "Web", 			cmenu.std						},
 		{ "Office", 			cmenu.office 						},
 		{ "Media", 			cmenu.media 						},
 		{ "Toolbox", 			cmenu.tools	 					},
 		{ "Game", 			cmenu.game	 					},
		{ "System",			cmenu.system						},
		{ "Up Awesome",			awesome.restart 					}
}
return retMenu
