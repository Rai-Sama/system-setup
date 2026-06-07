mkprj() {
    if [ -z "$1" ]; then
        echo "Usage: mkprj <project-name>"
        return 1
    fi

    local project_dir=~/everything/projects/$1

    if [ -d "$project_dir" ]; then
        echo "Error: Project '$1' already exists."
        return 1
    fi

    mkdir -p "$project_dir"/{src,notebooks,data,tests,docs}

    touch "$project_dir"/README.md
    touch "$project_dir"/pyproject.toml
    touch "$project_dir"/requirements.txt
    touch "$project_dir"/.gitignore

    cat > "$project_dir"/.gitignore << EOF
__pycache__/
*.pyc
.ipynb_checkpoints/
.venv/
.env
data/
datasets/
outputs/
EOF

    echo "# $1" > "$project_dir"/README.md

    cd "$project_dir" || return

    git init

    echo "Project created at $project_dir"
}

mknext() {
    if [ -z "$1" ]; then
        echo "Usage: mknext <project-name>"
        return 1
    fi

    local project_dir=~/everything/projects/$1

    if [ -d "$project_dir" ]; then
        echo "Error: Project '$1' already exists."
        return 1
    fi

    cd ~/everything/projects || return

    npx create-next-app@latest "$1"

    cd "$project_dir" || return

    echo "Next.js project created at $project_dir"
}

ranger() {
    local temp_file="$(mktemp -t "ranger_cd.XXXXXXXXXX")"

    /usr/bin/ranger --choosedir="$temp_file" "$@"

    if [ -f "$temp_file" ]; then
        local next_dir="$(cat "$temp_file")"

        rm -f "$temp_file"

        if [ -d "$next_dir" ] && [ "$next_dir" != "$PWD" ]; then
            cd "$next_dir"
        fi
    fi
}

mkignore() {
    cp ~/everything/system/templates/gitignore_template .gitignore
}
