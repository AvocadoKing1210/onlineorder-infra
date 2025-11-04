# Online Order — Infrastructure Setup Guide

This guide establishes all prerequisites and environment configurations before working on the development on actual functions.

## 1) Prerequisites

- Accounts
    - [Supabase](https://supabase.com/) for database, auth integration, edge functions, realtime api
    - [Cloudflare](https://www.cloudflare.com/en-ca/) for cloud functions, image storage, video streaming
    - [Auth0](https://auth0.com/) for OAuth

## 2) Setup Auth0

(Optional): [Set up own domain](https://auth0.com/docs/customize/custom-domains?tenant=dev-ozn3vdjt3s5s3wi5%40prod-us-5&locale=en-us) before getting started

1. Create Auth0 tenant from `+ Create Application` -> `SPA`.
2. Add an Auth0 Action (Post-Login) to inject the role claim:
   ```
   exports.onExecutePostLogin = async (event, api) => {
     api.accessToken.setCustomClaim('role', 'authenticated')
   }
   ```
Reference: [Supabase Auth0 guide](https://supabase.com/docs/guides/auth/third-party/auth0)

3. In Supabase project settings → Authentication → Third-Party Auth → add Auth0 integration (tenant id/region).
4. Ensure JWTs presented to Supabase include `role: authenticated` to map to the correct Postgres role.
5. Remember to configure `Friendly Name` under account settings, and also configure `Name` under your app's `Basic Information` section.

## 3) Setup Supabase

- Create one Supabase project
- Go to `Authentication` -> `Third Party Auth`, and add `Auth0` by following the instruction

## 4) Database initialization

Please refer to the `SQL` files under `/database_setup` directry, which contains the SQL script for creating tables and assosiate RLS rules.
