/**
 * Post-User-Registration Action
 * 
 * This action runs after a user successfully registers or logs in for the first time
 * (e.g., via Google OAuth consent screen acceptance).
 * 
 * Reference: https://auth0.com/docs/customize/actions/explore-triggers/signup-and-login-triggers/post-user-registration-trigger/post-user-registration-event-object
 * 
 * It:
 * 1. Creates a user profile in Supabase database using service_role key
 * 
 * Required Secrets (configure in Auth0 Action Secrets):
 * - SUPABASE_URL: Your Supabase project URL (e.g., https://xxxxx.supabase.co)
 * - SUPABASE_SERVICE_ROLE_KEY: Supabase service_role key (bypasses RLS)
 * 
 * Required npm package (add in Auth0 Action Dependencies):
 * - @supabase/supabase-js
 */

exports.onExecutePostUserRegistration = async (event, api) => {
    const { createClient } = require('@supabase/supabase-js');
    
    // Get secrets from Auth0 Action configuration
    // Reference: https://auth0.com/docs/customize/actions/explore-triggers/signup-and-login-triggers/post-user-registration-trigger/post-user-registration-api-object
    const supabaseUrl = event.secrets.SUPABASE_URL;
    const supabaseServiceRoleKey = event.secrets.SUPABASE_SERVICE_ROLE_KEY;
    
    // Initialize Supabase client with service_role key (bypasses RLS)
    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);
    
    try {
      // 1. Insert user profile into Supabase
      // event.user properties: https://auth0.com/docs/customize/actions/explore-triggers/signup-and-login-triggers/post-user-registration-trigger/post-user-registration-event-object#event-user
      const { data, error } = await supabase
        .from('user_profile')
        .insert({
          id: event.user.user_id, // Auth0 user ID (maps to JWT 'sub' claim)
          email: event.user.email || '',
          display_name: event.user.name || event.user.nickname || null,
          avatar_url: event.user.picture || null,
          phone_number: event.user.phone_number || null,
          preferred_locale: event.transaction?.locale || 'en'
        })
        .select()
        .single();
      
      if (error) {
        console.error('Error inserting user profile into Supabase:', error);
        // Don't throw - allow registration to complete even if profile creation fails
      } else {
        console.log('User profile created in Supabase:', event.user.user_id);
      }
      
    } catch (error) {
      console.error('Unexpected error in post-user-registration action:', error);
      // Don't throw - allow registration to complete even if action fails
    }
  };
  