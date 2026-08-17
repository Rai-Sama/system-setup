#!/bin/bash

# Define the absolute path to your icons directory
ICONS="$HOME/everything/files/assets/icons"

MENU_OPTIONS="󰣇 All Applications\n📂 Everything (Files)\n🤖 AI Assistants\n📊 Microsoft Office\n🚀 Projects\n🛠️ Tools\n🎬 Media Archiver\n💻 LeetCode Workflow\n⚙️ System Tools"

while true; do
    # 1. Show the main Rofi menu
    SELECTION=$(echo -e "$MENU_OPTIONS" | rofi -dmenu -i -p "Launcher" -theme-str 'listview {lines: 9;} window {width: 30%;}')

    if [ -z "$SELECTION" ]; then
        break
    fi

    # 3. Handle the selection
    case "$SELECTION" in
        "󰣇 All Applications")
            rofi -show drun
            break
            ;;
            
        "📂 Everything (Files)")
            CURRENT_DIR="$HOME/everything"
            
            while true; do
                DIR_LIST=$(find "$CURRENT_DIR" -mindepth 1 -maxdepth 1 -type d \( -name ".*" -o -name "node_modules" -o -name "__pycache__" \) -prune -o -type d -printf "%f\n" | sort)
                
                if [ "$CURRENT_DIR" = "$HOME/everything" ]; then
                    BACK_OPT="⬅️ Back to Main Menu"
                else
                    BACK_OPT="⬅️ Go Up One Level"
                fi
                
                OPEN_NEMO_OPT="✅ Open $(basename "$CURRENT_DIR") in Nemo"
                OPEN_TERM_OPT="💻 Open $(basename "$CURRENT_DIR") in Kitty"
                
                DIR_SEL=$(echo -e "$BACK_OPT\n$OPEN_NEMO_OPT\n$OPEN_TERM_OPT\n$DIR_LIST" | rofi -dmenu -i -p "Explore: $(basename "$CURRENT_DIR")")
                
                if [ -z "$DIR_SEL" ] || [ "$DIR_SEL" = "⬅️ Back to Main Menu" ]; then
                    break
                elif [ "$DIR_SEL" = "⬅️ Go Up One Level" ]; then
                    CURRENT_DIR=$(dirname "$CURRENT_DIR")
                elif [ "$DIR_SEL" = "$OPEN_NEMO_OPT" ]; then
                    nemo "$CURRENT_DIR" &
                    exit 0 
                elif [ "$DIR_SEL" = "$OPEN_TERM_OPT" ]; then
                    kitty --directory "$CURRENT_DIR" &
                    exit 0
                else
                    CURRENT_DIR="$CURRENT_DIR/$DIR_SEL"
                fi
            done
            ;;

        "🤖 AI Assistants")
            # Using custom icons! \0icon\x1f followed by the absolute path to the SVG
            AI_OPTS="⬅️ Back\nChatGPT\0icon\x1f$ICONS/ChatGPT-Icon.svg\nGemini\0icon\x1f$ICONS/Google_Gemini_icon_2025.svg\nClaude\0icon\x1f$ICONS/Claude_AI_symbol.svg"
            
            # Notice the added -show-icons flag here
            AI_SEL=$(echo -e "$AI_OPTS" | rofi -dmenu -i -p "AI" -show-icons)
            
            if [ "$AI_SEL" = "⬅️ Back" ]; then
                continue 
            elif [ -n "$AI_SEL" ]; then
                case "$AI_SEL" in
                    "ChatGPT") brave-browser --app="https://chatgpt.com" & ;;
                    "Gemini") brave-browser --app="https://gemini.google.com" & ;;
                    "Claude") brave-browser --app="https://claude.ai" & ;;
                esac
                break
            fi
            ;;

        "📊 Microsoft Office")
            # Using custom icons for the Office apps
            OFFICE_OPTS="⬅️ Back\nWord\0icon\x1f$ICONS/microsoft-word-icon.svg\nExcel\0icon\x1f$ICONS/Microsoft_Office_Excel_(2019–2025).svg\nPowerPoint\0icon\x1f$ICONS/microsoft-powerpoint-icon.svg\nM365 Copilot\0icon\x1f$ICONS/microsoft-copilot.svg\nOneDrive\0icon\x1f$ICONS/Microsoft_OneDrive_Icon_(2025_-_present).svg"
            
            OFFICE_SEL=$(echo -e "$OFFICE_OPTS" | rofi -dmenu -i -p "Office" -show-icons)
            
            if [ "$OFFICE_SEL" = "⬅️ Back" ]; then
                continue
            elif [ -n "$OFFICE_SEL" ]; then
                case "$OFFICE_SEL" in
                    "Word") brave-browser --app="https://word.cloud.microsoft" & ;;
                    "Excel") brave-browser --app="https://excel.cloud.microsoft" & ;;
                    "PowerPoint") brave-browser --app="https://powerpoint.cloud.microsoft" & ;;
                    "M365 Copilot") brave-browser --app="https://m365.cloud.microsoft" & ;;
                    "OneDrive") brave-browser --app="https://onedrive.live.com" & ;;
                esac
                break
            fi
            ;;

        "🚀 Projects")
            PROJ_OPTS="⬅️ Back\n📝 Agentic Notes (Neovim)\n📝 Agentic Notes (Run UI)\n🧠 Agentic Summarizer (Neovim)\n🧠 Agentic Summarizer (Run UI)\n📁 Browse All Projects..."
            PROJ_SEL=$(echo -e "$PROJ_OPTS" | rofi -dmenu -i -p "Projects")
            
            if [ "$PROJ_SEL" = "⬅️ Back" ]; then
                continue
            elif [ -n "$PROJ_SEL" ]; then
                case "$PROJ_SEL" in
                    "📝 Agentic Notes (Neovim)") kitty --directory ~/everything/projects/agentic_notes -e nvim . & ;;
                    "📝 Agentic Notes (Run UI)") kitty --hold --directory ~/everything/projects/agentic_notes -e zsh -i -c "chainlit run app.py -w" & ;;
                    "🧠 Agentic Summarizer (Neovim)") kitty --directory ~/everything/projects/agentic_summarizer -e nvim . & ;;
                    "🧠 Agentic Summarizer (Run UI)") kitty --hold --directory ~/everything/projects/agentic_summarizer -e zsh -i -c "chainlit run app.py -w" & ;;
                    "📁 Browse All Projects...") nemo ~/everything/projects & ;;
                esac
                break
            fi
            ;;

        "🛠️ Tools")
            TOOL_OPTS="⬅️ Back\nObsidian\nNeovim (Scratchpad)\nJupyter Lab\nMarimo"
            TOOL_SEL=$(echo -e "$TOOL_OPTS" | rofi -dmenu -i -p "Tools")
            
            if [ "$TOOL_SEL" = "⬅️ Back" ]; then
                continue
            elif [ -n "$TOOL_SEL" ]; then
                case "$TOOL_SEL" in
                    "Obsidian") obsidian & ;;
                    "Neovim (Scratchpad)") kitty --directory ~/everything/learning/notebooks/scratchpad -e nvim & ;;
                    "Jupyter Lab") kitty --hold -e zsh -i -c "jl" & ;;
                    "Marimo") kitty --hold -e zsh -i -c "mm" & ;;
                esac
                break
            fi
            ;;

        "🎬 Media Archiver")
            MEDIA_OPTS="⬅️ Back\n🔄 Sync\n🔍 Find\n👁️ View"
            MEDIA_SEL=$(echo -e "$MEDIA_OPTS" | rofi -dmenu -i -p "Media")
            
            if [ "$MEDIA_SEL" = "⬅️ Back" ]; then
                continue
            elif [ -n "$MEDIA_SEL" ]; then
                case "$MEDIA_SEL" in
                    "🔄 Sync") kitty -e zsh -i -c "media-sync" ;;
                    "🔍 Find") kitty -e zsh -i -c "media-find" ;;
                    "👁️ View") kitty -e zsh -i -c "media-view" ;;
                esac
                break
            fi
            ;;
            
        "💻 LeetCode Workflow")
            kitty --hold -e zsh -i -c "lc"
            break
            ;;
            
        "⚙️ System Tools")
            SYS_OPTS="⬅️ Back\n📦 Update System (apt)\n📝 Edit Aliases\n🔄 Refresh Zsh"
            SYS_SEL=$(echo -e "$SYS_OPTS" | rofi -dmenu -i -p "System")
            
            if [ "$SYS_SEL" = "⬅️ Back" ]; then
                continue
            elif [ -n "$SYS_SEL" ]; then
                case "$SYS_SEL" in
                    "📦 Update System (apt)") kitty --hold -e zsh -i -c "sup" ;;
                    "📝 Edit Aliases") kitty -e nvim ~/everything/system/custom_scripts/zsh/aliases.zsh ;;
                    "🔄 Refresh Zsh") kitty --hold -e zsh -i -c "refresh && echo 'Zsh Refreshed!'" ;;
                esac
                break
            fi
            ;;
    esac
done
