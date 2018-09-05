Experimental tab completions for npm, offering PowerShell niceties like tooltips.

To use npm's built-in completions, something like this:

    COMP_CWORD=1 COMP_LINE=0 COMP_POINT=4 npm completion -- npm run- 1>/dev/null

The stderr output is console.dir debugging that convertfrom-json can parse.
