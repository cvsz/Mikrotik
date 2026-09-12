---
name: routeros-capsman
description: "RouterOS legacy CAPsMAN (/caps-man) provisioning, reprovisioning, and access-list gotchas for multi-AP wireless controller deployments. Use when: diagnosing why a CAPsMAN provisioning-rule change didn't take effect on an already-connected CAP, forcing a specific radio or CAP to re-provision without a full disconnect, seeing interface=*XX (hex id) instead of a name in /caps-man/access-list print output, cleaning up wide/extension-channel (40MHz+) configs that keep reappearing and causing network-wide wireless slowness, or when the user mentions /caps-man, CAPsMAN provisioning, caps-man interface, or caps-man access-list. Covers the legacy wireless package CAPsMAN only — for the newer /interface/wifi CAPsMAN (wifi-qcom packages) see MikroTik's WiFi CAPsMAN docs instead."
---

# RouterOS Legacy CAPsMAN — Provisioning & Access-List Gotchas

Covers `/caps-man` (the `wireless` package controller, RouterOS 7.x). Does **not** cover
the newer `/interface/wifi` CAPsMAN (`wifi-qcom`/`wifi-qcom-ac` packages) — see MikroTik's
[WiFi CAPsMAN](https://manual.mikrotik.com/docs/wireless/wifi/capsman) docs for that stack.

## The core gotcha: provisioning is one-time, not live

Provisioning is used to create/bind interfaces when CAP radios are matched. Editing an
already-bound `/caps-man/configuration` or its referenced `/caps-man/channel` profile can
push changes live, but changing only the `/caps-man/provisioning` rule does not rebind an
existing interface.

Practical consequences:

1. Editing `/caps-man/provisioning` to point a `radio-mac` at another
   `master-configuration` does not change an interface that has already been provisioned.
2. Editing the bound `/caps-man/configuration` or `/caps-man/channel` profile updates the
   active interface without requiring a remove/recreate cycle.

```routeros
# WRONG for changing already-running radios: this only changes future matching/reprovisioning
/caps-man/provisioning/set [find radio-mac=02:00:00:00:05:01] master-configuration=cfg_5g_5220

# RIGHT: edit the profile the radio is already bound to
/caps-man/configuration/set [find name=cfg_5g_5220_40] channel=cfg_5g_5220
/caps-man/channel/set [find name=ch_5220_40] extension-channel=disabled control-channel-width=20mhz
```

The `02:` MAC values in this document are deliberately fictional, locally administered
examples and do not identify a real deployment.

## Forcing a real re-provision

When a radio really must re-run provisioning-rule matching, use the built-in provision
commands instead of removing the managed interface:

```routeros
/caps-man/radio/provision [find radio-mac="02:00:00:00:05:02"]
/caps-man/remote-cap/provision [find name="[02:00:00:00:05:03]"]
```

Avoid `/caps-man/interface remove` merely to force a rebind because dependent objects can
retain references to the old internal object ID.

## Collateral damage: removing an interface can orphan access-list rules

`/caps-man/access-list` rules can reference `interface=` by internal object ID. If the
interface is removed and recreated, an old rule can remain present while its reference is
no longer valid. A warning sign is a raw `*hex` value instead of a readable interface
name.

```routeros
[admin@CM] /caps-man/access-list> print terse
 8 comment=ap-a-5g:accept>-75dBm interface=*92 signal-range=-75..0 action=accept
```

A healthy rule should resolve to the current interface name, for example:

```routeros
 0 comment=ap-b-5g:accept>-75dBm interface=ap-b-5g signal-range=-75..0 action=accept
```

Repair by selecting the stale rule with a stable field such as its comment and recreating
it against the current interface:

```routeros
/caps-man/access-list remove [find comment="ap-a-5g:accept>-75dBm"]
/caps-man/access-list add interface="ap-a-5g" signal-range=-75..0 \
    action=accept comment="ap-a-5g:accept>-75dBm"
```

For generated automation, prefer stable selectors such as `name=` or `comment=` and do
not assume interactive row numbers or old internal IDs are durable.

## Diagnosing wide-channel regressions in dense deployments

In a dense multi-AP deployment, widening one AP from 20 MHz to 40 MHz or more can increase
co-channel/adjacent-channel interference and reduce network-wide performance. Audit both
channel profiles and provisioning rules before assuming client overload should be fixed
with channel width.

```routeros
/caps-man/channel/print detail
/caps-man/provisioning/print detail
```

Review any profile where `extension-channel` is not disabled, then cross-check which
provisioning/configuration entries use it. If one AP is accumulating weak clients, verify
signal-range/access-list roaming policy before widening channels.

## Related

- `routeros-fundamentals` for RouterOS CLI/REST fundamentals.
- `routeros-scripting` for `[find]`, idempotent selectors, and RouterOS scripting.
- Official docs: [CAPsMAN](https://manual.mikrotik.com/docs/wireless/abgn/capsman/),
  [AP Controller (CAPsMAN)](https://manual.mikrotik.com/docs/wireless/abgn/capsman/ap-controller-capsman),
  [WiFi CAPsMAN](https://manual.mikrotik.com/docs/wireless/wifi/capsman).

## Provenance

Vendored for zOS from the proposed upstream `tikoci/routeros-skills` PR #19. The examples
were sanitized before import to remove deployment-specific names and MAC addresses while
preserving the operational behavior being documented.
