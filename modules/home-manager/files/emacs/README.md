# Emacs config notes

This directory holds my vanilla Emacs config (`init.el`, `early-init.el`),
managed by home-manager. These notes cover how the build, the config, and the
host environment fit together — and the non-obvious gotchas that took real time
to figure out.

## How this is wired into the flake

`modules/home-manager/default.nix` symlinks **only the two static files**, not
the whole directory:

```nix
xdg.configFile."emacs/init.el".source = ./files/emacs/init.el;
xdg.configFile."emacs/early-init.el".source = ./files/emacs/early-init.el;
```

**Why file-level, not directory-level (like helix/zellij):** Emacs *writes*
into `~/.config/emacs/` constantly — `elpa/` (packages), `eln-cache/`
(native-comp output), `tree-sitter/` (grammars), `auto-save/`, `backups/`,
`custom.el`. If we symlinked the whole directory read-only from the Nix store
(the pattern used for helix/zellij), all of that would break. Linking the two
files individually keeps `~/.config/emacs/` a real, writable directory.

### Editing workflow

`init.el` / `early-init.el` in `~/.config/emacs/` are **read-only symlinks into
the Nix store**. Editing them in place won't work. Instead:

1. Edit the copies here in `files/emacs/`.
2. `git add` the changes (flakes only see git-tracked files).
3. `nix run .#homeConfigurations.clouddesktop.activationPackage` (or the matching
   host config) to re-link.

## Emacs is NOT installed by the flake

Deliberate choice: the flake manages only the config, not the Emacs package. The
Emacs in use is a **from-source build of Emacs 31** (see "Building Emacs" below).
A fresh host needs its own Emacs 31 built with tree-sitter + native-comp; the
flake won't provide it.

---

# Building Emacs 31 with tree-sitter on Amazon Linux 2023

Notes on building Emacs 31 (`emacs-31` branch, version 31.0.90) from source on
Amazon Linux 2023, with native compilation (AOT), tree-sitter, and dynamic
modules enabled. Configure line used:

```
./configure --with-native-compilation=aot --with-tree-sitter --with-modules
```

## The problem

Emacs 31 has native tree-sitter support, but `libtree-sitter-devel` is **not
available in the AL2023 repos**, so `sudo dnf install libtree-sitter-devel`
fails. The fix is to build the tree-sitter library from source — Emacs only
needs the shared library, its header, and the pkg-config file, all of which the
upstream Makefile installs.

## Prerequisites

All available via dnf on AL2023:

```bash
sudo dnf install -y git gcc make libgccjit-devel
```

- `libgccjit-devel` is required for `--with-native-compilation`.
- `--with-native-compilation=aot` compiles all bundled `.el` files to native
  code ahead of time, which makes the build take noticeably longer.

## Step 1 — Build tree-sitter from source

```bash
cd /tmp
git clone --depth 1 --branch v0.22.6 https://github.com/tree-sitter/tree-sitter.git
cd tree-sitter
make
sudo make install      # installs into /usr/local by default
```

Installs:
- `/usr/local/lib/libtree-sitter.so*` (and `libtree-sitter.a`)
- `/usr/local/include/tree_sitter/api.h`
- `/usr/local/lib/pkgconfig/tree-sitter.pc`

Register `/usr/local/lib` with the **system** dynamic linker (this is what makes
Emacs find the library at runtime — see the ldconfig gotcha below):

```bash
echo "/usr/local/lib" | sudo tee /etc/ld.so.conf.d/usr-local-lib.conf
sudo ldconfig
```

Verify pkg-config can see it (for the configure step):

```bash
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
pkg-config --modversion tree-sitter    # -> 0.22.6
```

## Step 2 — Configure Emacs

```bash
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
./configure --with-native-compilation=aot --with-tree-sitter --with-modules
```

Confirm the configure summary shows:

```
checking for tree-sitter >= 0.20.2... yes
  Does Emacs use -ltree-sitter?                           yes
  Does Emacs have dynamic modules support?                yes
  Does Emacs have native lisp compiler?                   yes
```

## Step 3 — Build and install

```bash
make -j"$(nproc)"
sudo make install
```

AOT native compilation is the slow part (it natively compiles every bundled
`.el`). With many cores it still finishes reasonably quickly. After
`sudo make install`, the binary is `/usr/local/bin/emacs` ->
`/usr/local/bin/emacs-31.0.90`.

## Step 4 — Verify the binary

```bash
emacs --batch --eval '(progn
  (princ (concat "version: " (emacs-version) "\n"))
  (princ (format "treesit available: %s\n" (treesit-available-p)))
  (princ (format "native-comp: %s\n" (native-comp-available-p)))
  (princ (format "modules: %s\n" (and (fboundp (quote module-load)) t))))'
```

Expected:

```
version: GNU Emacs 31.0.90 ...
treesit available: t
native-comp: t
modules: t
```

---

# Gotchas (the time-sinks)

## 1. The Nix `ldd`/`ldconfig` on PATH LIE about /usr/local/lib

This is the big one. This machine has a **mixed Nix + system toolchain**:
`which ldd` -> `~/.nix-profile/bin/ldd`, and `ldconfig` on PATH is also Nix's.
The Nix `ldconfig` errors out:

