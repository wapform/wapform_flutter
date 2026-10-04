# Installing and running the wapform_flutter example

This walks through the full setup, step by step, from installing
Flutter itself through to seeing the example app running — more
detail than the "1. Start the backend / 2. Run the Flutter app"
summary in `example/README.md`, and explains *why* each step is
needed, not just what to type.

---

## Why two things have to run, not just the Flutter app

Before diving in, it helps to understand why this example needs **a
Node.js server running before the Flutter app can do anything
useful** — this isn't an optional step, it's one of the package's
core design decisions.

**Flutter App (browser/mobile/desktop) → HTTP (`localhost:3000`) → server.js (Node.js gateway) → TCP (`localhost:3306`) → MariaDB / MySQL**

`TWapSQLConnection` (`lazarus_sqldb.dart`) handles the first half —
the HTTP call from the Flutter app to `server.js`. The actual TCP
connection to the database is opened by `server.js`, not by the
Flutter app itself.

**The Flutter app never connects to the database directly** —
especially on Web, where browser architecture doesn't allow a web
page to open a native TCP connection at all (this is also why the
main `README.md`'s "Platform Support & Web-First Architecture"
section exists). `lazarus_sqldb.dart`'s `TWapSQLConnection` calls the
`server.js` gateway over HTTP instead; `server.js` (running under
Node.js, which can open native TCP) is what actually talks to the
database, runs the SQL, and packages the result back as JSON.

**So the order matters**: the database has to be up first → `server.js`
has to be able to reach it → only then can the Flutter app reach
`server.js`. The steps below follow that order.

---

## Prerequisites

Before starting, make sure you have:

| What | Version | How to check |
|---|---|---|
| **Flutter SDK** | 3.19.0+ | `flutter --version` |
| **Node.js** | 18+ recommended (needed by `mysql2`) | `node --version` |
| **npm** | ships with Node.js | `npm --version` |
| **MariaDB or MySQL** | 10.4+ (MariaDB) / 8.0+ (MySQL) | `mysql --version` |

If `mysql` isn't found, the database server itself isn't installed
yet — this guide doesn't cover installing MariaDB/MySQL itself; see
your platform's usual method (an installer on Windows,
`brew install mariadb` on macOS, a package manager like
`apt install mariadb-server` on Linux).

If `flutter` isn't found, the Flutter SDK itself isn't installed yet
— see Step 1 below.

---

## Step 1: Install the Flutter SDK

If `flutter --version` already prints a version number, skip to
Step 2.

**Windows:**

1. Download the latest stable-channel zip from the
   [official Flutter install page](https://docs.flutter.dev/get-started/install/windows).
2. Extract it to **`C:\flutter`** — this is the most common
   convention in Flutter's own docs and the wider community (not a
   hard requirement, but nearly every tutorial and Stack Overflow
   troubleshooting thread assumes you installed here; a different
   path works fine too, it just makes following other people's guides
   a bit more work). **Avoid a path with non-ASCII characters or
   spaces** — Flutter tends to produce strange build errors under
   those.
3. Add `C:\flutter\bin` to your system `PATH` environment variable
   (Settings → System → Advanced system settings → Environment
   Variables → find `Path` → New).
