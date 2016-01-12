update_period = 10000  # in microseconds
offline_timeout = 300  # in seconds
min_duration = 60  # in seconds
break_symbol = '*'
break_period = 600  # in seconds
work_period = 3000  # in seconds
overwork_period = 300  # in seconds
hide_tray = True
hide_win = False
sqlite_manager = 'sqlite3'


# Update window after creation
def win_hook(win):
    win.move(0, 750)


# Update window text
def text_hook(ctx):
    target = ctx.target if ctx.active else 'OFF'
    label = '{0.duration.h}:{0.duration.m:02d} {1}'.format(ctx, target)

    text = '[{} {}]'.format('☭' if ctx.active else '☯', label)
    color = '#007700' if ctx.active else '#777777'
    markup = '<span color="{}" font="11">{}</span>'.format(color, text)
    return markup

