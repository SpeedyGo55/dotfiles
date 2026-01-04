# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /home/speedygo55/miniconda3/bin/conda
    eval /home/speedygo55/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/home/speedygo55/miniconda3/etc/fish/conf.d/conda.fish"
        . "/home/speedygo55/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/home/speedygo55/miniconda3/bin" $PATH
    end
end
# <<< conda initialize <<<

set -g theme_nerd_fonts yes
set -g theme_color_scheme terminal
set -g theme_newline_cursor yes
set -gx PATH /usr/local/go/bin /usr/bin /bin ~/go/bin ~/bin $PATH
fastfetch
