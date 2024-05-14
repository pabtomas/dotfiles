main ()
{
  set -eu

  # color line-number           1          $GRAY_900
  # color file                  69        $GRAY_900
  # color grep.file             69        $GRAY_900
  # color diff-add-highlight    42           ${GRAY_900}
  # color diff-del-highlight    203          ${GRAY_900}
  cat << TEMPLATING >> /root/.tigrc
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
TEMPLATING
}

main
