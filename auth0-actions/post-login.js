/**
 * Post-Login Action
 * 
 * This action runs after a user successfully logs in.
 * 
 * It:
 * 1. Sets 'role: authenticated' claim for Supabase compatibility
 * 2. Sets 'user_group' claim from existing roles or assigns 'Customer' as default
 * 
 * Reference: https://auth0.com/docs/customize/actions/explore-triggers/signup-and-login-triggers/login-flow
 */

/**
 * Handler that will be called during the execution of a PostLogin flow.
 *
 * @param {Event} event - Details about the user and the context in which they are logging in.
 * @param {PostLoginAPI} api - Interface whose methods can be used to change the behavior of the login.
 */
exports.onExecutePostLogin = async (event, api) => {
  // Always set role claim for Supabase compatibility
  api.accessToken.setCustomClaim('role', 'authenticated');
  api.idToken.setCustomClaim('role', 'authenticated');
  
  // Determine user_group: use existing roles or default to 'Customer' if empty
  let userGroup = [];
  
  if (event.authorization?.roles && event.authorization.roles.length > 0) {
    // User already has roles assigned (from Auth0 Groups or app_metadata)
    userGroup = event.authorization.roles;
  } else {
    // No roles assigned - default to 'Customer'
    userGroup = ['Customer'];
  }
  
  // Set user_group claim in both tokens
  api.accessToken.setCustomClaim('user_group', userGroup);
  api.idToken.setCustomClaim('user_group', userGroup);
};

/**
 * Handler that will be invoked when this action is resuming after an external redirect. If your
 * onExecutePostLogin function does not perform a redirect, this function can be safely ignored.
 *
 * @param {Event} event - Details about the user and the context in which they are logging in.
 * @param {PostLoginAPI} api - Interface whose methods can be used to change the behavior of the login.
 */
// exports.onContinuePostLogin = async (event, api) => {
// };

