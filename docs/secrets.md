# Secrets

This repository stores encrypted secret material under `secrets/` and renders
it at activation time with sops-nix. Keep secret values out of Nix expressions,
environment variables, command output, the Nix store, and Git history.

## Model

- [`.sops.yaml`](../.sops.yaml) is the recipient policy. It chooses recipients
  by path: shared secrets, `wslstation` secrets, and `homestation` secrets.
- The shared system module uses each machine's `~/.ssh/id_ed25519` as a
  sops-nix age identity. A machine can therefore decrypt only files for which
  its corresponding age recipient is configured.
- Nix modules reference secrets through `config.sops.secrets.*.path` or
  `config.sops.placeholder.*`. Templates and environment files are rendered at
  activation; values must never be copied into a Nix string.

The PGP administrator recipient is the recovery path. Do not remove it without
an intentional replacement and a tested recovery procedure.

## Edit an existing secret

Work from a machine whose configured SSH key or administrator PGP key can
decrypt the target file. Edit in place with sops:

```sh
sops secrets/hosts/homestation/infra.yaml
```

Use the file already referenced by the consuming module. For example,
`configurations/nixos/homestation/sops.nix` maps individual YAML keys into
sops-nix secret paths and templates. After editing, review the encrypted diff
without decrypting it into a file, run the appropriate evaluation, then activate
the target host.

## Add a secret

1. Choose the narrowest scope: `secrets/shared/` only when every listed
   recipient needs it; otherwise place it under the owning host.
2. Add the encrypted key with `sops` to the chosen YAML file, or create a new
   file whose path matches a rule in `.sops.yaml`.
3. Declare the key in the relevant host or shared sops module with restrictive
   ownership and mode, normally `0400`.
4. Pass it to a service by a sops-nix path or a rendered template. Never put the
   literal value in `environment`, a Nix file, a shell command, or a log.
5. Evaluate and activate the owning host, then verify only that the consumer
   starts successfully.

## Add a machine recipient

Before a new machine is expected to consume encrypted secrets, create and
secure its SSH identity. Convert its public SSH key to an age recipient with
`ssh-to-age`, add that recipient to the relevant `.sops.yaml` creation rules,
and re-encrypt affected files:

```sh
sops updatekeys secrets/hosts/<host>/<file>.yaml
```

Commit the encrypted result and the policy change together. Confirm the new
machine can activate without exposing plaintext. Do not add a recipient merely
because it is convenient: access should follow the host's actual secret needs.

## Rotate or remove access

Change the value in sops first when rotating a credential, update the external
provider if necessary, and activate every consumer. To revoke a machine or
administrator key, remove its recipient from `.sops.yaml`, run `sops updatekeys`
for every affected file, and confirm the remaining recovery recipient can still
decrypt them. Revocation is incomplete until all affected files are re-encrypted.

## Safety checks

- Never use `sops -d` in a command substitution, redirect plaintext to disk, or
  print a secret in a terminal transcript.
- Never use a secret value as a Nix derivation input.
- Treat generated sops templates and `environmentFiles` as runtime-only files;
  inspect service status and logs without copying their contents.
- If decryption fails, stop and repair recipient access. Do not replace an
  encrypted file with a new plaintext configuration.
