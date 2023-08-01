import os
import re

# The place to store your command history between sessions
histfile=os.environ["HOME"] + "/.python-history"

try:
    # Try to set up command history completion/saving/reloading
    import atexit
    import readline
    import rlcompleter

    isEditline = False
    try:
        if re.search(r"^/System/Library", readline.__file__): # editline; the BSD rewrite of readline
            isEditline = True
    except AttributeError:
        pass

    if isEditline:
        readline.parse_and_bind("bind ^I rl_complete")
        readline.parse_and_bind("bind ^R em-inc-search-prev")
        readline.parse_and_bind("bind ^U ed-move-to-beg em-next-word")
    else:                               # readline
        readline.parse_and_bind('tab: complete')

    readline.set_history_length(-1)     # don't truncate history list

    try:
        readline.read_history_file(histfile)
    except IOError:
        pass  # It doesn't exist yet.

    def savehist(nsave=1000):
        try:
            readline.set_history_length(nsave)
            readline.write_history_file(histfile)
        except Exception as msg:
            print('Unable to save Python command history:', msg)

    atexit.register(savehist)
    del atexit
except ImportError:
    pass