```
ldconfig: Can't open cache file /nix/store/.../glibc-2.42/etc/ld.so.cache
```

and the Nix `ldd` reports `libtree-sitter.so.0 => not found` for the Emacs
binary. **Both are misleading.** They use the Nix glibc loader/cache, which
knows nothing about `/usr/local/lib`.

The actual `emacs` binary requests the **system** loader
(`/lib64/ld-linux-x86-64.so.2`), which reads the **system** ldconfig cache. The
`/etc/ld.so.conf.d/usr-local-lib.conf` + `sudo ldconfig` from Step 1 populated
that system cache, so Emacs finds `libtree-sitter.so.0` with **no environment
help at all**.

**Consequence: you do NOT need `LD_LIBRARY_PATH=/usr/local/lib`.** Earlier notes
(and a lot of test commands) prepended it defensively after misreading the Nix
`ldconfig` error as a failure. It was never needed for the installed Emacs.

To check the truth, use the **system** tools explicitly:

```bash
/sbin/ldconfig -p | grep tree-sitter      # should list /usr/local/lib/libtree-sitter.so.0
/usr/bin/ldd /usr/local/bin/emacs-31.0.90 | grep tree-sitter   # resolves correctly
```

On a fresh host: just the `ld.so.conf.d` entry + `sudo ldconfig` is the right,
persistent fix. No env-var plumbing in home-manager required.

## 2. tree-sitter grammar ABI ceiling (0.22.6 -> ABI 13–14)

The locally-built tree-sitter **0.22.6** supports grammar ABI versions **13–14**.
Current grammar `master` branches compile to **ABI 15**, which won't load:

```
Warning (treesit): ... ABI version is 15, but supported versions are 13-14
```

**Fix: pin grammar versions** when installing. `init.el` sets
`treesit-language-source-alist` with pins (e.g. Rust -> `v0.21.2`). The
javascript/tsx grammars that came installed already were compatible.

To upgrade and allow newer-ABI grammars, rebuild tree-sitter from a newer
release (and re-verify Emacs still links it).

## 3. markdown-ts-mode has no autoload cookies

Emacs 31 ships a built-in `markdown-ts-mode` (`lisp/textmodes/markdown-ts-mode.el`),
but the file contains **zero `;;;###autoload` cookies**. So `M-x` can't see the
command until the file is loaded — `commandp` is nil before load, t after
`(require 'markdown-ts-mode)`.

**Fix:** `init.el` has `(use-package markdown-ts-mode :ensure nil :commands
(markdown-ts-mode))`, which creates the autoload so `M-x markdown-ts-mode` works.

It needs **two** grammars: `markdown` and `markdown-inline` (both from
`tree-sitter-grammars/tree-sitter-markdown`, pinned commit per the mode's own
`treesit-language-source-alist` entries). Both compile to a compatible ABI.

`.md` defaults to the full-featured MELPA `markdown-mode`; `markdown-ts-mode` is
available via `M-x` to compare.

## 4. Terminal keyboard protocol -> ";5u" inserted into buffers

Running terminal Emacs in **Ghostty** (`TERM=xterm-ghostty`), holding `C-n` (or
other Ctrl keys) randomly inserts `;5u` into the buffer. Cause: Ghostty enables
the **Kitty keyboard protocol**, which encodes `C-n` as `ESC [ 110 ; 5 u`. Emacs
doesn't negotiate that protocol by default, so on key auto-repeat it loses
parser sync and leaks the `;5u` tail as literal text.

**Fix:** the `kkp` package (`global-kkp-mode`) in `init.el`. It makes Emacs speak
the protocol properly. No-op in the GUI.

## 5. auto-save / backup dirs must exist

`init.el` redirects auto-saves to `~/.config/emacs/auto-save/` and backups to
`~/.config/emacs/backups/`. Emacs does NOT create these — it errors on save if
they're missing:

```
Error (auto-save): Auto-saving ...: Opening output file: No such file or directory
```

**Fix:** `init.el` calls `make-directory ... t` for both at startup, so it's
self-healing on any machine.

## 6. XDG config dir vs ~/.emacs.d precedence

Per `startup--xdg-or-homedot` (lisp/startup.el), if `~/.emacs.d/` **exists**,
Emacs uses it and **ignores `~/.config/emacs/`**. Originally the tree-sitter
grammars were installed under `~/.emacs.d/tree-sitter/`, which would have made
Emacs ignore this XDG config entirely. Fixed by moving grammars into
`~/.config/emacs/tree-sitter/` and removing `~/.emacs.d/`.

Keep `~/.emacs.d/` from coming back, or this config silently stops loading.

---

# tree-sitter library vs. grammars

The tree-sitter **library** (`libtree-sitter.so`) is separate from the language
**grammars** (rust, javascript, markdown, ...). Emacs builds and runs fine
without any grammars. Install grammars via `M-x treesit-install-language-grammar`
(respecting the ABI ceiling in gotcha #2) or by dropping compiled `.so` grammar
files into `~/.config/emacs/tree-sitter/`. Grammars are per-machine and not
managed by the flake.
