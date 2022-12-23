git config --global core.editor vim 2> /dev/null
git config merge.tool vimdiff 2> /dev/null
git config merge.conflictstyle diff3 2> /dev/null
git config mergetool.prompt false 2> /dev/null

if [[ -z "${TMUX+x}" ]]
then
  GREEN='42'
  GRAY_900='233'
  GRAY_800='239'
  GRAY_700='243'
  GRAY_600='246'
  GRAY_500='249'
  GRAY_400='252'
  ZINC='59'
  WHITE='231'
  THEMES=(20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 55 56 57 61 62 63 64 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 101 104 105 107 108 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230)
  THEME="${THEMES["$(( ${RANDOM} % 196 ))"]}"
  export GREEN GRAY_900 GRAY_800 GRAY_700 GRAY_600 GRAY_500 GRAY_400 ZINC \
    WHITE THEME

  set -- '/tmp/tig'
  mkdir -p "${1}" > /dev/null
  set -- "$(mktemp "${1}/.tigrc.tmp.XXXXXXXXXXXXXXX")"

  # color line-number           1          $GRAY_900
  # color file                  69        $GRAY_900
  # color grep.file             69        $GRAY_900
  # color diff-add-highlight    42           ${GRAY_900}
  # color diff-del-highlight    203          ${GRAY_900}
  while read -r REPLY
  do
    printf '%s\n' "${REPLY}" >> "${1}"
  done <<EOF
color default        ${WHITE}     ${GRAY_900}
color date           ${WHITE}     ${GRAY_900}  bold
color graph-commit   ${THEME}     ${GRAY_900}
color id             ${THEME}     ${GRAY_900}
color "author "      ${GRAY_500}  ${GRAY_900}
color cursor         ${GRAY_900}  ${GRAY_500}  bold
color title-focus    ${GRAY_900}  ${ZINC}      bold
color title-blur     ${GRAY_900}  ${GRAY_500}  bold
color status         ${GRAY_500}  ${GRAY_900}
color main-tracked   ${ZINC}      ${GRAY_900}  bold
color main-head      ${GRAY_600}  ${GRAY_900}  bold
color main-remote    ${THEME}     ${GRAY_900}  bold
color search-result  ${GRAY_900}  ${THEME}     bold

color "commit "             ${GRAY_500}  ${GRAY_900}  bold
color "Refs: "              ${WHITE}     ${GRAY_900}  bold
color "Merge: "             ${WHITE}     ${GRAY_900}  bold
color "Author: "            ${THEME}     ${GRAY_900}  bold
color "AuthorDate: "        ${THEME}     ${GRAY_900}  bold
color "Commit: "            ${THEME}     ${GRAY_900}  bold
color "CommitDate: "        ${THEME}     ${GRAY_900}  bold
color "---"                 ${GRAY_700}  ${GRAY_900}  bold
color "+++ "                ${THEME}     ${GRAY_900}  bold
color "--- "                ${GRAY_500}  ${GRAY_900}  bold
color "old file mode "      ${GRAY_900}  ${GRAY_700}  bold
color "new file mode "      ${GRAY_900}  ${GRAY_700}  bold
color "deleted file mode "  ${GRAY_900}  ${GRAY_700}  bold
color "copy from "          ${GRAY_900}  ${GRAY_700}  bold
color "copy to "            ${GRAY_900}  ${GRAY_700}  bold
color "rename from "        ${GRAY_900}  ${GRAY_700}  bold
color "rename to "          ${GRAY_900}  ${GRAY_700}  bold
color "similarity "         ${GRAY_900}  ${GRAY_700}  bold
color diff-index            ${GRAY_900}  ${GRAY_700}  bold
color diff-add              ${THEME}     ${GRAY_900}
color diff-del              ${GRAY_700}  ${GRAY_900}
color diff-stat             ${WHITE}     ${GRAY_900}
color diff-header           ${GRAY_900}  ${GRAY_700}  bold
color diff-chunk            ${ZINC}      ${GRAY_900}

color status.header         ${THEME}     ${GRAY_900}  bold
color status.section        ${GRAY_500}  ${GRAY_900}
color status.file           ${WHITE}     ${GRAY_900}
color stat-staged           ${ZINC}      ${GRAY_900}  bold
color stat-unstaged         ${THEME}     ${GRAY_900}  bold
color stat-untracked        ${THEME}     ${GRAY_900}  bold
color stat-none             ${WHITE}     ${GRAY_900}

color palette-0             ${ZINC}      ${GRAY_900}  bold
color palette-1             ${GRAY_500}  ${GRAY_900}  bold
color palette-2             ${GRAY_800}  ${GRAY_900}  bold
color palette-3             ${GRAY_400}  ${GRAY_900}  bold
color palette-4             ${GRAY_700}  ${GRAY_900}  bold
color palette-5             ${WHITE}     ${GRAY_900}  bold
color palette-6             ${THEME}     ${GRAY_900}  bold
color palette-7             ${ZINC}      ${GRAY_900}  bold
color palette-8             ${GRAY_500}  ${GRAY_900}  bold
color palette-9             ${GRAY_800}  ${GRAY_900}  bold
color palette-10            ${GRAY_400}  ${GRAY_900}  bold
color palette-11            ${GRAY_700}  ${GRAY_900}  bold
color palette-12            ${WHITE}     ${GRAY_900}  bold
color palette-13            ${THEME}     ${GRAY_900}  bold

set mouse = true

bind generic <Down> move-down
bind generic <Up>   move-up

bind generic g  none
bind generic gg move-first-line
bind generic G  move-last-line

set main-view-date = relative-compact
set main-view-id = yes
set blame-view-date = relative-compact
EOF

  TIGRC_USER="${1}"
  export TIGRC_USER

else
  TMUX_SESSION="$(tmux display -p '#S')"
  TMUX_WIN="$(tmux display -p '#I')"
  export TMUX_SESSION TMUX_WIN
fi

eval "$(direnv hook bash)"
