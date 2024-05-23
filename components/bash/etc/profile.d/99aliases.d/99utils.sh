colors () { command wget -q -O- https://gist.githubusercontent.com/HaleTom/89ffe32783f89f403bba96bd7bcd1263/raw/ | bash; }
ls () { command ls --color "${@}"; }
grep () { command grep --color "${@}"; }
diff () { command diff -u --color "${@}"; }
tree () { command tree -C "${@}"; }
ps () { command ps -a -x "${@}"; }
rm () { command rm -i -r -v "${@}"; }
cp () { command cp -i -r -v "${@}"; }
mv () { command mv -i -n -v "${@}"; }
ln () { command ln -i -v "${@}"; }
rl () { command readlink -m "${@}"; }
mkdir () { command mkdir -p -v "${@}"; }
cal () { command ncal -w -b -M "${@}"; }
less () { command less -R "${@}"; }
exit () { command exit 0; }

for i in 1 2 3 4
do
  alias ."$(printf '.%0.s' "${@}")"='cd '"$(printf '../%0.s' "${@}")"
done
