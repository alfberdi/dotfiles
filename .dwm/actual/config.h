/* See LICENSE file for copyright and license details. */
#include <X11/XF86keysym.h>
#include "mpdcontrol.c"

/* appearance */
static const char *fonts[] = {
	"monospace:size=9"
};
static const char dmenufont[]       = "monospace:size=9";
static const unsigned int borderpx  = 0;        /* border pixel of windows */
static const unsigned int gappx     = 4;
static const unsigned int snap      = 32;       /* snap pixel */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const int extrabar           = 1;        /* 0 means no extra bar */
#define NUMCOLORS         5
static const char colors[NUMCOLORS][MAXCOLORS][8] = {
  // border   foreground background
  { "#000000", "#ff8c00", "#000000" },  // normal
  { "#000000", "#000000", "#ff8f00" },  // selected
  { "#000000", "#0066ff", "#ff0000" },  // urgent/warning  (black on yellow)
  { "#ff0000", "#ffffff", "#ff0000" },  // error (white on red)
  { "#00ff00", "#000000", "#00ff00" },  // black on green
  // add more here
};


/* tagging */
static const char *tags[] = { "MAIN", "WEB", "COM", "GAME", "TERM", "DEV", "HACK" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      		instance	    title       	tags mask     isfloating   monitor */
	{ "Gimp",     		NULL,	   	    NULL,       	0,            True,        -1 },
	{ "Firefox",  		NULL,   	    NULL,       	1 << 1,       False,       -1 },
	{ "Pidgin",   		NULL,   	    NULL,       	1 << 2,       False,       -1 },
	{ "Thunderbird",   	NULL,   	    NULL,       	1 << 2,       False,       -1 },
	{ "Armitage",   	NULL,   	    NULL,       	1 << 6,       False,       -1 },
	{ NULL,   		NULL, "freshwrapper fullscreen window", 1 << 6,       False,       -1 },
	{ NULL,			NULL,     	  "wifite",       	1 << 6,       False,       -1 },
	{ NULL,			NULL,     	  "Steam",       	1 << 3,       False,       -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] 	= "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] 	= { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", colors[0][2], "-nf", colors[0][1], "-sb", colors[0][1], "-sf", colors[0][2], NULL };
static const char *tider[]	= { "tider", "call", "target", NULL };
static const char *termcmd[]  	= { "xterm", NULL };
static const char *todo[] 	= { "/home/adrian/.scripts/todo", NULL };
static const char *chooser[] 	= { "/home/adrian/.scripts/chooser", NULL };
static const char *volup[]   	= { "amixer", "-q", "sset", "Master", "5%+", "unmute", NULL };
static const char *voldown[] 	= { "amixer", "-q", "sset", "Master", "5%-", "unmute", NULL };
static const char *volmute[] 	= { "amixer", "-q", "sset", "Master", "toggle", NULL };
static const char *brightup[] 	= { "xbacklight", "-inc", "5", NULL };
static const char *brightdown[] = { "xbacklight", "-dec", "5", NULL };
static const char *lock[] 	= { "xscreensaver-command", "-lock", NULL };
static const char *shutdown[] 	= { "systemctl", "poweroff", NULL };
static const char *reboot[] 	= { "systemctl", "reboot", NULL };


static Key keys[] = {
	/* modifier                     key        function        argument */
	{ MODKEY,                       XK_d,      spawn,          {.v = dmenucmd } },
	{ MODKEY	,             XK_Return, spawn,            {.v = termcmd } },
	{ 0,             XF86XK_AudioRaiseVolume,  spawn,          {.v = volup } },
	{ 0,             XF86XK_AudioLowerVolume,  spawn,          {.v = voldown } },
	{ 0,             XF86XK_AudioMute,         spawn,          {.v = volmute } },
	{ 0,             XF86XK_MonBrightnessUp,   spawn,          {.v = brightup } },
	{ 0,             XF86XK_MonBrightnessDown, spawn,          {.v = brightdown } },
	{ MODKEY,        XF86XK_AudioLowerVolume,  mpdchange,      {.i = -1} },
        { MODKEY,        XF86XK_AudioRaiseVolume,  mpdchange,      {.i = +1} },
        { MODKEY,        XF86XK_AudioMute, 	   mpdcontrol,     {0} },
	{ MODKEY|ShiftMask,		XK_l,	   spawn,	   {.v = lock } },
	{ MODKEY|ShiftMask|ControlMask, XK_q, 	   spawn,          {.v = shutdown } },
	{ MODKEY|ShiftMask|ControlMask, XK_r, 	   spawn,          {.v = reboot } },
	{ MODKEY|ShiftMask,		XK_t,	   spawn,	   {.v = todo } },
	{ MODKEY|ShiftMask,		XK_s,	   spawn,	   {.v = chooser } },
	{ MODKEY,			XK_w,	   spawn,	   {.v = tider } },
	{ MODKEY,                       XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_b,      toggleextrabar, {0} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_o,      incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY|ShiftMask,             XK_c,      killclient,     {0} },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_f,      setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_space,  setlayout,      {0} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period, focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },
	{ MODKEY,                       XK_F1,     mpdchange,      {.i = -1} },
	{ MODKEY,                       XK_F2,     mpdchange,      {.i = +1} },
	{ MODKEY,                       XK_Escape, mpdcontrol,     {0} },
};

/* button definitions */
/* click can be ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};

