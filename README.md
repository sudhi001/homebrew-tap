# homebrew-tap

Homebrew formulae for [sudhi001](https://github.com/sudhi001)'s command-line
tools.

```sh
brew install sudhi001/tap/hl7probe
brew install sudhi001/tap/mdsmedia
brew install sudhi001/tap/logger-server
```

Recent Homebrew versions ask you to trust a third-party tap the first time; if
you see that prompt, run `brew trust sudhi001/tap` and install again.

## Formulae

| Formula | Description |
| --- | --- |
| [`hl7probe`](Formula/hl7probe.rb) | Inspect and validate HL7 v2 messages; installs the `hl7test` command ([hl7probe](https://github.com/sudhi001/hl7probe)) |
| [`mdsmedia`](Formula/mdsmedia.rb) | Send and test SMS through the MDS Media gateway ([mdsmedia](https://github.com/sudhi001/mdsmedia)) |
| [`logger-server`](Formula/logger-server.rb) | Self-hosted remote logger for mobile apps, with a live browser tail ([logger_server](https://github.com/sudhi001/logger_server)) |


