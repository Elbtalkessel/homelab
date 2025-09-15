import { Config, PartialDeep } from "./lib/types.ts"

/** Check the Config type for all the possible options and instructions. */
const config: PartialDeep<Config> = {
  auth: {
    // The base URL of the application you use to access the app,
    // i.e. "http://localhost:8000" or "https://cloud.example.com".
    // SSO redirect, if enabled, will be this + /oidc/callback,
    // so "https://cloud.example.com/oidc/callback".
    baseUrl: "http://docs.s1.home.arpa",
    // If true, anyone can sign up for an account.
    // Note that it's always possible to sign up for the first user, and they will be an admin.
    allowSignups: false,
    // If true, email verification will be required for signups (using SMTP settings below).
    enableEmailVerification: false,
    // If true, all signups become active for 100 years.
    enableForeverSignup: true,
    // If true, users can enable multi-factor authentication (TOTP, Passkeys, or Email if the SMTP settings below are set).
    enableMultiFactor: false,
    // Can be set to allow more than the baseUrl's domain for session cookies
    allowedCookieDomains: ["docs.s1.home.arpa", "docs.s2.home.arpa"],
    // If true, the cookie domain will not be strictly set and checked against. This skipping slightly reduces security, but is usually necessary for reverse proxies like Cloudflare Tunnel
    skipCookieDomainSecurity: false,
    // If true, single sign-on will be enabled
    enableSingleSignOn: false,
    // The Discovery URL (AKA Issuer) of the identity/single sign-on provider
    singleSignOnUrl: "",
    // The attribute to prefer as email of the identity/single sign-on provider
    singleSignOnEmailAttribute: "email",
    // The scopes to request from the identity/single sign-on provider
    singleSignOnScopes: ["openid", "email"],
  },
  files: {
    rootPath: "data-files",
    // If true, public file sharing will be allowed (still requires a user to enable sharing for a given file or directory)
    allowPublicSharing: false,
  },
  core: {
    // dashboard and files cannot be disabled
    enabledApps: [
      "news",
      "notes",
      // 'photos',
      "expenses",
      "contacts",
      "calendar",
    ],
  },
  visuals: {
    title: "Organizer",
    description: "Home documentes and contacts manager",
    helpEmail: "pieceof@duck.com",
  },
  email: {
    from: "pieceof@duck.com",
    host: "docs.s1.home.arpa",
    port: 465,
  },
  contacts: {
    enableCardDavServer: true,
    cardDavUrl: "http://radicale:5232",
  },
  calendar: {
    enableCalDavServer: true,
    calDavUrl: "http://radicale:5232",
  },
}

export default config
