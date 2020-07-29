# Changelog

## 0.4.0

### Fixes

* Fixed a glaring fatal bug in the child spec. Sorry about that :/

### Breaking Changes

* `socket_count/0` will now return `:not_started` rather than blowing up if the process isn't there.

## 0.2.0

* Switched to using `:erl_signal_server` to get notification of a sigterm