4. Open a **new** terminal window (a window opened before you changed
   `PATH` won't pick up the change) and run `flutter doctor` to check
   the install; follow whatever it flags as missing (it'll usually ask
   for Android Studio or Visual Studio — not required if you only
   plan to run the Web target; you can ignore those specific items and
   just make sure nothing's flagged for Chrome/Web).

**macOS:**

```bash
# Homebrew, or use Flutter's official install script instead:
brew install --cask flutter
```
Or follow the [official macOS install page](https://docs.flutter.dev/get-started/install/macos)
and extract manually to a path of your choice (a common convention is
`~/development/flutter`) — either way, add `flutter/bin` to `PATH`.

**Linux:**

```bash
sudo snap install flutter --classic
```
Or follow the [official Linux install page](https://docs.flutter.dev/get-started/install/linux).

Once installed, on any platform, confirm with:

```bash
flutter doctor
```

A green checkmark next to Flutter SDK and Chrome (if you're targeting
Web) is enough — you don't need every line green. If you're not
building native Android/iOS apps, red items under
Android toolchain/Xcode can be ignored for now.

---

## Step 2: Set up a database account

The connection credentials hard-coded in `server.js` are
**placeholders**, not a real working account:

```js
user:     'xyz',
password: '123',
```

`example/server/sales.sql` (Step 3) already creates this account. To create it by hand
in your MariaDB/MySQL instance (or to use
`root`, though that's not recommended outside local development):

```sql
CREATE USER 'xyz'@'localhost' IDENTIFIED BY '123';
GRANT ALL PRIVILEGES ON sales.* TO 'xyz'@'localhost';
FLUSH PRIVILEGES;
```

If you use different credentials, remember to come back and update
`user`/`password` in `server.js` in Step 4.

---

## Step 3: Create the database schema

```bash
cd example/server
mysql -u root -p < sales.sql
```

(Run it as `root` (or another admin account): it also creates the `xyz` account.)

**This creates 12 tables** — `cu`, `em`, `fm`, `login`, `mnu`, `num`,
`pa`, `sh`, `sn`, `sys`, `users`, `ve` — a real production
database export, checked against exactly which tables the 12 example
pages (plus `function.wml`'s menu entry) actually query, not picked
arbitrarily. (`web`, used by an earlier generator template's version
of `app002.dart`, is no longer queried by the current one and isn't
included.)

**Seed data:** this is a real data export, not hand-written
placeholder rows — every table except `num` (which the app populates
itself for document numbering) comes with real sample rows, including
`users`/`mnu`/`login`, which aren't optional: the app is login → a
fully data-driven menu (see `example/README.md`), so without an
account in `users` and menu items in `mnu`/`login`, you can't log in
or see anything at all. The seeded login is username `admin`,
password `admin`. The menu includes a permanent entry for
`function.wml`'s self-test report ("Function Self-Test") — see
`example/README.md`.

Verify afterward:

```bash
mysql -u xyz -p -e "USE sales; SHOW TABLES; SELECT * FROM sys; SELECT * FROM users;"
```

You should see the `sys` table with one seed row already in it (from
the `INSERT` at the end of `sales.sql`, so the example screen has
something to show and edit right away instead of a blank page).

---

## Step 4: Configure and start `server.js`

### 4-1. Install Node.js dependencies

```bash
cd example/server   # if you're still at the project root
npm install
```

`package.json` lists three dependencies: `express` (HTTP server
framework), `mysql2` (database driver), and `cors` (lets the
browser-based Flutter app call this server across origins).

### 4-2. Check the connection settings

Open `server.js` and find this block near the top:

```js
const pool = mysql.createPool({
  host:     'localhost',
  port:     3306,
  database: 'sales',
  user:     'xyz',
  password: '123',
  ...
});
```

If your database isn't running on `localhost:3306`, or you used
different credentials in Step 2, update the values here to match. If
your own database is named something other than `sales`, change
`database: 'sales'` above to match — and update `sales.sql`'s
`CREATE DATABASE`/`USE` statements in Step 3 to the same name before
running them.

### 4-3. Start it

```bash
node server.js
```

You should see:

```
WapForm API  →  http://localhost:3000
Database     →  sales @ localhost:3306
Endpoints    →  GET /ping  GET /tables  POST /query  POST /transaction
```

### 4-4. Verify the server can actually reach the database

**Don't skip this** — if it's broken here, the Flutter app will just
show a connection failure without telling you whether the problem is
"app can't reach server.js" or "server.js can't reach the database."
Check each hop separately with `curl` first:

```bash
curl http://localhost:3000/ping
```
Should return something like `{"ok":true}`.

```bash
curl http://localhost:3000/tables
```
Should return a JSON array that includes at least `"sys"`. If this
errors out or returns an empty array, either Step 3's schema didn't
get created successfully, or Step 4-2's connection settings are
wrong — fix that before continuing.

---

## Step 5: Run the Flutter app

From the `example/` directory (not `example/server/`):

```bash
cd ..              # back from example/server to example/
flutter pub get
flutter run -d chrome
```

(`-d chrome` targets Web; you can substitute an Android device/emulator
instead — both platforms have been fully exercised and refined, see
the main `README.md`'s "Platform Support & Web-First Architecture"
section. iOS and desktop are still future work.)

Once it opens, you'll see a login screen (matching the desktop
WapToolkit's own "WAPFORM Connect" dialog). Log in with username
`admin`, password `admin` (seeded in Step 3) — if login fails, the
gateway probably isn't reachable; re-check Step 4-4's `curl` tests.

After logging in, you'll see a fully data-driven main menu — its
groups, items, and titles all come from the `mnu`/`login` tables
seeded in Step 3, not from anything hardcoded in the app. Every menu
item, including **Function Self-Test** (`function.wml`'s expression-
engine self-test report), opens to real data — `sales.sql` is an
actual data export, not placeholder rows, so there's no "blank
form" case to expect here the way earlier versions of this guide
described.

---

## Troubleshooting

**`npm install` fails, can't find a package version**
Check that Node.js is recent enough (18+ recommended) — packages like
`mysql2` may not install on older versions.

**`mysql -u xyz -p < sales.sql` fails with `Access denied`**
Wrong credentials, or Step 2's `GRANT` didn't actually run. Log in
with `mysql -u root -p` and run
`SELECT User, Host FROM mysql.user WHERE User='xyz';` to confirm the
account exists.

**`curl http://localhost:3000/ping` gives connection refused**
`server.js` isn't running, or something else is using port 3000. Use
`lsof -i :3000` (macOS/Linux) or `netstat -ano | findstr 3000`
(Windows) to see what's on that port.

**`curl http://localhost:3000/tables` returns an empty array or a connection error**
`server.js` is running but can't reach the database — recheck Step
4-2's `host`/`port`/`database`/`user`/`password` against your actual
MariaDB/MySQL setup, and confirm the database server itself is
running (`mysql -u xyz -p -e "SELECT 1;"` tests the database
connection on its own, ruling `server.js`'s config in or out).

**Flutter app's login fails with "Account does not exist" or "Password error" even though `admin`/`admin` is right**
Step 3's seed `INSERT`s into `users` probably didn't run — reconnect
and check: `mysql -u xyz -p -e "USE sales; SELECT * FROM users;"`
should show one row with `USERID='admin'`.

**Flutter app's login hangs or throws a connection error**
The browser's resolution of `localhost` can occasionally differ from
your terminal's (rare, but possible); make sure you're running
`flutter run -d chrome` directly rather than inside some containerized
environment (a container's `localhost` may not be the host's
`localhost`). Also re-check Step 4-4's `curl` tests — a login attempt
goes through the exact same gateway.

**Logged in, but the main menu is empty or grayed out**
Empty menu → Step 3's seed `INSERT`s into `mnu` probably didn't run;
check `SELECT * FROM mnu;` shows 15 rows. Items visible but grayed
out and untappable → the `login` table's permission rows are missing
or don't have `w=1` for the `admin` account; check
`SELECT * FROM login WHERE uid='admin';` shows 60 rows.

**A menu item opens to a blank form or grid, or an actual error**
Not expected — `sales.sql` is a real data export, so every table
(other than `num`, which the app populates itself) should already
have rows to show. A blank screen or error here means something in
Step 3 didn't fully apply; re-run
`mysql -u xyz -p -e "USE sales; SELECT COUNT(*) FROM cu;"` (swap in
whichever table's page is blank) and confirm it's non-zero. If the
count looks right and you still get an actual error message, that's
worth investigating further (e.g. a grouped report like `app012` may
not handle some data shape cleanly) — please file that with the full
error text if it happens.
