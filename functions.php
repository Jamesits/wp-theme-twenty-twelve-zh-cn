<?php
/**
 * Twenty Twelve functions and definitions.
 *
 * Sets up the theme and provides some helper functions, which are used
 * in the theme as custom template tags. Others are attached to action and
 * filter hooks in WordPress to change core functionality.
 *
 * When using a child theme (see https://codex.wordpress.org/Theme_Development and
 * https://codex.wordpress.org/Child_Themes), you can override certain functions
 * (those wrapped in a function_exists() call) by defining them first in your child theme's
 * functions.php file. The child theme's functions.php file is included before the parent
 * theme's file, so the child theme functions would be used.
 *
 * Functions that are not pluggable (not wrapped in function_exists()) are instead attached
 * to a filter or action hook.
 *
 * For more information on hooks, actions, and filters, @link https://codex.wordpress.org/Plugin_API
 *
 * @since Twenty Twelve zh-CN 1.0
 */
 function theme_enqueue_styles()
 {
    wp_enqueue_style('parent-style', get_template_directory_uri().'/style.css');
    wp_enqueue_style('han',
        get_stylesheet_directory_uri().'/assets/han.min.css',
        array('parent-style')
    );
    wp_enqueue_script('pre-han-js', get_stylesheet_directory_uri().'/assets/pre-han.js');
    wp_enqueue_script('han-js', get_stylesheet_directory_uri().'/assets/han.min.js', array( 'pre-han-js' ), false, true);
    wp_enqueue_script('post-han-js', get_stylesheet_directory_uri().'/assets/post-han.js', array( 'han-js' ), false, true);
 }
 add_action('wp_enqueue_scripts', 'theme_enqueue_styles');
