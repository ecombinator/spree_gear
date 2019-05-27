<?php
    define( 'WP_USE_THEMES', false ); // Do not use the theme files
    define( 'COOKIE_DOMAIN', false ); // Do not append verify the domain to the cookie
    define( 'DISABLE_WP_CRON', true ); // We don't want extra things running...

    //$_SERVER['HTTP_HOST'] = ""; // For multi-site ONLY. Provide the
                                  // URL/blog you want to auth to.

    // Path (absolute or relative) to where your WP core is running
    require("wp-load.php");
    $user = null;

    if ( is_user_logged_in() || $_GET['wp_api_key'] == 'TODO_REPLACE_THIS_WITH_YOUR_OWN_KEY' ) {
        $user = wp_get_current_user();
        if ($user->ID == 0 && $_GET['email'] != '') {
          $user = get_user_by( 'email', $_GET['email']);
        }

        if (!$user || $user->ID == 0) {
          $data = false;
        } else {
          $data = array(
            'id' => $user->ID,
            'roles' => array_values( $user->roles ),
            'email' => $user->user_email,
            'first_name' => get_user_meta( $user->ID, 'shipping_first_name', true ),
            'last_name' => get_user_meta( $user->ID, 'shipping_last_name', true ),
            'address_1' => get_user_meta( $user->ID, 'shipping_address_1', true ),
            'address_2' => get_user_meta( $user->ID, 'shipping_address_2', true ),
            'city' => get_user_meta( $user->ID, 'shipping_city', true ),
            'state' => get_user_meta( $user->ID, 'shipping_state', true ),
            'postcode' => get_user_meta( $user->ID, 'shipping_postcode', true )
          );
        }

      echo json_encode( $data);
    } else {
      echo json_encode( false );
    }

