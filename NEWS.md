# NEWS

## 0.1.1 — 2026-11-05

- Tag successful Meterpreter last-known network-provider submissions with
  `provider: network` so the receiver can display the reported acquisition
  provider without claiming a fresh GPS measurement.
- Leave `measured_ms` and `accuracy_m` absent; existing recorded data is not
  changed. Stop and restart a running Metasploit job after reinstalling the
  module to use the updated field.

## 0.1.0 — 2026-11-04

Initial independent Metasploit Android acquisition adapter for Cartochron.

- Submit Android Meterpreter's reported last-known network-provider position
  to the Cartochron observation endpoint during an authorized framework job.
- Generate a new recording-run ID per job by default; optionally associate
  jobs with an enrolled `SOURCE_ID` and a stable configured `CHANNEL_ID`.
- Check successful receiver acknowledgment of `CHANNEL_ID` when provided,
  rather than continuing without the configured channel provenance.
- Support HTTP Basic authentication, bounded HTTP timeouts, framework-native
  logging, module installation/removal and Ruby unit tests.

### Important boundaries

- Android `geolocate` can return a cached location. Measurement age, accuracy
  and physical presence are not independently verified; the adapter does not
  fabricate measurement timestamps or accuracy.
- `SOURCE_ID` and `CHANNEL_ID` identify operator assertions, not device proof.
- A configured channel requires a compatible Cartochron receiver. A legacy
  request without a channel retains the original protocol behavior.
- Use only with explicitly authorized sessions and receivers.

See `README.md` for installation, configuration and usage.
