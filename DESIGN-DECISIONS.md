# Design Decisions

Record confirmed decisions that materially affect the module's implementation or maintenance. Keep entries in reverse chronological order, newest first. For each open design issue, use a query-response exchange: present a brief description of the common options and their respective pros and cons, ask one focused question, and record the selected decision and its consequences after the user responds. Do not treat an unanswered question as a decision.

## 2026-11-21 - WebUI TLS Ownership Handoff

**Status:** Confirmed

Use an explicit TLS mode switch for certificate ownership. Puppet manages the self-signed bootstrap certificate only in bootstrap mode. Before exposing the WebUI to real users, operators install the operational certificate and switch Puppet to operational mode.

**Consequences:** Make the selected mode and operational certificate paths explicit inputs. Ensure operational mode does not generate or overwrite the certificate, validate required files, and document/test the transition and service reload.

## 2026-11-21 - WebUI TLS Bootstrap

**Status:** Confirmed

Provide a self-signed Apache TLS certificate for initial WebUI bootstrap. Document that operators are expected to replace it with an operational Apache certificate, preferably issued by the managed OpenXPKI instance, before exposing the service to real users.

**Consequences:** Clearly identify the self-signed certificate as bootstrap-only and document issuance, installation, and verification of its replacement before real-user exposure.

## 2026-11-21 - Secret Delivery

**Status:** Confirmed

Use encrypted Hiera data (for example, hiera-eyaml) to provide sensitive values to the first release. This includes database credentials, SoftHSM PINs/vault material, and local account password hashes.

**Consequences:** Do not store plaintext secrets in module defaults or example data. Document encryption-key custody and rotation as operator responsibilities, and ensure Puppet resources/files and reports do not disclose resolved values. An external secret-manager integration is not a first-release dependency.

## 2026-11-21 - WebUI User Roles

**Status:** Confirmed

Support authenticated requestors using self-service WebUI workflows and RA operators reviewing and processing requests. Do not treat the first release as operator-only.

**Consequences:** Realm/account data and workflow ACLs must distinguish requestors from RA operators. Map exact permissions to the selected OpenXPKI workflows and test ownership and authorization boundaries before implementation; do not infer permissions from role labels alone.

## 2026-11-21 - Realm Input Model

**Status:** Confirmed

Operators will define managed realm configuration through structured Hiera data, which the module validates and renders into OpenXPKI configuration.

**Consequences:** Define and type the supported realm data schema before implementing the templates. Avoid accepting arbitrary realm file trees in the first release; keep the schema limited to the agreed manual WebUI workflows and test rendering with multiple realms.

## 2026-11-21 - Realm Cardinality

**Status:** Confirmed

Support multiple realms managed by the module in one OpenXPKI deployment.

**Consequences:** Model realm input as a collection and validate/render each realm consistently. Keep all managed realms within the first-release scope: local YAML-backed WebUI authentication and manual certificate lifecycle workflows. Add coverage for more than one realm and avoid bringing in unsupported optional interfaces.

## 2026-11-21 - Certificate Policy Ownership

**Status:** Confirmed

Operators supply certificate profiles and issuance policy through structured Hiera data. The README will document a functional minimal example, but that example is illustrative and is not an implicit module-managed production policy.

**Consequences:** Validate the supported policy input shape and render only operator-supplied policy. Label the README example as requiring review and adaptation to local PKI requirements; do not silently install it as a production baseline.

## 2026-11-21 - Local PostgreSQL Version

**Status:** Confirmed

Support PostgreSQL 15 only for module-managed local PostgreSQL on Debian 12. External PostgreSQL must use a version compatible with the selected OpenXPKI release.

**Consequences:** Keep local package and cluster configuration/tests scoped to PostgreSQL 15. Document and validate the compatibility requirement for external servers; supporting additional local major versions requires a later explicit decision.

## 2026-11-21 - OpenXPKI Package Version Control

**Status:** Confirmed

Expose OpenXPKI package version policy to operators through Hiera/class parameters. By default, install the repository candidate; operators can pin a specific package version.

**Consequences:** The default allows package updates without a module change but does not guarantee identical package versions across deployments. Document how to pin versions for repeatability, supported `ensure` values, and package availability behavior.

## 2026-11-21 - PostgreSQL Deployment Topology

**Status:** Confirmed

Support a local PostgreSQL deployment by default and allow PostgreSQL to be hosted externally.

**Consequences:** Separate database provisioning from OpenXPKI connection configuration. Define secure connection, authentication, and network requirements for the external mode, and test both local and external database catalog paths.

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

Ship a deliberately minimal, functional realm model for first-release WebUI and manual certificate lifecycle workflows, supporting multiple managed realms with a limited set of intentional customization points. Do not adopt a full upstream example realm as the module's production policy baseline.

**Consequences:** Define the minimum realm configuration needed for local user-database authentication and manual enrollment, renewal, and revocation. Keep the supported customization surface explicit and test it across multiple realms; vendor upstream realm material selectively with its provenance and license requirements.

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
