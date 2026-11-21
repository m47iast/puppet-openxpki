# Design Decisions

Record confirmed decisions that materially affect the module's implementation or maintenance. Keep entries in reverse chronological order, newest first. For each open design issue, use a query-response exchange: present a brief description of the common options and their respective pros and cons, ask one focused question, and record the selected decision and its consequences after the user responds. Do not treat an unanswered question as a decision.

## 2026-11-21 - Local Account File Ownership

**Status:** Confirmed

Puppet will manage the local YAML account file from Hiera data.

**Consequences:** Treat password hashes and account data as sensitive; use an appropriately protected Hiera backend, never store plaintext passwords in Puppet data, and ensure the rendered file is readable only by the required OpenXPKI service account. Document how account changes are applied and verified.

## 2026-11-21 - Local WebUI Account Store

**Status:** Confirmed

For the first release, use the upstream `LocalPassword` pattern with account records in a separate, access-controlled YAML file. Keep the authentication configuration boundary replaceable so a later release can add IdP accounts without making that integration part of the first release.

**Consequences:** Verify the connector behavior against the pinned OpenXPKI release; manage the account file's ownership, permissions, and secret-safe update process; do not enable the upstream `Testing` handler or its sample credentials. Defer IdP integration to a separate later-release plan.

## 2026-11-21 - First-Release Realm Configuration

**Status:** Confirmed

Ship a deliberately minimal, functional realm for the first-release WebUI and manual certificate lifecycle workflows, with a limited set of intentional customization points. Do not adopt a full upstream example realm as the module's production policy baseline.

**Consequences:** Define the minimum realm configuration needed for local user-database authentication and manual enrollment, renewal, and revocation. Keep the supported customization surface explicit and test it; vendor upstream realm material selectively with its provenance and license requirements.

## 2026-11-21 - Design Decision Workflow

**Status:** Confirmed

Design questions will be handled one at a time. Each question should give enough context to make the choice clear, summarize the most common viable options and their pros and cons, and allow the user to respond before implementation proceeds on that decision. Record decisions here as they are made; insert each new entry above older entries.

## 2026-11-21 - First-Release Scope

**Status:** Confirmed

The first release targets WebUI authentication against a local user database and human-operated WebUI workflows, including certificate enrollment, renewal, and revocation. IdP integrations, the OpenXPKI RPC endpoint and RPC workflows, and SCEP, ACME, and EST endpoints are deferred to later releases and separate planning.

**Consequences:** First-release packages, configuration, Apache routes, tests, and documentation should support only the scoped WebUI use case. Deferred integrations are not first-release acceptance criteria.

## 2026-11-21 - Puppet Template Language

**Status:** Confirmed

Migrate the module's existing ERB templates to EPP early in development and use EPP for new Puppet-rendered configuration.

**Consequences:** Convert existing `template()` calls to `epp()`, pass template inputs explicitly, and test rendered output before expanding the managed configuration set.

## 2026-11-21 - Attribution of Vendored Configuration

**Status:** Confirmed

Treat configuration sourced from `openxpki-config` as upstream project and contributor work. Preserve existing notices, identify the upstream source path and pinned revision, document local modifications, and comply with each file's applicable license and redistribution terms. Do not vendor files whose rights are unclear until clarified.

**Consequences:** Review attribution and license obligations as part of selecting files to vendor; keep provenance with the module and do not imply upstream endorsement.
